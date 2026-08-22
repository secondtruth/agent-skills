# Go / Cobra Shapes

The concrete Go shapes for the rules in `SKILL.md`. Written for Cobra, the boring choice for Go CLIs; the shapes transfer to other command libraries, the reasoning always does. Copy the structure, not the names.

Go-specific vocabulary up front:

- **Call the application context `App`, not `Deps`.** `Deps` is accurate but implementation-shaped; `App` names the running application (names outlive their writers). In reusable console infrastructure it stays thin and generic: `app := console.NewApp()`.
- **Use `RunE`, never `Run`** — handlers return errors; `Execute()` renders and exits.
- **Silence Cobra's automatic output** on the root: `SilenceErrors: true, SilenceUsage: true`, then render centrally.
- **`text/tabwriter`** for tables and key/value blocks.

## 1. Growing Command Tree

The parent command reads as a table of contents; each visible subcommand has a named construction boundary.

```go
func NewFileCommand(app *App) *cobra.Command {
    cmd := &cobra.Command{
        Use:   "file",
        Short: "File operations",
    }

    cmd.AddCommand(NewFileListCommand(app))
    cmd.AddCommand(NewFileStatCommand(app))
    cmd.AddCommand(NewFileCatCommand(app))

    return cmd
}
```

Whether `NewFileListCommand` lives in `file.go` or `file_list.go` is a readability call, not a rule — split when a file resists scanning, keep members together when splitting would only produce boilerplate.

## 2. Leaf Command With Local Options

The option struct stays local to the constructor, so flags and handler are read together.

```go
func NewFileListCommand(app *App) *cobra.Command {
    var opts struct {
        long      bool
        recursive bool
        limit     int
    }

    cmd := &cobra.Command{
        Use:   "list [path]",
        Short: "List files",
        Args:  cobra.MaximumNArgs(1),
        RunE: func(cmd *cobra.Command, args []string) error {
            path := "."
            if len(args) == 1 {
                path = args[0]
            }

            files, err := app.Files().List(cmd.Context(), path, opts.recursive, opts.limit)
            if err != nil {
                return fmt.Errorf("listing %s: %w", path, err)
            }

            return output.PrintFiles(cmd.OutOrStdout(), files, opts.long)
        },
    }

    cmd.Flags().BoolVarP(&opts.long, "long", "l", false, "Show details")
    cmd.Flags().BoolVarP(&opts.recursive, "recursive", "r", false, "Recurse into directories")
    cmd.Flags().IntVar(&opts.limit, "limit", 0, "Maximum number of entries (0 = no limit)")

    return cmd
}
```

Note the handler: it returns errors, wraps them with context via `%w`, and writes through `cmd.OutOrStdout()` rather than `os.Stdout`, which is what makes the command testable.

## 3. Root Command and Central Execution

```go
func NewRootCommand(app *App) *cobra.Command {
    root := &cobra.Command{
        Use:           "acme",
        Short:         "…",
        SilenceErrors: true,  // we render errors ourselves
        SilenceUsage:  true,  // runtime errors must not print usage
    }

    root.AddCommand(NewFileCommand(app))
    root.AddCommand(NewProjectCommand(app))
    root.AddCommand(NewConfigCommand(app))

    return root
}

func Execute() {
    app := NewApp()

    if err := NewRootCommand(app).Execute(); err != nil {
        app.RenderError(err)
        os.Exit(exitCodeFor(err))
    }
}
```

`Execute` is the only place that terminates the process. Everything below it returns errors.

## 4. Typed Usage Error

Lets the boundary tell "you invoked this wrong" from "the operation failed", and print usage only for the former.

```go
type UsageError struct {
    Cmd *cobra.Command
    Err error
}

func (e *UsageError) Error() string { return e.Err.Error() }
func (e *UsageError) Unwrap() error { return e.Err }

func NewUsageError(cmd *cobra.Command, format string, args ...any) error {
    return &UsageError{Cmd: cmd, Err: fmt.Errorf(format, args...)}
}
```

At the boundary:

```go
func (a *App) RenderError(err error) {
    var usageErr *UsageError
    if errors.As(err, &usageErr) {
        fmt.Fprintf(a.ErrOut, "Error: %v\n\n", usageErr)
        _ = usageErr.Cmd.Usage()
        return
    }

    fmt.Fprintf(a.ErrOut, "Error: %v\n", err)
}

func exitCodeFor(err error) int {
    var usageErr *UsageError
    if errors.As(err, &usageErr) {
        return 2   // conventional: incorrect invocation
    }
    return 1
}
```

In a handler:

```go
if opts.limit < 0 {
    return NewUsageError(cmd, "--limit must not be negative")
}
```

## 5. App and Console Helper

The helper lives in the `console` package and is **command-scoped** — it needs the Cobra output streams, the command path, the context, and the formatting conventions. The app provides the broader output policy and shared services.

```go
// Reusable console layer: thin and generic.
app := console.NewApp()

// Command-scoped helper: needs the command's streams, path, context.
h := console.NewHelper(app, cmd)   // or: h := app.Helper(cmd)

h.Status("Uploading %s…", name)
h.Warn("skipping %s: unreadable", path)
```

The helper may own `Print`/`Printf`/`Println`, `Status`/`Statusf`, `Warn`, `Error`, and table/formatter construction. It must **not** own `Fatal`/`Fatalf` in the long-term style: new code returns errors and lets the execution boundary render them. Existing `Fatal` calls may remain during a migration, not after it.

## 6. Config Lifecycle Helpers

Load/save policy, path handling, defaults, and permissions stay in the config package.

```go
// Read-only work.
err := config.LoadAnd(func(cfg *config.Config) error {
    profile, ok := cfg.Profiles[name]
    if !ok {
        return fmt.Errorf("unknown profile %q", name)
    }
    return output.PrintProfile(cmd.OutOrStdout(), profile)
})

// Mutation; Save is handled centrally.
err := config.Update(func(cfg *config.Config) error {
    cfg.Profiles[name] = profile
    return nil
})
```

## 7. Rendering With tabwriter

Vertical key/value block — Title Case labels, preserved acronyms, masked secrets:

```go
func PrintProfile(out io.Writer, profile config.Profile) error {
    w := tabwriter.NewWriter(out, 0, 0, 2, ' ', 0)

    fmt.Fprintf(w, "Name:\t%s\n", profile.Name)
    fmt.Fprintf(w, "URL:\t%s\n", profile.URL)
    fmt.Fprintf(w, "User:\t%s\n", profile.User)
    fmt.Fprintf(w, "Token:\t%s\n", tokenLabel(profile.Token))

    return w.Flush()
}
```

Horizontal table — ALL CAPS headers:

```go
func PrintProfiles(out io.Writer, profiles []config.Profile) error {
    w := tabwriter.NewWriter(out, 0, 0, 2, ' ', 0)

    fmt.Fprintln(w, "NAME\tURL\tUSER")
    for _, p := range profiles {
        fmt.Fprintf(w, "%s\t%s\t%s\n", p.Name, p.URL, p.User)
    }

    return w.Flush()
}
```

Renderers take an `io.Writer` and a view model, never a client or a service (Output boundary in `SKILL.md`).

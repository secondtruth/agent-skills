# The Twelve Principles — Deep Dive

This file expands each principle from `SKILL.md` with the full reasoning, counter-examples, and fixes. Consult it when a rule needs interpretation, when you are teaching the reasoning, or when scaffolding something unfamiliar. For per-ecosystem filename tables and folder trees, see `naming-and-trees.md`; for the named-pattern catalogue, see `patterns.md`.

---

## 1. The Folder Tree Tells the Domain Story

**Rule.** A new contributor should be able to read only the top-level folder names and roughly guess what the application does. Folders are the chapter headings of the codebase. They should be nouns from the domain, not nouns from the technology.

**Why.** A technical taxonomy — `helpers/`, `misc/`, `utils/`, `services/`, `components/`, `pages/` — forces the reader to already know the codebase in order to navigate it. It tells them nothing about what the product is. A domain taxonomy — `features/invoices/`, `features/billing/`, `features/auth/`, `features/admin/` — teaches the domain as the reader navigates. A new contributor can open `features/invoices/` and immediately know: this is where invoice behaviour lives, this is the surface area, this is what I am looking for or not. Technical folders still exist (`lib/` for shared utilities, `components/ui/` for design-system primitives, `app/` or `pages/` for routing) but they are the *shared* layer, not the *primary* axis.

**Counter-example.**

```text
src/
  components/
  hooks/
  utils/
  services/
  pages/
  api/
  types/
  styles/
  context/
  __tests__/
```

Eleven folders, zero domain signal. The reader has to open every folder to learn what the application does.

**Fix.**

```text
src/
  app/                  # routing, layouts
  features/
    invoices/
    billing/
    auth/
    admin/
  components/ui/        # design-system primitives
  lib/                  # shared, domain-free utilities
  server/               # backend entry points
```

The reader learns the domain by reading folder names. The technical folders are still there but in supporting roles.

## 2. Co-locate What Changes Together

**Rule.** Files that change together live together. A feature's component, its API client, its types, its styles, and its unit tests sit in the same folder. The folder is named for the feature, not for the technical role.

**Why.** When a new requirement arrives — "add a discount field to invoices" — it touches the invoice component, the invoice API call, the invoice types, and the invoice tests. If those files are scattered across `components/`, `api/`, `types/`, and `__tests__/`, the diff spans four top-level directories, the reviewer has to jump around the codebase to follow the change, and a future move of the feature to a separate package becomes an archaeological dig. Co-locating them in `features/invoices/` makes the change atomic: one folder, one diff, one mental model. This is the co-location principle as encoded in the Next.js App Router, in Go's one-package-per-feature layout (`internal/invoices/` holding `invoice.go`, `service.go`, `repository.go`, `handler.go`, `invoice_test.go`), and in Symfony's `src/Service/InvoiceService.php` + `src/Controller/InvoiceController.php` + `src/Entity/Invoice.php` triad, or Laravel's `app/Services/` + `app/Http/Controllers/` + `app/Models/` equivalent (in PHP the framework's layer convention is the boring choice; see `naming-and-trees.md` §3.5 for when a feature-folder overlay makes sense). The alternative — strict technical taxonomy (all components together, all hooks together, all tests together) — is the beginner's instinct because it looks tidy. It is tidy the way a sorted bookshelf is tidy: easy to scan, hard to use.

**Counter-example (TypeScript).**

```text
src/
  components/InvoiceList.tsx
  components/InvoiceRow.tsx
  components/InvoiceEditor.tsx
  api/invoices.ts
  types/invoice.ts
  hooks/useInvoices.ts
  __tests__/InvoiceList.test.tsx
  styles/invoice.css
```

A single "add a `discount` field" change touches eight directories.

**Fix (TypeScript).**

```text
src/features/invoices/
  InvoiceList.tsx
  InvoiceRow.tsx
  InvoiceEditor.tsx
  invoice-api.ts
  invoice-types.ts
  use-invoices.ts
  InvoiceList.test.tsx
  invoice.css
```

One folder, one feature, one diff. Shared code that is genuinely cross-feature (design-system primitives, HTTP client, auth session) lives in `src/lib/` and `src/components/ui/` — not in the feature folder. The Go equivalent is one package per feature under `internal/`; the PHP equivalent depends on the framework (Symfony's and Laravel's layer conventions are idiomatic; a feature-folder overlay — `src/Invoicing/{Controller,Entity,Service}/` — is acceptable for large apps). See `naming-and-trees.md` §3.4 (Go service) and §3.5 (PHP) for concrete trees.

Two Go caveats. Import cycles are illegal, so domain types consumed by several feature packages move to their own small package (or the module root) instead of being duplicated or forced into one feature. And a small tool that fits comfortably in one `package main` should stay flat — feature packages are for services with several features, not a ceremony imposed on every binary.

## 3. One Concept Per Unit

**Rule.** Each unit of encapsulation holds exactly one concept — one component, one service, one domain type, one cohesive family of utilities. If you have to use the word "and" to describe what it contains, it is doing too much. The unit is the file in most languages; in Go it is the package (see the Go note below).

**Why.** The filesystem is the cheapest, fastest, most durable index a programmer has. When a reader opens `slugify.ts` (or `slugify.go`, or `slugify.php`), the filename is the first sentence of the documentation — it tells them what is inside before they read a line. A 600-line `utils.ts` (or `utils.go`, or the classic PHP `functions.php`) destroys that signal. The reader opens it expecting "utility" and finds dates, HTTP helpers, slugifiers, formatters, and three functions that nobody remembers the purpose of. They close it and grep instead, which is slower, noisier, and lossy. One concept per file keeps the filesystem as a usable index forever. The shape this takes differs by language — TypeScript splits a `utils.ts` into `slugify.ts`, `format-date.ts`, `http-client.ts`; PHP splits `functions.php` into concept files and lets PSR-4 autoload them (for classes, PSR-1/PSR-4 make one class per file mandatory — the filename must match the class name exactly, so the principle is enforced by the autoloader); Go applies the principle one level up, at the package.

**Go note.** Go's unit of encapsulation is the package, not the file — all files in a directory share one namespace, and the import path is what readers see. So the rule lands differently: each *package* holds exactly one capability, named for what it provides (`package slug`, `package httpserver`). A grab-bag `util`, `common`, or `helpers` package is the exact `utils.ts` smell, and Go style guides reject those names explicitly. Within a package, each file groups one cohesive aspect (`parse.go`, `render.go`, `client.go`) — the standard library works this way (`strings` has `builder.go`, `replace.go`, `search.go`). Do not create one micro-file per tiny function; that fragments what the package already unifies. And before extracting a helper package at all, remember principle 9: a helper with one caller belongs next to that caller.

**Counter-example (TypeScript).**

```ts
// src/utils.ts — 612 lines
export function formatDate(d: Date) { /* ... */ }
export function slugify(s: string) { /* ... */ }
export async function get(url: string) { /* ... */ }
export function parseCsv(text: string) { /* ... */ }
export function currency(n: number) { /* ... */ }
export class EventBus { /* ... */ }
// ... 47 more exports
```

**Fix (TypeScript).**

```text
src/lib/
  format-date.ts
  slugify.ts
  http-client.ts
  parse-csv.ts
  currency.ts
  event-bus.ts
```

Each file is small, named for its concept, and findable by `ls` alone. In Go the equivalent move is one well-named package per capability — `internal/text/` (`slug.go`, `truncate.go`), `internal/httpx/` (`client.go`, `retry.go`) — never a `utils` package; in PHP it is `src/{FormatDate.php, Slugify.php, HttpClient.php, ...}` if the helpers are classes, or `src/functions/{format_date.php, slugify.php, http_client.php}` if they are namespaced functions. See `naming-and-trees.md` for per-ecosystem filename conventions and full folder trees.

**How small is too small.** Files are readability tools, not doctrine. The rule bites when a file holds unrelated concepts; it does not demand one file per symbol. A pile of three-line files is its own failure mode — the reader now pays a `ls` and an open for every hop, and the boilerplate outweighs the content. Judge by scanability, not by count.

Split a group into more files when:

- the file is hard to scan even after the internal structure is clean
- one member has substantial options, validation, helpers, or tests of its own
- a member has a distinct ownership boundary
- several people are likely to touch different members at the same time

Keep the members in one file when:

- they are small leaves with little logic
- splitting would produce mostly boilerplate
- the domain is easier to understand as a single local unit
- the file already opens with something that reads as a table of contents (principle 5)

## 4. Members Stay With Their Group

**Rule.** Inside a file, the members of a group — a class, a struct, an enum — form one contiguous block, in a stable order, with nothing unrelated interleaved. A type's declaration, its constructor(s), its methods, and the constants and errors that belong to it sit together.

**Why.** This is principle 2 one zoom level down, and the reasoning is identical: the unit of change is the unit of reading. When a field is added to a type, its constructor, its accessors, and its validation change together — if they sit together, the diff is one screen instead of six hops. A reader who finds `Invoice` should find `NewInvoice`, `Invoice.Total()`, and `ErrInvoiceNotFound` without scrolling past unrelated code. Scattered members also rot differently: a method that lives far from its type gets forgotten during a refactor, and dead members survive for years because nobody sees them next to the thing they belong to.

The rule is about grouping; principle 5 orders the groups (public before private, entry point before helpers). Together they make a file scannable: the reader finds the right block, then the right member within it.

**Ordering within the block.**

- Fields stay with fields, not interleaved with methods.
- Methods group by responsibility, not alphabetically. Alphabetical ordering optimizes for a search problem the editor already solved.
- Related declarations travel as pairs: an enum with its `switch`/`match` helpers, a type with its validation schema, a constant block with the type it describes.

**Counter-example (Go).**

```go
type Invoice struct { /* ... */ }

type Customer struct { /* ... */ }

func (i *Invoice) Total() Money { /* ... */ }

var ErrCustomerNotFound = errors.New("customer not found")

func NewInvoice(c Customer) *Invoice { /* ... */ }

func (c *Customer) DisplayName() string { /* ... */ }

var ErrInvoiceNotFound = errors.New("invoice not found")
```

Two types shredded into alternating slices. Adding a field to `Invoice` means touching lines scattered across the whole file.

**Fix (Go).**

```go
var ErrInvoiceNotFound = errors.New("invoice not found")

type Invoice struct { /* ... */ }

func NewInvoice(c Customer) *Invoice { /* ... */ }

func (i *Invoice) Total() Money { /* ... */ }

// --- Customer ---

var ErrCustomerNotFound = errors.New("customer not found")

type Customer struct { /* ... */ }

func (c *Customer) DisplayName() string { /* ... */ }
```

Each type owns a contiguous block: its errors, its declaration, its constructor, its methods.

**Language shapes.**

- **Go**: keep a type's methods in the same file as the type. Go permits scattering methods across files in the package — treat that permission as a trap. A genuinely large type may split by *aspect* (`server.go`, `server_tls.go`), which is a deliberate, named split, not scatter. Declare interfaces where they are *consumed*, next to the consumer — the Go idiom — rather than preemptively beside the implementation.
- **TypeScript/React**: a component's props type, the component, and its private subcomponents share the file; a hook used by exactly one component stays in that component's file until a second consumer arrives (principle 9).
- **PHP**: PSR-12 already fixes the macro order — constants, then properties, then methods; group the methods by responsibility within that frame.
- **Rust**: an `impl` block is the grouping mechanism the language gives you. Keep one `impl` per concern next to the type; do not scatter `impl` blocks for the same type across the file.

## 5. The Public Surface Goes on Top

**Rule.** Within a file, lead with the public surface — the exports, the types, the main function — and push implementation details below it in dependency order. The reader meets the headline first and the body text second.

**Why.** This is the newspaper metaphor from *Clean Code*, applied at the file level. A reader scanning `parseInvoiceCsv.ts` wants to know, in the first thirty lines: what does this module export, what types does it use, what is the entry point. If they have to scroll past three private helper functions to find the exported function, the file is upside down. The same principle applies to folders: a folder's `index.ts` should be a curated table of contents — the public surface of the module — not a firehose that re-exports every internal. Restricting the `index.ts` to the intended public API keeps the module's contract explicit and gives the maintainer freedom to refactor internals without breaking callers.

**Counter-example.**

```ts
// invoice.ts
function parseLine(line: string) { /* ... */ }
function validateHeader(rows: string[][]) { /* ... */ }
function normaliseAmount(raw: string) { /* ... */ }
function buildInvoice(rows: string[][]) { /* ... */ }

export function parseInvoiceCsv(text: string): Invoice {
  // ... uses all of the above
}
```

**Fix.**

```ts
// invoice.ts
export type Invoice = { /* ... */ };

export function parseInvoiceCsv(text: string): Invoice {
  const rows = splitRows(text);
  validateHeader(rows);
  return buildInvoice(rows);
}

// --- implementation details below ---

function splitRows(text: string) { /* ... */ }
function validateHeader(rows: string[][]) { /* ... */ }
function buildInvoice(rows: string[][]) { /* ... */ }
```

The exported function and its types are at the top. A reader who only wants the contract can stop reading after line 8. The helpers follow in the order they are called.

**Barrel files are the folder-level failure of this rule.** An `index.ts` that re-exports every internal symbol is the opposite of a curated surface: it hides the real source location, forces every importer to pull the whole barrel (defeating tree-shaking), and silently promotes internals to public API whether you intended it or not. TkDodo's "Please Stop Using Barrel Files" remains the canonical warning. Use a barrel only at an intentional public boundary — a package's entry point, where the barrel *is* the contract — never as a lazy way to shorten import paths inside an app. Go and PHP do not have this problem in the same form: Go decides its public surface by capitalisation, and PSR-4 ties each file to one class, so there is nothing for a barrel to do.

## 6. Whitespace Is a Section Break

**Rule.** Use blank lines to separate ideas, not as decoration. One blank line between functions, one blank line between logical sections within a long function, two blank lines between top-level sections of a file (exports vs. implementation). Never two blank lines in a row inside a function. Never zero blank lines in a fifty-line function.

**Why.** Vertical rhythm is invisible glue. When sections breathe at the same intervals, the eye flows predictably down the file and the reader's brain groups statements into paragraphs without conscious effort. When the rhythm is broken — random double blanks mid-block, or a hundred lines without a single blank line — the eye stutters and the reader loses their place. This is the same principle Todd Wolfson described for typography, applied to source. Whitespace is also a signal of intent: a blank line says "new thought", the way a paragraph break in prose does. Use it deliberately.

Indentation is non-negotiable in the same way: pick tabs or spaces once, configure the formatter once, and never argue about it again. The formatter is a tool; let it do its job. Vertical alignment of related tokens (e.g. aligning the `=` in a block of assignments) is permissible when it aids scanning, but never required — and never fight the formatter to keep it.

**Counter-example.**

```ts
function processInvoice(invoice) {
  const lines = invoice.lines;
  const total = lines.reduce((s, l) => s + l.amount, 0);
  const tax = total * 0.19;
  const net = total + tax;
  if (net > 1000) {
    const approval = requestApproval(invoice);
    if (!approval) {
      throw new Error('needs approval');
    }
  }
  return { ...invoice, total, tax, net };
}
```

Twelve lines, no breathing room, the eye cannot find the section breaks.

**Fix.**

```ts
function processInvoice(invoice: Invoice): ProcessedInvoice {
  const total = invoice.lines.reduce((sum, line) => sum + line.amount, 0);
  const tax = total * TAX_RATE;
  const net = total + tax;

  ensureApprovalIfRequired(invoice, net);

  return { ...invoice, total, tax, net };
}

function ensureApprovalIfRequired(invoice: Invoice, net: number) {
  if (net <= APPROVAL_THRESHOLD) return;

  const approval = requestApproval(invoice);
  if (!approval) {
    throw new ApprovalRequiredError(invoice.id);
  }
}
```

Two short functions, each with a clear single responsibility, separated by a blank line, each with internal whitespace marking the logical sections. The eye finds the breaks instantly.

## 7. Comments Are Paragraphs, Not Apologies

**Rule.** A comment explains *why* the code is the way it is — the constraint, the trade-off, the bug that was fixed, the upstream limitation. A comment almost never explains *what* the code does; if the code needs a "what" comment, the code is too clever or the names are too vague. Fix the code first.

**Why.** The code already tells the reader what happens — that is what code is for. What the code cannot tell the reader is the history that produced it: that this retry loop exists because the upstream gateway rate-limits bursty clients (INC-1234); that this apparently-redundant null check exists because a downstream serializer crashes on `undefined`; that this magic number is the rate limit published in the vendor's docs on 2024-03-14. Comments carry the institutional memory that the code alone cannot. They are paragraphs in the letter to the next programmer — write them when the *why* is non-obvious, omit them when it is.

When you find yourself writing a comment that explains *what* a block does, stop. Extract the block into a function whose name says what the comment said. The function name is now reusable documentation at every call site, and the comment was localized documentation at one. This is the Extract Method pattern, and it is the single most underused refactoring in the craft.

**Counter-example.**

```ts
// increment i by 1
i++;

// loop over users
for (const u of users) {
  // check if active
  if (u.active) {
    // send email
    await mail(u.email);
  }
}
```

Every comment here is a confession that the code is not self-describing.

**Fix.**

```ts
i++;

for (const user of activeUsers(users)) {
  await sendWelcomeEmail(user);
}
```

No comments. The names do the work. (And note: the *historical* comment is still allowed — `// 429 retries because the gateway burst-limits (INC-1234)` belongs at the top of the retry loop, because no amount of renaming will surface that fact.)

## 8. Names Outlive Their Writers

**Rule.** Name things for the reader who arrives cold, not for the writer who already understands. The reader does not have your context. The name must carry enough meaning that the call site reads as a sentence.

**Why.** A vague name forces every future reader to open the implementation to understand the call site. That is a tax compounded across every commit, every review, every debugging session, for the lifetime of the code. A precise name pays that tax once, at the moment of writing, when the writer actually has the context. Bob Martin's heuristic in *Clean Code* still holds: if you need a comment to explain what a name means, the name is wrong. But do not chase length for its own sake — the goal is *intent-revealing*, not *encyclopedic*. `parseInvoiceCsv` is better than `parse` and better than `parseTheInvoiceCsvFileThatComesFromTheAccountingSystem`. Three or four words is usually enough.

There is also a typographic dimension. Names carry structural hints in their suffix: plural for arrays (`invoiceLines`), `ById` or `ByX` for maps (`usersById`), `is`/`has`/`should` for booleans (`isVerified`), `Row`/`Card`/`Modal` for component variants, `Schema` for validation schemas. These hints let the reader infer the shape from the name without jumping to the definition.

**The sentence includes the receiver.** "Reads as a sentence" is about the whole call site, not the identifier alone. In procedural code the function name carries the sentence: `parseInvoiceCsv(text)`. In object-oriented code the receiver already carries half of it, so repeating the type in the member name stutters:

```text
invoice.invoiceTotal()          → invoice.total()
csvParser.parseCsv(text)        → csvParser.parse(text)
InvoiceRepository.findInvoiceById(id) → invoiceRepository.find(id)
user.getUserEmail()             → user.email()  (or the property itself)
```

Read the call site aloud and remove every word the receiver already said. The same applies to Go's package qualifier — `slug.SlugifyString(s)` reads as stutter at the call site, `slug.From(s)` reads as a sentence — and Go's style guides call this out explicitly. The heuristic generalizes: **a name is judged in context, never in isolation.** A method named `total()` is precise inside `Invoice` and meaningless as a free function; a free function named `parseInvoiceCsv` is precise standing alone and redundant as `InvoiceCsvParser.parseInvoiceCsv()`.

Two OOP-specific consequences. Methods are verbs against the receiver's state (`invoice.markPaid()`), so a method whose name needs an explicit object argument to make sense (`invoice.markPaid(invoice)`) is usually a free function in disguise. And boolean members keep the `is`/`has` prefix even as methods (`invoice.isOverdue()`), because it is the prefix, not the receiver, that reveals the return type.

**Filenames are names too.** Apply language-idiomatic casing to filenames, and make the filename match the primary export, the primary content, or (in PSR-4 languages) the class name exactly. Use the ecosystem's role suffixes where they exist. A glance at the file tree should reveal each file's role: inconsistent casing (`Utils.js`, `helpers.ts`, `data-handling.ts` next to `InvoiceList.tsx`) forces the reader to open each file to learn what it is, while consistent casing plus role suffixes turn the tree into a readable catalogue.

The full per-ecosystem filename table — TypeScript/React, Python, Go (including `internal/`, `cmd/`, `doc.go`), PHP (including PSR-4 mapping, Symfony and Laravel specifics, migration naming), and Rust — lives in `naming-and-trees.md` §2. The short version: TypeScript uses `kebab-case.ts` for non-components and `PascalCase.tsx` for components; Go uses `lowercase.go` with one package per directory; PHP uses `PascalCase.php` matching the class name exactly (PSR-4 requirement); Python uses `snake_case.py`; Rust uses `snake_case.rs`.

**Counter-example (filenames, TypeScript).**

```text
src/
  Utils.js
  helpers.ts
  data-handling.ts
  invoice.ts
  InvoiceList.tsx
```

**Fix.**

```text
src/
  lib/
    slugify.ts
    format-date.ts
    http-client.ts
  features/invoices/
    invoice-types.ts
    invoice-api.ts
    InvoiceList.tsx
    InvoiceList.test.tsx
```

Every filename announces its role at a glance. The Go equivalent: well-named capability packages like `internal/text/{slug.go, truncate.go}` (lowercase files, no `utils` package, per principle 3); the PHP equivalent: `src/{Slugify.php, FormatDate.php, HttpClient.php}` (PascalCase matching class names, PSR-4 autoloaded).

**Naming pairs.** The full before/after tables — variables, functions, files — live in `naming-and-trees.md` §1. Use them as a review checklist: if a name you introduced appears in the left column, change it.

## 9. Fewer Concepts, Deeper Concepts

**Rule.** When in doubt, choose the design with fewer moving parts. A direct function call beats a plugin system. A switch statement beats a registry of strategies. A type union beats an inheritance hierarchy. Refactor toward abstraction only when a second concrete use case actually arrives — not when one is imagined.

**Why.** This is the core of Calm Engineering and the YAGNI principle from XP. Every abstraction is a concept the next reader must learn before they can read the code, and a constraint they must respect before they can change it. The cost is paid by every future reader, every time, forever. The benefit is paid once, at the moment of writing, in the form of feeling clever. That trade is almost never worth it. The right time to introduce an abstraction is when you find yourself writing the third copy of something — at that point the abstraction is obvious, the cost is justified, and the shape is constrained by real use. Before that, the abstraction is a guess, and guesses about future flexibility are reliably wrong.

The corollary is harder: a healthy pull request removes more lines than it adds. If you never delete code, you are accumulating it. Every feature that ships and stays adds a permanent tax. Every abstraction that survives without earning its keep is a load-bearing mistake. Delete more than you add.

**Counter-example.**

```ts
// A generic plugin system for what is currently one need
interface InvoiceProcessor {
  type: string;
  process(invoice: Invoice): Promise<Invoice>;
}
class InvoiceProcessorRegistry {
  private processors = new Map<string, InvoiceProcessor>();
  register(p: InvoiceProcessor) { this.processors.set(p.type, p); }
  async run(type: string, invoice: Invoice) {
    const p = this.processors.get(type);
    if (!p) throw new Error(`no processor for ${type}`);
    return p.process(invoice);
  }
}
// ... to plug in a single VAT calculator
```

**Fix.**

```ts
function applyVat(invoice: Invoice): Promise<Invoice> {
  // 8 lines, called from one place
}
```

When the second processor actually arrives, *then* extract the abstraction. The shape will be clearer because you will have two examples to derive it from.

## 10. Make the Boring Choice

**Rule.** For 90% of decisions, pick the conventional option — the one a senior engineer in the language's ecosystem would expect without asking. Use the framework's built-in state management until you have a measured reason to use something else. Use the language's standard error model until you hit a wall. Use the community's lint config, the community's folder layout, the community's naming conventions.

**Why.** Convention is compressed documentation. Every reader who knows the ecosystem can read conventional code for free, without a learning curve. Divergence is a tax on every future reader, paid in cognitive load, and the tax compounds with every line of divergence. Pay it only when the convention genuinely cannot serve the need — and when you do, document the divergence at the boundary so the reader knows it is deliberate.

This principle is the complement of principle 9. Fewer concepts means fewer abstractions in your own code. Boring choices means fewer abstractions borrowed from outside. Together they make the codebase smaller and more predictable. The remaining 10% — the places where you genuinely must invent — is where your craft shows. Spend your creativity there, not on reinventing state management.

**Counter-example (TypeScript).** A bespoke event-bus implementation in a React app, because "Redux is too heavy". Three months later: nobody remembers how the event bus works, two bugs trace to event ordering, and the team is considering a rewrite to use Zustand.

**Fix (TypeScript).** Use Zustand (or Redux Toolkit, or Jotai) — the boring choice — until you have evidence it does not fit.

**Counter-example (Go).** A bespoke error type wrapping `error` with custom `Code()` / `Cause()` methods, because "the standard `errors.Is` / `errors.As` are too limited". Six months later: callers cannot use `errors.Is` properly, three bugs trace to error comparison, and the team is rewriting to use `fmt.Errorf("%w", err)` like the rest of the ecosystem.

**Fix (Go).** Use the standard `errors` package and `fmt.Errorf` with `%w` — the boring choice — until you have evidence it does not fit. The same logic applies to Go's `net/http` router (use `http.ServeMux` or chi/gin if your team has chosen one — do not invent a fourth), to Go's `context` package for cancellation (never invent a parallel cancellation mechanism), and to Go's `log/slog` for structured logging (the boring choice since Go 1.21).

**Counter-example (PHP).** A hand-rolled service container in a Symfony app, because "autowiring is too magic". A year later: nobody remembers which services are registered where, two bugs trace to resolution order, and the team is rewriting to use the framework container like the rest of the ecosystem.

**Fix (PHP).** Use the framework's container — Symfony's autowiring + autoconfiguration, or Laravel's service container — until you have evidence it does not fit. The same logic applies across the Symfony stack: use Doctrine repositories as the persistence boundary rather than wrapping them in a second hand-written repository layer; use the Validator and Serializer components with attributes instead of bespoke validation and array-mapping code; use voters for authorization instead of scattered permission checks; use Twig rather than a custom template layer. The Laravel equivalents are Eloquent (do not hide it behind a parallel repository layer), Form Requests for validation, and Blade for templates — and in either framework, do not introduce the *other* one's tooling without a measured reason.

The boring choice has docs, Stack Overflow answers, and a migration path. The bespoke choice has you.

## 11. Tests Live With the Code They Test

**Rule.** A unit test sits next to the file it tests, named with the suffix the ecosystem expects, matching the source file's basename. `InvoiceList.tsx` is tested by `InvoiceList.test.tsx`; `invoice.go` is tested by `invoice_test.go` (Go *requires* this); `Invoice.php` is tested by `InvoiceTest.php` (PHPUnit convention, co-located in modern setups or under `tests/Unit/` per framework convention). Integration and end-to-end tests may live apart, but unit tests belong with their unit.

**Why.** The test is part of the module's contract. Co-located tests move when the module moves, get deleted when the module is deleted, and remind the writer at the moment of writing that tests are not optional. The alternative — a top-level `test/` folder that mirrors the entire `src/` tree — is a beginner's instinct that looks tidy and ages terribly: the mirror drifts, files move on one side but not the other, and finding the test for a given source file becomes a chore. Co-location makes the relationship literal in the filesystem. Three ecosystem notes: (1) Go enforces co-location at the toolchain level — `*_test.go` must be in the same directory as the source, or `go test` will not find them; (2) Rust prefers inline `#[cfg(test)] mod tests` blocks in the same file, which is the language-level co-location; (3) PHP frameworks conventionally use a `tests/` directory instead — Symfony mirrors `src/` under `App\Tests\`, Laravel splits into `Feature/` and `Unit/` — a framework override of the general principle, accepted because the testing tooling expects it.

**Counter-example (TypeScript).**

```text
src/components/InvoiceList.tsx
src/components/InvoiceEditor.tsx
src/hooks/useInvoices.ts
test/components/InvoiceList.test.tsx
test/components/InvoiceEditor.test.tsx
test/hooks/useInvoices.test.ts
```

**Fix (TypeScript).**

```text
src/features/invoices/
  InvoiceList.tsx
  InvoiceList.test.tsx
  InvoiceEditor.tsx
  InvoiceEditor.test.tsx
  use-invoices.ts
  use-invoices.test.ts
```

The test is one `ls` away from the code it tests. The Go equivalent — `invoice.go` next to `invoice_test.go` in the same package directory — is not a stylistic choice but a toolchain requirement; the PHP equivalent depends on the framework (Symfony: `tests/Service/InvoiceServiceTest.php` mirroring `src/Service/InvoiceService.php` under the `App\Tests\` namespace; Laravel: `tests/Unit/InvoiceServiceTest.php` — both accepted as framework conventions).

## 12. Leave the Campsite Cleaner

**Rule.** Every commit should leave at least one nearby file slightly better than you found it — a renamed variable, a tightened comment, a co-located test, a small extraction. Do not pair the cleanup with a behaviour change in the same diff; keep cleanups as separate commits within the same pull request so reviewers can follow.

**Why.** Codebases decay or improve one commit at a time; there is no equilibrium. A team that never refactors in the small accumulates entropy until a rewrite feels like the only option. A team that cleans up as it goes maintains a codebase that gets easier to work in over time, not harder. This is the Boy Scout Rule as popularised by Uncle Bob, derived from the original scout maxim. The discipline is to do it *in the small*: not "I'll rewrite this module next quarter", but "while I am here adding a field, I will rename this confusing variable two lines up". The cleanup costs almost nothing in the moment and pays compound interest across years. The constraint — separate commit from the behaviour change — is what makes the rule survive code review. A reviewer can glance at the cleanup commit, see it is purely structural, and approve in seconds. Bundled into a behaviour change, the same cleanup is invisible, unreviewable, and silently risky.

**Counter-example.** A pull request titled "Add discount field to invoices" that also renames three unrelated functions, splits a util file, and updates the lint config — all in one diff. The reviewer cannot tell which changes are load-bearing and which are drive-by. They either rubber-stamp it or block the whole PR.

**Fix.** Three commits in one PR:

1. `refactor(invoices): rename confusing variables in invoice parser` — pure cleanup, no behaviour change, trivially reviewable.
2. `feat(invoices): add discount field to invoice model` — the actual change, small and focused.
3. `chore: update eslint config to forbid barrel re-exports` — unrelated, belongs in its own PR if it is more than a one-liner.


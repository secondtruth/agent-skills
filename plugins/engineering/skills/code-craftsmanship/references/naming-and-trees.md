# Naming Pairs and Folder Trees

This file is the concrete reference for the third lens in `SKILL.md`: naming, plus the folder structures it names. It expands Principle 1 (The Folder Tree Tells the Domain Story) and Principle 8 (Names Outlive Their Writers, which also covers filenames) with ready-to-use tables and ASCII trees.

## Table of Contents

1. [Naming Pairs — Before / After](#1-naming-pairs--before--after)
2. [Filename Conventions per Ecosystem](#2-filename-conventions-per-ecosystem)
   - [2.1 TypeScript / JavaScript / React](#21-typescript--javascript--react)
   - [2.2 Python](#22-python)
   - [2.3 Go](#23-go)
   - [2.4 PHP](#24-php)
   - [2.5 Rust](#25-rust)
3. [Folder Trees — Good vs Questionable](#3-folder-trees--good-vs-questionable)
   - [3.1 Next.js Application](#31-nextjs-application)
   - [3.2 Full-Stack Monorepo](#32-full-stack-monorepo)
   - [3.3 TypeScript Backend Service](#33-typescript-backend-service)
   - [3.4 Go Service](#34-go-service)
   - [3.5 PHP Application (Symfony, Laravel)](#35-php-application-symfony-laravel)

---

## 1. Naming Pairs — Before / After

Each row shows a vague name, an intent-revealing replacement, and a one-line rationale. Use this as a checklist when reviewing your own diff: if any new name you introduced appears in the left column, change it.

### Variables

| Vague | Intent-revealing | Why |
|---|---|---|
| `data` | `invoicePayload` | "data" tells you nothing; the second names the domain and role |
| `info` | `userSummary` | "info" is filler; "summary" implies a projection |
| `temp` | `unsortedBatch` | "temp" says it is temporary; the second says what it is |
| `result` | `validatedInvoice` | "result" describes the role; the second describes the value |
| `items` | `cartLines` | "items" is generic; "cartLines" names the domain |
| `flag` | `isVerified` | "flag" hides the type; the second reveals it |
| `value` | `lineTotal` | "value" is filler; the second names the concept |
| `obj` | `parsedConfig` | "obj" admits you did not name it |
| `array` | `pendingAlerts` | "array" describes the type, not the contents |
| `map` | `usersById` | "map" describes the structure; the second describes the key |
| `str` | `rawCsv` | "str" describes the type; the second describes the contents |
| `num` | `taxRate` | same |
| `cb` | `onInvoiceSubmit` | "cb" is an abbreviation; the second is a sentence |
| `ret` | `processedInvoice` | "ret" is filler |
| `thing` | `auditEvent` | "thing" is an admission of defeat |
| `x`, `y`, `z` | `columnIndex`, `rowIndex`, `depth` | single letters are reserved for tight loops over well-known indices |

### Functions

| Vague | Intent-revealing | Why |
|---|---|---|
| `process(x)` | `parseInvoiceCsv(x)` | "process" is a verb without object |
| `handle(x)` | `onInvoiceSubmit(x)` | "handle" is generic |
| `doStuff()` | `sendWelcomeEmail(user)` | "stuff" is an admission |
| `manage(x)` | `retryWithBackoff(x)` | "manage" is the classic meaningless verb |
| `util(x)` | `slugify(x)` | the function becomes its own index entry |
| `check(x)` | `isInvoiceValid(x)` | "check" hides the return shape; "is" reveals it |
| `get(x)` | `fetchCurrentUser()` | "get" is ambiguous about source (memory? server? cache?) |
| `set(x)` | `markInvoicePaid(invoiceId)` | "set" hides the domain effect |
| `update(x)` | `applyVat(invoice)` | "update" is a database word; the second is a domain word |
| `run()` | `importInvoicesFromCsv(path)` | "run" describes nothing |

### Types and Classes

| Vague | Intent-revealing | Why |
|---|---|---|
| `Manager` | `SessionStore` | "Manager" is the classic meaningless noun |
| `Helper` | `CsvParser` | name the responsibility |
| `Util` | `Slugifier` | name the responsibility |
| `Base` | `Invoice` (and use composition, not inheritance) | "Base" reveals the taxonomy, not the domain |
| `Object` | `InvoicePayload` | "Object" is the type, not the concept |
| `Data` | `Invoice` | "Data" is filler |
| `Info` | `UserSummary` | "Info" is filler |
| `Thing` | `AuditEvent` | name the domain concept |
| `Item` | `CartLine` | name the domain concept |
| `Record` | `InvoiceRow` | name the domain concept |
| `Deps` | `App` | "Deps" names the implementation shape; "App" names the thing it *is* — the running application context |
| `Context` (your own) | `RequestScope` | do not shadow a language/framework concept with a different meaning |

### Files

| Vague | Intent-revealing | Why |
|---|---|---|
| `utils.ts` | `slugify.ts` | one concept per file |
| `helpers.ts` | `format-date.ts` | one concept per file |
| `misc.ts` | (delete the file; distribute its contents to concept files) | "misc" is a junk drawer |
| `common.ts` | `http-client.ts` | "common" tells you nothing |
| `data.ts` | `invoice-types.ts` | name the domain |
| `index.ts` (as barrel) | (delete; import from the source file directly) | barrels hide the real source |
| `App.tsx` (1000 lines) | split into `AppShell.tsx`, `AppRoutes.tsx`, `AppProviders.tsx` | one concept per file |
| `package util` (Go) | `package slug`, `package httpx` — one capability per package | in Go the unit is the package; `util`/`common` are rejected by Go style guides |
| `helpers.go` (inside a package) | `parse.go`, `render.go` — one aspect per file | group by aspect, not one micro-file per function |
| `util.php` | `slugify.php` | one concept per file (PHP) |
| `functions.php` (PHP, 2000 lines) | split into `slugify.php`, `format-date.php`, `invoice-helpers.php` | "functions.php" is the classic PHP junk drawer |
| `inc/` (PHP) | `src/` or `app/` | "inc" tells you nothing |

---

## 2. Filename Conventions per Ecosystem

Apply language-idiomatic casing to filenames. Make the filename match the default export or primary content. Use suffix conventions for role. The conventions below are the boring choices (Principle 10 in `SKILL.md`) — follow them unless your ecosystem's framework has a stronger convention.

### 2.1 TypeScript / JavaScript / React

| File role | Convention | Example |
|---|---|---|
| Component file | `PascalCase.tsx` | `InvoiceList.tsx`, `InvoiceRow.tsx` |
| Non-component source | `kebab-case.ts` | `slugify.ts`, `format-date.ts`, `invoice-api.ts` |
| Test file | `*.test.ts` / `*.test.tsx` (co-located) | `InvoiceList.test.tsx` |
| Types file | `*.types.ts` | `invoice-types.ts` |
| Constants file | `*.constants.ts` | `tax-rates.constants.ts` |
| Schema file | `*.schema.ts` | `invoice.schema.ts` |
| Config file | `*.config.ts` | `eslint.config.ts` |
| Hook file | `use-*.ts` (kebab-case) | `use-invoices.ts` |
| Route/page file | framework convention | `page.tsx`, `layout.tsx`, `route.ts` (Next.js) |
| Barrel (only at public boundary) | `index.ts` | `packages/ui-kit/src/index.ts` |

### 2.2 Python

| File role | Convention | Example |
|---|---|---|
| Module | `snake_case.py` | `slugify.py`, `format_date.py` |
| Test file | `test_*.py` (co-located or in `tests/` per project convention) | `test_invoice.py` |
| Types file | `*_types.py` | `invoice_types.py` |
| Constants file | `*_constants.py` or `settings.py` | `tax_rates.py` |
| Schema file | `*_schema.py` | `invoice_schema.py` |
| Config file | `config.py` or `settings.py` | `settings.py` |

Note: Python projects often use a top-level `tests/` folder rather than co-located tests. This is a community convention and acceptable — but if your project is small and the team prefers co-location, `test_invoice.py` next to `invoice.py` is fine and arguably better (see Principle 11 in `SKILL.md`).

### 2.3 Go

Go has the strongest folder-vs-package coupling of any language here: **one directory = one package**, and the package name should match the directory name. This makes the filesystem itself the public-API surface — exporting is decided by capitalisation (`Invoice` is exported, `invoice` is not), not by separate `index.ts`-style files. Most of the principles in `SKILL.md` translate directly; the table below maps the conventions.

| File role | Convention | Example |
|---|---|---|
| Source file | `lowercase.go` — multi-word names use `snake_case.go` only when idiomatic (e.g. `format_date.go`); single-word is preferred (`slugify.go`) | `slugify.go`, `invoice.go` |
| Test file | `*_test.go` — **always co-located with source** (Go tooling requires it) | `invoice_test.go` |
| Types file | in-package; types live next to the functions that use them; a `types.go` is acceptable when a package has many exported types with no behaviour | `invoice.go`, `types.go` |
| Constants file | `constants.go` or in-package; exported constants group by domain | `tax_rates.go` |
| Package boundary | **one package per directory**; package name matches directory name and is `lowercase`, short, no underscores | directory `invoices/` → `package invoices` |
| Public API surface | capitalisation, not a barrel file — `Invoice` is public, `invoice` is not | `func NewInvoice() Invoice` |
| Internal packages | `internal/` directory — Go compiler enforces that only the parent module can import | `internal/invoicesrepo/` |
| Command entry point | `cmd/<binary-name>/main.go` — one main per binary | `cmd/api/main.go` |
| Package documentation | `doc.go` — a file containing only a package comment, for non-trivial packages | `doc.go` |

Notes specific to Go:

- Go has **no class inheritance** and no generics-only hierarchies, so the "Manager / Base / Helper" naming anti-patterns are rarer but still appear as interfaces named `Manager` or `Helper`. Name interfaces by behaviour (`Reader`, `InvoiceStore`), not by role.
- Go's `internal/` convention is the language-level enforcement of the Single Public Surface pattern (see `patterns.md`). Use it aggressively: anything that should not be imported from outside the module goes in `internal/`.
- Avoid the `pkg/` directory pattern that was popular circa 2015–2018. The modern convention is `internal/` for private code and direct imports for public code. `pkg/` is a junk drawer in waiting.
- Test files in Go are *required* to be co-located (`*_test.go` in the same directory as the source). This is not a stylistic choice — the `go` tool will not find them otherwise. The principle "Tests Live With the Code They Test" is enforced by the language.

### 2.4 PHP

PHP has two strong sub-conventions depending on whether the project follows PSR-4 autoloading (modern, framework-agnostic) or a framework's own conventions (Symfony, Laravel). The table below gives the PSR-4 baseline; framework addenda follow.

| File role | Convention | Example |
|---|---|---|
| Class file | `PascalCase.php` — filename matches the class name exactly (PSR-4 requirement) | `InvoiceList.php`, `InvoiceRepository.php` |
| Source file (non-class, e.g. functions) | `snake_case.php` | `slugify.php`, `format_date.php` |
| Test file | `*Test.php` (PHPUnit, co-located or in `tests/` per framework convention) | `InvoiceListTest.php` |
| Config file | `snake_case.php` or `*.config.php` | `tax_rates.php`, `app.config.php` |
| Routes file | framework convention | `config/routes.yaml` or PHP attributes (Symfony); `routes/web.php`, `routes/api.php` (Laravel) |
| Migration file | framework convention | `migrations/Version20250620000001.php` (Doctrine); `2025_06_20_000001_add_discount_to_invoices.php` (Laravel) |
| View / template | framework convention | `invoice/show.html.twig` (Symfony/Twig); `invoices/show.blade.php` (Laravel/Blade) |
| Public entry point | `index.php` in the web root (e.g. `public/index.php`); all other code outside the web root | `public/index.php` |

PSR-4 and namespaces:

- PSR-4 maps a fully-qualified class name `\App\Features\Invoices\InvoiceRepository` to the file `app/Features/Invoices/InvoiceRepository.php` (case-sensitive, exact match). **This is enforced by the autoloader** — get the casing wrong and the class will not load. Unlike TypeScript, PHP filenames are not stylistic; they are a hard requirement.
- Namespaces mirror directory structure: `App\Features\Invoices` lives in `app/Features/Invoices/`. The namespace is the filesystem, made legal. Use this to your advantage: a folder rename in PHP *forces* a namespace update, which *forces* a `use` statement update at every call site — the language itself enforces co-location discipline.

Symfony-specific notes:

- Follow the layout Symfony ships with: `src/Controller/`, `src/Entity/`, `src/Repository/`, `src/Service/`, with service definitions in `config/services.yaml`. The boring choice is whatever `bin/console make:` produces — accept its output rather than renaming it to taste.
- Prefer autowiring and autoconfiguration over manual service registration. Type-hint the interface, let the container resolve it; register by hand only for the cases autowiring genuinely cannot express (multiple implementations of one interface, scalar arguments).
- Put domain logic in `src/Service/` (or `src/Domain/` in a domain-driven layout), not in controllers and not in entities. Controllers translate HTTP into domain calls and back; entities model persistence.
- Use Doctrine repositories (`src/Repository/`) as the persistence boundary — they are already the repository pattern, so do not wrap them in a second hand-written repository layer.
- Tests live in `tests/` mirroring `src/` under the `App\Tests\` namespace, using `KernelTestCase` / `WebTestCase`. This is one of the few places where the framework convention overrides the general "co-located unit tests" principle.
- For validation and serialization, use the attribute-driven Validator and Serializer components before reaching for hand-rolled checks; for forms, `src/Form/*Type.php`; for authorization, voters in `src/Security/`.

Laravel-specific notes:

- Follow Laravel's conventions exactly: `app/Models/`, `app/Http/Controllers/`, `app/Services/`, `app/Repositories/` are the framework's idiomatic layers. Do not invent parallel structures.
- Use Laravel's `Illuminate\Support\` facades and helpers as the boring choice; reach for plain classes only when the facade genuinely gets in the way.
- Put domain logic in `app/Services/` (or `app/Actions/` for action-style classes), not in controllers or models. Controllers handle HTTP, models handle persistence and basic validation, services hold the domain.
- Use Laravel's built-in test helpers (`RefreshDatabase`, `TestCase`) and put tests in `tests/Feature/` (HTTP-level) and `tests/Unit/` (isolated) — the same framework override of the co-located-tests principle.

PHP anti-patterns to refuse:

- `functions.php` as a single dump-everything-here file. Split into concept files (`slugify.php`, `format_date.php`, etc.) and let the autoloader find them.
- `inc/` or `includes/` as a directory name. Use `src/` (PSR-4 root) or `app/` (framework convention). "inc" tells the reader nothing.
- `class-` prefixes on filenames (`class-invoice-repository.php`) — a WordPress convention. Modern PHP uses `InvoiceRepository.php` matching the class name, per PSR-4.
- Global state (`global $config`). Use dependency injection; modern PHP frameworks all support it natively.

### 2.5 Rust

| File role | Convention | Example |
|---|---|---|
| Source file | `snake_case.rs` | `slugify.rs`, `format_date.rs` |
| Module entry | `mod.rs` (for directory-as-module) or `snake_case.rs` (for file-as-module, Rust 2018+) | `mod.rs` |
| Test file | inline `#[cfg(test)] mod tests { ... }` (Rust convention) | in-source |
| Types file | in-file or `types.rs` | `invoice.rs` |

---

## 3. Folder Trees — Good vs Questionable

Three common project shapes, each with a good version and a questionable version. The good versions follow the twelve principles in `SKILL.md`. The questionable versions are the beginner's-instinct layouts that look tidy and age badly.

### 3.1 Next.js Application

#### Questionable

```text
my-app/
  src/
    components/         # all components, no domain signal
      InvoiceList.tsx
      UserCard.tsx
      Button.tsx
      Header.tsx
    hooks/              # all hooks
      useInvoices.ts
      useAuth.ts
    utils/              # junk drawer
      format.ts
      api.ts
      helpers.ts
      misc.ts
    pages/              # or app/ — flat routing
      index.tsx
      invoices.tsx
      users.tsx
    styles/
      globals.css
      invoices.css
      users.css
    types/
      invoice.ts
      user.ts
    context/
      AuthContext.tsx
  public/
  package.json
```

Problems: no domain folders; technical taxonomy only; `utils/` is a junk drawer in waiting; tests not shown (probably a top-level `__tests__/` mirror).

#### Good

```text
my-app/
  src/
    app/                          # Next.js App Router — routing, layouts, pages
      layout.tsx
      page.tsx
      invoices/
        page.tsx
        [id]/
          page.tsx
      users/
        page.tsx
    features/                     # domain features, co-located
      invoices/
        InvoiceList.tsx
        InvoiceList.test.tsx
        InvoiceEditor.tsx
        InvoiceEditor.test.tsx
        invoice-api.ts
        invoice-types.ts
        use-invoices.ts
        invoice.css
        index.ts                  # curated public surface (see Single Public Surface pattern)
      users/
        UserCard.tsx
        UserCard.test.tsx
        user-api.ts
        user-types.ts
        use-user.ts
        index.ts
      auth/
        AuthProvider.tsx
        use-auth.ts
        auth-types.ts
        index.ts
    components/ui/                # design-system primitives, shared across features
      Button.tsx
      Input.tsx
      Modal.tsx
      index.ts
    lib/                          # shared, domain-free utilities
      slugify.ts
      format-date.ts
      http-client.ts
  public/
  package.json
  tsconfig.json
  next.config.ts
  eslint.config.ts
```

Why it works: top-level folders tell the domain story (`features/invoices/`, `features/users/`, `features/auth/`). Each feature folder is self-contained — component, API, types, hooks, styles, tests. Shared UI primitives live in `components/ui/`. Domain-free utilities live in `lib/`. The App Router's `app/` folder holds routing only; the actual feature code lives in `features/` and is imported from the route files.

### 3.2 Full-Stack Monorepo

#### Questionable

```text
my-monorepo/
  packages/
    frontend/         # all frontend in one package
    backend/          # all backend in one package
    shared/           # everything cross-cutting dumped here
    utils/            # junk drawer
    types/            # all types in one package
  package.json
```

Problems: `shared/`, `utils/`, `types/` are junk drawers. No domain signal at the top level. Each package is itself likely a junk drawer.

#### Good

```text
my-monorepo/
  apps/
    web/                          # the customer-facing Next.js app
      src/
        app/
        features/
        components/ui/
        lib/
      package.json
    admin/                        # the internal admin app
      src/
        app/
        features/
        components/ui/
        lib/
      package.json
    api/                          # the backend API service
      src/
        routes/
        features/                 # backend feature folders mirror frontend
          invoices/
            invoices-router.ts
            invoices-service.ts
            invoices-repo.ts
            invoices-types.ts
            invoices.test.ts
          auth/
            auth-router.ts
            auth-service.ts
            auth-repo.ts
        lib/
        server.ts
      package.json
    worker/                       # background job runner
      src/
        jobs/
        lib/
      package.json
  packages/
    ui-kit/                       # design system, shared across apps
      src/
        Button.tsx
        Input.tsx
        Modal.tsx
        index.ts
      package.json
    api-client/                   # typed API client, shared across frontends
      src/
        invoices-client.ts
        auth-client.ts
        index.ts
      package.json
    types/                        # cross-stack domain types
      src/
        invoice.ts
        user.ts
        auth.ts
        index.ts
      package.json
    config/                       # shared eslint, tsconfig, prettier
      eslint.base.js
      tsconfig.base.json
      package.json
  package.json                    # workspace root
  pnpm-workspace.yaml             # or turbo.json / nx.json
```

Why it works: top-level `apps/` vs `packages/` separates deployable applications from shared libraries. Each app has its own feature folders. Shared UI lives in `packages/ui-kit/`. Shared types live in `packages/types/`. The `apps/api/` feature folders mirror the frontend feature folders — a change to "invoices" typically touches `apps/web/src/features/invoices/`, `apps/api/src/features/invoices/`, and `packages/types/src/invoice.ts`, all discoverable by the same domain name.

### 3.3 TypeScript Backend Service

#### Questionable

```text
my-service/
  src/
    controllers/      # all controllers
    services/         # all services
    repositories/     # all repos
    models/           # all models
    utils/            # junk drawer
    middleware/
    config/
  tests/              # mirror of src/, drifts over time
  package.json
```

Problems: technical taxonomy only; no domain signal; `tests/` mirror drifts; `utils/` is a junk drawer.

#### Good

```text
my-service/
  src/
    features/                 # domain features, each a vertical slice
      invoices/
        invoices-router.ts    # route definitions
        invoices-controller.ts# request/response handling
        invoices-service.ts   # business logic
        invoices-repo.ts      # persistence
        invoices-types.ts     # request/response/domain types
        invoices.test.ts      # co-located unit tests
        index.ts              # curated public surface (the router)
      auth/
        auth-router.ts
        auth-controller.ts
        auth-service.ts
        auth-repo.ts
        auth-types.ts
        auth.test.ts
        index.ts
      billing/
        billing-router.ts
        billing-controller.ts
        billing-service.ts
        billing-repo.ts
        billing-types.ts
        billing.test.ts
        index.ts
    lib/                      # shared, domain-free utilities
      http-client.ts
      logger.ts
      db.ts
      slugify.ts
    middleware/               # cross-cutting HTTP middleware
      auth.ts
      error-handler.ts
      request-id.ts
    config/                   # configuration loading
      env.ts
      index.ts
    server.ts                 # entry point — wires features to middleware
  package.json
  tsconfig.json
  .env.example
```

Why it works: each feature is a vertical slice — router, controller, service, repo, types, tests — all in one folder, all changing together. The entry point `server.ts` imports the curated public surface (`index.ts`) from each feature and wires them. Shared infrastructure (DB, logger, HTTP client) lives in `lib/`. Middleware is cross-cutting and lives at the top level. A new contributor reading the folder tree immediately sees: this service has invoices, auth, and billing.

### 3.4 Go Service

Go's layout is shaped by two language-level facts: (1) one directory = one package, and (2) the `internal/` directory is compiler-enforced private. The standard Go project layout — codified by the community as "Standard Go Project Layout" and refined over years — looks like this:

#### Questionable

```text
my-service/
  main.go             # 800 lines, everything in package main
  handlers.go         # HTTP handlers, package main
  models.go           # all domain types, package main
  db.go               # database access, package main
  utils.go            # junk drawer
  helpers.go          # second junk drawer
  tests/              # Go tool can't find these (must be *_test.go co-located)
  go.mod
```

Problems: everything in `package main` so nothing is reusable; no `internal/` boundary so all code is importable; `tests/` directory does not work in Go (tests must be `*_test.go` next to the source); `utils.go` and `helpers.go` are junk drawers.

#### Good

```text
my-service/
  cmd/                        # one directory per binary
    api/
      main.go                 # entry point: wires dependencies, starts server
    worker/
      main.go                 # separate binary for background jobs
  internal/                   # compiler-enforced: only this module can import
    invoices/                 # package invoices — domain feature
      invoice.go              # type + constructors
      service.go              # business logic (InvoiceService)
      repository.go           # persistence interface + postgres impl
      handler.go              # HTTP handler
      routes.go               # route registration
      invoice_test.go         # co-located unit tests (Go requirement)
      doc.go                  # package documentation
    auth/
      auth.go
      service.go
      repository.go
      handler.go
      routes.go
      auth_test.go
    billing/
      billing.go
      service.go
      repository.go
      handler.go
      routes.go
      billing_test.go
    httpserver/               # shared HTTP infrastructure
      server.go
      middleware.go
      errors.go
    postgres/                 # shared database infrastructure
      client.go
      migrations.go
    config/                   # configuration loading
      config.go
      env.go
  go.mod
  go.sum
  Makefile
  .env.example
  Dockerfile
```

Why it works: `cmd/api/main.go` and `cmd/worker/main.go` are thin entry points that wire dependencies and start the server — they contain no business logic. Everything else lives under `internal/`, which the Go compiler enforces as private to this module (no other module can import `my-service/internal/invoices`). Each domain feature is a package (`invoices/`, `auth/`, `billing/`) containing its types, service, repository, handler, routes, and tests — co-located and changing together. The package name (`invoices`) is the public API surface: only the exported symbols (`Invoice`, `NewService`, `RegisterRoutes`) are visible to other packages. There is no `pkg/` directory (the modern Go community has moved away from it). Tests are `*_test.go` next to the source, as the `go` tool requires. A new contributor reading the tree immediately sees: this service has invoices, auth, and billing, plus the shared `httpserver` and `postgres` infrastructure.

### 3.5 PHP Application (Symfony, Laravel)

PHP web applications have a distinctive shape because the web entry point (`public/index.php`) is fixed by the framework, all routing goes through a front controller, and PSR-4 autoloading ties class names to file paths exactly. Symfony is the primary layout below; the Laravel variant follows, and the two differ in folder names rather than in principle.

#### Questionable

```text
my-app/
  inc/                # "inc" tells the reader nothing
    functions.php     # 2000-line junk drawer
    db.php
    helpers.php
  classes/            # non-standard; PSR-4 wants src/ or app/
    Controllers/
      InvoiceController.php
    Models/
      Invoice.php
  public/
    index.php
    style.css         # assets mixed with entry point
    app.js
  tests/              # ok, but no PSR-4 mapping
  config.php          # ad-hoc config in root
  routes.php          # ad-hoc routes in root
```

Problems: `inc/` is a junk-drawer name; `functions.php` is the classic PHP anti-pattern; `classes/` does not match PSR-4 (which expects `src/` or `app/`); assets mixed with the entry point in `public/`; ad-hoc config and routes in the root rather than framework convention.

#### Good (Symfony)

```text
my-app/
  src/                            # PSR-4 root: App\ namespace
    Controller/
      InvoiceController.php       # App\Controller\InvoiceController
      SecurityController.php
    Entity/                       # Doctrine entities
      Invoice.php
      User.php
    Repository/                   # Doctrine repositories
      InvoiceRepository.php
    Service/                      # domain logic — the boring place for it
      InvoiceService.php
      BillingService.php
    Form/                         # form types
      InvoiceType.php
    Dto/                          # request/response shapes
      InvoiceInput.php
    EventSubscriber/
      InvoiceSubscriber.php
    Security/
      InvoiceVoter.php
    Command/                      # console commands
      ImportInvoicesCommand.php
    Kernel.php
  config/
    services.yaml                 # DI: autowiring + autoconfiguration
    routes.yaml                   # or attribute routing on the controllers
    packages/                     # per-bundle config
      doctrine.yaml
      security.yaml
      twig.yaml
  migrations/                     # DoctrineMigrationsBundle
    Version20250620000001.php
    Version20250620000002.php
  templates/                      # Twig, mirrors the controller structure
    invoice/
      index.html.twig
      show.html.twig
    base.html.twig
  translations/
    messages.en.xlf
  public/
    index.php                     # the single web entry point
  tests/                          # mirrors src/, PSR-4 as App\Tests\
    Controller/
      InvoiceControllerTest.php
    Service/
      InvoiceServiceTest.php
  bin/
    console                       # CLI entry point
  var/                            # cache, logs (gitignored)
  composer.json
  .env
```

Why it works: PSR-4 maps `App\Service\InvoiceService` to `src/Service/InvoiceService.php` exactly — the namespace is the filesystem, made legal. The folder names are the ones `bin/console make:` generates, so every Symfony developer can navigate the tree without being told. Domain logic lives in `src/Service/` (or `src/Domain/` in a domain-driven layout), not in controllers, which only translate HTTP to domain calls, and not in entities, which only model persistence. Autowiring in `config/services.yaml` means services are wired by type rather than registered by hand — the boring choice. Migrations are versioned classes managed by DoctrineMigrationsBundle. Templates mirror the controller structure (`src/Controller/InvoiceController.php` → `templates/invoice/`), so a reader who found the controller can guess the template path. Tests mirror `src/` under the `App\Tests\` namespace — Symfony's convention, and one of the few places a framework overrides the general "co-located unit tests" principle. The single web entry point is `public/index.php`; everything else lives outside the web root, so a misconfigured server cannot serve source files directly.

For a large Symfony application, a feature-oriented overlay is acceptable and increasingly common: `src/Invoicing/{Controller,Entity,Service}/`, `src/Billing/{...}/` — one top-level folder per bounded context, each holding the same layer folders. Principle 1 (the folder tree tells the domain story) favours this once the app has several contexts; below that size, the flat layer layout is the boring choice.

#### Good (Laravel)

```text
my-app/
  app/                            # PSR-4 root: App\ namespace
    Models/
      Invoice.php                 # App\Models\Invoice
      User.php
    Http/
      Controllers/
        InvoiceController.php     # App\Http\Controllers\InvoiceController
        AuthController.php
      Requests/                   # form request validation
        StoreInvoiceRequest.php
        UpdateInvoiceRequest.php
      Resources/                  # API resources (serialisers)
        InvoiceResource.php
    Services/                     # domain logic — the boring place for it
      InvoiceService.php
      BillingService.php
    Repositories/                 # persistence abstraction (optional but common)
      InvoiceRepository.php
    Actions/                      # action-style classes (Laravel convention)
      CreateInvoiceAction.php
    Providers/
      AppServiceProvider.php
  routes/
    web.php                       # web routes
    api.php                       # API routes
    console.php                   # artisan commands
  config/
    app.php                       # framework config
    database.php
    services.php
  database/
    migrations/                   # timestamped, framework-managed
      2025_06_20_000001_create_invoices_table.php
      2025_06_20_000002_add_discount_to_invoices.php
    factories/                    # test data factories
      InvoiceFactory.php
    seeders/                      # seed data
      DatabaseSeeder.php
  resources/
    views/                        # blade templates
      invoices/
        index.blade.php
        show.blade.php
        edit.blade.php
    js/                           # frontend assets
    css/
  public/
    index.php                     # the single web entry point
    .htaccess                     # rewrites everything to index.php
  tests/
    Feature/                      # HTTP-level tests (Laravel convention)
      InvoiceControllerTest.php
    Unit/                         # isolated unit tests
      InvoiceServiceTest.php
  bootstrap/
    app.php                       # framework bootstrap
    cache/
  composer.json
  artisan                        # CLI entry point
  .env.example
```

Why it works: the same reasoning as the Symfony tree, with Laravel's folder names. `app/` is the PSR-4 root instead of `src/`; controllers sit under `app/Http/Controllers/`; models are Eloquent classes in `app/Models/` rather than Doctrine entities; routes live in dedicated `routes/*.php` files instead of attributes or `config/routes.yaml`; migrations are timestamped files rather than versioned classes; templates are Blade under `resources/views/` rather than Twig under `templates/`. Domain logic still belongs in `app/Services/` (or `app/Actions/` for single-action classes), not in controllers or models. Tests split into `tests/Feature/` (HTTP-level, with database refresh) and `tests/Unit/` (isolated) — again a framework override of the co-located-tests principle.

Which to pick: whichever the project already uses. For a new project, take the one your team knows — both are boring choices in their own ecosystem, and mixing their conventions (Laravel folder names in a Symfony app, or a hand-rolled service container in either) is the only genuinely wrong answer. When in doubt inside an existing project, run `bin/console make:` (Symfony) or `artisan make:` (Laravel) and accept what the framework generates.

---

## Closing Note

The trees above are starting points, not laws. Adapt them to the framework you are using — but preserve the principles: one concept per file, co-location of what changes together, domain-named folders, curated public surfaces, co-located tests. The goal is a codebase that a new contributor can navigate by folder names alone, where every file announces its role at a glance, and where a change to one feature touches one folder.

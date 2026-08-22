# Named Patterns for Code Craftsmanship

This file is a catalogue of named patterns that codify the twelve principles in `SKILL.md`. Each pattern has the same shape:

- **Summary** — one line, quotable.
- **When to use** — the situations where the pattern applies.
- **Why it works** — the reasoning behind it.
- **Counter-pattern** — the failure mode it prevents.
- **Example** — a small, concrete illustration.

Patterns are tools, not religions. Choose the one that fits the situation. The goal is calm, readable code, not pattern-compliance for its own sake.

---

## 1. Feature Folder

**Summary.** Group all the files for one product feature into a folder named after the feature.

**When to use.** In any application with more than one feature. The default for React, Next.js, Vue, Svelte, and most full-stack frameworks. In Go, the equivalent is one package per feature under `internal/` (e.g. `internal/invoices/`). In PHP, Laravel's layer-based convention (`app/Services/`, `app/Http/Controllers/`, `app/Models/`) is the boring choice; a feature-folder overlay inside `app/` is acceptable for large apps.

**Why it works.** Files that change together live together. A feature requirement touches the feature's component, API, types, styles, and tests; co-locating them makes the change atomic and the diff readable. See Principle 2 in `SKILL.md`.

**Counter-pattern.** Technical Taxonomy — `components/`, `hooks/`, `api/`, `types/` as top-level folders, with each feature's files scattered across them (TypeScript); or in Go, everything in `package main` with no `internal/` boundary; or in PHP, ad-hoc `inc/` and `classes/` folders that do not match PSR-4. Looks tidy, ages badly.

**Example (TypeScript).**

```text
src/features/invoices/
  InvoiceList.tsx
  InvoiceList.test.tsx
  InvoiceEditor.tsx
  invoice-api.ts
  invoice-types.ts
  use-invoices.ts
  invoice.css
```

**Example (Go).**

```text
internal/invoices/        # package invoices
  invoice.go              # type + constructors
  service.go              # business logic
  repository.go           # persistence
  handler.go              # HTTP handler
  routes.go               # route registration
  invoice_test.go         # co-located tests (Go requirement)
  doc.go                  # package documentation
```

**Example (PHP / Laravel).**

```text
app/Services/InvoiceService.php       # domain logic
app/Http/Controllers/InvoiceController.php
app/Models/Invoice.php
app/Http/Requests/StoreInvoiceRequest.php
database/migrations/2025_06_20_000001_create_invoices_table.php
tests/Feature/InvoiceControllerTest.php
tests/Unit/InvoiceServiceTest.php
```

---

## 2. Co-Location

**Summary.** Put files that change together in the same folder, regardless of their technical role.

**When to use.** Always, as the default. The Next.js App Router encodes this: route files, components, styles, and tests for one route live in the route's folder.

**Why it works.** Reduces the radius of a change from "four top-level folders" to "one folder". Reviewers see the whole change in one place. VCS diffs become readable as stories. See Principle 2.

**Counter-pattern.** Test Mirror — a top-level `test/` folder that mirrors `src/`. Drifts over time as one side moves and the other does not.

**Example (TypeScript).**

```text
# Co-located
src/features/invoices/InvoiceList.tsx
src/features/invoices/InvoiceList.test.tsx

# Mirrored (avoid for unit tests)
src/features/invoices/InvoiceList.tsx
test/features/invoices/InvoiceList.test.tsx
```

**Example (Go).** Go *requires* co-location at the toolchain level — `*_test.go` must sit next to the source file in the same package directory, or `go test` will not find them.

```text
internal/invoices/invoice.go
internal/invoices/invoice_test.go     # required by the go tool
```

**Example (PHP).** PHPUnit convention is `*Test.php`. Modern setups co-locate; Laravel and Symfony conventions use a `tests/` directory split into `Feature/` and `Unit/` — this is a framework override, accepted because the testing tooling expects it.

```text
# Co-located (modern, framework-agnostic)
src/Invoice.php
src/InvoiceTest.php

# Laravel convention (framework override)
app/Services/InvoiceService.php
tests/Unit/InvoiceServiceTest.php
```

---

## 3. Newspaper Layout

**Summary.** Within a file, lead with the headline (exports, types, main function) and push implementation below.

**When to use.** Every source file. Especially valuable for files longer than ~50 lines.

**Why it works.** A reader scanning a file wants the contract first and the body second — same as a newspaper article. Leading with private helpers inverts this and forces the reader to scroll past details to find the entry point. See Principle 4.

**Counter-pattern.** Bottom-Up File — the exported function appears at line 200, after the writer "built up" to it with helpers. Reads like a proof, not a story.

**Example.** See the "Fix" example under Principle 4 in `SKILL.md`.

---

## 4. Single Public Surface

**Summary.** A module's `index.ts` (or equivalent) is a curated table of contents — the intended public API — not a firehose that re-exports every internal.

**When to use.** For library packages, for shared internal modules, and for any folder that callers from outside the folder will import from.

**Why it works.** Restricting the public surface makes the module's contract explicit. The maintainer is free to refactor internals — rename, split, restructure — without breaking callers, because callers only see the curated surface. See Principle 4.

**Counter-pattern.** Barrel File — an `index.ts` that re-exports every internal symbol for convenience. Hides the real source, breaks tree-shaking, and silently becomes the public API whether you intended it or not.

**Example.**

```ts
// features/invoices/index.ts — curated public surface
export { InvoiceList } from './InvoiceList';
export { InvoiceEditor } from './InvoiceEditor';
export type { Invoice, InvoiceLine } from './invoice-types';
export { useInvoices } from './use-invoices';

// Not exported: invoice-api internals, parsers, helpers.
// Callers go through the named exports above.
```

---

## 5. Extract Method Over Comment

**Summary.** When you find yourself writing a `// what` comment, extract the block into a function whose name says what the comment said.

**When to use.** Whenever a comment explains *what* a block of code does. Almost always.

**Why it works.** The function name becomes reusable documentation at every call site. The comment was localized to one place. See Principle 5.

**Counter-pattern.** Apology Comment — `// loop over users and send email to active ones` above a five-line block that does exactly that. The comment is a confession that the code is not self-describing.

**Example.** See the "Fix" example under Principle 5 in `SKILL.md`.

---

## 6. Barrel File Caution

**Summary.** Avoid `index.ts` files that only re-export other modules, except at intentional public boundaries. (This pattern is TypeScript/JavaScript-specific; Go and PHP do not have the barrel problem in the same form.)

**When to use.** Use barrels *only* for: a library package's entry point, a folder that is the explicit public surface of a module. Do not use barrels to shorten import paths inside an app. In Go, the public API is decided by capitalisation (`Invoice` is exported, `invoice` is not) and the `internal/` directory is compiler-enforced private, so there is no need for a barrel file. In PHP, PSR-4 autoloading makes the filename equal to the class name, so a "barrel" is meaningless — you import the class by its fully-qualified name and the autoloader finds the file.

**Why it works.** Barrels hide the real source location, force importers to pull the whole barrel (defeating tree-shaking in bundlers), and silently become the public API whether the maintainer intended it or not. TkDodo's "Please Stop Using Barrel Files" remains the canonical warning. See Principle 11.

**Counter-pattern.** Convenience Barrel — an `index.ts` in every folder so that imports look like `import { X } from './features'` instead of `import { X } from './features/invoices/InvoiceList'`. Convenient for the writer, expensive for the bundler and the reader.

**Example (TypeScript).**

```ts
// AVOID in app code:
// src/features/index.ts
export * from './invoices';
export * from './billing';
export * from './auth';
// Now every import from './features' pulls all three.

// ACCEPTABLE at a library boundary:
// packages/ui-kit/src/index.ts
export { Button } from './Button';
export { Input } from './Input';
export { Modal } from './Modal';
// This is the package's public contract.
```

**Note (Go).** Go's equivalent of a "curated public surface" is the set of exported (capitalised) symbols in a package. The Single Public Surface pattern (Pattern #4) is enforced by the language: anything starting with an uppercase letter is public, anything else is private. The `internal/` directory makes this even stronger — code in `internal/` cannot be imported from outside the module at all. No barrel file required.

**Note (PHP).** PHP's equivalent is the `composer.json` `autoload` section, which declares the PSR-4 mapping. The "public surface" of a PHP package is the set of classes in its namespace; there is no separate index file. If you want to hide internal classes, put them in a sub-namespace like `App\Internal\` and document that callers should not use it.

---

## 7. Boring Choice

**Summary.** For 90% of decisions, pick the conventional option — the one a senior engineer in the language's ecosystem would expect without asking.

**When to use.** As the default for every architectural decision. Diverge only with a measured reason.

**Why it works.** Convention is compressed documentation. Every reader who knows the ecosystem can read conventional code for free. Divergence is a tax on every future reader. See Principle 9.

**Counter-pattern.** Not Invented Here — a bespoke state container, a custom error hierarchy, a hand-rolled logger, a parallel test runner. Each one feels small in isolation; together they make the codebase illegible to anyone who knows the ecosystem but not the team.

**Example (TypeScript).**

```ts
// BORING (good):
import { create } from 'zustand';
export const useInvoiceStore = create((set) => ({ /* ... */ }));

// BESPOKE (avoid):
class EventEmitter { /* ... */ }
class Store<T> { /* ... */ }
const invoiceStore = new Store<InvoiceState>(/* ... */);
// Three months later: nobody remembers how this works.
```

**Example (Go).**

```go
// BORING (good):
if errors.Is(err, sql.ErrNoRows) { /* ... */ }

// BESPOKE (avoid):
type AppError struct { Code int; Cause error }
func (e *AppError) Is(target error) bool { /* custom logic */ }
// Six months later: nobody's Is() works with the ecosystem.
```

**Example (PHP / Laravel).**

```php
// BORING (good):
public function store(StoreInvoiceRequest $request, InvoiceService $service)
{
    $invoice = $service->create($request->validated());
    return new InvoiceResource($invoice);
}

// BESPOKE (avoid):
public function store(Request $request)
{
    $data = $this->customValidator->validate($request->all(), /* ... */);
    $invoice = $this->manualContainer->resolve('invoice')->create($data);
    return response()->json($this->customSerializer->toArray($invoice));
}
// A year later: nobody knows which validator/container/serializer is in use.
```

---

## 8. Campsite Rule

**Summary.** Every commit leaves at least one nearby file slightly better than you found it — and in a separate commit from the behaviour change.

**When to use.** Always, as a habit. On every PR.

**Why it works.** Codebases decay or improve one commit at a time; there is no equilibrium. Small cleanups in separate commits are trivially reviewable and compound across years. See Principle 12.

**Counter-pattern.** "I'll Clean It Up Later" — never happens. The next PR inherits the mess and adds its own.

**Example.**

```text
PR: "Add discount field to invoices"

Commit 1: refactor(invoices): rename `data` → `invoicePayload` in invoice-api.ts
Commit 2: feat(invoices): add discount field to invoice model and UI
Commit 3: test(invoices): add tests for discount calculation
```

Three commits, each reviewable in isolation. The reviewer can rubber-stamp Commit 1, focus on Commit 2, and skim Commit 3.

---

## 9. Newspaper Headline for Folders

**Summary.** A new contributor reads only the top-level folder names and roughly guesses what the application does.

**When to use.** When laying out a new project, or restructuring an existing one. The first decision a contributor makes is "which folder do I open first?" — the folders should answer that without code.

**Why it works.** Folders are the chapter headings of the codebase. Domain folders (`features/invoices/`) teach the domain as the reader navigates. Technical folders (`utils/`, `misc/`) force the reader to already know the codebase. See Principle 7.

**Counter-pattern.** Junk Drawer — a top-level `utils/` or `misc/` folder that accumulates everything that did not fit elsewhere. Within six months it contains 80 files, no two related, and nobody can find anything.

**Example.** See the "Counter-example" and "Fix" trees under Principle 7 in `SKILL.md`.

---

## 10. Single Concept File

**Summary.** A file holds exactly one concept — one component, one service, one domain type, one cohesive utility family.

**When to use.** Always. The filesystem is the cheapest index a programmer has.

**Why it works.** The filename is the first sentence of documentation. A 600-line `utils.ts` (or `utils.go`, or the classic PHP `functions.php`) destroys that signal. See Principle 1.

**Counter-pattern.** Junk File — a `utils.ts` / `helpers.ts` / `misc.ts` (TypeScript), or `utils.go` / `helpers.go` (Go), or `functions.php` / `helpers.php` (PHP) that grows without bound because it is the path of least resistance. Every new helper gets appended because the writer did not want to create a new file.

**Example.** See the "Counter-example" and "Fix" trees under Principle 1 in `SKILL.md`. Per-ecosystem filename conventions are in `references/naming-and-trees.md` §2.

---

## 11. Vertical Rhythm

**Summary.** Use blank lines to separate ideas, not as decoration. One blank line between functions, one between logical sections within a function, two between top-level sections of a file.

**When to use.** Always. Whitespace is a section break.

**Why it works.** Vertical rhythm is invisible glue. When sections breathe at the same intervals, the eye flows predictably and the brain groups statements into paragraphs without effort. See Principle 6.

**Counter-pattern.** Wall of Text — a fifty-line function with no blank lines, the eye cannot find the breaks. Or: Random Double Blanks — two blank lines mid-block for no reason, the eye stutters.

**Example.** See the "Counter-example" and "Fix" examples under Principle 6 in `SKILL.md`.

---

## 12. Why-Not-What Comment

**Summary.** A comment explains *why* the code is the way it is — never *what* it does.

**When to use.** When the *why* is non-obvious: a constraint from an upstream system, a bug that was fixed, a trade-off that was made, a magic number with a source.

**Why it works.** The code already tells the reader *what*. The comment carries the institutional memory the code cannot. See Principle 5.

**Counter-pattern.** Restating Comment — `// increment i by 1` above `i++`. Adds noise without information.

**Example.**

```ts
// GOOD — explains why:
// Retry on 429 because the upstream gateway burst-limits clients (INC-1234).
// Without this, batch imports fail at ~50 records.
await withRetry(() => api.post(invoice), { on: [429] });

// BAD — restates what:
// Call the API to create the invoice
await api.post(invoice);
```

---

## 13. Type-Hinting Suffix

**Summary.** Names carry structural hints in their suffix: plural for arrays, `ById` for maps, `is`/`has`/`should` for booleans, `Row`/`Card`/`Modal` for component variants, `Schema` for validation schemas.

**When to use.** When naming any variable, function, type, or file whose shape is not obvious from the context.

**Why it works.** The reader infers the shape from the name without jumping to the definition. See Principle 3.

**Counter-pattern.** Generic Noun — `items`, `data`, `info`, `flag` — that hides both the domain and the shape.

**Example.**

```ts
const invoiceLines: InvoiceLine[] = [];          // plural → array
const usersById: Map<string, User> = new Map();  // ById → map
const isVerified: boolean = false;               // is → boolean
const invoiceSchema = z.object({ /* ... */ });   // Schema → validator
const InvoiceRow = () => <tr>...</tr>;           // Row → component variant
```

---

## 14. Two-Hard-Problems Naming

**Summary.** Name for the future reader who has no context, not for the moment of writing. "There are only two hard problems in computer science: cache invalidation, naming things, and off-by-one errors."

**When to use.** Always, but especially when naming things that will outlive the current PR: exported functions, types, files, folders, database columns.

**Why it works.** Names outlive their writers. A vague name (`data`, `process`, `handle`) taxes every future reader. A precise name pays the tax once, at writing time. See Principle 3.

**Counter-pattern.** Writer-Centric Name — `temp`, `stuff`, `thing2`, `newAndImproved` — names that made sense to the writer in the moment and nobody else afterwards.

**Example.**

```ts
// WRITER-CENTRIC:
function process(data: any) { /* ... */ }
const temp = users.filter(u => u.active);

// READER-CENTRIC:
function parseInvoiceCsv(csv: string): Invoice { /* ... */ }
const activeUsers = users.filter(u => u.active);
```

---

## 15. Drive-By Cleanup

**Summary.** While you are in a file for a feature change, fix one small thing nearby — but in a separate commit.

**When to use.** On every PR that touches existing code. The constraint is "small" — a renamed variable, a tightened comment, an extracted helper. Not a refactor.

**Why it works.** Small cleanups compound. A codebase where every PR leaves one thing better is a codebase that gets easier to work in over time. The separate commit keeps the cleanup reviewable. See Principle 12.

**Counter-pattern.** Drive-by Refactor — the cleanup is large enough to need its own PR but is bundled into the feature PR, making the feature PR unreviewable and the cleanup invisible.

**Example.** See the example under Campsite Rule above.

---

## Closing Note

Patterns are tools. The goal is calm, readable, durable code — not pattern-compliance for its own sake. When two patterns conflict, pick the one that better serves the reader who arrives at 2 a.m. with a pager going off and no context. That reader is the customer. The patterns are for them.

---
name: code-craftsmanship
description: >-
  Structure code and its files like a craftsman — repo layout, file naming,
  module shape, and symbol craft for TypeScript/React, Python, Go, PHP, and
  Rust. Use whenever you write, edit, scaffold, or refactor any source code,
  from a single function to a greenfield project, and whenever the user asks
  for clean, elegant, idiomatic, or production-quality code or wants a
  codebase organized, tidied, or restructured. Encodes a Calm Engineering
  aesthetic — fewer concepts, smaller files, long-lived names, opinionated
  defaults — applied quietly on every code-touching task.
---

# Code Craftsmanship

Every file you write is a letter to the next programmer, who arrives at 2 a.m. with no context and only the code. Write for that reader. The aesthetic is Calm Engineering — the school that runs from the Unix philosophy through 37signals into the software-craftsmanship movement: fewer concepts beat more concepts, small files beat large files, long-lived names beat clever abbreviations, opinionated defaults beat endless configuration, convention beats invention.

Every decision passes through three lenses:

1. **Structure** — repo layout, module boundaries, the arrangement inside a file. The tree should tell what the application *does*, not what technologies it uses.
2. **Rhythm** — whitespace, ordering, cadence. Invisible when right, unbearable when wrong.
3. **Naming** — the words you give to symbols and files. A good name is a contract; a bad name is a lie.

## The Twelve Principles

Apply these on every code-touching task. They run from the largest scale to the smallest, then close with two judgment calls and two habits. Each principle is expanded — full reasoning, counter-examples, fixes, per-language shapes — in `references/principles-deep-dive.md`; consult it when a rule needs interpretation or when scaffolding something unfamiliar.

1. **The folder tree tells the domain story.** Top-level folders are domain nouns (`features/invoices/`, `features/billing/`), not technology nouns (`helpers/`, `misc/`). A new contributor should guess the product from `ls` alone. Technical folders exist only in supporting roles.

2. **Co-locate what changes together.** A feature's component, API client, types, styles, and unit tests share one folder named for the feature (`features/invoices/`; in Go one package under `internal/`; in Symfony and Laravel the framework's layer convention wins). One requirement, one folder, one diff. Genuinely cross-feature code lives in the project's shared layer — whatever that project already calls it (`src/`, `lib/`, `internal/`, `components/ui/`).

3. **One concept per unit.** Each unit of encapsulation holds exactly one concept. If you need the word "and" to describe its contents, split it. In most languages the unit is the *file*, and its name is the first sentence of the documentation — `slugify.ts` beats a 600-line `utils.ts`; PHP (PSR-4) makes one class per file mandatory. In Go the unit is the *package*: one capability per well-named package (never `util`/`common`/`helpers`), one cohesive aspect per file within it — not one micro-file per function. Files are readability tools, not doctrine: split when a file resists scanning, keep members together when splitting would only produce boilerplate.

4. **Members stay with their group.** Principle 2 one zoom level down: inside a file, a type's declaration, constructor, methods, and its constants/errors form one contiguous block — fields with fields, methods grouped by responsibility, related declarations as pairs, nothing unrelated interleaved. Go permits scattering a type's methods across a package; treat that permission as a trap.

5. **The public surface goes on top.** Exports, types, and the entry point lead the file; helpers follow below in call order. Principle 4 groups, this one orders. An `index.ts` is a curated table of contents, not a firehose of re-exports — barrels belong only at a library's public boundary.

6. **Whitespace is a section break.** One blank line between ideas, no random doubles, no fifty-line walls of text. Let the formatter own indentation and never fight it.

7. **Comments are paragraphs, not apologies.** Comment the *why* — the constraint, the trade-off, the incident — never the *what*. A "what" comment means: extract a function named for what the comment said.

8. **Names outlive their writers.** Name for the reader who arrives cold; the *call site* should read as a sentence. In procedural code the function carries it (`parseInvoiceCsv(text)`, not `process(x)`); in OOP the receiver carries half, so drop what it already says (`invoice.total()`, not `invoice.invoiceTotal()`) — the same stutter rule Go applies to package qualifiers. Use shape hints: plurals for arrays, `ById` for maps, `is`/`has`/`should` for booleans, `Schema` for schemas. Filenames are names too: language-idiomatic casing, matching the primary export or class (per-ecosystem table: `references/naming-and-trees.md` §2).

9. **Fewer concepts, deeper concepts.** A direct call beats a plugin system; a switch beats a strategy registry; a union beats an inheritance tree. Abstract when the second concrete use case arrives, never for an imagined one. A healthy PR deletes more than it adds. (The module / interface / depth / seam vocabulary is the `codebase-design` skill's when it is among your available skills.)

10. **Make the boring choice.** Pick what a senior in the ecosystem expects: framework built-ins, the standard error model, the community's lint config and layout. Divergence is a compounding tax — pay it only with a measured reason, documented at the boundary.

11. **Tests live with the code they test.** `InvoiceList.test.tsx` next to `InvoiceList.tsx`; Go requires `_test.go` co-location; Rust uses inline `#[cfg(test)]` modules. Framework conventions (Symfony's and Laravel's `tests/`) override. Integration and e2e tests may live apart. Which seam a test hooks into is the `tdd` skill's call when it is among your available skills; without it, test through the public interface, never against internals.

12. **Leave the campsite cleaner.** One small nearby improvement per change — after the loop is green, in a separate commit from the behaviour change, so reviews stay legible.

When a repository adopts this skill, name it in `CONTRIBUTING.md` or `CODING_STANDARDS.md` ("code style follows the `code-craftsmanship` skill") — that is the file a review skill's Standards axis reads. When the `code-review` skill is among your available skills, it is the review-time pass; the checklist below is the writing-time pass.

## House Rules

Defaults this skill adds on top of the principles:

- **Prefer object-oriented design** wherever the language supports it: model the domain as types that own their state and the behaviour over it, rather than as procedural helpers passing anonymous data around. Favour composition over inheritance, keep hierarchies shallow, and program against interfaces at the seams — principle 9 still applies, so this is a preference for *cohesive types*, not a licence for ceremony. In Go, the idiomatic form is a struct with methods plus small consumer-side interfaces; Go's lack of inheritance is not a reason to fall back to free functions over bare maps.

- **English is the repository language** — identifiers, comments, documentation, commit messages, log lines, and error strings. Only user-facing copy follows the product's locale; everything a developer reads stays English. Comments earn their place by carrying a *why* (principle 7); never restate what the code already says.

- **Write the working implementation** in committed work — not a `TODO`, not `throw new NotImplementedError`, not a stub returning fake data (a hard-coded return mid-way through a red-green loop is fine; it does not get committed). If something genuinely cannot be implemented (missing credentials, undecided requirement, unavailable API), say so plainly instead of shipping a hollow shell that looks finished.

- **Reuse before you write.** Search for an existing helper, type, or service before adding one — duplicated *knowledge* is the defect DRY targets. Duplicated *shape* is not: two blocks that merely look alike but change for different reasons stay apart, and the abstraction waits for the third occurrence (principle 9).

- **Honour the ecosystem's standards** instead of inventing local conventions. Follow the ones that apply to what you are building:
  - *CLI and service behaviour*: the `cli-design` and `service-application-design` skills own these when they are among your available skills; the non-negotiables are `NO_COLOR`, data on stdout and diagnostics on stderr, meaningful exit codes, the XDG Base Directory Specification for user files, environment variables for deployment config, and never a secret in the repository.
  - *Repository conventions*: Semantic Versioning, Conventional Commits, EditorConfig, the language's standard formatter and lint defaults, a `LICENSE` and a README that states what the thing is.
  - *Interfaces and data*: UTF-8, RFC 3339 / ISO 8601 timestamps, standard HTTP status codes over bespoke error envelopes (RFC 9457 problem details where a body is needed), and the ecosystem's schema format (OpenAPI, JSON Schema) rather than a hand-written contract.

## Pre-Commit Checklist

Before declaring the work done, run through this list. It is the apprentice's last look at the workbench before closing the shop — the moment where small defects are still cheap to fix.

- [ ] Does the folder tree tell the domain story? Could a new contributor guess the product from the top-level folders alone?
- [ ] Are the files that change together co-located in the same folder?
- [ ] Does every unit I touched or created hold exactly one concept — every file, and in Go every package?
- [ ] Do the members of each type stay in one contiguous block, in a stable order, with nothing unrelated interleaved?
- [ ] Does each file lead with its public surface — exports and types at the top, implementation below, no accidental barrel?
- [ ] Is the whitespace deliberate — one blank line between ideas, no random doubles, no fifty-line walls of text?
- [ ] Does every comment explain *why*, not *what*? Could any comment be replaced by an extracted function?
- [ ] Are all new names intent-revealing read *at the call site*, with nothing the receiver already says? Are filenames casing-consistent and role-suffixed?
- [ ] Have I avoided speculative abstraction? Is there a *second* concrete use case for every abstraction I introduced?
- [ ] Have I made the boring choice wherever there was one, and honoured the applicable standards (`NO_COLOR`, XDG paths, stdout/stderr, SemVer, RFC 3339, …)?
- [ ] Do unit tests sit next to the files they test, with a matching `.test` / `.spec` suffix?
- [ ] Have I left the campsite cleaner — at least one small drive-by improvement, in a separate commit from the behaviour change?

If any answer is "no", fix it before opening the pull request. The cost is minutes; the benefit is years.

## Reference Files

Progressive disclosure — read them when the situation calls for it:

- **`references/principles-deep-dive.md`** — the full Rule / Why / Counter-example / Fix treatment of all twelve principles, with per-language shapes for TypeScript, Go, and PHP. Read when a principle needs interpretation, justification, or teaching.
- **`references/patterns.md`** — a catalogue of named patterns (Feature Folder, Newspaper Layout, Extract Method Over Comment, Boring Choice, Campsite Rule, and others), each with summary, when-to-use, counter-pattern, and example. Read when picking a concrete shape for a new module or feature.
- **`references/naming-and-trees.md`** — before/after naming pair tables, filename conventions per ecosystem (TypeScript, Python, Go, PHP, Rust), and good-vs-questionable folder trees for common project shapes. Read when scaffolding or restructuring a project.

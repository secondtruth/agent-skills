# Specification Writing Guide

Best practices for writing protocol specifications, technical standards, and RFC-style documents.

---

## 1. Document Structure

RFC-style documents follow a predictable structure. Readers — especially implementers — expect to find things in specific places. Don't surprise them.

### Canonical Section Order

1. **Title, Version, Date, Authors**
2. **Abstract** — What this spec defines, in 2–4 sentences. No motivation, no history, no forward references.
3. **Conventions and Definitions** — RFC 2119 boilerplate + glossary of domain-specific terms.
4. **Design Goals** — What the protocol optimizes for. Keep it to 5–7 bullet points max. These are constraints, not features.
5. **Core Specification** — The normative meat. Subdivide logically (see §2).
6. **Security Considerations** — Always present, even for trusted-network protocols.
7. **Extensibility** — How the protocol can grow without breaking.
8. **Use Cases** — Brief, illustrative. Not a marketing pitch.
9. **Appendices** — Examples, quick references, MIME types, status code tables.
10. **References** — Cited specs, RFCs, related documents.
11. **License, Authors, Version History**

Not every spec needs every section. A 2-page discovery protocol doesn't need a Use Cases section. But when in doubt, include the section — even a single paragraph signals that the topic was considered.

### Abstract vs. Introduction

The Abstract states *what*. No motivation, no "why we built this", no comparisons to other protocols. If the spec needs historical context or motivation, add a separate **Background and Motivation** section after the Abstract. The Abstract is the one paragraph someone reads to decide whether this spec is relevant to them.

Bad: "Due to the limitations of existing protocols and the growing need for LLM-optimized discovery mechanisms, we developed Beacon, which improves upon..."

Good: "Beacon is an application protocol for identity and capability discovery, designed for AI agents, users, and organizations."


## 2. Writing Normative Prose

### Prose Over Lists

Specifications are legal documents for software. Write them in paragraphs, not bullet points. Lists are acceptable for tables (status codes, fields, parameters) and enumerated options, but the explanatory text connecting them should be prose.

Bad:
```
### Entity Types
- `user` - Human users
  - Personal profiles
  - Organization references
  - Personal documentation
```

Good:
```
**`user`** — Human users. Typically contains a personal profile,
organizational affiliations, personal documentation, and optionally
the traditional Finger files `.project` and `.plan`.
```

The prose version forces you to articulate the *relationships* between items, not just list them.

### Use RFC 2119 Keywords Precisely

Every MUST, SHOULD, and MAY carries specific weight. Use them deliberately:

- **MUST / MUST NOT** — Absolute requirement. Non-compliance breaks interoperability. Use sparingly.
- **SHOULD / SHOULD NOT** — Strong recommendation. There may be legitimate reasons to deviate, but the full implications must be understood.
- **MAY** — Truly optional. Implementations can ignore this without consequence.

Common mistakes: Using MUST when you mean SHOULD (making the spec unnecessarily rigid), or using SHOULD when you mean MAY (implying pressure where none is warranted).

Write the keyword, then immediately state the consequence of violation or the rationale. "Servers MUST reject requests exceeding 1024 bytes with status code `59`" is better than "Requests MUST NOT exceed 1024 bytes" because the first version tells the implementer what to *do*.

### Document Edge Cases

For every feature, ask: What happens when this goes wrong? What happens at the boundary? Then write it down.

Questions to ask for each protocol element:
- What if the input is empty?
- What if the input is malformed?
- What if it exceeds size limits?
- What if the referenced thing doesn't exist?
- What if there are duplicates?
- What if the server/client is a version behind?

These answers often become MUST/SHOULD statements. If you can't answer the question, that's a gap in the spec.

### One Concept, One Place

If a concept appears in two sections, one of them is wrong. Duplication inevitably leads to inconsistency — one copy gets updated, the other doesn't. Define each concept once, then reference it.

This applies within a document and across document suites. If the daemon guide needs to explain query format, it references the protocol spec — it doesn't re-explain it.


## 3. Scope Discipline

### A Spec Knows Only What It Defines

The most common spec-writing mistake: referencing things that haven't been defined yet, or that exist in a different document that hasn't been written yet. A specification should be self-contained within its declared scope.

Concrete rules:
- Don't name specific alternative implementations ("e.g., HTTP") unless the spec actually defines them. A generic statement like "Other transports MAY be used" is sufficient.
- Don't reference documents that don't exist yet. If you plan an HTTP spec later, that's your business — the base spec doesn't know about it.
- Don't add sections whose sole purpose is to point elsewhere. If a section only says "see document X for details", it shouldn't exist.

The exception: well-established external references (RFCs, widely-adopted specs) are fine to cite.

### Avoid Retrofitted Architecture

When adding capabilities to an existing spec (e.g., transport-agnostic framing), the addition should read as if it was always there. Signs that something was retrofitted:
- A section that exists only to explain the *change* rather than the *concept*
- Terminology that appears once in a new section but nowhere else in the document
- Cross-references that feel like footnotes bolted onto the side

The fix: Rewrite the relevant sections so the new concept is integrated into the existing structure. If "Protocol Stack" needs to say the protocol is transport-agnostic, rewrite Protocol Stack — don't add a "Protocol Layering" section next to it.

### Separation of Concerns

Each document in a spec suite should have exactly one job:

| Document | Scope |
|----------|-------|
| Protocol spec | What queries mean, what responses contain |
| Transport spec | How bytes move over the wire |
| Implementation guide | How to build a server |
| README / Overview | How the documents relate to each other |

A protocol spec should not contain implementation advice. An implementation guide should not redefine protocol semantics. When you find yourself writing "as defined in Section X of this document" more than twice, consider whether the document is trying to do two jobs.


## 4. Terminology Consistency

### Pick a Word and Stick With It

If you call it "transport" in Section 3, don't call it "binding" in Section 7 and "carrier" in Section 12. Maintain a mental (or actual) glossary and enforce it across the entire document.

Common traps:
- "query" vs. "request" vs. "command"
- "entity" vs. "resource" vs. "object"
- "server" vs. "daemon" vs. "service"
- "path" vs. "route" vs. "endpoint"

The Conventions and Definitions section exists precisely for this. Define your terms, then use them consistently.

### Don't Import Terminology Prematurely

If the base spec doesn't use the word "binding", don't introduce it. Terminology should emerge from the concepts the document actually defines. If a later document (e.g., an HTTP transport spec) introduces "binding" as a concept, that's fine — but the base spec doesn't need to retroactively adopt it.


## 5. Examples

### Less Is More (Inline)

Inline examples should illustrate a concept *exactly once*, at the point where it's first defined. One canonical example per concept. If you need more, put them in an appendix.

The inline example answers: "What does this look like?" The appendix examples answer: "What does this look like in all the different scenarios?"

### Appendix Examples Are Complete

Appendix examples should be full request-response pairs (or whatever the protocol's equivalent is). Include status lines, headers, content — everything a developer would see on the wire. Group them by scenario, not by feature.

### Examples Are Not Normative

Make this explicit if there's any ambiguity. If an example shows a frontmatter field with value "public", that doesn't mean "public" is the only valid value. The normative definition in the spec text is authoritative; examples merely illustrate.


## 6. Versioning and Evolution

### Version What You Ship, Not What You Plan

A version number reflects the state of the document, not the state of the project. Don't bump the version for "planned features" or "architectural decisions" — bump it when normative text changes.

### Changelog Entries Are Summaries

The Version History entry should tell a reader *what changed*, not *why*. "Added conventions section, consolidated duplicate content, expanded error handling prose" is useful. "Major revision to align with new architecture" is not — it doesn't say what actually changed.

### Breaking Changes Deserve Major Versions

If an existing compliant implementation would break, that's a major version bump. If it still works but gains new optional features, that's a minor version.


## 7. Style

### Be Precise, Not Clever

Specs are not the place for personality, metaphors, or humor. Save the wit for the README. In the spec itself, every sentence should have exactly one interpretation.

Bad: "The server gracefully handles the situation."
Good: "The server responds with status code `51` (Not Found)."

### Active Voice, Present Tense

"The server sends a response" not "A response is sent by the server." Active voice makes it clear who does what — critical in a protocol spec where client and server have distinct responsibilities.

### Short Sentences

Protocol specs are parsed by humans who are simultaneously writing code. Long compound sentences with multiple clauses and nested conditions force the reader to hold too much state. Break them up.

Bad: "When a client sends a query that includes a path component that resolves to a directory rather than a file, and the directory contains an index document, the server should return the index document wrapped in an info tag along with a directory listing."

Good: "When the query path resolves to a directory, the server checks for an index document. If one exists, it is returned within an `<info>` tag. The response also includes a `<directory_contents>` listing of the directory's contents."


## 8. Review Checklist

Before considering a spec done, verify:

- [ ] Every MUST has a corresponding error behavior defined
- [ ] Every status code / error code is used at least once in the normative text
- [ ] No concept is defined in two places
- [ ] No section exists solely to reference another document
- [ ] All terminology is defined in Conventions and Definitions
- [ ] The Abstract contains no motivation, history, or forward references
- [ ] Inline examples appear at most once per concept
- [ ] Edge cases are addressed: empty input, malformed input, size limits, missing resources, duplicates
- [ ] The document can be understood without reading any other document in the suite (except declared dependencies)
- [ ] The Version History summarizes what changed, not why

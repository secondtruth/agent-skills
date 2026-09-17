---
name: reverse-engineering
license: MIT
version: "1.0"
description: >-
  Recover layouts, addresses and behaviour from native and .NET binaries
  for interoperability (a plugin, a compatible server, a data reader) with
  radare2, Ghidra headless and ilspycmd, reading decompiled C instead of
  disassembly and verifying every claim against the live process. Use
  whenever a task needs facts only a binary holds.
---

# Reverse engineering for interoperability

The question is "what does this build do", one build, one installation,
for the purpose of serving or reading it. Every answer names its evidence
and its standing:
verified (re-read in the binary or the live process), likely (consistent, an
inference in the chain), or refuted (kept in one line, so the next reader
skips it). An offset stays a hypothesis until a live check confirms it.

## Cost model

Assembly costs five to ten times the tokens of the same function as C, and a
fresh analysis of a large binary costs seconds to a minute per invocation.
So:

- Decompile (`pdg` with r2ghidra, `pdd` with r2dec, Ghidra headless export)
  and read C. Open the listing (`pdf`) for the few instructions a decompiler
  mangles: calling conventions, SSE constants, switch tables.
- Keep one session per binary open (`scripts/r2q`, or radare2's `=h` HTTP
  server, or r2pipe) and save projects; a command then costs milliseconds.
- Write long outputs to files and grep them. A whole-program export of
  decompiled C, grepped for a global's address, beats paging through xrefs.
- Prefer JSON commands (`aflj`, `axtj`, `pdfj`) when the answer feeds a
  script; `~` filters output in place.

## Scripts in this skill

`scripts/` holds three tools, called by path (`<skill-dir>/scripts/r2q`);
for shells and agents that run without the skill loaded, a symlink from a
`PATH` directory does. They need radare2 with `r2ghidra` and `r2dec`, `uv`,
Ghidra and a JDK 21.

- `r2q` keeps one radare2 session per binary in a daemon and answers
  commands in milliseconds: `r2q -f x.exe -P auto -- aaa` opens the session
  and analyses, `r2q -f x.exe -- 'pdg @ 0x6f1790'` decompiles, `--out f.c`
  writes the answer to a file, `-` reads one command per line from stdin.
  The project is remembered per binary, saved after analysis, after a quiet
  half minute following other changes, and on `--stop`; an idle session
  stops after four hours. What radare2 says on stderr (a missing function,
  a failed command) comes back prefixed `r2:`. `r2q --help` has the rest.
- `ghidra-headless <owner>/<project> -import x.exe` analyses a binary once
  with Ghidra; `-process x.exe -noanalysis -postScript ExportDecomp.java out.c
  0x6f1790 …` writes decompiled C of those functions (every function without
  addresses). Projects live under `$RE_CACHE/<owner>/ghidra`; `GHIDRA_HOME`
  and `JAVA_HOME` point at the installs.

## Round zero: the free names

Before interpreting a single function, sweep what the binary gives away and
record every result, including the empty ones:

- Build stamps and PDB paths (`RSDS`, compile dates from the PE header).
- Exported and RTTI names (`??_7` vftables, `.?AV` class descriptors), and the
  `.CRT$XC*` initialiser table, which lists static registrations in order.
- Registration tables: a `push str.Name; call hash; mov [global], eax` at the
  end of `.text` registers a component, message id or attribute class by
  name; the callee and the list head are the seams of the engine.
- String tables, dumped once to a file (`strings -a -t x`, plus wide strings
  from radare2) and grepped from there on.

Names an agent assigns are working labels; evidence is what the binary or
the process says.

## Per function, in this order

1. **Users, then accessors.** From a string or a global, `axt` to the code
   that reads it; small accessors (`mov eax,[ecx+0x94]; ret`) give field
   offsets, decompiled loops give record sizes (`i * 0x18`) and array globals.
2. **Types and constants before vtables, identity before decompilation.**
   Pin the record layout and the scales (a float at a data address the code
   multiplies by) first; a vtable's slot numbers next; only then read the
   function body as C.
3. **Decompile with two engines when they disagree.** r2ghidra and r2dec
   differ on calling conventions and on SSE code; the listing settles it.
4. **Bound the loop.** Read twenty to fifty lines, name what is now known,
   verify it, then decide whether the task still needs the next function.
   Every third function, check the goal: the offsets the consumer needs are
   the deliverable, the engine around them is context.

## Verify live before building on it

- **Read the running process** with the platform's memory read
  (`ReadProcessMemory` from a script run in the user's session, a debugger's
  dump, `frida` where a server is allowed) and decode the arrays with a
  script. Compare the decoded numbers with observed behaviour first: a
  recording of positions, a log, a capture.
- **Render the dump through the production reader.** A test harness that
  maps a memory dump into a fake image lets the real reader run on the
  development machine, so the interpretation is tested while the target
  keeps running.
- **Signature-check every site** the consumer touches (the first bytes of a
  function, with the relocated dwords masked), and let the consumer go
  passive on a mismatch: another build is a different subject.
- Dynamic instrumentation (`frida-trace`) confirms argument meanings and call
  order in minutes where static reading takes an hour; it needs the target's
  owner to allow the agent on the machine.

## .NET and script layers

Managed assemblies decompile to source with `ilspycmd` (`-l c` lists types,
`-t Ns.Type` one type, `-o dir` the assembly); Scaleform and Flash layers
with JPEXS `ffdec`. Read those before the native code: they hold the names
the native side lost.

## Writing it down

Document per finding: the address as a virtual address at the file's
preferred image base (which is what disassemblers print), the layout as a
table of offsets, the scale constants, the evidence, and the standing. A
loaded image is relocated, so the consumer resolves every address as the
module's runtime base plus the address minus the preferred base -- one
function (`At(fileAddress)`) used everywhere, and stated once in the
document. Keep file offsets (what `strings -t x` prints) apart from virtual
addresses: the section table maps between them. Keep working listings and dumps
off the repository in a scratch directory the document names. A consumer's
constants live in one header with a comment per address that points back to
the document.

## Embedded firmware

Stripped, statically linked binaries inside squashfs rootfs images (MIPS/ARM
cameras, routers, appliances) follow the same evidence discipline with a
different toolkit: string tables as the primary artifact, qemu-user against
the extracted rootfs as the live check, partition tables as the addresses.
`references/embedded-firmware.md` carries that toolkit.

The consumer code follows the `code-craftsmanship` skill when it is among your available skills.
A tool built around the session follows the `cli-design` skill when it is among your available skills.

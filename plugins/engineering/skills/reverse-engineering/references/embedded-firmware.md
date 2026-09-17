# Embedded firmware targets

MIPS/ARM Linux devices — cameras, routers, appliances — where the subject is a
stripped, statically linked updater or daemon inside a squashfs rootfs, and the
"live process" may only be reachable through emulation. The evidence discipline
of the main skill applies unchanged; these are the techniques the target class
adds.

## Round zero on a stripped binary

With no symbols, the string table becomes the primary artifact, so dump it
once (`strings -a -t x`) and grep from there:

- **Source paths in log strings.** Embedded builds often print `__FILE__` and
  line numbers in diagnostics — `/home/build/.../update.cpp line 198` names
  the function, its file, and sometimes the build tree layout.
- **Format strings as behaviour.** Error strings reveal state machines and
  check order: `"magic failed"`, `"board type"`, `"crc err"`, `"won't fit into
  %s"` read as the validation pipeline the binary runs.
- **Config and registration surfaces.** `inittab`, `rcS` and per-service init
  scripts are the embedded analogue of registration tables: they list every
  daemon that starts, in order, with its arguments — the seams of the system.
- **Build stamps.** `version_file`-style stamps, kernel banners and compile
  dates pin the SDK generation, which predicts library versions and quirks.

## Live checks without the target

- **qemu-user as the live process.** Run the foreign-arch subject against the
  extracted rootfs (`qemu-mipsel -L rootfs/ binary args`) to observe its real
  control flow — the checks it runs, the sections it attempts, the order it
  works in. A full boot is often impossible; the subject alone under emulation
  still executes its genuine logic against the genuine libraries.
- **Flash layout as addresses.** Partition tables in firmware containers and
  bootloader `mtdparts` are addresses in the skill's sense: parsed from the
  image as hypotheses, confirmed on the device (`cat /proc/mtd`) before
  anything is written.
- **Dynamic linking as dependency map.** A new binary's `DT_NEEDED` entries,
  checked against the target rootfs, replace guesswork about library
  availability; an interpreter path (`ld-uClibc.so.0`) pins the libc family.

## Firmware containers

Vendor images pack partitions behind a small header (magic, CRC, board type,
per-section table). Parse the container with its community tool where one
exists (e.g. pakler for Reolink/Novatek-class images); the section table gives
file offsets, the mtd table gives flash offsets, and keeping the two apart is
the first discipline — a file offset flashed to the wrong partition erases
whatever lives there.

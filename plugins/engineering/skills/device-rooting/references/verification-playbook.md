# Verification playbook

Concrete techniques for steps 3–4 of the pipeline. Each earns its place by
catching a failure class that static inspection misses.

## Running a foreign-arch binary on the workbench

qemu-user turns "does the binary link and run against the real rootfs" into a
five-minute check, no target hardware needed:

```sh
# run against the extracted rootfs as library prefix
qemu-mipsel -L rootfs/ rootfs/usr/sbin/dropbear -V

# full end-to-end: start the daemon, publish a container port, SSH from the host
qemu-mipsel -L rootfs/ rootfs/usr/sbin/dropbear -F -E -p 2222
ssh -p 2222 -i key root@127.0.0.1 'id'
```

Trap: `-L` prefixes only the *dynamic linker* lookup. Absolute paths the
program opens itself (host keys, config) resolve against the host, not the
rootfs — for file-path-sensitive behaviour run through `chroot`, or prepare
the equivalent host paths in a scratch container. A green run against the
wrong paths proves the binary loads, not that the deployment works.

Container note: on macOS, docker Desktop's binfmt does not register 32-bit
mipsel; run qemu-user inside an amd64 Linux container instead. Host-key
generation and ECC-heavy key exchange that segfault under emulation are
usually emulator artefacts, but confirm against the target's real directory
layout before dismissing them.

## Proving the patched image before flashing

- **Roundtrip:** extract the patched container again and byte-compare every
  untouched section against stock; only the intended section may differ.
- **Integrity:** the updater's own CRC (recalculated by the packing tool) must
  pass its listing check.
- **Layout:** repacked filesystems use the stock superblock parameters —
  compression, block size, ownership model; the image must fit its partition
  with headroom; a partition offset stays a hypothesis until the device
  confirms it (`cat /proc/mtd`, bootloader `mtdparts`).
- **Init scripts:** syntax-check with the target's BusyBox (`busybox sh -n`)
  under qemu-user, not the host shell.
- **Dependencies:** parse the added binary's `DT_NEEDED` list and confirm each
  library exists in the target rootfs — a missing uClibc soname means a silent
  startup failure on the device.

## Matching the updater's checks

Vendor updaters typically validate magic, board type, a CRC, and a
version-in-filename. The last one is the subtle gate: the filename must carry
a *newer* version than the device reports, and devices report the internal
version string, which a modified image usually leaves unchanged — bump the
filename until the prepare step accepts, and treat acceptance as a checkpoint
that costs nothing (nothing has flashed yet).

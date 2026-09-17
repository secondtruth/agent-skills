# Pitfalls of this device class

Each entry cost real time on a real project; the standing is what would have
prevented it. Generalisable lessons only — device-specific quirks belong in
the session's notes, not here.

## The ssh daemon runs but nobody can log in

- **Strict modes on a stock rootfs.** Stock `/root` directories are often
  world-writable (`777`), and both OpenSSH and Dropbear refuse `authorized_keys`
  under a group/other-writable home. The refusal is silent — the daemon is
  healthy, the login just fails. Fix the home directory mode in the *image*,
  because the rootfs mounts read-only and no runtime `chmod` can repair it.
- **Legacy-only daemons.** Dropbear of the 2015 era knows only `ssh-rsa`
  signatures and classic DH key exchange; modern clients need them forced:
  `ssh -oKexAlgorithms=diffie-hellman-group14-sha1 -oHostKeyAlgorithms=ssh-rsa
  -oPubkeyAcceptedAlgorithms=+ssh-rsa`. The first connection after a reboot
  may close during host-key generation — reconnect immediately.
- **Emulator optimism.** A qemu-user green run proves the binary loads; the
  deployment can still fail on perms the emulator host masked. Reproduce the
  target's directory modes in the verification environment.

## The upgrade path

- **"Restore config" flags reset silently.** An upgrade parameter mirroring
  the vendor UI default (e.g. `restoreCfg=1`) can reset hostname, IP and
  settings while leaving WiFi credentials intact — the device vanishes from
  its old address and reappears under a default name. Find it by MAC, and
  treat any restore-flag semantics as unverified until observed.
- **Updaters write everything.** Some updaters attempt every named partition,
  including zero-length sections — an "only the rootfs" package that relies on
  sections being skipped can still erase boot partitions. Verify the skip
  behaviour in emulation before trusting it.
- **The write takes minutes.** A full image to SPI NOR is slow; the device's
  absence after upload is the write, not a failure. Stable power, patience,
  no power cycling.
- **Version gates check the filename.** Same-version images are refused;
  the internal version string usually stays unchanged in a patched image, so
  the filename carries the bump.

## Hardening that locks the owner out

- Disabling password login before the key login is proven from a *second*
  session (not the shell that just edited the config).
- Embedded dropbear variants read `authorized_keys` from different paths —
  OpenWrt-style `/etc/dropbear/`, home-dir style `/root/.ssh/`. Confirm per
  binary with `strings` or the vendor's docs, not by analogy.
- Read-only-rootfs devices keep persistent state on a small jffs2/config
  partition; writes outside it vanish on reboot. Hardening that must persist
  belongs in the image or the persistent partition.

## Recovery order when a device goes dark

1. Wait past the plausible flash time, then scan the whole subnet by MAC —
   config resets renumber the device.
2. One clean power cycle after the write window has passed.
3. Serial/UART console (the bootloader is usually intact even when the
   rootfs is not), then a flash programmer on the desoldered SPI chip as the
   last resort.

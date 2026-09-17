---
name: device-rooting
license: MIT
description: Gain root on embedded devices the user owns — IP cameras, IoT appliances, routers — by modifying vendor firmware and flashing it through the safest path. Identify the platform, parse the firmware container, patch the rootfs, verify offline under emulation, flash patiently, then harden with a recovery route open. Use when the user wants shell access to their own device.
---

# Device rooting

The goal is a *durable* root shell on a device the user owns or is explicitly
authorized to modify, reached through changes that let the device keep working.
Build to survive: every step is chosen so a mistake costs settings or time,
never the device.

## The pipeline

**1. Identify before touching.** Sweep the network (ARP, port scan, banners)
and the vendor's documentation first; open the case only when the software
route is exhausted. Deliverable: model, hardware revision, firmware version,
SoC, open ports. Completion: every open port accounted for by a known service.

**2. Analyze the vendor firmware.** Download the stock image for the exact
model and revision — it is the ground truth for the flash layout, the root
filesystem, and the updater's checks, and it doubles as the rollback image.
Parse the container (packing tools such as pakler for Reolink-class images),
map every partition to its flash offset and size, extract the root filesystem.
Record the layout in a notes file the session keeps updating; offsets are
hypotheses until the device confirms them (`cat /proc/mtd`).

**3. Choose the access route.** Prefer, in order: a vendor upgrade mechanism
the stock updater already exercises (web UI or its HTTP API), a UART console,
an SD-card autorun hook, config injection. Each route's checks — CRC, board
type, version-in-filename — are matched, not bypassed: a modified image that
passes the vendor's own validation is the least surprising thing the updater
ever flashes. `references/verification-playbook.md` carries the route details.

**4. Verify offline before any flash.** Every addition to the image is proven
on the workbench: re-extract the patched container and byte-compare against
the stock sections, check CRC and partition sizes, syntax-check init scripts
with the target's own BusyBox, and run added binaries under qemu-user against
the real extracted rootfs — a foreign-arch SSH daemon serving a login from
the development machine is the strongest pre-flash proof that exists.

**5. Flash patiently.** A full-image write to SPI flash takes minutes, and
some updaters additionally reset or rewrite the config partition. Stay on
stable power, expect the first connection after reboot to fail (host-key
generation), and find the device by its MAC address after any config reset —
the old IP is the first thing a reset takes away.

**6. Harden without self-sabotage.** Additive changes only, so stock behaviour
survives a failed addition. Key-only SSH with the authorized_keys file present
before password login is disabled; each device keeps a documented recovery
route (UI password, serial console, config backup). Config backups are pulled
before every change.

## Standing and evidence

Every claim about the device — partition offset, updater behaviour, a binary's
library dependencies — carries a standing: verified on the device or in
emulation, likely from consistent inference, or refuted and kept in one line
so the next reader skips it.
The `reverse-engineering` skill when it is among your available skills
supplies the evidence discipline; this skill supplies the pipeline.

`references/pitfalls.md` collects the traps that cost the most time across
devices of this class.

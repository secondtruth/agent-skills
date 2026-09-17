# Embedded device rooting skill

## Decision

Build an original skill for gaining and keeping root access on the user's own embedded Linux devices (IP cameras, IoT appliances, routers). The capability is a distinct pipeline that no candidate covers as a whole: identify the platform → analyze the vendor firmware → modify the image → flash via the safest available path → verify offline before and after → harden the result without severing the recovery path.

Placement: agent-skills-private. Rooting workflows are dual-use; the public marketplace rules and the private repo's security-sensitive scope both point there. The skill must document the ownership boundary (own devices, authorized targets) and carry the safety-first philosophy from the E1 Zoom project, not a pentest tool chain.

## Scouting, 2026-09-13

Capability named three ways for search: firmware rooting, embedded root shell, jailbreak/own device. Sources: skills.sh API + `npx skills find`, GitHub topics (`claude-skills`, `agent-skills`), repo-tree fetches of every candidate; raw SKILL.md read for all below.

- [firmware-pentest](https://skills.sh/zhaoxuya520/reverse-skill/firmware-pentest) (806 installs): OWASP FSTM extraction → emulation → exploitation pipeline (binwalk v3, unblob, Firmadyne, EMBA). Its Stage 4 (filesystem extraction) and Stage 5+ (hardware access, UART/JTAG/SPI dump) are genuine slices of the new skill's analysis phase. Rejected for adoption: Chinese-only, and its operating philosophy ("ACTION REQUIRED" self-authorization rituals, default-to-attack routing) clashes with the build-to-survive, own-devices-only approach here. **Reference**, cited inside the new skill's analysis phase.
- [embedded-linux-login-debug](https://github.com/easyzoom/aix-skills) (31 stars): safe login-path decision for embedded Linux (SSH/UART/ADB order). Solid philosophy, dev-debug scope, ends before modification. **Reference**, cited for the access-method decision.
- [iot-firmware](https://skills.sh/ruvnet/ruflo/iot-firmware) (899 installs): fleet rollout orchestration, unrelated.
- [reverse-engineer-anything](https://github.com/morluto/rea) (401 stars): desktop/Electron package reversing, not embedded firmware.
- [ctf-skills](https://github.com/ljagiello/ctf-skills) (3260 stars): CTF pwn, different goal and target class.
- ESP32 firmware-engineer skills and the aix-skills embedded collection generally: development/bring-up, not rooting.

No existing skill covers firmware *modification with brick-risk management* — the differentiating capability. That gap is what the E1 Zoom project demonstrated end to end, and the verdict rests on those learnings rather than on more breadth of search.

## Build content (from the E1 Zoom root project)

The skill's spine, each step carrying a survival rule:

1. **Enumerate and identify** — ARP/portscan/banner first; never start by opening the case.
2. **Analyze vendor firmware** — download the stock image, parse the container format, map flash layout, extract the rootfs. Survival rule: record and verify partition offsets before touching anything.
3. **Choose the access route** — vendor API (like the Reolink `/cgi-bin/api.cgi` upgrade path), UART, SD autorun hooks, config-injection. Survival rule: prefer the route the vendor's updater already exercises; match its checks rather than bypass them where possible.
4. **Offline verification before flash** — re-extract the patched image and compare, check CRC and partition sizes, syntax-check init scripts with the target's own busybox, and boot-test added binaries under qemu-user against the real rootfs (the E1 Zoom dropbear login was proven this way before any flash).
5. **Flash and wait patiently** — no power cycle during write (flash can take many minutes); expect the first connection after reboot to fail (host-key generation); find the device by MAC after a config reset, not by its old IP.
6. **Harden without self-sabotage** — key-only SSH with an authorized_keys fallback, every hardening change additive, a documented recovery path left deliberately open.
7. **Known pitfalls** — dropbear strict modes reject world-writable `$HOME`; old dropbear needs legacy `ssh-rsa` algorithms forced; "restore config" upgrade flags silently reset device settings; updater binaries write all sections including empty ones.

## Delivery state

Decision recorded only. The skill itself is not yet written: source, placement in agent-skills-private, references, and the private plugin's manifests/keywords/README still to be done, followed by the private repo's own lint and release flow. The references above stay discovery leads-turned-read-sources, imported as citations, never as copied structure.

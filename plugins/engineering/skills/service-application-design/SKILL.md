---
name: service-application-design
license: MIT
description: >-
  What a long-running service owes its operator — schema migrations and
  startup behaviour, health checks, graceful shutdown, environment
  configuration, and an install path that works on a fresh system. Use when
  building or reviewing a service application: adding a database schema,
  wiring the startup sequence, exposing health, handling signals, or writing
  the install instructions.
---

# Service Application Design

Code-structure skills write for the next programmer; this skill writes for the **operator** — whoever installs the service, starts it, watches it, and upgrades it, with no way to ask you anything. Every rule below follows from that one reader. It holds whether the operator is a stranger self-hosting your MIT-licensed project or you, six months from now, on your own homelab box.

The command surface itself — flags, help anatomy, exit codes, command trees — is the `cli-design` skill's when it is among your available skills. This skill owns what the service does around that surface.

**The bar:** a fresh install, following only the README, reaches a working first sign-in with no undocumented step. Every rule here is checkable against that run; make it before calling a service done.

## Schema migrations

A service that owns a database schema owes the operator both halves of this, together:

- **A `migrate` command**, plus a `migrate status` reporting what has been applied. This is the controlled lever: CI, a rollout where the schema should move before the new binary serves traffic, or any setup with automatic migration switched off.
- **Automatic migration on startup**, governed by one environment variable (`<APP>_AUTO_MIGRATE`), defaulting to on. Apply it before opening the main connection pool, and log that the schema is current.

Ship them as a pair. Either half alone is a trap: the command without the automatic run means a fresh install starts against an empty schema, and the automatic run without the command leaves the operator no way to stage a migration ahead of a deploy.

Default the automatic run to on where the deployment is single-instance and the migration tool serializes concurrent runs — goose, Alembic and Flyway all take a lock. Those two conditions are what make the default safe, so state them where the default is set; the next person can then tell whether their deployment still qualifies.

**Name the automatic behaviour in the command's own help text**, together with the switch and the purpose that survives it. Otherwise the operator cannot tell whether running it is required or redundant. This generalises past migrations: any command whose work also happens automatically elsewhere says so in its help.

This section covers the migration *surface* — how the service exposes and runs migrations. The safety of a migration's *content* is a separate dimension: zero-downtime ordering, reversibility, table locks, gating destructive changes. Audit-time skills cover it well; `smiladinov/claude-saas-readiness` (MIT) has a solid treatment in `references/data-database.md`.

## Health

- **An HTTP health endpoint**, for the reverse proxy and the container runtime.
- **A `healthcheck` subcommand** that probes it, so a distroless or scratch image can declare a healthcheck without shipping curl or a shell.

Report healthy only once the service can actually serve. A process that is merely listening passes a naive check while the schema is missing, the data directory is unwritable, or a required upstream is unreachable — and a green healthcheck over a broken deployment is worse than a red one, because it sends the operator looking somewhere else. Check what the first real request would need.

## Startup and shutdown

- **Validate configuration at startup and fail fast**, naming the offending variable and what it expects. A service that starts on a broken setting and dies at the first request has moved the diagnosis away from the cause.
- **Handle SIGINT and SIGTERM**, then shut down gracefully: stop accepting new work, finish what is in flight under a bounded timeout, close pools. Container runtimes send SIGTERM and wait; a service that sits out that window is killed mid-request on every deploy.

## Configuration

- **Environment variables**, one flat namespace prefixed with the application name.
- **A committed example file** naming every variable, kept complete — it is the operator's only inventory of what exists.
- **Secrets through files or a credential service.** Flags and env vars both leak, via `ps`, shell history, logs and `docker inspect`.

## The install path

The documented quickstart is a claim about behaviour, so verify it like one: run it against an empty database and an empty data directory, through to a first sign-in.

Two failure shapes survive a careful reading of the code and appear only in that run — a step that lives in a developer's shell history rather than the README, and a failure that surfaces far from its cause, after an OAuth round trip or at the first request, where the operator will suspect whatever they configured most recently.

Steps only a human can take — registering an OAuth client, creating the first admin, placing a secret — are what the `wizard` skill scripts when it is among your available skills; without it, list them as a numbered checklist in the README, each with the URL and the value it produces.

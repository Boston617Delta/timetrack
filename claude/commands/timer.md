---
description: Start/stop the per-client time tracker (logs to ~/.timetrack/log.csv)
argument-hint: "[stop [client] [--at <time>|--after <dur>] | status | cancel [client] | report [client|today|week|month] | <client> <task>]"
allowed-tools: Bash(~/.timetrack/bin/track:*), AskUserQuestion
---

The user invoked the time tracker. The CLI is `~/.timetrack/bin/track` (call it by full path). Arguments passed: `$ARGUMENTS`

Decide what to do based on the arguments:

- **Empty** → First run `~/.timetrack/bin/track report` to see which client codes the user has logged before. Then use AskUserQuestion to ask **two** things: (1) which client, offering their most-logged codes as options; and (2) a short task description (the user will usually type this via "Other"). Then run `~/.timetrack/bin/track start <client> "<task>"`. Timers run one per client: several clients can run at once, but a client can't have two. If that client already has a timer (`~/.timetrack/bin/track status`), tell the user instead of starting another.
- **`stop [client]`** → run `~/.timetrack/bin/track stop <client>` and report the logged duration. The client can be left off only when a single timer is running; otherwise the CLI refuses and lists them, so ask which one.
- **`stop --at <time>` / `stop --after <dur>`** → pass straight through. `--at` closes the timer at a clock time (`11:54`, `"2026-09-19 11:54"`, or `now`); a bare `HH:MM` is read on the day the timer *started*, not today. `--after` closes it a fixed span after the start (`3h`, `90m`, `1.5h`, `2h30m`, or a bare number meaning hours). Use these for a timer that was left running overnight: they keep the true start time and only correct the end. Both refuse a stop time that is before the start or in the future, and leave the timer running if they refuse.
- **`status`** → run `~/.timetrack/bin/track status`.
- **`cancel [client]`** → run `~/.timetrack/bin/track cancel <client>` (same client rule as stop).
- **`report ...`** → run `~/.timetrack/bin/track report <rest of args>` (e.g. `report week`, `report ACME`).
- **Anything else** (e.g. `ACME homepage copy`) → treat the first word as the client and the rest as the task, and run `~/.timetrack/bin/track start <client> "<task>"` directly without asking.

Keep your reply short: just confirm what you started or stopped and the elapsed time.

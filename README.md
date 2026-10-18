# timetrack

A small per-client time tracker for people who bill by the hour, plus a to-do list and optional Claude Code hooks. It is plain Bash and a CSV file. There is no app, no account, and no background process: `start` saves a timestamp, `stop` writes a row.

I built it for my one-person marketing agency, where several client projects run in parallel and the expensive mistake is not a missing timer but a timer left running overnight.

## What it does

- **One timer per client.** Several clients can run at once, but the same client cannot have two timers, so hours are not double-counted.
- **Survives restarts.** Running timers live in a text file, so closing the terminal or rebooting does not lose them.
- **Fixes forgotten timers honestly.** `stop --after 3h` or `stop --at 16:30` closes a timer that ran too long. The real start time is kept and only the end is corrected.
- **Refuses impossible entries.** A stop time before the start or in the future is rejected and the timer stays running.
- **Backfills missed sessions** without touching running timers, and refuses entries that overlap existing ones for the same client.
- **Reports** hours by client for today, the last 7 days, this month, or all time.
- **With Claude Code (optional):** a hook tells Claude which timers are running when a session starts and as you work, flags any timer running longer than 8 hours as probably forgotten, and reminds Claude to start a timer when client work begins. A `/timer` slash command starts and stops timers in chat.

What it does **not** do: decide what is billable. It gives you a clean record; checking that record against the work and your client agreement is still your job.

## Requirements

- macOS. The scripts use BSD `date` flags (`date -r`, `date -j -f`, `date -v`), so they will not run unmodified on Linux.
- Bash, awk, and Python 3 (Python is used only by the Claude Code hook, to print JSON).

## Install

```bash
git clone https://github.com/Boston617Delta/timetrack.git
cd timetrack
./install.sh
```

This copies the scripts to `~/.timetrack/bin/` and, if Claude Code is installed, the `/timer` command to `~/.claude/commands/`. It skips anything that already exists unless you pass `--force`, and it never touches your data. Then add the aliases it prints to your shell profile.

## Usage

```bash
track start ACME "homepage copy"     # start a timer
track status                          # what is running
track stop ACME                       # stop and log it
track stop ACME --after 2h30m         # it ran overnight; log 2.5 hours from the real start
track stop ACME --at 16:30            # log it as ending at 4:30 pm on the day it started
track cancel ACME                     # discard without logging
track report week                     # hours per client, last 7 days
track report ACME                     # all-time hours for one client
track log 20                          # last 20 log rows
track backfill ACME "client call" --from "2026-10-14 09:00" --to "2026-10-14 10:15"
```

The log is `~/.timetrack/log.csv` with columns `date,client,start_iso,stop_iso,duration_hours,task`, ready for a spreadsheet or invoicing tool.

### To-do list

```bash
todo add ACME "send revised proposal" !h @2026-10-20
todo list                # open tasks grouped by client
todo list ACME
todo done 4
todo all                 # include completed
todo clear done
```

Tasks are stored in `~/.timetrack/todos.tsv`.

## Claude Code hooks (optional)

Add this to `~/.claude/settings.json` (merge with any hooks you already have):

```json
{
  "hooks": {
    "SessionStart": [
      { "hooks": [ { "type": "command", "command": "$HOME/.timetrack/bin/hook-status session-start" } ] }
    ],
    "UserPromptSubmit": [
      { "hooks": [ { "type": "command", "command": "$HOME/.timetrack/bin/hook-status prompt" } ] }
    ]
  }
}
```

The hook only adds context for Claude; it never starts or stops a timer itself. You can tune it with environment variables:

| Variable | Default | What it does |
|---|---|---|
| `TT_DIR` | `~/.timetrack` | Where data lives (also respected by `track` and `todo`) |
| `TT_STALE_HOURS` | `8` | When a running timer is flagged as probably forgotten |
| `TT_THROTTLE_MIN` | `20` | Minutes between "no timer running" reminders |
| `TT_IGNORE` | (none) | Comma-separated client codes to leave out of suggestions |
| `TT_DEFAULT_CLIENT` | (none) | Your code for internal, non-client work |
| `TT_TRACK_CMD` | `~/.timetrack/bin/track` | The path Claude is told to call |

To let Claude run the tracker without a permission prompt each time, allow `Bash(~/.timetrack/bin/track:*)` in your Claude Code permissions.

## Privacy

Everything stays on your machine. Your log and task files are plain text in `~/.timetrack/`; nothing is sent anywhere. Do not commit that folder to a public repository.

## License

MIT

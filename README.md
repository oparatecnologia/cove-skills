# Cove & WP-CLI — Agent Skills

> Manage local WordPress sites with [Cove](https://cove.run) and run WP-CLI through the FrankenPHP runtime — from AI coding agents (Claude Code, Codex, Cursor, Copilot, opencode…).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Cove](https://img.shields.io/badge/Cove-v1.14-green)](https://cove.run)
[![Validate Skills](https://github.com/oparatecnologia/cove-skills/actions/workflows/validate-skills.yml/badge.svg)](https://github.com/oparatecnologia/cove-skills/actions/workflows/validate-skills.yml)

**🇧🇷 [Leia em Português](README.pt-BR.md)**

---

## Table of Contents

- [Overview](#overview)
- [Why this skill exists](#why-this-skill-exists)
- [What the skill teaches](#what-the-skill-teaches)
- [Repository structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Command reference](#command-reference)
- [Non-interactive / agent usage](#non-interactive--agent-usage)
- [Gotchas](#gotchas)
- [Compatibility](#compatibility)
- [Testing](#testing)
- [License](#license)

---

## Overview

This is an **Agent Skill** (`SKILL.md`) that teaches AI agents how to work with local WordPress environments managed by [Cove](https://cove.run). Cove is a tiny CLI that runs Caddy + FrankenPHP + MariaDB + Mailpit — no Docker — and serves every site at `https://<name>.localhost`.

The skill focuses on the two things agents get wrong most often:

1. **Running WP-CLI through the wrong PHP runtime.** Cove bundles its own PHP via FrankenPHP (`~/Cove/php.ini`). A system `wp`/`php` may miss extensions or config. The skill enforces the correct invocation.
2. **Hardcoding ports and hostnames.** Ports change per machine (`cove ports`) and via Tailscale. The skill teaches that `cove status` is the source of truth.

## Why this skill exists

Without guidance, agents:

- Call bare `wp` from the system PATH and get different behavior than the site serves with;
- Invent Adminer/Mailpit URLs that don't exist (`db.cove.localhost`, `mail.cove.localhost`);
- Get stuck waiting on interactive prompts in a non-TTY environment;
- Don't know about Cove's PHP pinning (`cove php`), core management (`cove core`), or migration (`cove pull`/`push`);
- Are surprised by Cove-specific behavior (GD image editor forced instead of Imagick, Whoops error pages, 15-minute login token expiry).

## What the skill teaches

- **WP-CLI execution** via FrankenPHP: `PHPRC=~/Cove/php.ini frankenphp php-cli $(which wp) --path=$(cove path <name>) <command>`, plus a reusable shell alias.
- **Non-interactive usage** for agents/scripts/CI: every interactive prompt has a flag (`--yes`, `--force`, `--dry-run`, `--porcelain`, explicit ports), and `cove status --porcelain` is a stable `key=value` contract.
- **Service discovery**: Dashboard, Mailpit and Adminer URLs come from `cove status`, never from memory.
- **Site lifecycle**: add (with version/pin), clone, rename, delete, login, path, url.
- **Migration & sharing**: `cove pull`/`cove push` over SSH (including `--proxy-uploads`), `cove share` public tunnel.
- **PHP & core management**: `cove php <site> <version>`, `cove core check`/`update`.
- **Database**: `cove db list`, `cove db backup`, `cove memory`.
- **Diagnostics**: `cove health`, `cove log <site> -f`, `cove reload`, `cove trust`, `cove upgrade`.
- **Customization**: `cove mappings`, `cove proxy`, `cove directive`.
- **Gotchas** and a **common mistakes** table.

## Repository structure

```
cove-skills/
├── README.md               # EN
├── README.pt-BR.md         # PT-BR
├── LICENSE                 # MIT
├── CHANGELOG.md
├── install.sh              # one-command installer
├── scripts/
│   └── validate-skill.sh   # frontmatter/structure validator
├── tests/
│   └── scenarios.md        # reference-skill test scenarios
└── skills/
    └── cove-wp/            # the skill itself
        └── SKILL.md
```

## Prerequisites

- [Cove](https://cove.run) installed and running (`cove status` shows services up).
- An AI coding agent that supports skills (Claude Code, Codex, Cursor, Copilot, opencode, etc.).
- A local WordPress site created with `cove add <name>`.

## Installation

### One command

```bash
bash <(curl -sL https://raw.githubusercontent.com/oparatecnologia/cove-skills/main/install.sh)
```

Installs to `~/.agents/skills/`. Override the target with `AGENTS_SKILLS_DIR`
(e.g. `AGENTS_SKILLS_DIR=~/.claude/skills`) or pick specific skills with
`SKILLS="cove-wp"`.

### Manual

Clone this repository and copy (or symlink) the skill into your agent's skills directory:

```bash
git clone https://github.com/oparatecnologia/cove-skills.git
mkdir -p ~/.claude/skills            # Claude Code
cp -R cove-skills/skills/cove-wp ~/.claude/skills/cove-wp

# or, cross-runtime alias:
mkdir -p ~/.agents/skills
cp -R cove-skills/skills/cove-wp ~/.agents/skills/cove-wp
```

### Per-project

To scope the skill to one repository, place it under a project-local directory instead:

```bash
mkdir -p .claude/skills   # or .agents/skills, .cursor/skills…
cp -R cove-skills/skills/cove-wp .claude/skills/cove-wp
```

## Usage

Once installed, the skill activates automatically when a task involves local WordPress + Cove. Typical triggers:

> "Set up a new WordPress site locally with Cove"
> "Install and activate the WooCommerce plugin on the 'loja' site"
> "Pull my production site down via SSH without the uploads"
> "Update WordPress core on every Cove site"
> "Why is my site showing 'Allowed memory size exhausted'?"

The agent will read `SKILL.md` and apply the correct commands. Example the skill produces:

```bash
SITE_PATH=$(cove path loja)
WP="PHPRC=~/Cove/php.ini frankenphp php-cli $(which wp) --path=$SITE_PATH"

$WP plugin install woocommerce --activate
```

## Command reference

The skill documents every Cove command group as a quick-reference table:

| Group | Commands |
| :--- | :--- |
| **Site management** | `cove add` (with version/`--plain`/`--php`), `cove delete`, `cove rename`, `cove clone`, `cove list`, `cove login`, `cove path`, `cove url` |
| **Migration & sharing** | `cove pull`, `cove push`, `cove share`, `cove transfer probe` |
| **Network** | `cove lan`, `cove tailscale`, `cove ports`, `cove wsl-hosts` |
| **Database & services** | `cove db list`, `cove db backup`, `cove memory`, `cove trust`, `cove enable/disable`, `cove log`, `cove status`, `cove health` |
| **Maintenance & versions** | `cove php`, `cove core check/update`, `cove upgrade`, `cove reload`, `cove version` |
| **Customization** | `cove mappings`, `cove proxy`, `cove directive` |

## Non-interactive / agent usage

The skill ships a dedicated section so agents never stall on prompts:

| Flag | Applies to | Effect |
| :--- | :--- | :--- |
| `--yes` | `pull`, `push`, `share`, `install`, `delete`, `ports`, `memory set`, `upgrade`, `core update --all` | Skip confirmation |
| `--force` | `delete`, `directive delete`, `proxy add/delete` | Skip confirmation/overwrite |
| `--dry-run` | `ports`, `core update --all` | Preview without changes |
| `--porcelain` | `status` | Stable `key=value` machine-readable output |

## Gotchas

- **GD image editor (not Imagick):** Cove forces `WP_Image_Editor_GD` to avoid a FrankenPHP crash (SIGSEGV). Opt back in with `add_filter('cove_force_gd_editor', '__return_false')`.
- **Pinned PHP sites:** WP-CLI for a site pinned with `cove php` runs under that PHP, not FrankenPHP — prefer Cove's native commands there.
- **Login token expiry:** `cove login` tokens are 7 chars and expire in **15 minutes**.
- **`cove upgrade` ≠ `cove core update`:** one updates Cove the tool; the other updates WordPress core on sites.

## Compatibility

| Component | Version |
| :--- | :--- |
| Cove | tested against v1.14 |
| WordPress | any `cove add` release (incl. `6.4.3`, `nightly`, `plain`) |
| PHP | FrankenPHP default or per-site pin via `cove php` |

## Testing

The skill is verified with the reference-skill testing methodology (retrieval,
application, and gap-testing scenarios) using subagents — see
[`tests/scenarios.md`](tests/scenarios.md) for the scenarios and last results.
A [GitHub Action](.github/workflows/validate-skills.yml) also validates the
frontmatter and structure of every `SKILL.md` in the repository on push/PR.

Run the validator locally:

```bash
bash scripts/validate-skill.sh skills/cove-wp
```

## Contributing

- Keep `SKILL.md` aligned with the [official Cove docs](https://cove.run) and its changelog.
- When Cove ships a new version, re-run the scenarios in [`tests/scenarios.md`](tests/scenarios.md).
- Update [`CHANGELOG.md`](CHANGELOG.md) for any user-facing change.
- Ensure `bash scripts/validate-skill.sh skills/cove-wp` passes.

## License

MIT — see [LICENSE](LICENSE).

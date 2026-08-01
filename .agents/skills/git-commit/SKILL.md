---
name: git-commit
description: Create git commits with reviewed staging and Conventional Commit messages. Use when the user asks to commit changes, create a git commit, or mentions "/commit".
license: MIT
---

# Git Commit with Conventional Commits

## Overview

Create standardized, semantic git commits using the Conventional Commits specification. Analyze the actual diff to determine appropriate type, scope, and message.

## Conventional Commit Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Commit Types

| Type       | Purpose                        |
| ---------- | ------------------------------ |
| `feat`     | New feature                    |
| `fix`      | Bug fix                        |
| `docs`     | Documentation only             |
| `style`    | Formatting/style (no logic)    |
| `refactor` | Code refactor (no feature/fix) |
| `perf`     | Performance improvement        |
| `test`     | Add/update tests               |
| `build`    | Build system/dependencies      |
| `ci`       | CI/config changes              |
| `chore`    | Maintenance/misc               |
| `revert`   | Revert commit                  |

## Breaking Changes

```
# Exclamation mark after type/scope
feat!: remove deprecated endpoint

# BREAKING CHANGE footer
feat: allow config to extend other configs

BREAKING CHANGE: `extends` key behavior changed
```

## Workflow

### 1. Analyze Diff

```shell
# If files are staged, use staged diff
git diff --staged

# If nothing staged, use working tree diff
git diff

# Also check status
git status --porcelain
```

### 2. Stage Files (if needed)

If nothing is staged or you want to group changes differently:

```shell
# Stage specific files
git add path/to/file1 path/to/file2
```

Prefer explicit non-interactive staging after reviewing `git status --porcelain` and the relevant diffs. Do not use broad staging commands such as `git add .` unless the user explicitly asks and the status has been reviewed. Avoid shell-specific glob examples because wildcard behavior differs across shells.

Use patch or interactive staging only when the user explicitly asks for it.

**Never commit secrets** (.env, credentials.json, private keys).

### 3. Verify Commit Readiness

Before committing, always check whitespace in both unstaged and staged changes:

```shell
git diff --check
git diff --staged --check
```

If either command reports whitespace errors, fix them, restage affected files, and rerun the checks before committing.

For explicit repository-wide whitespace audits, use:

```shell
git grep -n '[[:blank:]]$'
```

This audit checks tracked files and is not required before every commit unless the user asks for a full whitespace scan.

### 4. Generate Commit Message

Analyze the diff to determine:

- **Type**: What kind of change is this?
- **Scope**: What area/module is affected?
- **Description**: One-line summary of what changed (present tense, imperative mood, <72 chars)

### 5. Execute Commit

Use multiple `-m` flags — git joins each value with a blank line. This works in bash, zsh, PowerShell, and cmd.

```
# Subject only
git commit -m "<type>: <description>"

# With body
git commit -m "<type>(<scope>): <description>" -m "<body>"

# With body and footer
git commit -m "<type>(<scope>): <description>" -m "<body>" -m "<footer>"
```

## Best Practices

- One logical change per commit
- Present tense: "add" not "added"
- Imperative mood: "fix bug" not "fixes bug"
- Reference issues: `Closes #123`, `Refs #456`
- Keep description under 72 characters

## Git Safety Protocol

- NEVER update git config
- NEVER run destructive commands (--force, hard reset) without explicit request
- NEVER skip hooks (--no-verify) unless user asks
- NEVER force push to main/master
- If commit hooks fail, fix the issue, restage, and retry the commit. Do not bypass hooks unless the user explicitly asks.

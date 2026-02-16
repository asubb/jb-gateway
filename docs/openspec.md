# OpenSpec with Claude Agent

OpenSpec is a spec-driven development workflow that helps AI agents understand and implement changes predictably.

## Step 1: Initialize OpenSpec

If your project doesn't have OpenSpec initialized yet, navigate to your project root and run:

```bash
openspec init
```

During init, you'll be prompted to pick your AI tool. Select **Claude** to ensure the project is configured for Claude Agent. This generates the native slash commands for the OpenSpec workflow:

- `.claude/commands/opsx/` — native slash commands for the OpenSpec workflow

Note: You should also ensure the following context files exist or create them if they are missing:

- `openspec/project.md` — your project context doc
- `openspec/AGENTS.md` — the instructions for the AI agent (the "README for Robots")

## Step 2: Fill out project.md

Use the `/opsx:onboard` command or give Claude this prompt to auto-fill the project context file:

> "Introspect my current project and fill out openspec/project.md"

This typically produces a concise markdown file with comprehensive project details — tech stack, conventions, structure.

## Step 3: The OpenSpec workflow with Claude

Claude supports native slash commands for the OpenSpec workflow:

| OpenSpec command | Description                                                            |
|:-----------------|:-----------------------------------------------------------------------|
| `/opsx:new`      | Start a new change                                                     |
| `/opsx:ff`       | Fast-forward this change — generate proposal, specs, design, and tasks |
| `/opsx:apply`    | Implement all tasks in the current change                              |
| `/opsx:archive`  | Archive the completed change and update the specs directory            |
| `/opsx:explore`  | Enter explore mode to think through ideas and clarify requirements     |

## Practical tips

- **Kotlin/Spring projects**: You can supplement `openspec/AGENTS.md` with Kotlin/Spring-specific guidelines (naming conventions, package structure, `@Transactional` usage, etc.).
- **Claude Capabilities**: Claude can run code, execute terminal commands, and work with the file system, handling all file creation and task execution required by OpenSpec.

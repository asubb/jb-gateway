# AGENTS.md: Instructions for AI Agents

Welcome, AI Agent. You are working within JB Gateway, a secure sandbox designed for spec-driven development.

## Your Workflow: OpenSpec

This project follows the **OpenSpec** workflow. Before implementing changes, you must ensure they are properly
specified.

### Workflow Steps

1. **New Change**: Use `/opsx:new <change-name>` to start a new change.
2. **Specify**: Follow the artifact sequence (Proposal → Design/Specs → Tasks).
3. **Fast-Forward**: Use `/opsx:ff` if you want to generate all artifacts at once for simple changes.
4. **Implement**: Use `/opsx:apply` to execute the tasks defined in `tasks.md`.
5. **Archive**: Use `/opsx:archive` once the change is complete and verified.

## Capabilities & Constraints

- **Shell Access**: You have full bash access within the container.
- **Docker**: You can use `docker` commands to manage containers on the host.
- **Project Root**: All development happens in `/home/jb-gateway/projects/`.
- **SDKs**: Use `sdk` command (SDKMAN!) to manage Java/Kotlin/Gradle versions.
- **Filesystem**: You can create, read, and modify files within the mounted project directory.

## Guiding Principles

- **Spec First**: Never implement without a task in `tasks.md` and a corresponding spec/design.
- **Atomic Commits**: If requested to commit, keep changes focused and follow project conventions.
- **Safety**: Do not attempt to bypass the container boundaries unless explicitly using `host-ssh` for authorized tasks.
- **Consistency**: Match the existing code style and documentation patterns.

## Context Files

- `openspec/project.md`: Read this for technical background and conventions.
- `openspec/specs/`: Read existing specifications before proposing changes.
- `README.md`: Overview of the environment and tooling.

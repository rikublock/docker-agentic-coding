# AGENTS.md

Guidance for humans and coding agents working in this repository.

## Project purpose

This repo builds and publishes minimal Docker images for terminal coding agents:
- `codex` (`@openai/codex`)
- `copilot` (`@github/copilot`)
- `claude` (`@anthropic-ai/claude-code`)

All agent images are based on `ghcr.io/rikublock/agent-base:latest`.

## Repository layout

- `base/Dockerfile`: shared Ubuntu + tooling base image.
- `<agent>/Dockerfile`: installs one npm CLI package globally (`codex`, `copilot`, `claude`).
- `.github/workflows/reusable-agent-build.yml`: shared workflow that resolves latest npm version and publishes image tags.
- `.github/workflows/build-*.yml`: scheduled/manual workflow entry points.

## Build and publish behavior

1. Base image (`agent-base`) is built weekly and tagged as:
   - `latest`
   - `YYYY-MM-DD`
2. Agent images are built daily using the reusable workflow:
   - Reads the latest npm version of the configured package.
   - Skips build if that version tag already exists in GHCR.
   - Publishes both `latest` and exact version tags.

## Local development conventions

- Keep Dockerfiles minimal and focused on image concerns only.
- Prefer changing shared tooling in `base/Dockerfile` instead of duplicating in agent Dockerfiles.
- Keep each agent Dockerfile limited to installing its own npm package plus required runtime tweaks.
- Use existing scripts/workflows rather than adding parallel build flows unless necessary.

## Change checklist (for agents)

When updating one agent image:
1. Modify only the relevant `<agent>/Dockerfile` unless shared dependencies are required.
2. Ensure the workflow input (`npm_package`, `dockerfile`, `image_name`) remains aligned.
3. Keep compatibility with both `linux/amd64` and `linux/arm64` builds.

When updating shared base behavior:
1. Make changes in `base/Dockerfile`.
2. Assume all agent images inherit the change.
3. Avoid removing core tooling (`git`, `gh`, `curl`, Node, build essentials) unless explicitly intended.


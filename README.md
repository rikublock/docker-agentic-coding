# Docker Agentic Coding

Minimal Docker images for terminal coding agents:

- `ghcr.io/rikublock/codex` (`@openai/codex`)
- `ghcr.io/rikublock/copilot` (`@github/copilot`)
- `ghcr.io/rikublock/claude` (`@anthropic-ai/claude-code`)

All agent images are built on `ghcr.io/rikublock/agent-base`.

## Repository structure

- `docker/base/Dockerfile`: shared Ubuntu + tooling image (Node.js, Chrome, git, gh, curl, etc.)
- `docker/<agent>/Dockerfile`: installs one agent CLI package plus `chrome-devtools-mcp`
- `.github/workflows/reusable-agent-build.yml`: reusable workflow for agent images
- `.github/workflows/build-*.yml`: scheduled/manual workflow entry points
- `scripts/run-*.sh`: helper scripts to run each image locally

## Image tags

- `agent-base`
  - `latest`
  - `YYYY-MM-DD` (weekly build)
- `codex`, `copilot`, `claude`
  - `latest`
  - `<npm-version>` (for example `0.130.0` for Codex)

## Build automation

- `build-base.yml` runs weekly and publishes `agent-base`.
- `build-codex.yml`, `build-copilot.yml`, and `build-claude.yml` run daily.
- Agent workflows resolve the latest npm version, skip publishing if that version tag already exists, and otherwise publish both `latest` and version tags.

## Pull images

```sh
docker pull ghcr.io/rikublock/codex:latest
docker pull ghcr.io/rikublock/copilot:latest
docker pull ghcr.io/rikublock/claude:latest
```

Version-specific example:

```sh
docker pull ghcr.io/rikublock/codex:0.130.0
```

## Usage

Run interactively with your config directory and current project mounted:

```sh
docker run --rm -it \
  -v ~/.codex:/home/ubuntu/.codex \
  -v $(pwd):/workspace/$(basename $(pwd)) \
  -w /workspace/$(basename $(pwd)) \
  --shm-size=2gb \
  ghcr.io/rikublock/codex:latest
```

Run a single command:

```sh
docker run --rm \
  -v ~/.copilot:/home/ubuntu/.copilot \
  -v $(pwd):/workspace/$(basename $(pwd)) \
  -w /workspace/$(basename $(pwd)) \
  ghcr.io/rikublock/copilot:latest \
  copilot --version
```

Equivalent helper scripts are available under `scripts/`:

- `run-codex.sh`
- `run-copilot.sh`
- `run-claude.sh`

You can link the agent CLI helper scripts into your PATH with:

```sh
ln -s "$PWD/scripts/run-codex.sh" ~/.local/bin/codex
```

## Codex Chrome MCP config

To use Chrome MCP from Codex, keep `--shm-size=2gb` and add this to `~/.codex/config.toml`:

```toml
[mcp_servers.chrome-devtools]
command = "npx"
args = [
  "chrome-devtools-mcp@latest",
  "--isolated=true",
  "--performanceCrux=false",
  "--usageStatistics=false",
  "--chrome-arg='--headless=new'",
  "--chrome-arg='--no-sandbox'",
  "--chrome-arg='--disable-setuid-sandbox'",
  "--logFile=/tmp/mcp-debug.log"
]
```

## Build locally

```sh
git clone https://github.com/rikublock/docker-agentic-coding.git
cd docker-agentic-coding

docker build -t agent-base:latest docker/base/
docker build --build-arg VERSION=0.130.0 -t codex:0.130.0 docker/codex/
```

Use the same pattern for `docker/copilot` and `docker/claude`.

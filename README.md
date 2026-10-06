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

## Host System Restrictions

Some host systems restrict the namespace and mount operations required by Codex's `bubblewrap` sandbox. This is most commonly encountered on Ubuntu and other distributions that restrict unprivileged user namespaces.

Codex may also require additional seccomp permissions for syscalls used by `bubblewrap`.

### AppArmor

Install the Codex AppArmor profile on the **Docker host**:

```sh
curl -fsSL \
  https://raw.githubusercontent.com/openai/codex-security/main/docker/codex-security.apparmor \
  -o codex-security.apparmor

sudo install -m 0644 \
  codex-security.apparmor \
  /etc/apparmor.d/codex-security-container

sudo apparmor_parser -r -W \
  /etc/apparmor.d/codex-security-container
```

The AppArmor profile is loaded by the host kernel and therefore cannot be installed only inside the container.

### Seccomp

Docker's default seccomp profile may block syscalls required by `bubblewrap`, including namespace and mount-related operations.

Use the Codex-specific seccomp profile instead of disabling seccomp entirely:

```sh
curl -fsSL \
  https://raw.githubusercontent.com/openai/codex-security/main/docker/codex-security-seccomp.json \
  -o codex-seccomp.json
```

Then run the Codex container with both profiles enabled:

```sh
docker run --rm -it \
  -v "$HOME/.codex:/home/ubuntu/.codex" \
  -v "$PWD:/workspace/$(basename "$PWD")" \
  -w "/workspace/$(basename "$PWD")" \
  --shm-size=2gb \
  --cap-drop=ALL \
  --security-opt no-new-privileges:true \
  --security-opt seccomp=./codex-seccomp.json \
  --security-opt apparmor=codex-security-container \
  ghcr.io/rikublock/codex:latest
```

Hosts that already permit the namespace and mount operations required by `bubblewrap` may not need the additional AppArmor configuration.

## Configuration 

### Codex

Make changes to the global `~/.codex/config.toml` file.

#### Run without approval prompts

Disabling approval prompts is separate from disabling the sandbox. If you want Codex to work autonomously without giving it unrestricted filesystem access, use:

```toml
approval_policy = "never"
```

#### Secret security

Configure filesystem permissions so that local secret files such as `.env` and `.dev.vars` cannot be read by the agent.

```toml
default_permissions = "workspace-no-secrets"

[permissions.workspace-no-secrets]
extends = ":workspace"

[permissions.workspace-no-secrets.filesystem]
glob_scan_max_depth = 8

[permissions.workspace-no-secrets.filesystem.":workspace_roots"]
"**/.env" = "deny"
"**/.env.*" = "deny"
"**/.dev.vars" = "deny"
"**/.dev.vars.*" = "deny"

[shell_environment_policy]
ignore_default_excludes = false
```

The profile inherits the normal `:workspace` permissions while explicitly denying access to common local secret files. Unlike `.gitignore`, these rules are enforced by the Codex filesystem sandbox and prevent the agent from reading matching files.

The shell environment policy additionally filters inherited environment variables with names containing **KEY**, **SECRET**, or **TOKEN**, reducing the risk of exposing secrets that are already present in the environment.

> [!WARNING]
> **Do not use Codex in YOLO / full-access mode if you rely on these restrictions.**
>
> `--yolo` bypasses both approval prompts and sandboxing. In that mode, assume Codex can access `.env`, `.dev.vars`, and other files available to the process.

#### Chrome MCP

To use Chrome MCP from Codex, make sure the container is started with `--shm-size=2gb`, then add the following configuration:

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

## References

- https://github.com/openai/codex-security/blob/main/docker/

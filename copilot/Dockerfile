FROM ghcr.io/rikublock/agent-base:latest

# Install copilot from npm globally
ARG VERSION
RUN npm install -g \
  @github/copilot@${VERSION} \
  chrome-devtools-mcp@latest \
  && npm cache clean --force

USER ubuntu

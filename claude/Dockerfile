FROM ghcr.io/rikublock/agent-base:latest

# Install claude-code from npm globally
ARG VERSION
RUN npm install -g \
  @anthropic-ai/claude-code@${VERSION} \
  chrome-devtools-mcp@latest \
  && npm cache clean --force

USER ubuntu

FROM ghcr.io/rikublock/agent-base:latest

# Install codex from npm globally
ARG VERSION
RUN npm install -g \
  @openai/codex@${VERSION} \
  chrome-devtools-mcp@latest \
  && npm cache clean --force

# Inside the container we consider the environment already sufficiently locked
# down, therefore instruct Codex CLI to allow running without sandboxing.
ENV CODEX_UNSAFE_ALLOW_NO_SANDBOX=1

# Add chrome codex extension
RUN mkdir -p /usr/share/google-chrome/extensions \
  && echo '{ "external_update_url": "https://clients2.google.com/service/update2/crx" }' \
  > /usr/share/google-chrome/extensions/hehggadaopoacecdllhhajmbjkdcmajg.json

USER ubuntu


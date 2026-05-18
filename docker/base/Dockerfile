FROM ubuntu:24.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install basic development tools
RUN apt-get update && apt-get install -y --no-install-recommends \
  aggregate \
  binutils \
  build-essential \
  bzr \
  ca-certificates \
  curl \
  default-libmysqlclient-dev \
  dnsutils \
  fd-find \
  fzf \
  gettext \
  gh \
  git \
  git-lfs \
  gnupg \
  inotify-tools \
  iproute2 \
  ipset \
  iptables \
  iputils-ping \
  jq \
  less \
  libbz2-dev \
  libc6 \
  libc6-dev \
  libcurl4-openssl-dev \
  libdb-dev \
  libedit2 \
  libffi-dev \
  libgcc-13-dev \
  libgdbm-compat-dev \
  libgdbm-dev \
  libgdiplus \
  libgssapi-krb5-2 \
  liblzma-dev \
  libncurses-dev \
  libnss3-dev \
  libpq-dev \
  libpsl-dev \
  libpython3-dev \
  libreadline-dev \
  libsqlite3-dev \
  libssl-dev \
  libstdc++-13-dev \
  libunwind8 \
  libuuid1 \
  libxml2-dev \
  libz3-dev \
  make \
  man-db \
  moreutils \
  netcat-openbsd \
  openssh-client \
  pkg-config \
  procps \
  protobuf-compiler \
  ripgrep \
  rsync \
  software-properties-common \
  sqlite3 \
  sudo \
  swig3.0 \
  tk-dev \
  tzdata \
  universal-ctags \
  unixodbc-dev \
  unzip \
  uuid-dev \
  wget \
  xz-utils \
  zip \
  zlib1g \
  zlib1g-dev \
  zsh \
  && rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:0.11.14 /uv /uvx /bin/

# Corepack tries to do too much - disable some of its features:
# https://github.com/nodejs/corepack/blob/main/README.md
ENV COREPACK_DEFAULT_TO_LATEST=0
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
ENV COREPACK_ENABLE_AUTO_PIN=0
ENV COREPACK_ENABLE_STRICT=0

# Install Node.js 24
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
  && apt-get install -y nodejs \
  && corepack enable \
  && rm -rf /var/lib/apt/lists/*

# Set up npm global directory with proper permissions
RUN mkdir -p /usr/local/share/npm-global \
  && chmod 755 /usr/local/share/npm-global

# Set npm global config for any user
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# Install Google Chrome
RUN curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list

RUN apt-get update && apt-get install -y --no-install-recommends \
  google-chrome-stable \
  && rm -rf /var/lib/apt/lists/*

# Add existing user to the sudo group and configure passwordless sudo
RUN usermod -aG sudo ubuntu && \
  echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

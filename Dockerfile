# DragoNodes AIO Image
# Maintainer: DragoNodes
# Based on: DanBot Hosting AIO component list

FROM ubuntu:22.04

LABEL maintainer="DragoNodes"
LABEL description="AIO runtime - NodeJS LTS, Java 21, Python 3.11+, Golang, .NET 8, Bun, pm2, yarn, pnpm, nodemon, puppeteer, playwright, ffmpeg, yt-dlp, redis, mariadb-client"

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Jakarta
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# ────────────────────────────────────────────
# 1. Base system & tools
# ────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    curl wget git tar unzip zip \
    ca-certificates gnupg lsb-release \
    build-essential software-properties-common \
    tzdata iproute2 iputils-ping \
    neofetch \
    # Chromium / Puppeteer / Playwright deps
    libgbm1 libnss3 libatk1.0-0 libatk-bridge2.0-0 \
    libcups2 libdrm2 libxkbcommon0 libxcomposite1 \
    libxdamage1 libxfixes3 libxrandr2 libglib2.0-0 \
    libpango-1.0-0 libcairo2 libasound2 libxshmfence1 \
    libx11-xcb1 libxcb-dri3-0 libxcb1 fonts-liberation \
    chromium-browser \
    # FFmpeg
    ffmpeg \
    # MariaDB client
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# ────────────────────────────────────────────
# 2. NodeJS LTS (NodeSource)
# ────────────────────────────────────────────
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Global npm packages
RUN npm install -g pm2 yarn pnpm nodemon \
    && npm install -g puppeteer --unsafe-perm=true \
    && npx playwright install-deps 2>/dev/null || true \
    && npx playwright install chromium 2>/dev/null || true

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# ────────────────────────────────────────────
# 3. Java 21 (OpenJDK)
# ────────────────────────────────────────────
RUN apt-get update && apt-get install -y openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# ────────────────────────────────────────────
# 4. Python 3.11+
# ────────────────────────────────────────────
RUN add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update \
    && apt-get install -y python3.11 python3.11-dev python3.11-venv \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 \
    && rm -rf /var/lib/apt/lists/*

# ────────────────────────────────────────────
# 5. Golang (latest stable)
# ────────────────────────────────────────────
RUN GO_VERSION=$(curl -fsSL https://go.dev/VERSION?m=text | head -1 | sed 's/go//') \
    && wget -q https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && rm go${GO_VERSION}.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/root/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# ────────────────────────────────────────────
# 6. .NET 8 SDK
# ────────────────────────────────────────────
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] \
    https://packages.microsoft.com/repos/microsoft-ubuntu-jammy-prod jammy main" \
    > /etc/apt/sources.list.d/microsoft.list \
    && apt-get update \
    && apt-get install -y dotnet-sdk-8.0 \
    && rm -rf /var/lib/apt/lists/*

# ────────────────────────────────────────────
# 7. Bun
# ────────────────────────────────────────────
RUN BUN_VERSION=$(curl -fsSL https://api.github.com/repos/oven-sh/bun/releases/latest \
    | grep '"tag_name"' | sed 's/.*"bun-v\([^"]*\)".*/\1/') \
    && wget -q https://github.com/oven-sh/bun/releases/latest/download/bun-linux-x64.zip \
    && unzip -q bun-linux-x64.zip \
    && mv bun-linux-x64/bun /usr/local/bin/bun \
    && chmod +x /usr/local/bin/bun \
    && rm -rf bun-linux-x64 bun-linux-x64.zip

# ────────────────────────────────────────────
# 8. YT-DLP
# ────────────────────────────────────────────
RUN curl -fsSL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
    -o /usr/local/bin/yt-dlp \
    && chmod +x /usr/local/bin/yt-dlp

# ────────────────────────────────────────────
# 9. Redis client tools
# ────────────────────────────────────────────
RUN apt-get update && apt-get install -y redis-tools \
    && rm -rf /var/lib/apt/lists/*

# ────────────────────────────────────────────
# Copy startup script
# ────────────────────────────────────────────
COPY start.sh /start.sh
RUN chmod +x /start.sh

WORKDIR /home/container

CMD ["/bin/bash", "/start.sh"]


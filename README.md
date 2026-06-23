# DragoNodes AIO

Docker image AIO untuk Pterodactyl Panel.

## Runtime yang tersedia
- NodeJS LTS + npm, npx, yarn, pnpm, pm2, nodemon
- Python 3.11+
- Java OpenJDK 21
- Golang (latest)
- .NET 8 SDK
- Bun

## Tools
- FFmpeg + FFprobe
- YT-DLP
- Chromium (headless)
- Puppeteer + Playwright deps
- Redis CLI
- MariaDB Client
- Git, curl, neofetch, dll

## Docker Hub
```
dragonodes/aio
```

## Penggunaan di Pterodactyl
Import `egg-dragonodes-aio.json` ke panel, lalu set:
- **Startup Command**: perintah yang mau dijalankan (contoh: `node index.js`)
- **Pesan Startup**: pesan custom yang tampil di console sebelum server jalan
- 

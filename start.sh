#!/bin/bash

# ── Colors ──────────────────────────────────
RED='\033[0;31m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
GRAY='\033[0;90m'
RESET='\033[0m'

# ── Terminal width ───────────────────────────
COLS=$(tput cols 2>/dev/null || echo 70)

# ── Full separator line ───────────────────────
sep() {
    local label="$1"
    if [ -z "$label" ]; then
        printf "${CYAN}%${COLS}s${RESET}\n" | tr ' ' '─'
    else
        local len=${#label}
        local total=$(( (COLS - len - 2) ))
        local left=$(( total / 2 ))
        local right=$(( total - left ))
        printf "${CYAN}%${left}s${RESET}" | tr ' ' '─'
        printf "${CYAN} ${WHITE}${label}${CYAN} ${RESET}"
        printf "${CYAN}%${right}s${RESET}\n" | tr ' ' '─'
    fi
}

# ── Progress bar ─────────────────────────────
bar() {
    local used=$1 total=$2
    local width=30 pct=0
    [ "$total" -gt 0 ] && pct=$((used * 100 / total))
    local filled=$((pct * width / 100))
    local empty=$((width - filled))
    local b=""
    for ((i=0; i<filled; i++)); do b+="█"; done
    for ((i=0; i<empty; i++)); do b+="░"; done
    printf "${GREEN}%s${RESET}${WHITE}%s%%${RESET}" "$b" "$pct"
}

clear

# ── ASCII Art ────────────────────────────────
echo -e "${RED}"
echo '▀▄▀ █ ▄▀█ █▀█ █▀▀ █ ▄▀█'
echo '█░█ █ █▀█ █▄█ █▄▄ █ █▀█'
echo ''
echo '█▀▀ █░░ █ █▀▀ █▄░█ ▀█▀'
echo '█▄▄ █▄▄ █ ██▄ █░▀█ ░█░'
echo -e "${RESET}"
printf "%*s\n" $(( (COLS + 36) / 2 )) "${WHITE}Powered By DragoNodes © $(date +%Y)${RESET}"
echo ""

# ── System Info ──────────────────────────────
sep "SYSTEM INFO"
echo ""

ISP=$(curl -s --max-time 3 https://ipinfo.io/org 2>/dev/null | sed 's/AS[0-9]* //' || echo "Tidak diketahui")
IPV4=$(curl -s --max-time 3 https://ipinfo.io/ip 2>/dev/null || echo "Tidak diketahui")
COUNTRY=$(curl -s --max-time 3 https://ipinfo.io/country 2>/dev/null || echo "??")
KERNEL=$(uname -r)
UPTIME=$(uptime -p 2>/dev/null | sed 's/up //' || echo "Tidak diketahui")

printf " ${CYAN}c-${RESET} %-14s : ${YELLOW}%s${RESET}\n" "ISP" "$ISP"
printf " ${CYAN}c-${RESET} %-14s : ${YELLOW}%s ${GRAY}(Public IP)${RESET}\n" "IPv4" "$IPV4"
printf " ${CYAN}c-${RESET} %-14s : ${YELLOW}%s${RESET}\n" "Negara" "$COUNTRY"
printf " ${CYAN}c-${RESET} %-14s : ${YELLOW}%s${RESET}\n" "OS/Kern" "$KERNEL"
printf " ${CYAN}c-${RESET} %-14s : ${GREEN}%s${RESET}\n" "Uptime" "$UPTIME"
echo ""

# ── Runtime Versions ─────────────────────────
sep "RUNTIME VERSIONS"
echo ""

NODE_VER=$(node -v 2>/dev/null | sed 's/v//' || echo "N/A")
PYTHON_VER=$(python3 --version 2>/dev/null | awk '{print $2}' || echo "N/A")
JAVA_VER=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' || echo "N/A")
GO_VER=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//' || echo "N/A")
DOTNET_VER=$(dotnet --version 2>/dev/null || echo "N/A")
BUN_VER=$(bun -v 2>/dev/null || echo "N/A")

printf " ${CYAN}c-${RESET} %-14s : ${CYAN}%s${RESET}\n" "NodeJS Ver" "$NODE_VER"
printf " ${CYAN}c-${RESET} %-14s : ${CYAN}%s${RESET}\n" "Python Ver" "$PYTHON_VER"
printf " ${CYAN}c-${RESET} %-14s : ${CYAN}%s${RESET}\n" "Java Ver" "$JAVA_VER"
printf " ${CYAN}c-${RESET} %-14s : ${CYAN}%s${RESET}\n" "Golang Ver" "$GO_VER"
printf " ${CYAN}c-${RESET} %-14s : ${CYAN}%s${RESET}\n" ".NET Ver" "$DOTNET_VER"
printf " ${CYAN}c-${RESET} %-14s : ${CYAN}%s${RESET}\n" "Bun Ver" "$BUN_VER"
echo ""

# ── Resource Usage ───────────────────────────
sep "SERVER USAGE"
echo ""

CPU_CORES=$(nproc)
CPU_ARCH=$(uname -m)
MEM_TOTAL=$(free -m | awk '/^Mem:/ {print $2}')
MEM_USED=$(free -m | awk '/^Mem:/ {print $3}')
MEM_TOTAL_G=$(free -g | awk '/^Mem:/ {print $2}')
MEM_USED_G=$(free -g | awk '/^Mem:/ {print $3}')
DISK_TOTAL=$(df -m / | awk 'NR==2 {print $2}')
DISK_USED=$(df -m / | awk 'NR==2 {print $3}')
DISK_TOTAL_G=$(( DISK_TOTAL / 1024 ))
DISK_USED_G=$(( DISK_USED / 1024 ))

printf " ${CYAN}c-${RESET} %-14s : ${CYAN}%s [%s]${RESET}\n" "CPU Cores" "$CPU_CORES Core(s)" "$CPU_ARCH"
printf " ${CYAN}c-${RESET} %-14s : " "Memory"
printf "$(bar $MEM_USED $MEM_TOTAL) ${GRAY}(%sG / %sG)${RESET}\n" "$MEM_USED_G" "$MEM_TOTAL_G"
printf " ${CYAN}c-${RESET} %-14s : " "Disk Space"
printf "$(bar $DISK_USED $DISK_TOTAL) ${GRAY}(%sG / %sG)${RESET}\n" "$DISK_USED_G" "$DISK_TOTAL_G"
printf " ${CYAN}c-${RESET} %-14s : ${GREEN}%s${RESET}\n" "Server Time" "$(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# ── Packages ─────────────────────────────────
sep "PACKAGES"
echo ""
printf "%*s\n" $(( (COLS + 52) / 2 )) "${WHITE}BUN, PYTHON, NODEJS, FFMPEG, GOLANG, JAVA, .NET${RESET}"
printf "%*s\n" $(( (COLS + 46) / 2 )) "${WHITE}PM2, YARN, PNPM, NODEMON, PUPPETEER, YT-DLP${RESET}"
printf "%*s\n" $(( (COLS + 36) / 2 )) "${WHITE}PLAYWRIGHT, REDIS-CLI, MARIADB-CLIENT${RESET}"
echo ""

sep ""
echo ""

# ── Startup message ───────────────────────────
MSG="${STARTUP_MSG:-DragoNodes Client Siap. Menjalankan perintah startup...}"
echo -e "${GREEN}${MSG}${RESET}"
echo ""

# ── Run ───────────────────────────────────────
exec ${STARTUP_CMD:-bash}

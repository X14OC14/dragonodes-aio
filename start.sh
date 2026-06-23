#!/bin/bash

# ── Colors ──────────────────────────────────
RED='\033[0;31m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── Progress bar ─────────────────────────────
bar() {
    local used=$1 total=$2 width=20 pct=0
    [ "$total" -gt 0 ] && pct=$((used * 100 / total))
    local filled=$((pct * width / 100))
    local empty=$((width - filled))
    local b=""
    for ((i=0; i<filled; i++)); do b+="█"; done
    for ((i=0; i<empty; i++)); do b+="░"; done
    printf "${RED}%s${RESET} ${WHITE}%s%%${RESET}" "$b" "$pct"
}

clear

# ── ASCII Banner ─────────────────────────────
echo -e "${RED}"
echo '█░░ █▀█ █░░   █▀▀ █░░ █ █▀▀ █▄░█ ▀█▀'
echo '█▄▄ █▄█ █▄▄   █▄▄ █▄▄ █ ██▄ █░▀█ ░█░'
echo -e "${RESET}"
echo -e "${DIM}${WHITE}        Powered By DragoNodes © $(date +%Y)${RESET}"
echo ""

SEP="${CYAN}$(printf '%.0s─' {1..50})${RESET}"

# ── System Info ──────────────────────────────
echo -e "$SEP"
echo -e "${WHITE}                 [ SYSTEM INFO ]${RESET}"
echo -e "$SEP"

ISP=$(curl -s --max-time 3 https://ipinfo.io/org 2>/dev/null | sed 's/AS[0-9]* //' || echo "Tidak diketahui")
IPV4=$(curl -s --max-time 3 https://ipinfo.io/ip 2>/dev/null || echo "Tidak diketahui")
COUNTRY=$(curl -s --max-time 3 https://ipinfo.io/country 2>/dev/null || echo "??")
KERNEL=$(uname -r)
UPTIME=$(uptime -p 2>/dev/null | sed 's/up //' || echo "Tidak diketahui")

echo -e " ${CYAN}ISP${RESET}          : ${WHITE}${ISP}${RESET}"
echo -e " ${CYAN}IPv4${RESET}         : ${WHITE}${IPV4}${DIM} (Public IP)${RESET}"
echo -e " ${CYAN}Negara${RESET}       : ${WHITE}${COUNTRY}${RESET}"
echo -e " ${CYAN}Kernel${RESET}       : ${WHITE}${KERNEL}${RESET}"
echo -e " ${CYAN}Uptime${RESET}       : ${RED}${UPTIME}${RESET}"
echo ""

# ── Runtime Versions ─────────────────────────
echo -e "$SEP"
echo -e "${WHITE}              [ RUNTIME VERSIONS ]${RESET}"
echo -e "$SEP"

NODE_VER=$(node -v 2>/dev/null | sed 's/v//' || echo "N/A")
PYTHON_VER=$(python3 --version 2>/dev/null | awk '{print $2}' || echo "N/A")
JAVA_VER=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' || echo "N/A")
GO_VER=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//' || echo "N/A")
DOTNET_VER=$(dotnet --version 2>/dev/null || echo "N/A")
BUN_VER=$(bun -v 2>/dev/null || echo "N/A")

echo -e " ${CYAN}NodeJS${RESET}       : ${RED}${NODE_VER}${RESET}"
echo -e " ${CYAN}Python${RESET}       : ${RED}${PYTHON_VER}${RESET}"
echo -e " ${CYAN}Java${RESET}         : ${RED}${JAVA_VER}${RESET}"
echo -e " ${CYAN}Golang${RESET}       : ${RED}${GO_VER}${RESET}"
echo -e " ${CYAN}.NET${RESET}         : ${RED}${DOTNET_VER}${RESET}"
echo -e " ${CYAN}Bun${RESET}          : ${RED}${BUN_VER}${RESET}"
echo ""

# ── Resource Usage ───────────────────────────
echo -e "$SEP"
echo -e "${WHITE}              [ RESOURCE USAGE ]${RESET}"
echo -e "$SEP"

CPU_CORES=$(nproc)
CPU_ARCH=$(uname -m)
MEM_TOTAL=$(free -m | awk '/^Mem:/ {print $2}')
MEM_USED=$(free -m | awk '/^Mem:/ {print $3}')
DISK_TOTAL=$(df -m / | awk 'NR==2 {print $2}')
DISK_USED=$(df -m / | awk 'NR==2 {print $3}')

echo -e " ${CYAN}CPU${RESET}          : ${WHITE}${CPU_CORES} Core(s) [${CPU_ARCH}]${RESET}"
printf " ${CYAN}Memory${RESET}       : $(bar $MEM_USED $MEM_TOTAL) ${DIM}(${MEM_USED}MB / ${MEM_TOTAL}MB)${RESET}\n"
printf " ${CYAN}Disk${RESET}         : $(bar $DISK_USED $DISK_TOTAL) ${DIM}(${DISK_USED}MB / ${DISK_TOTAL}MB)${RESET}\n"
echo -e " ${CYAN}Waktu Server${RESET} : ${WHITE}$(date '+%Y-%m-%d %H:%M:%S')${RESET}"
echo ""

# ── Packages ─────────────────────────────────
echo -e "$SEP"
echo -e "${WHITE}                 [ PACKAGES ]${RESET}"
echo -e "$SEP"
echo -e " ${WHITE}BUN, PYTHON, NODEJS, GOLANG, JAVA, .NET, FFMPEG${RESET}"
echo -e " ${WHITE}PM2, YARN, PNPM, NODEMON, PUPPETEER, PLAYWRIGHT${RESET}"
echo -e " ${WHITE}YT-DLP, REDIS-CLI, MARIADB-CLIENT, CHROMIUM${RESET}"
echo ""
echo -e "$SEP"
echo ""

# ── Startup message ───────────────────────────
MSG="${STARTUP_MSG:-DragoNodes Client Siap. Menjalankan perintah startup...}"
echo -e "${RED}${MSG}${RESET}"
echo ""

# ── Run ───────────────────────────────────────
exec ${STARTUP_CMD:-bash}


#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  DragoNodes - Pterodactyl Egg AIO
#  Author: DragoNodes
# ═══════════════════════════════════════════════════════════════

# Color Definitions
declare -A COLORS=(
    [RESET]="\033[0m"
    [BOLD]="\033[1m"
    [DIM]="\033[2m"
    [BLACK]="\033[30m"
    [RED]="\033[31m"
    [GREEN]="\033[32m"
    [YELLOW]="\033[33m"
    [BLUE]="\033[34m"
    [MAGENTA]="\033[35m"
    [CYAN]="\033[36m"
    [WHITE]="\033[37m"
    [BRED]="\033[91m"
    [BGREEN]="\033[92m"
    [BYELLOW]="\033[93m"
    [BBLUE]="\033[94m"
    [BMAGENTA]="\033[95m"
    [BCYAN]="\033[96m"
    [BWHITE]="\033[97m"
    [BG_BLACK]="\033[40m"
    [BG_WHITE]="\033[47m"
)
export HOME="/home/container"

# Emoji/Icons
ICON_SERVER="🖥️ "
ICON_DOCKER="🐳"
ICON_SHELL="💻"
ICON_NODE="⬢ "
ICON_LOCATION="📍"
ICON_NETWORK="🌐"
ICON_TIME="⏱️ "
ICON_RAM="🧠"
ICON_DISK="💾"
ICON_CPU="⚡"
ICON_GPU="🎮"
ICON_ARCH="🏗️ "
ICON_KERNEL="🔧"
ICON_LINK="🔗"

# ═══════════════════════════════════════════════════════════════
#  UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════
get_terminal_width() {
    tput cols 2>/dev/null || echo 80
}

calc_size() {
    local raw=$1
    local total_size=0
    local num=1
    local unit="KB"
    [[ ! ${raw} =~ ^[0-9]+$ ]] && echo "" && return
    if [ "${raw}" -ge 1073741824 ]; then
        num=1073741824; unit="TB"
    elif [ "${raw}" -ge 1048576 ]; then
        num=1048576; unit="GB"
    elif [ "${raw}" -ge 1024 ]; then
        num=1024; unit="MB"
    elif [ "${raw}" -eq 0 ]; then
        echo "${total_size}"; return
    fi
    total_size=$(awk 'BEGIN{printf "%.1f", '"$raw"' / '$num'}')
    echo "${total_size} ${unit}"
}

to_kibyte() {
    awk 'BEGIN{printf "%.0f", '"$1"' / 1024}'
}

calc_sum() {
    local s=0
    for i in "$@"; do s=$((s + i)); done
    echo ${s}
}

_exists() {
    command -v "$1" &>/dev/null
}

get_opsy() {
    if [ -f /etc/os-release ]; then
        awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release
    elif [ -f /etc/redhat-release ]; then
        awk '{print $0}' /etc/redhat-release
    elif [ -f /etc/lsb-release ]; then
        awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release
    fi
}

get_uptime() {
    local uptime_s=$(uptime -s)
    local now=$(date +%s)
    local start=$(date -d "$uptime_s" +%s)
    local diff=$((now - start))
    local days=$((diff / 86400))
    local hours=$(( (diff % 86400) / 3600 ))
    local minutes=$(( (diff % 3600) / 60 ))
    echo "${days}d ${hours}h ${minutes}m"
}

convert_size() {
    local size_kb=$1
    local size_mb=$((size_kb / 1024))
    local size_gb=$((size_mb / 1024))
    if (( size_gb > 0 )); then
        echo "${size_gb} GB"
    elif (( size_mb > 0 )); then
        echo "${size_mb} MB"
    else
        echo "${size_kb} KB"
    fi
}

# ═══════════════════════════════════════════════════════════════
#  SYSTEM INFORMATION GATHERING
# ═══════════════════════════════════════════════════════════════
gather_system_info() {
    OPSY=$(get_opsy)
    ARCH=$(uname -m)
    KERN=$(uname -r)

    CPU_NAME=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^[[:space:]]*//; s/ @.*//')
    CORES=$(awk '/^processor/ { core++ } END { print core+0 }' /proc/cpuinfo)
    FREQ=$(awk -F': ' '/^cpu MHz/ { print $2; exit }' /proc/cpuinfo)
    if [ -n "$FREQ" ]; then
        CPU_COUNT="$CORES cores @ ${FREQ%.*} MHz"
    else
        CPU_COUNT="$CORES cores"
    fi

    if _exists lspci; then
        GPU_NAME=$(lspci | grep -Ei 'vga|3d|display' | cut -d: -f2- | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | head -n1)
        [ -z "$GPU_NAME" ] && GPU_NAME="Not detected"
    else
        GPU_NAME="Not available"
    fi

    if _exists getconf; then
        LBIT=$(getconf LONG_BIT)
    else
        case "$ARCH" in
            *64*) LBIT=64 ;;
            *)    LBIT=32 ;;
        esac
    fi

    TRAM_KB=$(awk '/^MemTotal:/ { print $2 }' /proc/meminfo)
    AVAILABLE_RAM_KB=$(awk '/^MemAvailable:/ { print $2 }' /proc/meminfo)
    USED_RAM_KB=$((TRAM_KB - AVAILABLE_RAM_KB))
    TRAM_GB=$(echo "scale=2; $TRAM_KB / 1024 / 1024" | bc)
    USED_RAM_GB=$(echo "scale=2; $USED_RAM_KB / 1024 / 1024" | bc)
    AVAILABLE_RAM_GB=$(echo "scale=2; $AVAILABLE_RAM_KB / 1024 / 1024" | bc)
    TRAM=$(calc_size "$TRAM_KB")
    URAM=$(calc_size "$USED_RAM_KB")

    IN_KERNEL_TOTAL_KB=$(df -t simfs -t ext2 -t ext3 -t ext4 -t btrfs -t xfs -t vfat -t ntfs --total 2>/dev/null | awk 'END { print $2 }')
    [ -z "$IN_KERNEL_TOTAL_KB" ] && IN_KERNEL_TOTAL_KB=0
    DISK_TOTAL=$(calc_size $((IN_KERNEL_TOTAL_KB)))

    IN_KERNEL_USED_KB=$(df -t simfs -t ext2 -t ext3 -t ext4 -t btrfs -t xfs -t vfat -t ntfs --total 2>/dev/null | awk 'END { print $3 }')
    [ -z "$IN_KERNEL_USED_KB" ] && IN_KERNEL_USED_KB=0
    DISK_USED=$(calc_size $((IN_KERNEL_USED_KB)))

    FREE_DISK_KB=$(df --output=avail / 2>/dev/null | tail -n1)
    [ -z "$FREE_DISK_KB" ] && FREE_DISK_KB=0
    CONVERTED_DISK=$(convert_size "$FREE_DISK_KB")

    JSON_RESPONSE=$(curl -s --max-time 3 "http://ip-api.com/json/")
    if [ -n "$JSON_RESPONSE" ] && echo "$JSON_RESPONSE" | jq -e .query >/dev/null 2>&1; then
        IP=$(echo "$JSON_RESPONSE" | jq -r '.query')
        CITY=$(echo "$JSON_RESPONSE" | jq -r '.city // "Unknown"')
        REGION=$(echo "$JSON_RESPONSE" | jq -r '.region // "Unknown"')
        COUNTRY_CODE=$(echo "$JSON_RESPONSE" | jq -r '.countryCode // "Unknown"')
        COUNTRY=$(echo "$JSON_RESPONSE" | jq -r '.country // "Unknown"')
        ISP=$(echo "$JSON_RESPONSE" | jq -r '.isp // "Unknown"')
    else
        IP="N/A"; CITY="N/A"; REGION="N/A"
        COUNTRY_CODE="N/A"; COUNTRY="N/A"; ISP="N/A"
    fi

    # Runtime versions
    NODE_VER=$(node -v 2>/dev/null || echo "N/A")
    PYTHON_VER=$(python3 --version 2>/dev/null | awk '{print $2}' || echo "N/A")
    JAVA_VER=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' || echo "N/A")
    GO_VER=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//' || echo "N/A")
    DOTNET_VER=$(dotnet --version 2>/dev/null || echo "N/A")
    BUN_VER=$(bun -v 2>/dev/null || echo "N/A")

    CURRENT_DATETIME=$(TZ="Asia/Jakarta" date +"%Y-%m-%d %H:%M:%S")
    YEAR=$(date +'%Y')
    UPTIME=$(get_uptime)
}

# ═══════════════════════════════════════════════════════════════
#  DISPLAY FUNCTIONS
# ═══════════════════════════════════════════════════════════════
print_gradient_line() {
    local width=$(get_terminal_width)
    local colors=("${COLORS[BRED]}" "${COLORS[BYELLOW]}" "${COLORS[BGREEN]}" "${COLORS[BCYAN]}" "${COLORS[BBLUE]}" "${COLORS[BMAGENTA]}")
    local num_colors=${#colors[@]}
    local segment_size=$((width / num_colors))
    for i in $(seq 0 $((num_colors - 1))); do
        echo -n -e "${colors[$i]}"
        printf '═%.0s' $(seq 1 $segment_size)
    done
    echo -e "${COLORS[RESET]}"
}

print_section_header() {
    local title="$1"
    local icon="$2"
    echo -e "${COLORS[BCYAN]}${COLORS[BOLD]}│${COLORS[RESET]} ${icon} ${COLORS[BWHITE]}${COLORS[BOLD]}${title}${COLORS[RESET]}"
}

print_info_line() {
    local label="$1"
    local value="$2"
    printf "${COLORS[DIM]} »${COLORS[RESET]} ${COLORS[YELLOW]}%-14s${COLORS[RESET]} ${COLORS[CYAN]}→${COLORS[RESET]} ${COLORS[WHITE]}%b${COLORS[RESET]}\n" "$label" "$value"
}

print_system_info() {
    echo " "
    print_section_header "SERVER INFORMATION" "${ICON_SERVER}"
    print_info_line "OS" "$OPSY"
    print_info_line "Shell" "DragoNodes AIO" "${ICON_SHELL}"
    print_info_line "Node.js" "$NODE_VER" "${ICON_NODE}"
    print_info_line "Python" "$PYTHON_VER"
    print_info_line "Java" "$JAVA_VER"
    print_info_line "Golang" "$GO_VER"
    print_info_line ".NET" "$DOTNET_VER"
    print_info_line "Bun" "$BUN_VER"
    print_info_line "Location" "$COUNTRY ($COUNTRY_CODE)" "${ICON_LOCATION}"
    print_info_line "ISP" "$ISP" "${ICON_NETWORK}"
    print_info_line "Uptime" "$UPTIME" "${ICON_TIME}"
    print_info_line "Time" "$CURRENT_DATETIME"
}

print_hardware_info() {
    echo " "
    print_section_header "HARDWARE SPECIFICATIONS" "⚙️ "
    print_info_line "RAM" \
    "${COLORS[BGREEN]}${TRAM}${COLORS[RESET]} ${COLORS[DIM]}(${URAM} used / ${AVAILABLE_RAM_GB} GB free)${COLORS[RESET]}" \
    "${ICON_RAM}"
    print_info_line "Disk (/)" "${COLORS[BGREEN]}$DISK_TOTAL${COLORS[RESET]} ${COLORS[DIM]}($DISK_USED used / $CONVERTED_DISK free)${COLORS[RESET]}" "${ICON_DISK}"
    print_info_line "CPU" "$CPU_NAME" "${ICON_CPU}"
    print_info_line "Cores" "$CPU_COUNT" "🔥"
    print_info_line "Architecture" "$ARCH ($LBIT Bit)" "${ICON_ARCH}"
    print_info_line "Kernel" "$KERN" "${ICON_KERNEL}"
}

print_footer() {
    echo " "
    echo -e " ${COLORS[GREEN]}✓${COLORS[RESET]} DragoNodes AIO Siap!"
    echo -e " ${COLORS[DIM]}──────────────────────────────${COLORS[RESET]}"
}

# ═══════════════════════════════════════════════════════════════
#  CUSTOM SHELL
# ═══════════════════════════════════════════════════════════════
run_prompt() {
    local user="app"
    local hostname="dragonodes"
    local cwd
    cwd=$(pwd)

    local S=$'\001'
    local E=$'\002'
    _expand_color() {
        local raw="$1"
        printf '%b' "$raw"
    }

    local c_bold c_bcyan c_reset c_bred c_bblue c_bgreen c_byellow
    c_bold=$(_expand_color "${COLORS[BOLD]:-}")
    c_bcyan=$(_expand_color "${COLORS[BCYAN]:-}")
    c_reset=$(_expand_color "${COLORS[RESET]:-}")
    c_bred=$(_expand_color "${COLORS[BRED]:-}")
    c_bblue=$(_expand_color "${COLORS[BBLUE]:-}")
    c_bgreen=$(_expand_color "${COLORS[BGREEN]:-}")
    c_byellow=$(_expand_color "${COLORS[BYELLOW]:-}")

    local prompt=""
    prompt+="${S}${c_bold}${c_bcyan}${E}${user}"
    prompt+="${S}${c_reset}${E}@"
    prompt+="${S}${c_byellow}${E}${hostname}"
    prompt+="${S}${c_reset}${E}:"
    prompt+="${S}${c_bblue}${E}${cwd}"
    prompt+="${S}${c_reset}${E} "
    prompt+="${S}${c_bgreen}${E}#${S}${c_reset}${E} "

    printf '%s' "$prompt"
}

run_shell() {
    local cmd line prompt
    local histfile="$HOME/.bash_history"

    touch "$histfile" 2>/dev/null || true
    HISTFILE="$histfile"
    HISTSIZE=5000
    HISTFILESIZE=5000
    history -r 2>/dev/null || true

    while true; do
        prompt="$(run_prompt)"
        IFS= read -re -p "$prompt" line || break
        cmd="$(echo "$line" | awk '{$1=$1;print}')"
        [ -z "$cmd" ] && continue
        echo "$cmd" >> "$histfile" 2>/dev/null || true
        case "$cmd" in
            exit|quit) break ;;
            clear|cls) clear; continue ;;
            *)
                read -r -a args <<<"$cmd"
                run_command "${args[@]}"
                ;;
        esac
    done

    history -a 2>/dev/null || true
}

run_command() {
    local cmd="$1"
    shift
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${COLORS[BRED]}✗ Command '${cmd}' not found${COLORS[RESET]}"
        return 127
    fi
    "$cmd" "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo -e "${COLORS[BRED]}⚠ Command '${cmd}' exited with code ${status}${COLORS[RESET]}"
    fi
    return $status
}

# ═══════════════════════════════════════════════════════════════
#  MAIN
# ═══════════════════════════════════════════════════════════════
main() {
    clear

    # ASCII Banner
    echo -e "${COLORS[BRED]}"
    echo '█▀▄ █▀█ ▄▀█ █▀▀ █▀█ █▄░█ █▀█ █▀▄ █▀▀ █▀'
    echo '█▄▀ █▀▄ █▀█ █▄█ █▄█ █░▀█ █▄█ █▄▀ ██▄ ▄█'
    echo -e "${COLORS[RESET]}"
    echo -e "       ${COLORS[WHITE]}Powered By XIAOCIA.MY.ID © $(date +%Y)${COLORS[RESET]}"

    print_gradient_line
    gather_system_info
    print_system_info
    print_hardware_info
    print_footer

    echo " "
    MSG="${STARTUP_MSG:-DragoNodes Client Siap. Menjalankan perintah startup...}"
    echo -e " ${COLORS[GREEN]}✓${COLORS[RESET]} ${COLORS[CYAN]}${MSG}${COLORS[RESET]}"
    echo " "

    if [ -n "$STARTUP_CMD" ]; then
        exec eval "$STARTUP_CMD"
    else
        echo -e " ${COLORS[CYAN]}⚙${COLORS[RESET]} Tidak ada command. Masuk ke shell interaktif."
        echo ""
        run_shell
    fi
}

main "$@"

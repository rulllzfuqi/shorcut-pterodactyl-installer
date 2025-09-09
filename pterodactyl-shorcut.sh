#!/usr/bin/env bash
set -euo pipefail

readonly COL_NC='\e[0m'
readonly COL_LIGHT_GREEN='\e[1;32m'
readonly COL_LIGHT_RED='\e[1;31m'
readonly COL_LIGHT_CYAN='\e[1;36m'

print_status() {
    echo -e "${COL_LIGHT_CYAN}[*]${COL_NC} $1"
}

print_success() {
    echo -e "${COL_LIGHT_GREEN}[+]${COL_NC} $1"
}

print_error() {
    echo -e "${COL_LIGHT_RED}[!]${COL_NC} $1"
}

animate_text() {
    local text="$1"
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep 0.01
    done
}

cleanup() {
    tput cnorm
}
trap cleanup EXIT INT TERM

tput civis

echo -ne "${COL_LIGHT_CYAN}"
animate_text "=== PTERODACTYL AUTO INSTALLER (NON-EXPECT) ==="
echo -e "${COL_NC}\n"

if [[ $EUID -ne 0 ]]; then
    print_error "Skrip ini harus dijalankan sebagai root"
    exit 1
fi

ARG_DOMAIN="${1:-}"
valid_domain_regex='^([a-zA-Z0-9][-a-zA-Z0-9]{0,62}\.)+[a-zA-Z]{2,}$'

get_domain() {
    local domain_input
    while true; do
        read -rp "$(echo -e "${COL_LIGHT_GREEN}Masukkan domain panel (tanpa https://): ${COL_NC}")" domain_input
        if [[ $domain_input =~ $valid_domain_regex ]]; then
            echo "$domain_input"
            break
        else
            print_error "Domain tidak valid. Coba lagi."
        fi
    done
}

domain="${ARG_DOMAIN:-$(get_domain)}"

TIMESTAMP=$(date +%Y%m%d%H%M%S)
LOGFILE="/tmp/ptero_install_${TIMESTAMP}.log"
touch "$LOGFILE"

detect_pkg_manager() {
    if command -v apt-get &>/dev/null; then
        echo "apt"
    elif command -v yum &>/dev/null; then
        echo "yum"
    else
        print_error "Tidak dapat mendeteksi package manager"
        exit 1
    fi
}

ensure_curl() {
    if ! command -v curl &>/dev/null; then
        print_status "Menginstal curl..."
        local pkg_manager=$(detect_pkg_manager)
        case $pkg_manager in
            "apt") apt-get update -y && apt-get install -y curl ;;
            "yum") yum install -y curl ;;
        esac
    fi
}

ensure_curl

DL="curl -fsSL"

print_status "Memulai proses instalasi — log disimpan di: $LOGFILE"

{
echo "0"
echo "admin"
echo "FuqiHost123"
echo "Asia/Jakarta"
echo "admin@${domain}"
echo "admin@${domain}"
echo "admin"
echo "admin"
echo "admin"
echo "FuqiHost123"
echo "$domain"
echo "y"
echo "y"
echo "1"
echo "y"
echo "y"
echo "y"
echo "y"
echo "y"
echo "A"
} | bash <($DL https://pterodactyl-installer.se) 2>&1 | tee -a "$LOGFILE"

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    print_success "Instalasi berhasil diselesaikan"
    print_status "Log lengkap: $LOGFILE"
else
    print_error "Instalasi gagal. Periksa log: $LOGFILE"
    exit 1
fi

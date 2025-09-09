#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

readonly COL_NC='\e[0m'
readonly COL_GOOD='\e[1;32m'
readonly COL_WARN='\e[1;33m'
readonly COL_BAD='\e[1;31m'
readonly COL_INFO='\e[1;36m'

print() { echo -e "${COL_INFO}[*]${COL_NC} $1"; }
ok()    { echo -e "${COL_GOOD}[+]${COL_NC} $1"; }
warn()  { echo -e "${COL_WARN}[~]${COL_NC} $1"; }
err()   { echo -e "${COL_BAD}[!]${COL_NC} $1"; }

cleanup() { 
    tput cnorm 
    exit 0
}
trap cleanup EXIT INT TERM

tput civis

readonly DEFAULT_DAEMON_PORT=8080
readonly DEFAULT_SFTP_PORT=2022
readonly DEFAULT_RAM=2048
readonly DEFAULT_DISK=10240
readonly DEFAULT_PANEL_DIR="/var/www/pterodactyl"

show_usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --domain DOMAIN           FQDN node (example: node.example.com)
  --location-name NAME      Nama lokasi
  --location-desc DESC      Deskripsi lokasi
  --node-name NAME          Nama node
  --locid ID                Lokasi ID (angka)
  --ram MB                  RAM per server default (MB)
  --disk MB                 Disk per server default (MB)
  --daemon-port PORT        Daemon port (default: ${DEFAULT_DAEMON_PORT})
  --sftp-port PORT          SFTP port (default: ${DEFAULT_SFTP_PORT})
  --panel-dir DIR           Direktori panel (default: ${DEFAULT_PANEL_DIR})
  -h, --help                Tampilkan bantuan ini

Contoh:
  sudo $(basename "$0") --domain node.example.com --location-name "SG" --locid 1 --node-name "node-sg"
EOF
}

validate_domain() {
    local domain_regex='^([a-zA-Z0-9][-a-zA-Z0-9]{0,62}\.)+[a-zA-Z]{2,}$'
    [[ "$1" =~ $domain_regex ]]
}

validate_number() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

validate_port() {
    validate_number "$1" && (( "$1" > 0 && "$1" < 65536 ))
}

prompt_with_validation() {
    local varname="$1"
    local prompt="$2"
    local default="${3:-}"
    local validation_func="${4:-}"
    local error_msg="${5:-}"
    
    local input=""
    local valid=false
    
    while [[ "$valid" == false ]]; do
        if [[ -n "$default" ]]; then
            read -rp "$(echo -e "${COL_INFO}${prompt} [${default}]: ${COL_NC}")" input
            input="${input:-$default}"
        else
            read -rp "$(echo -e "${COL_INFO}${prompt}: ${COL_NC}")" input
        fi
        
        if [[ -z "$validation_func" ]] || $validation_func "$input"; then
            valid=true
        else
            err "${error_msg:-"Input tidak valid"}"
        fi
    done
    
    eval "$varname=\"\$input\""
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --domain)
                DOMAIN="$2"
                shift 2
                ;;
            --location-name)
                LOCATION_NAME="$2"
                shift 2
                ;;
            --location-desc)
                LOCATION_DESC="$2"
                shift 2
                ;;
            --node-name)
                NODE_NAME="$2"
                shift 2
                ;;
            --locid)
                LOCID="$2"
                shift 2
                ;;
            --ram)
                RAM="$2"
                shift 2
                ;;
            --disk)
                DISK="$2"
                shift 2
                ;;
            --daemon-port)
                DAEMON_PORT="$2"
                shift 2
                ;;
            --sftp-port)
                SFTP_PORT="$2"
                shift 2
                ;;
            --panel-dir)
                PANEL_DIR="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                err "Option tidak dikenali: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

init_variables() {
    DOMAIN="${DOMAIN:-}"
    LOCATION_NAME="${LOCATION_NAME:-}"
    LOCATION_DESC="${LOCATION_DESC:-}"
    NODE_NAME="${NODE_NAME:-}"
    LOCID="${LOCID:-}"
    RAM="${RAM:-$DEFAULT_RAM}"
    DISK="${DISK:-$DEFAULT_DISK}"
    DAEMON_PORT="${DAEMON_PORT:-$DEFAULT_DAEMON_PORT}"
    SFTP_PORT="${SFTP_PORT:-$DEFAULT_SFTP_PORT}"
    PANEL_DIR="${PANEL_DIR:-$DEFAULT_PANEL_DIR}"
}

validate_environment() {
    # Cek PHP
    if ! command -v php >/dev/null 2>&1; then
        err "PHP tidak ditemukan. Pastikan PHP terinstal dan berada di PATH."
        exit 1
    fi
    
    if [[ ! -d "$PANEL_DIR" ]]; then
        warn "Direktori panel tidak ditemukan: $PANEL_DIR"
        prompt_with_validation PANEL_DIR "Masukkan path panel" "$PANEL_DIR" \
            "[[ -d \$input ]]" "Direktori tidak valid atau tidak ada"
    fi
    
    if [[ ! -f "${PANEL_DIR}/artisan" ]]; then
        err "File artisan tidak ditemukan di ${PANEL_DIR}. Pastikan path panel benar."
        exit 1
    fi
}

setup_logging() {
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    LOGFILE="/tmp/ptero_node_create_${timestamp}.log"
    touch "$LOGFILE"
    exec > >(tee -a "$LOGFILE") 2>&1
    ok "Log disimpan ke: $LOGFILE"
}

prompt_missing_inputs() {
    print "Mengumpulkan informasi yang diperlukan..."
    
    prompt_with_validation LOCATION_NAME "Masukkan nama lokasi" "Default-Location"
    prompt_with_validation LOCATION_DESC "Masukkan deskripsi lokasi" "$LOCATION_NAME"
    prompt_with_validation DOMAIN "Masukkan domain node (FQDN)" "" \
        validate_domain "Format domain tidak valid"
    prompt_with_validation NODE_NAME "Masukkan nama node" "node-01"
    prompt_with_validation LOCID "Masukkan locid (angka)" "1" \
        validate_number "LocID harus berupa angka"
    prompt_with_validation RAM "Masukkan RAM per server (MB)" "$RAM" \
        validate_number "RAM harus berupa angka"
    prompt_with_validation DISK "Masukkan disk per server (MB)" "$DISK" \
        validate_number "Disk harus berupa angka"
    prompt_with_validation DAEMON_PORT "Masukkan daemon port" "$DAEMON_PORT" \
        validate_port "Port harus antara 1-65535"
    prompt_with_validation SFTP_PORT "Masukkan SFTP port" "$SFTP_PORT" \
        validate_port "Port harus antara 1-65535"
}

confirm_execution() {
    echo
    ok "Konfigurasi yang akan diterapkan:"
    print "Panel path: $PANEL_DIR"
    print "Location name: $LOCATION_NAME"
    print "Location description: $LOCATION_DESC"
    print "Node name: $NODE_NAME"
    print "FQDN: $DOMAIN"
    print "LocID: $LOCID"
    print "RAM: ${RAM}MB, Disk: ${DISK}MB"
    print "Daemon port: $DAEMON_PORT, SFTP port: $SFTP_PORT"
    echo
    
    local confirm
    read -rp "$(echo -e "${COL_INFO}Lanjutkan pembuatan lokasi & node? (y/N): ${COL_NC}")" confirm
    confirm="${confirm:-n}"
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        warn "Dibatalkan oleh pengguna."
        exit 0
    fi
}

create_location() {
    print "Membuat lokasi..."
    php artisan p:location:make <<EOF
$LOCATION_NAME
$LOCATION_DESC
EOF
}

create_node() {
    print "Membuat node..."
    php artisan p:node:make <<EOF
$NODE_NAME
$LOCATION_DESC
$LOCID
https
$DOMAIN
yes
no
no
$RAM
$RAM
$DISK
$DISK
100
$DAEMON_PORT
$SFTP_PORT
/var/lib/pterodactyl/volumes
EOF
}

main() {
    parse_arguments "$@"
    init_variables
    validate_environment
    setup_logging
    prompt_missing_inputs
    confirm_execution
    
    # Pindah ke direktori panel
    pushd "$PANEL_DIR" >/dev/null
    
    # Eksekusi perintah
    if create_location && create_node; then
        ok "Lokasi & node berhasil dibuat."
        print "Periksa panel untuk memastikan node sudah muncul dan alokasi OK."
        print "Log lengkap: $LOGFILE"
    else
        err "Terjadi kesalahan saat membuat node. Periksa log: $LOGFILE"
        exit 1
    fi
    
    popd >/dev/null
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

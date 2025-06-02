#!/bin/bash

# ─── Colors ───────────────────────────────────────────────────────────────
BOLD='\033[1m'
NC='\033[0m'
RED='\033[1;31m' 
GREEN='\033[1;32m' 
YELLOW='\033[1;33m'
BLUE='\033[1;34m' 
CYAN='\033[1;36m' 
MAGENTA='\033[1;35m'

# ─── Logging ──────────────────────────────────────────────────────────────
log_info()     { echo -e "${CYAN}>>${NC} $1"; }
log_success()  { echo -e "${GREEN}${BOLD}>> SUCCESS:${NC} $1"; }
log_warning()  { echo -e "${YELLOW}${BOLD}>> WARNING:${NC} $1"; }
log_error()    { echo -e "${RED}${BOLD}>> ERROR:${NC} $1"; }
log_step()     { echo -e "${BLUE}${BOLD}>> STEP:${NC} $1"; }

# ─── Globals ──────────────────────────────────────────────────────────────
script_file="$0"
deps_openwrt=(build-essential clang flex bison g++ gawk gcc-multilib g++-multilib gettext git libncurses5-dev libssl-dev python3-setuptools rsync swig unzip zlib1g-dev file wget)
deps_immortalwrt=(ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential bzip2 ccache clang cmake cpio curl device-tree-compiler ecj fastjar flex gawk gettext gcc-multilib g++-multilib git gnutls-dev gperf haveged help2man intltool lib32gcc-s1 libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses-dev libpython3-dev libreadline-dev libssl-dev libtool libyaml-dev libz-dev lld llvm lrzsz mkisofs msmtp nano ninja-build p7zip p7zip-full patch pkgconf python3 python3-pip python3-ply python3-docutils python3-pyelftools qemu-utils re2c rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev zstd)

# ─── Checks ───────────────────────────────────────────────────────────────
check_git() {
    command -v git &> /dev/null || { log_error "Git is required. Please install it."; exit 1; }
}

# ─── Menu ─────────────────────────────────────────────────────────────────
main_menu() {
    clear
    echo -e "${MAGENTA}${BOLD}--------------------------------------"
    echo -e "  UNIVERSAL Firmware Build Tool"
    echo -e "--------------------------------------${NC}"
    echo -e "${BLUE}${BOLD}Select firmware distribution:${NC}"
    echo "1) OpenWrt"
    echo "2) OpenWrt-IPQ"
    echo "3) ImmortalWrt"

    while true; do
        read -rp "Enter choice [1/2/3]: " choice
        case "$choice" in
            1) distro="openwrt"; repo="https://github.com/openwrt/openwrt.git"; deps=("${deps_openwrt[@]}"); break ;;
            2) distro="openwrt-ipq"; repo="https://github.com/qosmio/openwrt-ipq.git"; deps=("${deps_openwrt[@]}"); break ;;
            3) distro="immortalwrt"; repo="https://github.com/immortalwrt/immortalwrt.git"; deps=("${deps_immortalwrt[@]}"); break ;;
            *) log_error "Invalid choice. Please select 1, 2, or 3." ;;
        esac
    done

    log_info "Selected: ${BOLD}$distro${NC}"
}

# ─── Feeds ────────────────────────────────────────────────────────────────
update_feeds() {
    log_step "Updating feeds..."
    ./scripts/feeds update -a && ./scripts/feeds install -a || return 1
    read -rp "${BLUE}Press Enter after editing feeds (if needed)... ${NC}"
    ./scripts/feeds update -a && ./scripts/feeds install -a || return 1
    log_success "Feeds updated and installed."
}

# ─── Target Branch/Tag ────────────────────────────────────────────────────
select_target() {
    log_step "Select branch or tag:"
    echo -e "${BLUE}Available branches:${NC}"; git branch -a
    echo -e "${BLUE}Available tags:${NC}"; git tag | sort -V

    while true; do
        read -rp "Enter branch/tag to checkout: " target_tag
        git checkout "$target_tag" && break || log_error "Invalid branch or tag."
    done

    log_success "Checked out to: $target_tag"
}

# ─── Configuration ────────────────────────────────────────────────────────
apply_seed_config() {
    [[ "$distro" == "openwrt-ipq" ]] || return
    log_step "Applying NSS config..."
    cp nss-setup/config-nss.seed .config && make defconfig
    log_success "NSS configuration applied."
}

run_menuconfig() {
    log_step "Running make menuconfig..."
    make menuconfig && log_success "Configuration saved." || log_error "Menuconfig failed."
}

# ─── Build Process ────────────────────────────────────────────────────────
start_build() {
    local MAKE_J=$(nproc)
    local start_time duration hours minutes seconds

    log_step "Building with -j$MAKE_J"
    while true; do
        start_time=$(date +%s)
        make -j"$MAKE_J" && {
            duration=$(( $(date +%s) - start_time ))
            hours=$((duration / 3600)); minutes=$(((duration % 3600) / 60)); seconds=$((duration % 60))
            log_success "Build completed in ${hours}h ${minutes}m ${seconds}s"
            log_info "Output: ${YELLOW}$(pwd)/bin/targets/${NC}"
            break
        }

        log_error "Build failed. Retrying with verbose output..."
        make -j1 V=s
        read -rp "Fix issues, then press Enter to retry... "
        update_feeds
        make defconfig
        run_menuconfig
    done
}

# ─── Fresh Build ──────────────────────────────────────────────────────────
fresh_build() {
    log_step "Starting clean build..."
    if [ -d "$distro" ]; then
        read -rp "${YELLOW}Directory '$distro' exists. Delete? [y/N]: ${NC}" confirm
        [[ "$confirm" =~ ^[Yy]$ ]] && rm -rf "$distro" || { pushd "$distro" >/dev/null; rebuild_menu; popd >/dev/null; return; }
    fi

    git clone "$repo" "$distro" || { log_error "Git clone failed."; return 1; }

    pushd "$distro" >/dev/null || return
    update_feeds
    select_target
    apply_seed_config
    run_menuconfig
    start_build
    popd >/dev/null
}

# ─── Rebuild ──────────────────────────────────────────────────────────────
rebuild_menu() {
    pushd "$distro" >/dev/null || { log_error "Cannot access directory."; return 1; }

    while true; do
        echo -e "${BLUE}${BOLD}Rebuild options:${NC}"
        echo "1) Full clean + reconfigure"
        echo "2) Quick rebuild with current settings"
        read -rp "Choose option [1/2]: " rebuild_choice

        case "$rebuild_choice" in
            1) make distclean; update_feeds; select_target; run_menuconfig; start_build; break ;;
            2) make -j"$(nproc)" && { log_success "Rebuild successful."; show_output_location; break; } || { log_error "Quick rebuild failed. Switching to full mode..."; update_feeds; make defconfig; run_menuconfig; start_build; break; } ;;
            *) log_error "Invalid option." ;;
        esac
    done

    popd >/dev/null
}

show_output_location() {
    log_info "Firmware is located at: ${YELLOW}$(pwd)/bin/targets/${NC}"
}

# ─── Clean ────────────────────────────────────────────────────────────────
[[ "$1" == "--clean" ]] && {
    log_step "Cleaning up..."
    [ -f "$script_file" ] && rm -f "$script_file" && log_info "Script removed."
    log_success "Cleanup done."
    exit 0
}

# ─── Entry Point ──────────────────────────────────────────────────────────
check_git
main_menu

if [ -d "$distro" ]; then
    read -rp "${BLUE}Directory '$distro' exists. Choose build type - Fresh [1] or Rebuild [2]: ${NC}" build_choice
    case "$build_choice" in
        1) fresh_build ;;
        2) rebuild_menu ;;
        *) log_error "Invalid selection." ;;
    esac
else
    log_step "Installing required packages..."
    sudo apt update -y >/dev/null
    sudo apt install -y "${deps[@]}" >/dev/null
    log_success "Dependencies installed."
    fresh_build
fi

log_info "Script complete."

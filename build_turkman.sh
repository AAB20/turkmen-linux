#!/bin/bash

# ==============================================================================
# PROJECT: TURKMENOS BUILDER (V7.1 - VM Ready Edition)
# FEATURES: Dual Desktop (KDE+GNOME) + VirtualBox Drivers Pre-installed
# ==============================================================================

# --- [ Configuration ] ---
ISO_URL="https://releases.ubuntu.com/24.04.3/ubuntu-24.04.3-desktop-amd64.iso"
ISO_NAME="ubuntu-base.iso"
WORK_DIR="$HOME/turkman_factory"
OUTPUT_DIR="/home/ubuntu"
FINAL_ISO="Turkmenos-Dual-VM.iso"
FINAL_RAR="Turkmenos-Dual-VM.rar"

# --- [ Colors & Safety ] ---
set -e
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

cleanup() {
    echo -e "\n${BLUE}[!] Cleaning up workspace...${NC}"
    sudo umount -lf "$WORK_DIR/edit/proc" 2>/dev/null || true
    sudo umount -lf "$WORK_DIR/edit/sysfs" 2>/dev/null || true
    sudo umount -lf "$WORK_DIR/edit/dev/pts" 2>/dev/null || true
    sudo umount -lf "$WORK_DIR/edit/dev" 2>/dev/null || true
    sudo umount -lf "$WORK_DIR/mnt" 2>/dev/null || true
}
trap cleanup EXIT

# ==============================================================================
# MAIN PROCESS
# ==============================================================================

clear
echo -e "${GREEN}>>> STARTING TURKMENOS BUILDER V7.1 (VM FIXED)${NC}"

# 1. Setup
echo ">>> Step 1/8: Installing Build Tools..."
sudo apt update -qq
sudo apt install -y squashfs-tools xorriso sed syslinux-utils aria2 rar -qq

if [ -d "$WORK_DIR" ]; then sudo rm -rf "$WORK_DIR"; fi
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# 2. Download
if [ ! -f "$ISO_NAME" ]; then
    echo ">>> Step 2/8: Downloading Ubuntu Base..."
    aria2c -x 16 -s 16 -o "$ISO_NAME" "$ISO_URL"
fi

# 3. Extraction
echo ">>> Step 3/8: Extracting Files (Safe Mode)..."
xorriso -osirrox on -indev "$ISO_NAME" -extract / extracted 2>&1 | grep -E "Extracting|100%"
chmod -R +w extracted

if [ ! -f "extracted/casper/filesystem.squashfs" ]; then
    echo -e "${RED}[X] Critical: Filesystem not found!${NC}"
    exit 1
fi

# Boot Menu Branding
echo ">>> Branding Boot Menu..."
find extracted/boot/grub -type f -name "*.cfg" -exec sed -i 's/Try or Install Ubuntu/Install Turkmenos (Dual Desktop)/g' {} +
find extracted/boot/grub -type f -name "*.cfg" -exec sed -i 's/Ubuntu/Turkmenos/g' {} +

echo ">>> Decompressing SquashFS..."
sudo unsquashfs -d edit extracted/casper/filesystem.squashfs > /dev/null

# 4. Bind Mounts
sudo cp /etc/resolv.conf edit/etc/
sudo mount --bind /dev edit/dev
sudo mount -t proc proc edit/proc
sudo mount -t sysfs sysfs edit/sysfs
sudo mount -t devpts devpts edit/dev/pts

# 5. INJECTING CONFIGURATION
echo ">>> Step 5/8: Injecting System Configuration..."

cat <<'EOF' | sudo tee edit/tmp/install_turkman.sh
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

echo ">>> INSIDE CHROOT: Configuring System..."

# A. Update & Drivers (Fixing VirtualBox Issues)
apt update -qq
apt upgrade -y -qq
apt install -y software-properties-common wget curl git gpg nano

# تثبيت تعريفات VirtualBox مسبقاً لتجنب الشاشة السوداء
echo ">>> Installing VM Drivers..."
apt install -y virtualbox-guest-utils virtualbox-guest-x11 virtualbox-guest-dkms

# B. Install Desktops
echo ">>> Installing KDE Plasma..."
apt install -y kubuntu-desktop sddm

echo ">>> Installing GNOME (Minimal)..."
apt install -y ubuntu-desktop-minimal

# C. Fixing Display Manager (Force SDDM)
echo ">>> Forcing SDDM as default..."
systemctl disable gdm3 2>/dev/null
systemctl enable sddm
echo "/usr/sbin/sddm" > /etc/X11/default-display-manager
dpkg-reconfigure -f noninteractive sddm

# D. Gaming Support
dpkg --add-architecture i386
mkdir -p /etc/apt/keyrings
wget -qO - https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key -
wget -qNP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources
apt update -qq
apt install --install-recommends winehq-staging -y
apt install -y winbind cabextract p7zip-full unrar flatpak lutris gamemode

# E. Themes & Look
mkdir -p /usr/share/themes /usr/share/icons
git clone --depth 1 https://github.com/yeyushengfan258/Win11-icon-theme.git /tmp/icons
cp -r /tmp/icons/* /usr/share/icons/

# F. Branding (Turkmenos)
echo ">>> Applying Turkmenos Branding..."
sed -i 's/NAME="Ubuntu"/NAME="Turkmenos"/g' /etc/os-release
sed -i 's/PRETTY_NAME="Ubuntu 24.04.3 LTS"/PRETTY_NAME="Turkmenos 1.0 LTS"/g' /etc/os-release
sed -i 's/ID=ubuntu/ID=turkmenos/g' /etc/os-release
echo "Turkmenos 1.0 LTS \n \l" > /etc/issue
echo "turkmenos" > /etc/hostname

# تعديل GRUB الداخلي
sed -i 's/GRUB_DISTRIBUTOR=`lsb_release -i -s 2> \/dev\/null || echo Debian`/GRUB_DISTRIBUTOR="Turkmenos"/g' /etc/default/grub

# الخلفية
mkdir -p /usr/share/backgrounds/turkman/
cat <<SVG > /usr/share/backgrounds/turkman/wallpaper.svg
<svg width="1920" height="1080" xmlns="http://www.w3.org/2000/svg">
    <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#101010"/><stop offset="1" stop-color="#303030"/></linearGradient></defs>
    <rect width="1920" height="1080" fill="url(#g)"/>
    <text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-size="80" fill="white" font-family="sans-serif" font-weight="bold">TURKMENOS</text>
    <text x="50%" y="60%" dominant-baseline="middle" text-anchor="middle" font-size="30" fill="#00aaff" font-family="sans-serif">Select your Desktop at Login</text>
</svg>
SVG

# G. AI
apt install -y python3-pip vlc ffmpeg
pip3 install streamlit --break-system-packages
curl -fsSL https://ollama.com/install.sh | sh

# H. Cleanup
apt autoremove -y
apt clean
rm -rf /tmp/* /var/lib/apt/lists/*
EOF

sudo chmod +x edit/tmp/install_turkman.sh
sudo chroot edit /bin/bash /tmp/install_turkman.sh

# 6. Repackaging
echo ">>> Step 6/8: Compressing System (High Compression)..."
sudo umount -lf edit/proc
sudo umount -lf edit/sysfs
sudo umount -lf edit/dev/pts
sudo umount -lf edit/dev

sudo chmod +w extracted/casper/filesystem.manifest
sudo chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' > extracted/casper/filesystem.manifest
sudo rm extracted/casper/filesystem.squashfs

# Compression (XZ - Slow but small)
sudo mksquashfs edit extracted/casper/filesystem.squashfs -comp xz -noappend -processors 4

# 7. ISO Generation
echo ">>> Step 7/8: Generating Bootable ISO..."
cd extracted
sudo rm -f md5sum.txt
find -type f -print0 | sudo xargs -0 md5sum | grep -v "boot.catalog" | sudo tee md5sum.txt

BOOT_IMG=$(find . -name "eltorito.img" | head -n 1 | sed 's|^\./||')
EFI_IMG=$(find . -name "efi.img" | head -n 1 | sed 's|^\./||')

sudo xorriso -as mkisofs \
  -r -V "Turkmenos 1.0" \
  -J -joliet-long -l \
  -iso-level 3 \
  -partition_offset 16 \
  -b "$BOOT_IMG" \
  -c boot.catalog \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
  -e "$EFI_IMG" \
  -no-emul-boot -isohybrid-gpt-basdat \
  -o "$OUTPUT_DIR/$FINAL_ISO" .

# 8. Archiving
echo ">>> Step 8/8: Creating RAR Archive..."
cd "$OUTPUT_DIR"

if [ -f "$FINAL_ISO" ]; then
    rar a -m5 -df "$FINAL_RAR" "$FINAL_ISO"
    sudo chown ubuntu:ubuntu "$FINAL_RAR"
    
    echo -e "${GREEN}=================================================${NC}"
    echo -e "${GREEN}   DONE! Download from: ${OUTPUT_DIR}/${FINAL_RAR}   ${NC}"
    echo -e "${GREEN}=================================================${NC}"
else
    echo -e "${RED}[X] Build Failed! Check logs.${NC}"
    exit 1
fi

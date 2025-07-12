#!/bin/bash

LOGFILE="$HOME/install.log"

echo "Update And Upgrade Termux For Ccminer... Please Wait"
apt update && apt upgrade -y -o Dpkg::Options::='--force-confold'

clear
echo "Done, Continue To Collecting Data"
sleep 5
clear

# Warna hijau tebal
GREEN_BOLD="\e[1;32m"
CYAN_BOLD="\e[1;36;44m"
RESET="\e[0m"

# Spinner hijau di baris yang sama
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='🌑🌘🌗🌖🌕🌔🌓🌒'
    local i=0

    # Sembunyikan kursor
    while kill -0 $pid 2>/dev/null; do
        local char="${spinstr:i++%${#spinstr}:1}"
        printf "\r${GREEN_BOLD}[%s] %s...${RESET}" "$char" "$CURRENT_MSG"
        sleep $delay
    done
    # Tampilkan kembali kursor
    printf "\r${GREEN_BOLD}[🟢] %s... ✅${RESET}\n" "$CURRENT_MSG"
}

# Fungsi jalankan perintah dengan spinner dan sembunyikan output
run_cmd() {
    CURRENT_MSG="$1"
    bash -c "$2" > /dev/null 2>&1 & spinner
}

#!/bin/bash

# Lokasi file log
LOGFILE="$HOME/copy.log"

# Jalankan perintah-perintah
echo -e "${CYAN_BOLD}================================${RESET}"
echo -e "${CYAN_BOLD}=    CCminer installer v0.1    =${RESET}"
echo -e "${CYAN_BOLD}================================${RESET}"
echo -e ""
echo -e "${GREEN_BOLD}📥----------Mengumpulkan Komponen----${RESET}"
run_cmd "Install Unzip" "apt install unzip -y -o Dpkg::Options::='--force-confold'"
run_cmd "Install Wget" "apt install wget -y -o Dpkg::Options::='--force-confold'"
run_cmd "Download File Build" "wget -O ccminer.zip https://github.com/zaxinaga/exava/raw/refs/heads/main/ccminer.zip"
run_cmd "Make Folder" "mkdir ccminer"
run_cmd "Unzip Ccminer" "unzip ccminer.zip -d ccminer"
echo -e "${GREEN_BOLD}🔧----------Persiapan Instalasi Ubuntu----${RESET}"
run_cmd "Install Proot Distro" "pkg install proot-distro -y -o Dpkg::Options::='--force-confold'"
run_cmd "Check Available proot-distro" "proot-distro list"
run_cmd "Install Ubuntu" "proot-distro install ubuntu"
echo -e "${GREEN_BOLD}📑----------Menyalin Configurasi----${RESET}"
# Lokasi direktori root Ubuntu (PRoot-Distro)
UBUNTU_ROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/root"

# Pastikan direktori tujuan ada
if [ ! -d "$UBUNTU_ROOT" ]; then
  echo "Direktori root Ubuntu tidak ditemukan di: $UBUNTU_ROOT" | tee -a "$LOGFILE"
  exit 1
fi

# Salin file dengan pengecekan
cp -v ~/ccminer/runcc.sh ~/
chmod +x runcc.sh
cp -v ~/ccminer/ubuntu.sh "$UBUNTU_ROOT/" >> "$LOGFILE" 2>&1
cp -v ~/ccminer/ccminer.cpp "$UBUNTU_ROOT/" >> "$LOGFILE" 2>&1
cp -v ~/ccminer/run.sh "$UBUNTU_ROOT/" >> "$LOGFILE" 2>&1
cp -v ~/ccminer/ccminer.conf "$UBUNTU_ROOT/" >> "$LOGFILE" 2>&1
# Opsional: buat semua file bisa dieksekusi jika perlu
chmod +x "$UBUNTU_ROOT/ubuntu.sh" "$UBUNTU_ROOT/run.sh" >> "$LOGFILE" 2>&1
echo -e "${GREEN_BOLD}Semua file berhasil disalin ke root Ubuntu.${RESET}" | tee -a "$LOGFILE"
echo -e "${GREEN_BOLD}====Done====${RESET}"
sleep 2
clear
echo -e "${CYAN_BOLD}================================${RESET}"
echo -e "${CYAN_BOLD}=    CCminer installer v0.1    =${RESET}"
echo -e "${CYAN_BOLD}================================${RESET}"
echo -e ""
echo -e "${GREEN_BOLD}Melanjutkan Proses di Ubuntu${RESET}"
rm -r ccminer
rm -r ccminer.zip
rm -r copy.log
proot-distro login ubuntu -- bash -c "chmod +x ubuntu.sh && bash ubuntu.sh"



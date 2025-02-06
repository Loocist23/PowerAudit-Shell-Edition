#!/bin/bash

echo " ____                         _             _ _ _   
|  _ \ _____      _____ _ __ / \  _   _  __| (_) |_ 
| |_) / _ \ \ /\ / / _ \ '__/ _ \| | | |/ _\` | | __|
|  __/ (_) \ V  V /  __/ | / ___ \ |_| | (_| | | |_ 
|_|   \___/ \_/\_/ \___|_|/_/   \_\__,_|\__,_|_|\__| v0.2.3
"

# -------------------- Progress Bar Function --------------------
total_steps=13
current_step=0
show_progress() {
    local current=$1
    local total=$2
    local step_name="$3"
    local width=50
    local num_hashes=$(( width * current / total ))
    local num_dashes=$(( width - num_hashes ))
    local progress=$(printf "%0.s#" $(seq 1 $num_hashes))
    local remainder=$(printf "%0.s-" $(seq 1 $num_dashes))
    echo -ne "\r[${progress}${remainder}] ${current}/${total} - ${step_name}"
    if [ "$current" -eq "$total" ]; then
        echo ""
    fi
}
# -------------------- Fin Progress Bar --------------------

# -------------------- 1. Creating Folders --------------------
current_step=$((current_step+1))
show_progress $current_step $total_steps "Creating folders"
output_folder="output"
app_folder="$output_folder/apps-list"
mkdir -p "$output_folder" "$app_folder"

# -------------------- 2. Generating Unique ID --------------------
current_step=$((current_step+1))
show_progress $current_step $total_steps "Generating unique ID"
pc_id=$(cat /etc/machine-id 2>/dev/null || dmidecode -s system-uuid 2>/dev/null | head -n 1 | tr -d ' ')

# -------------------- 3. Getting Basic System Info --------------------
current_step=$((current_step+1))
show_progress $current_step $total_steps "Getting basic system info"
hostname=$(hostname)
os_name=$(cat /etc/os-release | grep "^PRETTY_NAME=" | cut -d '=' -f2 | tr -d '"')
kernel_version=$(uname -r)
install_date=$(ls -lt --time=birth / | tail -n 1 | awk '{print $6, $7, $8}')
username=$(whoami)
is_admin=$(groups | grep -q "sudo" && echo "Yes" || echo "No")

# -------------------- 4. Getting Motherboard Info --------------------
current_step=$((current_step+1))
show_progress $current_step $total_steps "Getting motherboard info"
mb_manufacturer=$(dmidecode -s baseboard-manufacturer 2>/dev/null || echo "Unknown")
mb_model=$(dmidecode -s baseboard-product-name 2>/dev/null || echo "Unknown")
mb_serial=$(dmidecode -s baseboard-serial-number 2>/dev/null || echo "Unknown")
bios_version=$(dmidecode -s bios-version 2>/dev/null || echo "Unknown")

# -------------------- 5. Getting CPU Info --------------------
current_step=$((current_step+1))
show_progress $current_step $total_steps "Getting CPU info"
cpu_model=$(lscpu | grep "Model name" | awk -F: '{print $2}' | sed 's/^[ \t]*//' | tr '\n' ' ')
cpu_cores=$(nproc)
cpu_threads=$(($(lscpu | grep "Thread(s) per core" | awk '{print $NF}') * cpu_cores))
cpu_freq=$(lscpu | grep "MHz" | awk '{print $NF}' | paste -sd "," -)
cpu_cache_l2=$(lscpu | grep "L2 cache" | awk '{print $NF}' | paste -sd "," -)
cpu_cache_l3=$(lscpu | grep "L3 cache" | awk '{print $NF}' | paste -sd "," -)
cpu_arch=$(lscpu | grep "Architecture" | awk '{print $2}')
cpu_socket=$(lscpu | grep "Socket(s)" | awk '{print $NF}')
cpu_virtualization=$(lscpu | grep "Virtualization" | awk '{print $NF}')

# -------------------- 6. Getting GPU Info --------------------
current_step=$((current_step+1))
show_progress $current_step $total_steps "Getting GPU info"
gpu_model=$(lspci | grep -i 'vga\|3d\|2d' | cut -d ':' -f3)
gpu_vram=$(glxinfo | grep "Video memory" | awk '{print $3}' 2>/dev/null || echo "Unknown" | paste -sd "," -)
gpu_driver_version=$(glxinfo | grep "OpenGL version string" | awk '{print $4}')
gpu_driver_release=$(glxinfo | grep "OpenGL version string" | awk '{print $6}')

# -------------------- 7. Getting RAM Info --------------------
current_step=$((current_step+1))
show_progress $current_step $total_steps "Getting RAM info"
ram_manufacturer=$(dmidecode -t memory | grep "Manufacturer" | awk '{print $2}' | paste -sd "," -)
ram_total=$(free -h | awk '/Mem:/ {print $2}')
ram_channels=$(dmidecode -t memory | grep "Locator" | awk '{print $2}' | paste -sd "," -)
ram_slots=$(dmidecode -t memory | grep "Bank Locator" | awk '{print $3}' | paste -sd "," -)

# -------------------- 8. Getting Disk Info --------------------
current_step=$((current_step+1))
show_progress $current_step $total_steps "Getting disk info"
disk_total=$(df -h --total | awk '/total/ {print $2}')
disk_free=$(df -h --total | awk '/total/ {print $4}')
disk_types=$(lsblk -o NAME,TYPE | grep disk | awk '{print $2}' | paste -sd "," -)
disk_models=$(lsblk -o NAME,MODEL | grep disk | awk '{print $2}' | paste -sd "," -)
disk_health=$(lsblk -o NAME,STATE | grep disk | awk '{print $2}' | paste -sd "," -)
disk_partitions=$(lsblk -o NAME,FSTYPE | grep part | awk '{print $2}' | paste -sd "," -)

# -------------------- 9. Getting Network Info --------------------
current_step=$((current_step+1))
show_progress $current_step $total_steps "Getting network info"
domain=$(hostname -d)
ip_address=$(hostname -I | awk '{print $1}')
mac_address=$(ip link show | awk '/ether/ {print $2}' | paste -sd "," -)
gateway=$(ip route | grep default | awk '{print $3}')
dns_servers=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | paste -sd "," -)
dhcp_status=$(nmcli device show | grep DHCP4 | awk '{print $2}' | paste -sd "," -)

# -------------------- 10. Getting Security Info --------------------
current_step=$((current_step+1))
show_progress $current_step $total_steps "Getting security info"
bitlocker_status=$(lsblk -o NAME,TYPE,MOUNTPOINT | grep crypt | awk '{print $1}')
antivirus="ClamAV actif"  # Linux n'a pas d'antivirus par défaut

# -------------------- 11. Getting Installed Applications --------------------
current_step=$((current_step+1))
show_progress $current_step $total_steps "Getting installed applications"
apps_list=$(dpkg-query -W -f='${Package};${Version};${Maintainer}\n' 2>/dev/null)

# -------------------- 12. Cleaning Data --------------------
current_step=$((current_step+1))
show_progress $current_step $total_steps "Cleaning data"
cpu_model=$(echo "$cpu_model" | tr '\n' ' ')
cpu_freq=$(echo "$cpu_freq" | tr '\n' ' ')
cpu_cache_l2=$(echo "$cpu_cache_l2" | tr '\n' ' ')
cpu_cache_l3=$(echo "$cpu_cache_l3" | tr '\n' ' ')
gpu_vram=$(echo "$gpu_vram" | tr '\n' ' ')
dns_servers=$(echo "$dns_servers" | tr '\n' ' ')
mac_address=$(echo "$mac_address" | tr '\n' ' ')

# -------------------- 13. Exporting Data --------------------
current_step=$((current_step+1))
show_progress $current_step $total_steps "Exporting data"

echo "\n1: CSV"
echo "2: JSON"
read -p "Choice: " choice

csv_file="${output_folder}/system-info.csv"
json_file="${output_folder}/system-info.json"
app_list_csv_file="${app_folder}/app-list-${pc_id}.csv"
app_list_json_file="${app_folder}/app-list-${pc_id}.json"

if [[ "$choice" == "1" ]]; then
    # Si le fichier CSV n'existe pas, ajouter l'en-tête
    if [[ ! -f "$csv_file" ]]; then
        echo "Identifiant PC;Nom d'utilisateur;Statut administrateur;Domaine;Adresse IP;Adresse MAC;Passerelle;Serveurs DNS;Statut DHCP;Système d'exploitation;Version noyau;Date d'installation;Nom de l'ordinateur;Fabricant carte mère;Modèle carte mère;Numéro de série carte mère;Version BIOS;Modèle CPU;Nombre de cœurs CPU;Nombre de threads CPU;Fréquence CPU;Cache L2;Cache L3;Architecture CPU;Socket CPU;Virtualisation;Modèle GPU;VRAM;Version du driver GPU;Date de sortie du driver GPU;Fabricant RAM;Quantité totale RAM;Canaux RAM;Slots RAM;Espace disque total;Espace libre disque;Type de disque;Modèle disque;État de santé disque;Type de partition;Statut chiffrement BitLocker/LUKS;Antivirus installé;Imprimantes installées;Version d'Office installée" > "$csv_file"
    fi

    # Ajout d'une ligne avec les valeurs collectées
    echo "$pc_id;$username;$is_admin;$domain;$ip_address;$mac_address;$gateway;$dns_servers;$dhcp_status;$os_name;$kernel_version;$install_date;$hostname;$mb_manufacturer;$mb_model;$mb_serial;$bios_version;$cpu_model;$cpu_cores;$cpu_threads;$cpu_freq MHz;$cpu_cache_l2;$cpu_cache_l3;$cpu_arch;$cpu_socket;$cpu_virtualization;$gpu_model;$gpu_vram MB;$gpu_driver_version;$gpu_driver_release;$ram_manufacturer;$ram_total;$ram_channels;$ram_slots;$disk_total;$disk_free;$disk_types;$disk_models;$disk_health;$disk_partitions;$bitlocker_status;$antivirus;$printers;$office_version" >> "$csv_file"

    # Export des applications en CSV
    {
        echo "Nom;Version;Éditeur"
        echo "$apps_list"
    } > "$app_list_csv_file"

    echo -e "\nCSV file updated: $csv_file"
    echo "Applications CSV: $app_list_csv_file"

elif [[ "$choice" == "2" ]]; then
    # Export en JSON
    {
        echo "{"
        echo "  \"Identifiant PC\": \"$pc_id\","
        echo "  \"Utilisateur\": {"
        echo "    \"Nom\": \"$username\","
        echo "    \"Administrateur\": \"$is_admin\""
        echo "  },"
        echo "  \"Réseau\": {"
        echo "    \"Domaine\": \"$domain\","
        echo "    \"Adresse IP\": \"$ip_address\","
        echo "    \"Adresse MAC\": \"$mac_address\","
        echo "    \"Passerelle\": \"$gateway\","
        echo "    \"Serveurs DNS\": \"$dns_servers\","
        echo "    \"Statut DHCP\": \"$dhcp_status\""
        echo "  },"
        echo "  \"Système\": {"
        echo "    \"OS\": \"$os_name\","
        echo "    \"Version noyau\": \"$kernel_version\","
        echo "    \"Date d'installation\": \"$install_date\","
        echo "    \"Nom de l'ordinateur\": \"$hostname\""
        echo "  },"
        echo "  \"Hardware\": {"
        echo "    \"Carte mère\": {"
        echo "      \"Fabricant\": \"$mb_manufacturer\","
        echo "      \"Modèle\": \"$mb_model\","
        echo "      \"Numéro de série\": \"$mb_serial\","
        echo "      \"Version BIOS\": \"$bios_version\""
        echo "    },"
        echo "    \"CPU\": {"
        echo "      \"Modèle\": \"$cpu_model\","
        echo "      \"Cœurs\": \"$cpu_cores\","
        echo "      \"Threads\": \"$cpu_threads\","
        echo "      \"Fréquence\": \"$cpu_freq MHz\","
        echo "      \"Cache L2\": \"$cpu_cache_l2\","
        echo "      \"Cache L3\": \"$cpu_cache_l3\","
        echo "      \"Architecture\": \"$cpu_arch\","
        echo "      \"Socket\": \"$cpu_socket\","
        echo "      \"Virtualisation\": \"$cpu_virtualization\""
        echo "    },"
        echo "    \"GPU\": {"
        echo "      \"Modèle\": \"$gpu_model\","
        echo "      \"VRAM\": \"$gpu_vram MB\","
        echo "      \"Version du driver\": \"$gpu_driver_version\","
        echo "      \"Date de sortie du driver\": \"$gpu_driver_release\""
        echo "    },"
        echo "    \"RAM\": {"
        echo "      \"Fabricant\": \"$ram_manufacturer\","
        echo "      \"Quantité totale\": \"$ram_total\","
        echo "      \"Canaux\": \"$ram_channels\","
        echo "      \"Slots\": \"$ram_slots\""
        echo "    },"
        echo "    \"Disques\": {"
        echo "      \"Espace total\": \"$disk_total\","
        echo "      \"Espace libre\": \"$disk_free\","
        echo "      \"Types\": \"$disk_types\","
        echo "      \"Modèles\": \"$disk_models\","
        echo "      \"État de santé\": \"$disk_health\","
        echo "      \"Type de partition\": \"$disk_partitions\""
        echo "    }"
        echo "  },"
        echo "  \"Sécurité\": {"
        echo "    \"Chiffrement BitLocker/LUKS\": \"$bitlocker_status\","
        echo "    \"Antivirus installé\": \"$antivirus\""
        echo "  },"
        echo "  \"Périphériques\": {"
        echo "    \"Imprimantes installées\": \"$printers\","
        echo "    \"Version Office\": \"$office_version\""
        echo "  }"
        echo "}"
    } > "$json_file"

    echo -e "\nJSON file updated: $json_file"
else
    echo "Invalid choice. No output generated."
fi

echo ""

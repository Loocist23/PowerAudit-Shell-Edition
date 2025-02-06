#!/bin/bash

echo " ____                         _             _ _ _   
|  _ \ _____      _____ _ __ / \  _   _  __| (_) |_ 
| |_) / _ \ \ /\ / / _ \ '__/ _ \| | | |/ _\` | | __|
|  __/ (_) \ V  V /  __/ | / ___ \ |_| | (_| | | |_ 
|_|   \___/ \_/\_/ \___|_|/_/   \_\__,_|\__,_|_|\__| v0.7.2
"

# Définition des variables
output_folder="output"
app_folder="$output_folder/apps-list"

# Création des dossiers
mkdir -p "$output_folder" "$app_folder"

# Génération d'un ID unique basé sur l'UUID de la carte mère ou un autre identifiant stable
pc_id=$(cat /etc/machine-id 2>/dev/null || dmidecode -s system-uuid 2>/dev/null | head -n 1 | tr -d ' ')

# Récupération des infos matérielles
hostname=$(hostname)
os_name=$(cat /etc/os-release | grep "^PRETTY_NAME=" | cut -d '=' -f2 | tr -d '"')
kernel_version=$(uname -r)
install_date=$(ls -lt --time=birth / | tail -n 1 | awk '{print $6, $7, $8}')
username=$(whoami)
is_admin=$(groups | grep -q "sudo" && echo "Yes" || echo "No")

# Carte mère
mb_manufacturer=$(dmidecode -s baseboard-manufacturer 2>/dev/null || echo "Unknown")
mb_model=$(dmidecode -s baseboard-product-name 2>/dev/null || echo "Unknown")
mb_serial=$(dmidecode -s baseboard-serial-number 2>/dev/null || echo "Unknown")
bios_version=$(dmidecode -s bios-version 2>/dev/null || echo "Unknown")

# CPU
cpu_model=$(lscpu | grep "Model name" | awk -F: '{print $2}' | sed 's/^[ \t]*//')
cpu_cores=$(nproc)
cpu_threads=$(($(lscpu | grep "Thread(s) per core" | awk '{print $NF}') * cpu_cores))
cpu_freq=$(lscpu | grep "MHz" | awk '{print $NF}')
cpu_cache_l2=$(lscpu | grep "L2 cache" | awk '{print $NF}')
cpu_cache_l3=$(lscpu | grep "L3 cache" | awk '{print $NF}')
cpu_arch=$(lscpu | grep "Architecture" | awk '{print $2}')
cpu_socket=$(lscpu | grep "Socket(s)" | awk '{print $NF}')
cpu_virtualization=$(lscpu | grep "Virtualization" | awk '{print $NF}')

# GPU
gpu_model=$(lspci | grep -i 'vga\|3d\|2d' | cut -d ':' -f3)
gpu_vram=$(glxinfo | grep "Video memory" | awk '{print $3}' || echo "Unknown")
gpu_driver_version=$(glxinfo | grep "OpenGL version string" | awk '{print $4}')
gpu_driver_release=$(glxinfo | grep "OpenGL version string" | awk '{print $6}')

# RAM
ram_manufacturer=$(dmidecode -t memory | grep "Manufacturer" | awk '{print $2}' | paste -sd "," -)
ram_total=$(free -h | awk '/Mem:/ {print $2}')
ram_channels=$(dmidecode -t memory | grep "Locator" | awk '{print $2}' | paste -sd "," -)
ram_slots=$(dmidecode -t memory | grep "Bank Locator" | awk '{print $3}' | paste -sd "," -)

# Disques
disk_total=$(df -h --total | awk '/total/ {print $2}')
disk_free=$(df -h --total | awk '/total/ {print $4}')
disk_types=$(lsblk -o NAME,TYPE | grep disk | awk '{print $2}' | paste -sd "," -)
disk_models=$(lsblk -o NAME,MODEL | grep disk | awk '{print $2}' | paste -sd "," -)
disk_health=$(lsblk -o NAME,STATE | grep disk | awk '{print $2}' | paste -sd "," -)
disk_partitions=$(lsblk -o NAME,FSTYPE | grep part | awk '{print $2}' | paste -sd "," -)

# Réseau
domain=$(hostname -d)
ip_address=$(hostname -I | awk '{print $1}')
mac_address=$(ip link show | awk '/ether/ {print $2}')
gateway=$(ip route | grep default | awk '{print $3}')
dns_servers=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | paste -sd "," -)
dhcp_status=$(nmcli device show | grep DHCP4 | awk '{print $2}' | paste -sd "," -)

# Sécurité
bitlocker_status=$(lsblk -o NAME,TYPE,MOUNTPOINT | grep crypt | awk '{print $1}')
antivirus="ClamAV actif" # Linux n'a pas d'antivirus par défaut

# Applications installées
apps_list=$(dpkg-query -W -f='${Package};${Version};${Maintainer}\n' 2>/dev/null)

# Export
echo "1: CSV"
echo "2: JSON"
read -p "Choix: " choice

system_info_file="$output_folder/system-info"
app_list_file="$app_folder/app-list-$pc_id"

# Export en CSV
if [[ "$choice" == "1" ]]; then
    {
        echo "Clé;Valeur"
        echo "Identifiant PC;$pc_id"
        echo "Nom d'utilisateur;$username"
        echo "Statut administrateur;$is_admin"
        echo "Domaine;$domain"
        echo "Adresse IP;$ip_address"
        echo "Adresse MAC;$mac_address"
        echo "Passerelle;$gateway"
        echo "Serveurs DNS;$dns_servers"
        echo "Statut DHCP;$dhcp_status"
        echo "Système d'exploitation;$os_name"
        echo "Version noyau;$kernel_version"
        echo "Date d'installation;$install_date"
        echo "Nom de l'ordinateur;$hostname"
        echo "Fabricant carte mère;$mb_manufacturer"
        echo "Modèle carte mère;$mb_model"
        echo "Numéro de série carte mère;$mb_serial"
        echo "Version BIOS;$bios_version"
        echo "Modèle CPU;$cpu_model"
        echo "Nombre de cœurs CPU;$cpu_cores"
        echo "Nombre de threads CPU;$cpu_threads"
        echo "Fréquence CPU;$cpu_freq MHz"
        echo "Cache L2;$cpu_cache_l2"
        echo "Cache L3;$cpu_cache_l3"
        echo "Architecture CPU;$cpu_arch"
        echo "Socket CPU;$cpu_socket"
        echo "Virtualisation;$cpu_virtualization"
        echo "Modèle GPU;$gpu_model"
        echo "VRAM;$gpu_vram MB"
        echo "Version du driver GPU;$gpu_driver_version"
        echo "Date de sortie du driver GPU;$gpu_driver_release"
        echo "Fabricant RAM;$ram_manufacturer"
        echo "Quantité totale RAM;$ram_total"
        echo "Canaux RAM;$ram_channels"
        echo "Slots RAM;$ram_slots"
        echo "Espace disque total;$disk_total"
        echo "Espace libre disque;$disk_free"
        echo "Type de disque;$disk_types"
        echo "Modèle disque;$disk_models"
        echo "État de santé disque;$disk_health"
        echo "Type de partition;$disk_partitions"
        echo "Statut chiffrement BitLocker/LUKS;$bitlocker_status"
        echo "Antivirus installé;$antivirus"
        echo "Imprimantes installées;$printers"
        echo "Version d'Office installée;$office_version"
    } > "${system_info_file}.csv"

    # Export des applications en CSV
    {
        echo "Nom;Version;Éditeur"
        echo "$apps_list"
    } > "${app_list_file}.csv"

    echo "Fichiers CSV générés :"
    echo "- ${system_info_file}.csv"
    echo "- ${app_list_file}.csv"

# Export en JSON
elif [[ "$choice" == "2" ]]; then
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
        echo "      \"Driver version\": \"$gpu_driver_version\","
        echo "      \"Driver release\": \"$gpu_driver_release\""
        echo "    },"
        echo "    \"RAM\": {"
        echo "      \"Fabricant\": \"$ram_manufacturer\","
        echo "      \"Total\": \"$ram_total\","
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
    } > "${system_info_file}.json"

    # Export des applications en JSON
    {
        echo "{"
        echo "  \"Applications installées\": ["
        echo "    $(echo "$apps_list" | awk -F';' '{print "    {\"Nom\": \""$1"\", \"Version\": \""$2"\", \"Éditeur\": \""$3"\"}"}' | paste -sd ",\n" -)"
        echo "  ]"
        echo "}"
    } > "${app_list_file}.json"

    echo "Fichiers JSON générés :"
    echo "- ${system_info_file}.json"
    echo "- ${app_list_file}.json"

else
    echo "Choix invalide. Aucune sortie générée."
fi

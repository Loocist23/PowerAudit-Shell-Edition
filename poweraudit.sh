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

# Récupération des infos système
hostname=$(hostname)
cpu_model=$(lscpu | grep "Model name" | awk -F: '{print $2}' | sed 's/^[ \t]*//')
cpu_cores=$(nproc)
total_ram=$(free -h | awk '/Mem:/ {print $2}')
total_disk=$(df -h --total | awk '/total/ {print $2}')
gpu_info=$(lspci | grep -i 'vga\|3d\|2d' | cut -d ':' -f3)
os_name=$(cat /etc/os-release | grep "^PRETTY_NAME=" | cut -d '=' -f2 | tr -d '"')
kernel_version=$(uname -r)
uptime_info=$(uptime -p)

# Récupération des infos de la carte mère
motherboard_manufacturer=$(dmidecode -s baseboard-manufacturer 2>/dev/null || echo "Inconnu")
motherboard_model=$(dmidecode -s baseboard-product-name 2>/dev/null || echo "Inconnu")
motherboard_serial=$(dmidecode -s baseboard-serial-number 2>/dev/null || echo "Inconnu")
bios_version=$(dmidecode -s bios-version 2>/dev/null || echo "Inconnu")

# Infos réseau
ip_address=$(hostname -I | awk '{print $1}')
mac_address=$(ip link show | awk '/ether/ {print $2}')
gateway=$(ip route | grep default | awk '{print $3}')
dns_servers=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | paste -sd "," -)

# Liste des logiciels installés
installed_apps=$(dpkg-query -W -f='${binary:Package}\n' 2>/dev/null || echo "dpkg non disponible")

# Infos disques et partitions
disk_info=$(lsblk -o NAME,SIZE,TYPE | grep disk)

# Infos imprimantes
printers=$(lpstat -p 2>/dev/null | awk '{print $2}')

# Vérification du chiffrement LUKS
encryption_status=$(lsblk -o NAME,TYPE,MOUNTPOINT | grep crypt | awk '{print $1}')

# Vérification de l'antivirus
if systemctl is-active --quiet clamav; then
    antivirus="ClamAV actif"
else
    antivirus="Aucun antivirus actif"
fi

# Choix du format de sortie
echo -e "\nChoisissez le format de sortie:"
echo "1: CSV"
echo "2: JSON"
read -p "Choix: " choice

system_info_file="$output_folder/system-info-$pc_id"
app_list_file="$app_folder/app-list-$pc_id"

if [[ "$choice" == "1" ]]; then
    # Fichier CSV pour les infos système
    {
        echo "Clé;Valeur"
        echo "Identifiant PC;$pc_id"
        echo "Nom de l'ordinateur;$hostname"
        echo "Modèle du CPU;$cpu_model"
        echo "Nombre de cœurs CPU;$cpu_cores"
        echo "Mémoire RAM totale;$total_ram"
        echo "Espace disque total;$total_disk"
        echo "Carte graphique;$gpu_info"
        echo "Système d'exploitation;$os_name"
        echo "Version du noyau;$kernel_version"
        echo "Uptime;$uptime_info"
        echo "Fabricant de la carte mère;$motherboard_manufacturer"
        echo "Modèle de la carte mère;$motherboard_model"
        echo "Numéro de série de la carte mère;$motherboard_serial"
        echo "Version du BIOS;$bios_version"
        echo "Adresse IP;$ip_address"
        echo "Adresse MAC;$mac_address"
        echo "Passerelle;$gateway"
        echo "Serveurs DNS;$dns_servers"
        echo "Partitions de disque;$(echo "$disk_info" | tr '\n' ', ')"
        echo "Imprimantes installées;$printers"
        echo "État du chiffrement;$encryption_status"
        echo "Antivirus actif;$antivirus"
    } > "${system_info_file}.csv"

    # Fichier CSV pour les applications installées
    {
        echo "Nom de l'application"
        echo "$installed_apps"
    } > "${app_list_file}.csv"

    echo "Fichier CSV généré: ${system_info_file}.csv"
    echo "Fichier CSV des applications généré: ${app_list_file}.csv"

elif [[ "$choice" == "2" ]]; then
    # Fichier JSON pour les infos système
    {
        echo "{"
        echo "  \"Identifiant PC\": \"$pc_id\","
        echo "  \"Nom de l'ordinateur\": \"$hostname\","
        echo "  \"Modèle du CPU\": \"$cpu_model\","
        echo "  \"Nombre de cœurs CPU\": \"$cpu_cores\","
        echo "  \"Mémoire RAM totale\": \"$total_ram\","
        echo "  \"Espace disque total\": \"$total_disk\","
        echo "  \"Carte graphique\": \"$gpu_info\","
        echo "  \"Système d'exploitation\": \"$os_name\","
        echo "  \"Version du noyau\": \"$kernel_version\","
        echo "  \"Uptime\": \"$uptime_info\","
        echo "  \"Fabricant de la carte mère\": \"$motherboard_manufacturer\","
        echo "  \"Modèle de la carte mère\": \"$motherboard_model\","
        echo "  \"Numéro de série de la carte mère\": \"$motherboard_serial\","
        echo "  \"Version du BIOS\": \"$bios_version\","
        echo "  \"Adresse IP\": \"$ip_address\","
        echo "  \"Adresse MAC\": \"$mac_address\","
        echo "  \"Passerelle\": \"$gateway\","
        echo "  \"Serveurs DNS\": \"$dns_servers\","
        echo "  \"Partitions de disque\": [$(echo "$disk_info" | sed ':a;N;$!ba;s/\n/","/g' | sed 's/^/"/;s/$/"/')],"
        echo "  \"Imprimantes installées\": \"$printers\","
        echo "  \"État du chiffrement\": \"$encryption_status\","
        echo "  \"Antivirus actif\": \"$antivirus\""
        echo "}"
    } > "${system_info_file}.json"

    # Fichier JSON pour les applications installées
    {
        echo "{"
        echo "  \"Applications installées\": [$(echo "$installed_apps" | sed ':a;N;$!ba;s/\n/","/g' | sed 's/^/"/;s/$/"/')]"
        echo "}"
    } > "${app_list_file}.json"

    echo "Fichier JSON généré: ${system_info_file}.json"
    echo "Fichier JSON des applications généré: ${app_list_file}.json"

else
    echo "Choix invalide. Aucune sortie générée."
fi

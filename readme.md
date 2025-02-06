<div align="center">
<h1>PowerAudit (Shell Edition)</h1>
<a href="https://github.com/Loocist23/PowerAudit-Shell-Edition/releases"><img alt="Static Badge" src="https://img.shields.io/badge/linux_version-Ubuntu_%7C_Debian_%7C_Arch_%7C_Fedora-green?style=for-the-badge&logo=linux&labelColor=%23313244&color=%2389dceb" style="margin-right: 10px"></a>
<a href="https://github.com/Loocist23/PowerAudit-Shell-Edition/releases"><img alt="Static Badge" src="https://img.shields.io/badge/Release-v0.2.3-green?style=for-the-badge&labelColor=%23313244&color=%23a6e3a1" style="margin-right: 10px"> 
</a>
<h3>
An open-source Bash script for retrieving computer specifications and storing them in CSV/JSON files.  
This is a Shell translation of the original <a href="https://github.com/Yelodress/PowerShell-Audit-Tool">PowerShell-Audit-Tool v0.7.2</a>.
</h3>
</div>

## 📋 Features

- ⚡ Extremely fast
- 🖥️ No dependencies (only built-in Linux tools)
- 🔧 Modular and easy to extend
- 🍃 Lightweight and efficient
- ❤️ Supports multiple Linux distributions

## 📓 Documentation
This script is a translation of the original **PowerShell-Audit-Tool** to **Shell**.  
For optional features and usage instructions, refer to the [original documentation](https://github.com/Yelodress/PowerShell-Audit-Tool/wiki/Documentation).

## 📁 Output Structure
<pre>
├── poweraudit.sh
└── output
    ├── system-info.csv       # Contains system specifications
    ├── system-info.json      # Contains system specifications (JSON)
    └── apps-list
        ├── app-list-userid.csv  # List of installed software
        ├── app-list-userid.json # List of installed software
</pre>

## 🚧 Roadmap:
- Add an interactive mode to choose the output format
- Improve compatibility with more Linux distributions
- Retrieve additional security-related information

**I'm open to all suggestions!**  

If you encounter any issues, feel free to open an issue in the repository.

## 📊 Collected Data
### 🔧 **Hardware**
#### <img src="https://api.iconify.design/bi:motherboard-fill.svg?color=%23cdd6f4" height="15"> Motherboard
- Manufacturer
- Model
- Serial number
- BIOS version
#### <img src="https://api.iconify.design/ri:cpu-line.svg?color=%23cdd6f4" height="15"> CPU
- Model
- Cores
- Threads
- Frequency
- Cache size (L2 & L3)
- Architecture
- Socket
- Virtualization (On/Off)
#### <img src="https://api.iconify.design/bi:gpu-card.svg?color=%23cdd6f4" height="15"> GPU
- Model
- VRAM
- Drivers version
- Drivers release date
#### <img src="https://api.iconify.design/clarity:memory-solid.svg?color=%23cdd6f4" height="15"> RAM
- RAM Manufacturer
- Total RAM amount
- RAM channels
- RAM slots
#### <img src="https://api.iconify.design/mdi:harddisk.svg?color=%23cdd6f4" height="15"> Disks
- Total space
- Total free space
- Types
- Models
- Health status
- Partition type
- Network drives

### 🏢 **System**
#### <img src="https://api.iconify.design/mdi:account.svg?color=%23cdd6f4" height="15"> User
- Username
- User administrator status
#### <img src="https://api.iconify.design/material-symbols:router.svg?color=%23cdd6f4" height="15"> Network Configuration
- Domain
- IP address
- MAC address
- Gateway
- DNS
- DHCP status
#### <img src="https://api.iconify.design/mdi:microsoft-windows.svg?color=%23cdd6f4" height="15"> Operating System
- Version
- Architecture
- Installation date
- Computer hostname
#### <img src="https://api.iconify.design/material-symbols:lock.svg?color=%23cdd6f4" height="15"> Security
- BitLocker/LUKS encryption status
- Installed antivirus

### 🎯 **Others**
#### <img src="https://api.iconify.design/mdi:printer.svg?color=%23cdd6f4" height="15"> Peripherals
- Printer(s) name(s)
#### <img src="https://api.iconify.design/mdi:microsoft-office.svg?color=%23cdd6f4" height="15"> Office
- Office installed version

### 📦 **Apps**
#### <img src="https://api.iconify.design/material-symbols:deployed-code-update.svg?color=%23cdd6f4" height="15"> Installed Software
- Name
- Version
- Publisher

### 📌 **Optional Features** (see [documentation](https://github.com/Yelodress/PowerShell-Audit-Tool/wiki/Documentation))
- Retrieve specific user/group information
- Filter specific software lists

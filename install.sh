#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

cur_dir=$(pwd)

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Fatal error：${plain} Please run this script with root privilege \n " && exit 1

# Check OS and set release variable
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    release=$ID
elif [[ -f /usr/lib/os-release ]]; then
    source /usr/lib/os-release
    release=$ID
else
    echo "Failed to check the system OS, please contact the author!" >&2
    exit 1
fi
echo "The OS release is: $release"

arch3xui() {
    case "$(uname -m)" in
        x86_64 | x64 | amd64 ) echo 'amd64' ;;
        armv8 | arm64 | aarch64 ) echo 'arm64' ;;
        * ) echo -e "${green}Unsupported CPU architecture! ${plain}" && rm -f install.sh && exit 1 ;;
    esac
}
echo "arch: $(arch3xui)"

os_version=""
os_version=$(grep -i version_id /etc/os-release | cut -d \" -f2 | cut -d . -f1)

if [[ "${release}" == "centos" ]]; then
    if [[ ${os_version} -lt 8 ]]; then
        echo -e "${red} Please use CentOS 8 or higher ${plain}\n" && exit 1
    fi
elif [[ "${release}" ==  "ubuntu" ]]; then
    if [[ ${os_version} -lt 20 ]]; then
        echo -e "${red}please use Ubuntu 20 or higher version！${plain}\n" && exit 1
    fi

elif [[ "${release}" == "fedora" ]]; then
    if [[ ${os_version} -lt 36 ]]; then
        echo -e "${red}please use Fedora 36 or higher version！${plain}\n" && exit 1
    fi

elif [[ "${release}" == "debian" ]]; then
    if [[ ${os_version} -lt 10 ]]; then
        echo -e "${red} Please use Debian 10 or higher ${plain}\n" && exit 1
    fi
else
    echo -e "${red}Failed to check the OS version, please contact the author!${plain}" && exit 1
fi

install_base() {
    case "${release}" in
        centos|fedora)
            yum install -y -q wget curl tar
            ;;
        *)
            apt install -y -q wget curl tar
            ;;
    esac
}

#This function will be called when user installed x-ui out of sercurity
config_after_install() {
    /usr/local/x-ui/x-ui migrate
    echo -e "${yellow}Install/update finished! For security it's recommended to modify panel settings ${plain}"
    read -p "Do you want to continue with the modification [y/n]? ": config_confirm
    if [[ "${config_confirm}" == "y" || "${config_confirm}" == "Y" ]]; then
        read -p "Please set up your username:" config_account
        echo -e "${yellow}Your username will be:${config_account}${plain}"
        read -p "Please set up your password:" config_password
        echo -e "${yellow}Your password will
install_x-ui() {
systemctl stop x-ui
cd /usr/local/
if [ $# == 0 ]; then
    last_version=$(curl -Ls "https://api.github.com/repos/sepidezare/3x-ui/releases/latest" | grep '"tag_name":' | sed -E 's/."([^"]+)"./\1/')
else
    last_version=$1
fi

echo -e "${green}start to install x-ui ${last_version}${plain}"

if [[ -d "/usr/local/x-ui" ]]; then
    if [[ -d "/usr/local/x-ui.bak" ]]; then
        rm -rf /usr/local/x-ui.bak
    fi
    mv /usr/local/x-ui /usr/local/x-ui.bak
    echo -e "${yellow}Backup the old version to /usr/local/x-ui.bak${plain}"
fi

if [[ ${last_version} == "install" ]];then
    wget -N --no-check-certificate -O /tmp/x-ui.zip https://github.com/sepidezare/3x-ui/archive/main.zip
else
    wget -N --no-check-certificate -O /tmp/x-ui.tar.gz https://github.com/sepidezare/3x-ui/archive/${last_version}.tar.gz
fi

if [[ $? -ne 0 ]]; then
    echo -e "${red}Failed to download the x-ui file, please check your network${plain}"
    exit 1
fi

tar zxf /tmp/x-ui.tar.gz -C /usr/local/
mv /usr/local/3x-ui* /usr/local/x-ui
chmod +x /usr/local/x-ui/x-ui.sh

if [[ ! -f "/usr/local/x-ui/app/app.db" ]]; then
    echo -e "${green}Starting up the x-ui app for the first time${plain}"
    /usr/local/x-ui/x-ui.sh install
else
    echo -e "${green}Starting up the x-ui app${plain}"
    systemctl start x-ui
fi

sleep 3

if [[ $(systemctl is-active x-ui) != "active" ]]; then
    echo -e "${red}Failed to start x-ui service, please check the installation logs${plain}"
    exit 1
fi

echo -e "${green}x-ui ${last_version} has been installed successfully!${plain}"
config_after_install
}

arch3xui
install_base
install_x-ui $1

exit 0

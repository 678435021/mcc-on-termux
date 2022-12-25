#!/usr/bin/bash
dir=$(pwd)

read -p "Do you have 64 bit ARM processor? [Y/n] (n for 32 bit): " ARCH64
read -p "Do you want dotnet to be installed automatically? [Y/n]: " INSTALLDOTNET
if [ "${ARCH64,,}" == "y" ] || [ "$ARCH64" == "" ]; then
	ARCH=arm64
else
	ARCH=arm32
fi

# Install dependencies
pkg update --assume-yes
pkg upgrade --assume-yes
pkg install proot wget --assume-yes

# Install ubuntu
cd $PREFIX/bin
wget -O - https://raw.githubusercontent.com/MFDGaming/ubuntu-in-termux/master/ubuntu.sh > installubuntu
chmod +x installubuntu
echo Y | ./installubuntu
rm installubuntu

# Install MCC
installMCC='
install_dotnet () {
	# Install dependencies
	apt update -y && apt upgrade -y
	apt install wget unzip libc6 libgcc1 libgssapi-krb5-2 libstdc++6 zlib1g libicu70 libssl3 libatomic1 -y

	# Download dotnet if it s not already there
	if [ "${ARCH,,}" == "arm64" ]; then
		dotnetDlLink=https://download.visualstudio.microsoft.com/download/pr/1055ed3b-6d81-42b8-bfaf-594baf240ec0/37f4c7113ec851f20569bb7435cd527b/dotnet-sdk-6.0.404-linux-arm64.tar.gz
		echo Downloading 64 bit version of dotnet6
	else
		dotnetDlLink=https://download.visualstudio.microsoft.com/download/pr/58ebc46e-68d7-44db-aaea-5f5cb66a1cb5/44d292c80c0e13c444e6d66d67ca213e/dotnet-sdk-6.0.404-linux-arm.tar.gz
		echo Downloading 32 bit version of dotnet6
	fi
	dotnetDlPath=dotnet6-$ARCH.tar.gz
	wget -nc -O $dotnetDlPath $dotnetDlLink

	# Set dotnet path
	export DOTNET_ROOT=$PREFIX/lib/.dotnet
	export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
	echo -e "export DOTNET_ROOT=$DOTNET_ROOT"\nexport PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools >> /root/.bashrc

	# Remove old dotnet from path
	rm -rf "$DOTNET_ROOT/*"

	# Install dotnet
	DOTNET_ARCHIVE=dotnet6-$ARCH.tar.gz
	mkdir -p "$DOTNET_ROOT" && tar zxf "$DOTNET_ARCHIVE" -C "$DOTNET_ROOT"
}

install_mcc () {
	if [ "${ARCH,,}" == "arm64" ]; then
		mccDlLink=https://github.com/MCCTeam/Minecraft-Console-Client/releases/latest/download/MinecraftClient-linux-arm64.zip
	else
		mccDlLink=https://github.com/MCCTeam/Minecraft-Console-Client/releases/latest/download/MinecraftClient-linux-armv6.zip
	fi
	mccPath=/usr/bin/MinecraftConsoleClient

	mkdir "$mccPath"
	wget -nc -O $mccPath/MinecraftClient-linux-$ARCH.zip $mccDlLink
	echo A | unzip $mccPath/MinecraftClient-linux-$ARCH -d $mccPath
	rm $mccPath/MinecraftClient-linux-$ARCH.zip
	chmod +x $mccPath/MinecraftClient
	echo $mccPath/MinecraftClient > /usr/bin/mcc
	chmod +x /usr/bin/mcc
	mkdir ~/MinecraftConsoleClient

	# Add update command
	echo $updateMCC > /usr/bin/updatemcc
	chmod +x /usr/bin/updatemcc
}

ARCH='"$ARCH"'

if [ '"${INSTALLDOTNET,,}"' == "y" ] || [ '"$INSTALLDOTNET"' == "" ]; then
	install_dotnet
fi
install_mcc
'

$PREFIX/bin/startubuntu "$installMCC"
echo 'startubuntu "cd ~/MinecraftConsoleClient; mcc"' > $PREFIX/bin/mcc
chmod +x $PREFIX/bin/mcc
chmod +x $PREFIX/bin/updatemcc
ln -s $PREFIX/bin/ubuntu-fs/root/MinecraftConsoleClient ~/MinecraftConsoleClient
clear
echo 'Installation complete'
echo "Run 'mcc' to start Minecraft Console Client"
echo 'To update mcc run this installer again'
echo 'Minecraft Console Client config directory is at ~/MinecraftConsoleClient'
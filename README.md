You must have termux installed.

Run in termux to install Minecraft Console Client:

```bash
pkg update --assume-yes
pkg install wget --assume-yes
wget --no-cache --no-cookies -O - https://raw.githubusercontent.com/678435021/mcc-on-termux/master/mcc.sh > mcc-installer.sh
chmod +x mcc-installer.sh
./mcc-installer.sh
```

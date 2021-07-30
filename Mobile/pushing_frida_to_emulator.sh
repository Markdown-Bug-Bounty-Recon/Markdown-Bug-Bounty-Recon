#!/bin/bash -x

# FRIDA
newest_frida_version=$(frida --version)
phone_architecture=$(adb shell getprop ro.product.cpu.abi)

wget https://github.com/frida/frida/releases/download/"${newest_frida_version}"/frida-server-"${newest_frida_version}"-android-"${phone_architecture}".xz

unxz frida-server-"${newest_frida_version}"-android-"${phone_architecture}".xz

name_of_the_frida_server=frida-server-"${newest_frida_version}"-android-"${phone_architecture}"


adb root

adb shell rm data/local/frida

adb push "${PWD}"/"${name_of_the_frida_server}" /data/local/frida

adb shell chmod +x /data/local/frida
adb shell /data/local/frida &

rm "${name_of_the_frida_server}"

# DROZER
## Won't be achieved, because of incosistency in Drozer version vs Drozer Agent Version

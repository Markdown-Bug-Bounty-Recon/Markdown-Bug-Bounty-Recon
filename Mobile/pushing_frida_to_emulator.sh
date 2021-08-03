#!/bin/bash -x

# FRIDA
newest_frida_version=$(frida --version)
phone_architecture=$(adb shell getprop ro.product.cpu.abi)

wget https://github.com/frida/frida/releases/download/"${newest_frida_version}"/frida-server-"${newest_frida_version}"-android-"${phone_architecture}".xz

unxz frida-server-"${newest_frida_version}"-android-"${phone_architecture}".xz

name_of_the_frida_server=frida-server-"${newest_frida_version}"-android-"${phone_architecture}"


adb root

adb shell pkill frida
adb shell rm data/local/frida

adb push "${PWD}"/"${name_of_the_frida_server}" /data/local/frida

adb shell chmod +x /data/local/frida
adb shell /data/local/frida &

rm "${name_of_the_frida_server}"

# DROZER
## Won't be achieved, because of incosistency in Drozer version vs Drozer Agent Version

wget https://github.com/FSecureLABS/drozer/releases/download/2.3.4/drozer-agent-2.3.4.apk
drozer_agent=$(ls ./*drozer*)
adb install "${drozer_agent}"
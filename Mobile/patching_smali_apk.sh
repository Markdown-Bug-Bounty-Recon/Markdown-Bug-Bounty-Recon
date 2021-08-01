#!/bin/bash -x

usage(){

	echo "Usage: $0 -p [.APK name]" >&2
	echo ' -a Your apktool / smali directory which you want to patch'
    echo ' -k Your generated key to sign the app. IF YOU DONT HAVE IT, generate it with the command:'
    echo `  #keytool -genkey -alias myDomain -keyalg RSA -keysize 2048 -validity 7300 -keystore myKeyStore.jks -storepass myStrongPassword`
		exit 1

}

while getopts d:k: OPTION; do
	case $OPTION in
		d)
		apktool_dir="$OPTARG"
		;;
        k)
        key="$OPTARG"
        ;;
		?)
		usage
		;;
	esac
done

apktool b "$apktool_dir" -o "$apktool_dir".apk
patchedUnSigned_apk="$apktool_dir".apk
#package_name_fragment="$apktool_dir"

signing_apk.sh -p "$patchedUnSigned_apk" -k "$key" 

## Getting the name of the app to uninstall
#package_name=$(adb shell pm list packages | grep "$package_name_fragment" | cut -d : -f 2)

#adb uninstall "$package_name"
#adb install "$apktool_dir"patchedSignedApp.apk
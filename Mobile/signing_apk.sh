#!/bin/bash -x

usage(){

	echo "Usage: $0 -p [.APK name]" >&2
	echo ' -p Your package name you want to deassemble and decompile'
    echo ' -k Your generated key to sign the app. IF YOU DONT HAVE IT, generate it with the command:'
    echo `  #keytool -genkey -alias myDomain -keyalg RSA -keysize 2048 -validity 7300 -keystore myKeyStore.jks -storepass myStrongPassword`
		exit 1

}

while getopts p:k: OPTION; do
	case $OPTION in
		p)
		apk_UnSignedPackage="$OPTARG"
		;;
        k)
        key="$OPTARG"
        ;;
		?)
		usage
		;;
	esac
done


#keytool -genkey -alias myDomain -keyalg RSA -keysize 2048 -validity 7300 -keystore myKeyStore.jks -storepass myStrongPassword

name_of_the_app=$(echo "$apk_UnSignedPackage" | cut -d . -f 1)

apksigner sign --out "${name_of_the_app}"patchedSignedApp.apk --ks "$key" "$apk_UnSignedPackage" --key-pass myStrongPassword

jarsigner -keystore "$apk_UnSignedPackage"
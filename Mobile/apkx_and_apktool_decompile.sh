#!/bin/bash -x
usage(){

	echo "Usage: $0 -p [.APK name]" >&2
	echo ' -p Your package name you want to deassemble and decompile'
		exit 1

}

while getopts p: OPTION; do
	case $OPTION in
		p)
		package_name="$OPTARG"
		;;
		?)
		usage
		;;
	esac
done


name_without_ext=$( echo "${package_name}" | cut -d . -f 1)
location_of_the_apk=$("$PWD"/"$package_name")

if ! [ -d "$package_name" ]; then
mkdir "${package_name}"
fi

cd "${package_name}" || exit

mkdir "${name_without_ext}"_java
cd "${name_without_ext}"_java || exit
apkx "$location_of_the_apk"/"${package_name}"
cd ..

apktool d "$location_of_the_apk"/"${package_name}" -o "${name_without_ext}"_smali




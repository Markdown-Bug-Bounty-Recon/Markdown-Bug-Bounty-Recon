#!/bin/bash

usage(){

	echo "Usage: $0 -p [.APK name]" >&2
	echo ' -p Your package name you want to deassemble and decompile'
		exit 1

}

while getopts p OPTION; do
	case $OPTION in
		p)
		package_name="$OPTARG"
		;;
		?)
		usage
		;;
	esac
done

name_without_ext=$( "$package_name" | cut -d . -f 1)
mkdir "${name_without_ext}"_apktool
mkdir "${name_without_ext}"_apkx

apktool d "${package_name}" -o "${name_without_ext}"_apktool

cd "${name_without_ext}"_apkx || exit
apkx ../"${package_name}"


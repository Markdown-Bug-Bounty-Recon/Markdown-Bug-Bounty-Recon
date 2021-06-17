#!/bin/bash -x

usage(){

	echo "Usage: $0 -p [.APK name]" >&2
	echo ' -p Your package name you want to deassemble and decompile'
		exit 1

}

while getopts p: OPTION; do
	case $OPTION in
		p)
		package_name_fragment="$OPTARG"
		;;
		?)
		usage
		;;
	esac
done

package_name=$(adb shell pm list packages | grep "$package_name_fragment" | cut -d : -f 2)


package_path=$(adb shell pm path "${package_name}" | cut -d : -f 2)

adb pull "${package_path}" "${package_name}"

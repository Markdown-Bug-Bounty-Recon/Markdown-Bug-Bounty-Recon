#!/bin/bash -x

usage(){

	echo "Usage: $0 [-d DOMAIN]" >&2
	echo ' -d DOMAIN Specify your domain with address in format without protocol (e.g "chosen_domain.com")'
	echo ' -a ASN Number: Go to the site https://bgp.he.net/ and search for company that you are up to and enter their ASN number without "AS" prefix prefix [YOU NEED TO FIND THE VALID ASN NUMBER that has a IPv4 ranges connected to them!'
	echo ' Furthermore, please fill in the Acquisitions.txt file in order to scan Acquisitions too!'

		exit 1

}

#while getopts d: OPTION do
#	case $OPTION in
#		domain)
#		domain="$OPTARG"
#		;;
#		ASN)
#		ASN="$OPTARG"
#		;;
#		?)
#		usage
#		;;
#	esac
#done

while getopts d:a:u: OPTION; do
	case $OPTION in
		d)
		domain="$OPTARG"
		mkdir "${domain}"
		touch "${PWD}"/"${domain}"/roots.txt
		echo "${domain}" >> "${PWD}"/"${domain}"/roots.txt
		;;
		a)
		ASN="$OPTARG"
		;;
		u)
		USER_EXEC="$OPTARG"
		;;
		?)
		usage
		;;
	esac
done

 if [ -z "${USER_EXEC}" ]; then
 	USER_EXEC=root
 fi


scope-adding.sh -d "$domain"

CURRENTDATE=$(date +"%Y-%m-%d")
echo "$CURRENTDATE" > "$PWD"/"${domain}"/last-init-date.txt
mkdir -p "${domain}"/"${CURRENTDATE}"/"$domain"/tools-io

echo "${ASN}" > ./"${domain}"/asn.txt

if ! [ -f "./${domain}/Acquisitions.txt" ];then
	echo "There's already text file for Acquisitions"
else
	echo "Do you want to create Acquisitions.txt file to include"
fi

sort "${PWD}"/"${domain}"/roots.txt | uniq > "${PWD}"/"${domain}"/tmp_roots.txt && mv "${PWD}"/"${domain}"/tmp_roots.txt "${PWD}"/"${domain}"/roots.txt

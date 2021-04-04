#!/bin/bash

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


company_name=$(echo "${domain}" | cut -d . -f 1)
ASNs=$(amass intel -org "${company_name}" | cut -f 1 -d , )





parallel -l 1 -j 10 -k --verbose amass intel -active -asn {} >> "${PWD}"/"${domain}"/roots.txt ::: "${ASNs}" &
pid=$!

while kill -0 $pid 2> /dev/null; do
sort "${PWD}"/"${domain}"/roots.txt | uniq > "${PWD}"/"${domain}"/tmp_roots.txt && mv "${PWD}"/"${domain}"/tmp_roots.txt "${PWD}"/"${domain}"/roots.txt
sleep 30
done

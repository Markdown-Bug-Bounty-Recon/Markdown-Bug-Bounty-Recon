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

 if [ "$EUID" -ne 0 ]
   then echo "Please run as root"
   exit
 fi



 LAST_INIT_DATE=$(cat "$PWD"/"${domain}"/last-init-date.txt)

while read -r domain; do
 dir=$PWD/${domain}/${LAST_INIT_DATE}/"$domain"
 bin=$dir/tools-io/

 eyewitness -f "$bin"/"${domain}"_alive_subdomains.txt -d /tmp/Eyewitness
 mkdir "${bin}"/Eyewitness
 mv /tmp/Eyewitness "${bin}"/Eyewitness

done < "${PWD}"/"${domain}"/roots.txt

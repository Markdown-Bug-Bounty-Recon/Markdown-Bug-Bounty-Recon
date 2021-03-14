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


 LAST_INIT_DATE=$(cat "$PWD"/"${domain}"/last-init-date.txt)
 mkdir -p "${domain}"/"${LAST_INIT_DATE}"/tools-io
 dir=$PWD/${domain}/${LAST_INIT_DATE}
 bin=$dir/tools-io

if [ -f "/home/${USER_EXEC}/lists/resolvers.txt*" ]; then
 echo "resolvers.txt file exists"
else
 mkdir "/home/${USER_EXEC}/lists/"
 wget https://raw.githubusercontent.com/blechschmidt/massdns/master/lists/resolvers.txt -O "/home/${USER_EXEC}/lists/resolvers.txt"
fi

massdns --resolvers /home/"${USER_EXEC}"/lists/resolvers.txt --drop-user ${USER_EXEC} --drop-group ${USER_EXEC} -t AAAA "$bin"/"${domain}"_subdomains.txt -o J -w "${bin}"/"${domain}"_dns-resolved-ip.json
<"${bin}"/"${domain}"_dns-resolved-ip.json  jq '. | "\(.resolver) \(.name)"' | tr " " "," | tr "\"" " " | tr -s " " | awk '$1=$1' >> "$bin"/"${domain}"_subdomains_ip.txt

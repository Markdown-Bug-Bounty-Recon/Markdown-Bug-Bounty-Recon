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

while getopts d:a:u:p OPTION; do
	case $OPTION in
		d)
		domain="$OPTARG"
		;;
		a)
		ASN="$OPTARG"
		;;
		u)
		USER_EXEC="$OPTARG"
		;;
		p)
		NO_BRUTE=1
		;;
		?)
		usage
		;;
	esac
done

redCl="\e[0;31m\033[1m"
greenCl="\e[0;32m\033[1m"
yellowCl="\e[0;33m\033[1m"
blueCl="\e[0;34m\033[1m"
magentCl="\e[0;35m\033[1m"
cyanCl="\e[0;36m\033[1m"
endCl="\033[0m\e[0m"


echo -e "${redCl} INITIALIZATION.sh ${endCl}"
initialization.sh -d "$domain" -a "$ASN" -u "$USER_EXEC"
get-other-root-domains.sh -d "$domain" -u "$USER_EXEC" &
echo -e "${greenCl} GET-TECHNOLOGIES.sh ${endCl}"
get-technologies.sh -d "$domain" -u "$USER_EXEC"
echo -e "${yellowCl} GET-SUBDOMAINS-PASSIVELY.sh ${endCl}"
get-subdomains-passively.sh -d "$domain" -u "$USER_EXEC"
echo -e "${blueCl} GET-ALIVE-SUBDOMAINS.sh ${endCl}"
get-alive-subdomains.sh -d "$domain" -u "$USER_EXEC"
echo -e "${magentCl} GET-NOT-ALIVE-SUBDOMAINS.sh ${endCl}"
get-not-alive-subdomains-ip.sh -d "$domain" -u "$USER_EXEC"
echo -e "${cyanCl} EXTRACTING-JAVASCRIPT.sh ${endCl}"
# extracting-javascript.sh -d "$domain" -u "$USER_EXEC"
if [ $NO_BRUTE -ne 1 ]; then
	echo -e "${redCl} BRUTING-NOT-ALIVE-SUBDOMAINS.sh ${endCl}"
	bruting-not-alive-subdomains-ip.sh -d "$domain" -u "$USER_EXEC"
	echo -e "${redCl} BRUTING-NOT-ALIVE-SUBDOMAINS.sh ${endCl}"
	bruting-alive-subdomains.sh -d "$domain" -u "$USER_EXEC"
fi

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

initialization.sh -d "$domain" -a "$ASN" -u "$USER_EXEC"
get-subdomains.sh -d "$domain" -a "$ASN" -u "$USER_EXEC"
get-alive-subdomains.sh -d "$domain" -a "$ASN" -u "$USER_EXEC"
get-not-alive-subdomains-ip.sh -d "$domain" -a "$ASN" -u "$USER_EXEC"
bruting-not-alive-subdomains.sh -d "$domain" -a "$ASN" -u "$USER_EXEC"
bruting-alive-subdomains.sh -d "$domain" -a "$ASN" -u "$USER_EXEC"

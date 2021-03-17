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
 dir=$PWD/${domain}/${LAST_INIT_DATE}
 bin=$dir/tools-io
while read -r domain; do
	while read -r line;
	do
	  ip=$(echo "${line}" | awk -F"," '{print $1}')
	  subdomain=$(echo "${line}" | awk -F"," '{print $2}')
	  subdomain=${subdomain%?} # For some reason, without it there will be dot sign after .com e.g "subdomain.com."
	  mkdir "$bin"/not_alive_"${subdomain}"

	  masscan "${ip}" --ports 0-65535 ––rate 1000 -oX "${bin}"/not_alive_"${subdomain}"/masscan_grepable.json



	  # NMAP SCAN WITH -oG flag output

	  # nmap -T4 -A -p- -Pn -oN "${bin}"/not_alive_"${subdomain}"/nmap-results.txt -oX "${bin}"/not_alive_"${subdomain}"/nmap-results.xml $subdomain

	  # ----------------
	  #brutespray -f $bin/not_alive_${subdomain}/${domain}_${subdomain}_nmap.txt -o $bin/not_alive_${subdomain}/${domain}_${subdomain}_brutespray


	done < "${bin}"/"${domain}"_subdomains_ip.txt
done < "${PWD}"/"${domain}"/roots.txt

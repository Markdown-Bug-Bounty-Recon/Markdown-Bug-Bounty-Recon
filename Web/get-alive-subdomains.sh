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

bbrf use "$(echo "${domain}" | cut -f 1 -d .)"

 LAST_INIT_DATE=$(cat "$PWD"/"${domain}"/last-init-date.txt)
while read -r domain; do

	mkdir -p "${domain}"/"${LAST_INIT_DATE}"/"$domain"/tools-io
	dir=$PWD/${domain}/${LAST_INIT_DATE}/"$domain"
	bin=$dir/tools-io

			# We do the same thing as in get-subdomains-passively.sh again, but this time with -active flag
		bbrf scope in --wildcard --top | amass enum -active -d "${domain}" -o "$bin"/"${domain}"_subdomains_amass.txt 
		
		cat "$bin"/"${domain}"_subdomains_amass.txt >> "$bin"/"${domain}"_subdomains.txt
		rm "$bin"/"${domain}"_subdomains_amass.txt
		sort "$bin"/"${domain}"_subdomains.txt | uniq | tee "$bin"/tmp_"${domain}"_subdomains.txt && mv "$bin"/tmp_"${domain}"_subdomains.txt "$bin"/"${domain}"_subdomains.txt
 
 <"$bin"/"${domain}"_subdomains.txt httprobe | tee  -a "$bin"/"${domain}"_alive_subdomains.txt

 <"$bin"/"${domain}"_alive_subdomains.txt tr -d "/" | cut -d ":" -f 2 | sort | uniq -o "$bin"/"${domain}"_alive_subdomains_without_protocol.txt
 sdiff "$bin"/"${domain}"_subdomains.txt "$bin"/"${domain}"_alive_subdomains_without_protocol.txt | grep "<" | cut -d"<" -f1 | tr -d " " | tee "$bin"/tmp_"${domain}"_subdomains.txt && mv "$bin"/tmp_"${domain}"_subdomains.txt "$bin"/"${domain}"_subdomains.txt



 touch "$bin"/"${domain}"_alive-subdomain_bruting_amass.txt

 # Amass bruting
 parallel -a "$bin"/"${domain}"_alive_subdomains_without_protocol.txt -l 1 -j 10 -k --verbose amass enum -brute -d {} -o "$bin"/"${domain}"_subdomain_bruting_amass.txt


 sort "$bin"/"${domain}"_subdomain_bruting_amass.txt | uniq | tee "$bin"/"${domain}"_tmp_subdomain_bruting_amass.txt && mv "$bin"/"${domain}"_tmp_subdomain_bruting_amass.txt "$bin"/"${domain}"_subdomain_bruting_amass.txt

 wait
 cat "$bin"/"${domain}"_subdomain_bruting_amass.txt >> "$bin"/"${domain}"_alive_subdomains.txt

 <"$bin"/"${domain}"_alive_subdomains.txt favfreak.py -o "$bin"/"${domain}"_favfreak
 cat "$bin"/"${domain}"_favfreak >> "$bin"/"${domain}"_alive_subdomains.txt

 sort "$bin"/"${domain}"_alive_subdomains.txt | uniq | tee "$bin"/"${domain}"_tmp_alive_subdomains.txt && mv "$bin"/"${domain}"_tmp_alive_subdomains.txt "$bin"/"${domain}"_alive_subdomains.txt

 # puredns bruting
 


## Adding not alive domains to bbrf
"$bin"/"${domain}"_subdomains.txt bbrf domain add - -t type:not-alive -t from:framework-script -t date:"$(date +"%Y-%m-%d")"

 ## Adding alive domains to bbrf
 <"$bin"/"${domain}"_alive_subdomains.txt bbrf url add - -t type:alive -t from:framework-script -t date:"$(date +"%Y-%m-%d")"

done < "${PWD}"/"${domain}"/roots.txt

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


 if [ -z "${USER_EXEC}" ]; then
 	echo "You did not passed another ${USER} account, executing as root user"
 	USER_EXEC=root#!/bin/bash

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
 	echo "You did not passed another ${USER} account, executing as root user"
 	USER_EXEC=root
 else
 	echo "You passed another ${USER} account"
 fi


 mkdir "${domain}"
 LAST_INIT_DATE=$(cat "$PWD"/"${domain}"/last-init-date.sh)
 mkdir -p "${domain}"/"${LAST_INIT_DATE}"/tools-io
 dir=$PWD/${domain}/${LAST_INIT_DATE}
 bin=$dir/tools-io

 <"$bin"/"${domain}"_subdomains.txt httprobe | tee  -a "$bin"/"${domain}"_alive_subdomains.txt

 <"$bin"/"${domain}"_alive_subdomains.txt tr -d "/" | cut -d ":" -f 2 | sort | uniq > "$bin"/"${domain}"_alive_subdomains_without_protocol.txt
 sdiff "$bin"/"${domain}"_subdomains.txt "$bin"/"${domain}"_alive_subdomains_without_protocol.txt | grep "<" | cut -d"<" -f1 | tr -d " " | tee "$bin"/tmp_"${domain}"_subdomains.txt && mv "$bin"/tmp_"${domain}"_subdomains.txt "$bin"/"${domain}"_subdomains.txt

 	touch "$bin"/"${domain}"_alive-subdomain_bruting_amass.txt
 	while read -r subdomain;
 	do
 		amass enum -brute -d "${subdomain}" -src -o "$bin"/"${domain}"_subdomain_bruting_amass.txt &
 	done < "$bin"/"${domain}"_alive_subdomains.txt

  sort "$bin"/"${domain}"_subdomain_bruting_amass.txt | uniq | tee "$bin"/"${domain}"_tmp_subdomain_bruting_amass.txt && mv "$bin"/"${domain}"_tmp_subdomain_bruting_amass.txt "$bin"/"${domain}"_subdomain_bruting_amass.txt

 	wait
 	cat "$bin"/"${domain}"_subdomain_bruting_amass.txt >> "$bin"/"${domain}"_alive_subdomains.txt

  <"$bin"/"${domain}"_alive_subdomains.txt favfreak.py -o "$bin"/"${domain}"_favfreak

 else
 	echo "You passed another ${USER} account"
 fi


 mkdir "${domain}"
 LAST_INIT_DATE=$(cat $PWD/${domain}/last-init-date.sh)
 mkdir -p "${domain}"/${LAST_INIT_DATE}/tools-io
 dir=$PWD/${domain}/${LAST_INIT_DATE}
 bin=$dir/tools-io

 <"$bin"/"${domain}"_subdomains.txt httprobe | tee  -a "$bin"/"${domain}"_alive_subdomains.txt

 <"$bin"/"${domain}"_alive_subdomains.txt tr -d "/" | cut -d ":" -f 2 | sort | uniq > "$bin"/"${domain}"_alive_subdomains_without_protocol.txt
 sdiff "$bin"/"${domain}"_subdomains.txt "$bin"/"${domain}"_alive_subdomains_without_protocol.txt | grep "<" | cut -d"<" -f1 | tr -d " " | tee "$bin"/tmp_"${domain}"_subdomains.txt && mv "$bin"/tmp_"${domain}"_subdomains.txt "$bin"/"${domain}"_subdomains.txt

 	touch "$bin"/"${domain}"_alive-subdomain_bruting_amass.txt
 	while read -r subdomain;
 	do
 		amass enum -brute -d "${subdomain}" -src -o "$bin"/"${domain}"_subdomain_bruting_amass.txt &
 	done < "$bin"/"${domain}"_alive_subdomains.txt

  sort "$bin"/"${domain}"_subdomain_bruting_amass.txt | uniq | tee "$bin"/"${domain}"_tmp_subdomain_bruting_amass.txt && mv "$bin"/"${domain}"_tmp_subdomain_bruting_amass.txt "$bin"/"${domain}"_subdomain_bruting_amass.txt

 	wait
 	cat "$bin"/"${domain}"_subdomain_bruting_amass.txt >> "$bin"/"${domain}"_alive_subdomains.txt

  <"$bin"/"${domain}"_alive_subdomains.txt favfreak.py -o "$bin"/"${domain}"_favfreak

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

while read -r domain; do
	mkdir -p "${domain}"/"${LAST_INIT_DATE}"/"$domain"/tools-io
	dir=$PWD/${domain}/${LAST_INIT_DATE}/"$domain"
	bin=$dir/tools-io
	## Wappalyzer / Listing Technologies
	https_link=$(echo "${domain}" | httprobe)
	node "/home/${USER_EXEC}/tools/wappalyzer/src/drivers/npm/cli.js" "$https_link" -P | jq '.technologies[].name' | tee "$bin"/"${domain}"_technologies.txt

 # MANY OF THESE TOOLS ARE COMMENTED, BECAUSE AMASS ALREADY OFFERS ENUMERATION FROM DIFFERENT OUTPUTS AND APIs!

	## Crawling the website with hakrawler to find new roots, subdomain and javascript files
	#hakrawler -url "${domain}" -depth 2 -js -plain | tee "$bin"/"${domain}"_javascript_files.txt &
	#hakrawler -url "${domain}" -depth 1 -subs -usewayback -plain | tee -a "$bin"/"${domain}"_subdomains.txt
	#wait
	#sed -i 's/www.//' "$bin"/"${domain}"_subdomains.txt # Some of the output from hakrawler begin with 'www.' to make this output uniform we're using sed on it


	## Analyzing Javascript with SubDomainizer and subscraper
	#SubDomainizer.py -l "$bin"/"${domain}"_javascript_files.txt -o "$bin"/"${domain}"_subdomains_subdomainizer.txt


	# Subdomain Scraping
	amass enum -passive -d "${domain}" -o "$bin"/"${domain}"_subdomains_amass.txt &
	#subfinder -d "${domain}" -o "$bin"/"${domain}"_subdomains_subfinder.txt &
	#curl "https://tls.bufferover.run/dns?q=.${domain}" 2>/dev/null | jq .Results | cut -d ',' -f 3 | tr -d '\"' | tr -d ']' | tr -d '[' | tee -a "$bin"/"${domain}"_subdomains_cloud.txt & # YES I KNOW THAT THESE 'TR' LOOK TERRIBLE, WILL CHANGE IT TO SED SOMEDAY OR GREP
	wait

	# Fetching the final results
	cat "$bin"/"${domain}"_subdomains_amass.txt >> "$bin"/"${domain}"_subdomains.txt &
  #  cat "$bin"/"${domain}"_subdomains_subfinder.txt >> "$bin"/"${domain}"_subdomains.txt &
	#cat "$bin"/"${domain}"_subdomains_cloud.txt >> "$bin"/"${domain}"_subdomains.txt &
	#cat "$bin"/"${domain}"_subdomains_subdomainizer.txt >> "$bin"/"${domain}"_subdomains.txt &
	wait
	#Deleting the unnecessary
	rm "$bin"/"${domain}"_subdomains_amass.txt &
	#rm "$bin"/"${domain}"_subdomains_subfinder.txt &
	#rm "$bin"/"${domain}"_subdomains_cloud.txt &
	#rm "$bin"/"${domain}"_subdomains_subdomainizer.txt &
	wait

	sort "$bin"/"${domain}"_subdomains.txt | uniq | tee "$bin"/tmp_"${domain}"_subdomains.txt && mv "$bin"/tmp_"${domain}"_subdomains.txt "$bin"/"${domain}"_subdomains.txt

	regex_out_of_scope=$( cat ./"${domain}"/out-of-scope.regx)
	sed -i.old -E "/${regex_out_of_scope}/d" "$bin"/"${domain}"_subdomains.txt



	done < "${PWD}"/"${domain}"/roots.txt

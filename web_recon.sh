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
 	USER_EXEC=root
 else
 	echo "You passed another ${USER} account"
 fi

mkdir "${domain}"
if [ -f "./${domain}/Acquisitions.txt" ];then
	echo "There's already text file for Acquisitions"
else
	touch ./"${domain}"/Acquisitions.txt
fi

## Acquisitions



#while read p; do

#done Acquisitions



mkdir -p "${domain}"/bin
dir=$PWD/${domain}
bin=$dir/bin
## ASN Enumeration
 if [ -z "${ASN}" ]; then
	echo 'You did not supplied ASN number'
	touch "${bin}"/roots.txt # Making empty file
	echo "${domain}" >> "${bin}"/roots.txt
 else
 	amass intel --asn "$ASN" -o "${bin}"/roots.txt
 fi

 if [ "${UID}" -ne 0 ]; then
 	echo "You need to execute this command as SUDO "
 	echo "sudo <script>"
 	exit 1
 fi


  sort "${bin}"/roots.txt | uniq | tee "${bin}"/tmp_roots.txt && mv "${bin}"/tmp_roots.txt "${bin}"/roots.txt

# Getting resolvers for massdns ( we later use this )
 if [ -f "/home/${USER_EXEC}/lists/resolvers.txt*" ]; then
 	echo "resolvers.txt file exists"
 else
 	mkdir "/home/${USER_EXEC}/lists/"
 	wget https://raw.githubusercontent.com/blechschmidt/massdns/master/lists/resolvers.txt -O "/home/${USER_EXEC}/lists/resolvers.txt"
 fi

# HERE'S THE PLACE FOR 'WHILE' STATEMENT
while read -r domain; do
	mkdir "$bin"/"${domain}"
	bin=$dir/bin/${domain}
	## Wappalyzer / Listing Technologies
	https_link=$(echo "${domain}" | httprobe)
	node "/home/${USER_EXEC}/tools/wappalyzer/src/drivers/npm/cli.js" "$https_link" -P | jq '.technologies[].name' | tee "$bin"/"${domain}"_technologies.txt

	## Crawling the website with hakrawler to find new roots, subdomain and javascript files

	hakrawler -url "${domain}" -depth 2 -js -plain | tee "$bin"/"${domain}"_javascript_files.txt &

	hakrawler -url "${domain}" -depth 1 -subs -usewayback -plain | tee -a "$bin"/"${domain}"_subdomains.txt 
	wait
	sed -i 's/www.//' "$bin"/"${domain}"_subdomains.txt # Some of the output from hakrawler begin with 'www.' to make this output uniform we're using sed on it 


	## Analyzing Javascript with SubDomainizer and subscraper
	SubDomainizer.py -l "$bin"/"${domain}"_javascript_files.txt -o "$bin"/"${domain}"_subdomains_subdomainizer.txt


	# Subdomain Scraping
	amass enum -d "${domain}" -o "$bin"/"${domain}"_subdomains_amass.txt &
	subfinder -d "${domain}" -o "$bin"/"${domain}"_subdomains_subfinder.txt &
	curl "https://tls.bufferover.run/dns?q=.${domain}" 2>/dev/null | jq .Results | cut -d ',' -f 3 | tr -d '\"' | tr -d ']' | tr -d '[' | tee -a "$bin"/"${domain}"_subdomains_cloud.txt & # YES I KNOW THAT THESE 'TR' LOOK TERRIBLE, WILL CHANGE IT TO SED SOMEDAY OR GREP
	wait

	# Fetching the final results
	cat "$bin"/"${domain}"_subdomains_amass.txt >> "$bin"/"${domain}"_subdomains.txt & 
    cat "$bin"/"${domain}"_subdomains_subfinder.txt >> "$bin"/"${domain}"_subdomains.txt &
	cat "$bin"/"${domain}"_subdomains_cloud.txt >> "$bin"/"${domain}"_subdomains.txt &
	cat "$bin"/"${domain}"_subdomains_subdomainizer.txt >> "$bin"/"${domain}"_subdomains.txt & 
	wait
	#Deleting the unnecessary
	rm "$bin"/"${domain}"_subdomains_amass.txt &
	rm "$bin"/"${domain}"_subdomains_subfinder.txt &
	rm "$bin"/"${domain}"_subdomains_cloud.txt &
	rm "$bin"/"${domain}"_subdomains_subdomainizer.txt &
	wait
	# Checking if these subdomains are alive

	sort "$bin"/"${domain}"_subdomains.txt | uniq | tee "$bin"/tmp_"${domain}"_subdomains.txt && mv "$bin"/tmp_"${domain}"_subdomains.txt "$bin"/"${domain}"_subdomains.txt 

	# Another while loop here for subdomains bruting with hyper-processing
	
	touch "$bin"/"${domain}"_subdomain_bruting_amass.txt 
	#while read -r subdomain;
	#do
	#	amass enum -brute -d "${subdomain}" -src -o "$bin"/"${domain}"_subdomain_bruting_amass.txt &
	#done < "$bin"/"${domain}"_subdomains.txt 
	

	wait
	cat "$bin"/"${domain}"_subdomain_bruting_amass.txt >> "$bin"/"${domain}"_subdomains.txt

	sort "$bin"/"${domain}"_subdomains.txt | uniq | tee -a "$bin"/tmp_"${domain}"_subdomains.txt && mv "$bin"/tmp_"${domain}"_subdomains.txt "$bin"/"${domain}"_subdomains.txt

	 <"$bin"/"${domain}"_subdomains.txt httprobe | tee  -a "$bin"/"${domain}"_alive_subdomains.txt



	#Small script to compare ${domain}_subdomains with alive to delete all alive lines that are in subdomains and pipe it to ${domain}_not_alive_subdomains.txt

	<"$bin"/"${domain}"_alive_subdomains.txt tr -d "/" | cut -d ":" -f 2 | sort | uniq > "$bin"/"${domain}"_alive_subdomains_without_protocol.txt

	sdiff "$bin"/"${domain}"_subdomains.txt "$bin"/"${domain}"_alive_subdomains_without_protocol.txt | grep "<" | cut -d"<" -f1 | tr -d " " | tee "$bin"/tmp_"${domain}"_subdomains.txt && mv "$bin"/tmp_"${domain}"_subdomains.txt "$bin"/"${domain}"_subdomains.txt
	


	rm "$bin"/"${domain}"_alive_subdomains_without_protocol.txt

	# Favfreak
	<"$bin"/"${domain}"_alive_subdomains.txt favfreak.py -o "$bin"/"${domain}"_favfreak
	# Port scanning not alive hosts


	massdns --resolvers /home/"${USER_EXEC}"/lists/resolvers.txt --drop-user ${USER_EXEC} --drop-group ${USER_EXEC} -t AAAA "$bin"/"${domain}"_subdomains.txt -o J -w "${bin}"/"${domain}"_dns-resolved-ip.json
	<"${bin}"/"${domain}"_dns-resolved-ip.json  jq '. | "\(.resolver) \(.name)"' | tr " " "," | tr "\"" " " | tr -s " " | awk '$1=$1' >> "$bin"/"${domain}"_subdomains_ip.txt



	while read -r line; 
	do
		ip=$(echo "${line}" | awk -F"," '{print $1}')
		subdomain=$(echo "${line}" | awk -F"," '{print $2}')
		subdomain=${subdomain%?} # For some reason, without it there will be dot sign after .com e.g "subdomain.com."
		mkdir "$bin"/not_alive_"${subdomain}"

		masscan "${ip}" --ports 0-65535 ––rate 1000 -oJ "${bin}"/not_alive_"${subdomain}"/masscan_grepable.json



		# NMAP SCAN WITH -oG flag output
		
		# nmap -T4 -A -p- -Pn -oN "${bin}"/not_alive_"${subdomain}"/nmap-results.txt -oX "${bin}"/not_alive_"${subdomain}"/nmap-results.xml $subdomain

		# ----------------
		#brutespray -f $bin/not_alive_${subdomain}/${domain}_${subdomain}_nmap.txt -o $bin/not_alive_${subdomain}/${domain}_${subdomain}_brutespray


	done < ${bin}/${domain}_subdomains_ip.txt

	wait

	for alive_subdomain in $(cat "${bin}"/"${domain}"_alive_subdomains.txt)
	do
		
		alive_subdomain_folder_name=$(echo "${alive_subdomain}" | tr / _ ) # Because in creation of directories, the '/' letter is not escaped we need to cut out only domain.com and get rid of 'https://'' 
		
		mkdir "${bin}"/alive_"${alive_subdomain_folder_name}" 
		mkdir "${bin}"/alive_"${alive_subdomain_folder_name}"/"${alive_subdomain_folder_name}"_nuclei_op 

		nuclei -target "${alive_subdomain}" -t "/home/${USER_EXEC}/tools/nuclei-templates/cves/*.yaml" -c 60 -o  "$bin"/alive_"${alive_subdomain_folder_name}"/"${alive_subdomain_folder_name}"_nuclei_op/cves.txt &
		nuclei -target "${alive_subdomain}" -t "/home/${USER_EXEC}/tools/nuclei-templates/files/*.yaml" -c 60 -o  "$bin"/alive_"${alive_subdomain_folder_name}"/"${alive_subdomain_folder_name}"_nuclei_op/files.txt & 
		nuclei -target "${alive_subdomain}" -t "/home/${USER_EXEC}/tools/nuclei-templates/panels/*.yaml" -c 60 -o  "$bin"/alive_"${alive_subdomain_folder_name}"/"${alive_subdomain_folder_name}"_nuclei_op/panels.txt & 
		nuclei -target "${alive_subdomain}" -t "/home/${USER_EXEC}/tools/nuclei-templates/security-misconfiguration/*.yaml" -c 60 -o  "$bin"/alive_"${alive_subdomain_folder_name}"/"${alive_subdomain_folder_name}"_nuclei_op/security-misconfiguration.txt & 
		nuclei -target "${alive_subdomain}" -t "/home/${USER_EXEC}/tools/nuclei-templates/technologies/*.yaml" -c 60 -o  "$bin"/alive_"${alive_subdomain_folder_name}"/"${alive_subdomain_folder_name}"_nuclei_op/technologies.txt &
		nuclei -target "${alive_subdomain}" -t "/home/${USER_EXEC}/tools/nuclei-templates/tokens/*.yaml" -c 60 -o  "$bin"/alive_"${alive_subdomain_folder_name}"/"${alive_subdomain_folder_name}"_nuclei_op/tokens.txt &
		nuclei -target "${alive_subdomain}" -t "/home/${USER_EXEC}/tools/nuclei-templates/vulnerabilities/*.yaml" -c 60 -o  "$bin"/alive_"${alive_subdomain_folder_name}"/"${alive_subdomain_folder_name}"_nuclei_op/vulnerabilities.txt & 
		nuclei -target "${alive_subdomain}" -t "/home/${USER_EXEC}/tools/nuclei-templates/subdomain-takeover/*.yaml" -c 60 -o  "$bin"/alive_"${alive_subdomain_folder_name}"/"${alive_subdomain_folder_name}"_nuclei_op/subdomain-takeover.txt &
		wait
	done
	
	# Javascript work

	mkdir -p "${bin}"/javascript_work/scripts &
	mkdir -p "${bin}"/javascript_work/scriptsresponse &
	mkdir -p "${bin}"/javascript_work/endpoints &
	mkdir -p "${bin}"/javascript_work/responsebody &
	mkdir -p "${bin}"/javascript_work/headers &
	wait

	jsep()
{
		response(){
		echo "Gathering Response"       
		        while read -r x; do
		        NAME=$(echo "$x" | tr / _ )
		        curl -X GET -H "X-Forwarded-For: evil.com" "$x" -I | tee -a "${bin}/javascript_work/headers/$NAME" 
		        curl -s -X GET -H "X-Forwarded-For: evil.com" -L "$x" |tee -a "${bin}/javascript_work/responsebody/$NAME"
		done < "${bin}"/"${domain}"_alive_subdomains.txt
		}

		jsfinder(){
		echo "Gathering JS Files"       
		for x in $(ls "${bin}/javascript_work/responsebody"); do
		        echo -e "\n\n${RED}${x}${NC}\n\n"
		        END_POINTS=$( <"${bin}/javascript_work/responsebody/${x}"  grep -Eoi "src=\"[^>]+></script>" | cut -d '"' -f 2)
		        for end_point in $END_POINTS; do
		                len=$(echo "${end_point}" | grep "http" | wc -c)
		                mkdir "${bin}/javascript_work/scriptsresponse/$x/" > /dev/null 2>&1
		                URL=${end_point}
		                if [ "${len}" == 0 ]
		                then
		                        URL="https://${x}${end_point}"
		                fi
		                file=$(basename "${end_point}")
		                curl -X GET "${URL}" -L  | tee "${bin}/javascript_work/scriptsresponse/${x}/${file}"
		                js-beautify -f "${bin}/javascript_work/scriptsresponse/${x}/${file}" -o "${bin}/javascript_work/scriptsresponse/${x}/${file}"
		                echo "${URL}" |  sed  's/http:__//' | sed  's/https:__//' | tee -a "${bin}/javascript_work/scripts/${x}"
		        done
		done
		}
		response
		jsfinder

		}
	jsep

	dir=$PWD/${domain}
	bin=${dir}/bin

done < "${bin}"/roots.txt
chown -R "${USER_EXEC}" "${domain}"

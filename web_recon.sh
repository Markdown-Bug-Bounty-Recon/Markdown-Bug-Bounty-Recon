#!/bin/bash -xv

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

while getopts d: OPTION; do
	case $OPTION in
		d)
		domain="$OPTARG"
		;;
		a)
		ASN="$OPTARG"
		;;
		?)
		usage
		;;
	esac
done

dirsearchWordlist=~/tools/dirsearch/db/dicc.txt
massdnsWordlist=~/tools/SecLists/Discovery/DNS/clean-jhaddix-dns.txt

mkdir ${domain}
if [ -f "./${domain}/Acquisitions.txt" ];then
	echo "There's already text file for Acquisitions"
else
	touch ./${domain}/Acquisitions.txt
fi

## Acquisitions



#while read p; do

#done Acquisitions



mkdir -p ./${domain}/bin
dir=$PWD/${domain}
bin=$dir/bin
## ASN Enumeration
if [ $ASN -z ]; then
	echo 'You did not supplied ASN number'
	touch $bin/roots.txt # Making empty file
	echo "${domain}" >> $bin/roots.txt

else

	amass intel --asn $ASN -o $bin/roots.txt
fi


# HERE'S THE PLACE FOR 'WHILE' STATEMENT
for domain in $(cat ${bin}/roots.txt); do
	mkdir $bin/${domain}
	bin=$dir/bin/${domain}
	## Wappalyzer / Listing Technologies
	https_link=$(echo ${domain} | httprobe)
	node ~/tools/wappalyzer/src/drivers/npm/cli.js $https_link -P | jq '.technologies[].name' | tee $bin/${domain}_technologies.txt

	## Crawling the website with hakrawler to find new roots, subdomain and javascript files

	hakrawler -url ${domain} -depth 2 -js -plain | tee $bin/${domain}_javascript_files.txt

	hakrawler -url ${domain} -depth 1 -subs -usewayback -plain | tee -a $bin/${domain}_subdomains.txt
	sed -i 's/www.//' $bin/${domain}_subdomains.txt # Some of the output from hakrawler begin with 'www.' to make this output uniform we're using sed on it 


	## Analyzing Javascript with SubDomainizer and subscraper

	SubDomainizer.py -l $bin/${domain}_javascript_files.txt -o $bin/${domain}_subdomains_subdomainizer.txt
	uniq -u $bin/${domain}_subdomains.txt $bin/${domain}_subdomains_subdomainizer.txt | tee -a $bin/${domain}_subdomains.txt


	# Subdomain Scraping
	amass enum -d ${domain} -o $bin/${domain}_subdomains_amass.txt
	uniq -u $bin/${domain}_subdomains.txt $bin/${domain}_subdomains_amass.txt   | tee -a $bin/${domain}_subdomains.txt
	rm $bin/${domain}_subdomains_amass.txt

	subfinder -d ${domain} -o $bin/${domain}_subdomains_subfinder.txt
	uniq -u $bin/${domain}_subdomains.txt $bin/${domain}_subdomains_subfinder.txt | tee -a $bin/${domain}_subdomains.txt
	rm $bin/${domain}_subdomains_subfinder.txt

	## From cloud ranges
	curl 'https://tls.bufferover.run/dns?q=.${domain}' 2>/dev/null | jq .Results | cut -d ',' -f 3 | tr -d '\"' | tr -d ']' | tr -d '[' | tee -a $bin/${domain}_subdomains_cloud.txt # YES I KNOW THAT THESE 'TR' LOOK TERRIBLE, WILL CHANGE IT TO SED SOMEDAY OR GREP
	uniq -u  $bin/${domain}_subdomains.txt $bin/${domain}_subdomains_cloud.txt | tee -a $bin/${domain}_subdomains.txt
	rm $bin/${domain}_subdomains_cloud.txt
	#github-subdomains.py -d ${domain} -o $bin/{domain}_subdomain_github.txt

	# Checking if these subdomains are alive

	cat $bin/${domain}_subdomains.txt | httprobe | tee -a $bin/${domain}_alive_subdomains.txt


	# Another while loop here for subdomains bruting
	#while read subdomain;
	#do
		#amass enum -brute -d ${subdomain} -src -o $bin/${domain}_subdomain_bruting_amass.txt

	#done < $bin/${domain}_alive_subdomains.txt

	uniq -u $bin/${domain}_subdomains.txt $bin/${domain}_subdomain_bruting_amass.txt | tee -a $bin/${domain}_subdomains.txt

	cat $bin/${domain}_subdomains.txt | httprobe | tee -a $bin/${domain}_alive_subdomains.txt

	#Small script to compare ${domain}_subdomains with alive to delete all alive lines that are in subdomains and pipe it to ${domain}_not_alive_subdomains.txt

	cat $bin/${domain}_alive_subdomains.txt | tr -d "/" | cut -d ":" -f 2 > $bin/${domain}_alive_subdomains_without_protocol.txt
	grep -v -x $bin/${domain}_alive_subdomains_without_protocol.txt $bin/${domain}_subdomains.txt | tee $bin/${domain}_subdomains.txt
	rm $bin/${domain}_alive_subdomains_without_protocol.txt

	# Favfreak
	cat $bin/${domain}_alive_subdomains.txt | favfreak.py -o $bin/${domain}_favfreak
	# Port scanning with not alive hosts

	for subdomain in $(cat ${bin}/${domain}_subdomains.txt); do
		mkdir $bin/not_alive_${subdomain}
		#dnmasscan ${subdomain} -oG "$bin/not_alive_${subdomain}/${subdomain}_masscan.log"

		# NMAP SCAN WITH -oG flag output

		# ----------------
		#brutespray -f $bin/not_alive_${subdomain}/${domain}_${subdomain}_nmap.txt -o $bin/not_alive_${subdomain}/${domain}_${subdomain}_brutespray
		

		# Cleaning directories that are empty
		#if [ "$(ls -A $bin/not_alive_${subdomain}/${domain}_${subdomain}_brutespray)" ];
		#then
		#	echo ''
		#else
		#	rm -rf $bin/not_alive_${subdomain}/${domain}_${subdomain}_brutespray
		#fi

		#if [ "$(ls -A $bin/not_alive_${subdomain})" ];
		#then
		#	echo ''
		#else
		#	rm -rf $bin/not_alive_${subdomain}
		#fi


	done


	for alive_subdomain in $(cat ${bin}/${domain}_alive_subdomains.txt); do
		
		alive_subdomain_folder_name=$(echo ${alive_subdomain} | tr -d "/" | cut -d ":" -f 2) # Because in creation of directories, the '/' letter is not escaped we need to cut out only domain.com and get rid of 'https://''
		
		mkdir ${bin}/alive_${alive_subdomain_folder_name}
		mkdir ${bin}/alive_${alive_subdomain_folder_name}/${alive_subdomain_folder_name}_nuclei_op

		nuclei -target ${alive_subdomain} -t "/home/penelope/tools/nuclei-templates/cves/*.yaml" -c 60 -o  $bin/alive_${alive_subdomain_folder_name}/${alive_subdomain_folder_name}_nuclei_op/cves.txt
		nuclei -target ${alive_subdomain} -t "/home/penelope/tools/nuclei-templates/files/*.yaml" -c 60 -o  $bin/alive_${alive_subdomain_folder_name}/${alive_subdomain_folder_name}_nuclei_op/files.txt
		nuclei -target ${alive_subdomain} -t "/home/penelope/tools/nuclei-templates/panels/*.yaml" -c 60 -o  $bin/alive_${alive_subdomain_folder_name}/${alive_subdomain_folder_name}_nuclei_op/panels.txt
		nuclei -target ${alive_subdomain} -t "/home/penelope/tools/nuclei-templates/security-misconfiguration/*.yaml" -c 60 -o  $bin/alive_${alive_subdomain_folder_name}/${alive_subdomain_folder_name}_nuclei_op/security-misconfiguration.txt
		nuclei -target ${alive_subdomain} -t "/home/penelope/tools/nuclei-templates/technologies/*.yaml" -c 60 -o  $bin/alive_${alive_subdomain_folder_name}/${alive_subdomain_folder_name}_nuclei_op/technologies.txt
		nuclei -target ${alive_subdomain} -t "/home/penelope/tools/nuclei-templates/tokens/*.yaml" -c 60 -o  $bin/alive_${alive_subdomain_folder_name}/${alive_subdomain_folder_name}_nuclei_op/tokens.txt
		nuclei -target ${alive_subdomain} -t "/home/penelope/tools/nuclei-templates/vulnerabilities/*.yaml" -c 60 -o  $bin/alive_${alive_subdomain_folder_name}/${alive_subdomain_folder_name}_nuclei_op/vulnerabilities.txt
		nuclei -target ${alive_subdomain} -t "/home/penelope/tools/nuclei-templates/subdomain-takeover/*.yaml" -c 60 -o  $bin/alive_${alive_subdomain_folder_name}/${alive_subdomain_folder_name}_nuclei_op/subdomain-takeover.txt
	done
	
	# Javascript work

	mkdir -p ${bin}/javascript_work/scripts
	mkdir -p ${bin}/javascript_work/scriptsresponse
	mkdir -p ${bin}/javascript_work/endpoints
	mkdir -p ${bin}/javascript_work/responsebody
	mkdir -p ${bin}/javascript_work/headers

	jsep()
{
		response(){
		echo "Gathering Response"       
		        for x in $(cat ${bin}/${domain}_alive_subdomains.txt); do
		        NAME=$(echo $x | awk -F/ '{print $3}')
		        curl -X GET -H "X-Forwarded-For: evil.com" $x -I | tee -a "${bin}/javascript_work/headers/$NAME" 
		        curl -s -X GET -H "X-Forwarded-For: evil.com" -L $x |tee -a "${bin}/javascript_work/responsebody/$NAME"
		done
		}

		jsfinder(){
		echo "Gathering JS Files"       
		for x in $(ls "${bin}/javascript_work/responsebody"); do
		        printf "\n\n${RED}${x}${NC}\n\n"
		        END_POINTS=$(cat "${bin}/javascript_work/responsebody/${x}" | grep -Eoi "src=\"[^>]+></script>" | cut -d '"' -f 2)
		        for end_point in $END_POINTS; do
		                len=$(echo ${end_point} | grep "http" | wc -c)
		                mkdir "${bin}/javascript_work/scriptsresponse/$x/" > /dev/null 2>&1
		                URL=${end_point}
		                if [ ${len} == 0 ]
		                then
		                        URL="https://${x}${end_point}"
		                fi
		                file=$(basename ${end_point})
		                curl -X GET ${URL} -L > "${bin}/javascript_work/scriptsresponse/${x}/${file}"
		                echo ${URL} | tee -a "${bin}/javascript_work/scripts/${x}"
		        done
		done
		}

		endpoints()
		{
		echo "Gathering Endpoints"
		for domain in $(ls ${bin}/javascript_work/scriptsresponse); do
		        #looping through files in each domain
		        mkdir ${bin}/javascript_work/endpoints/${domain}
		        for file in $(ls ${bin}/javascript_work/scriptsresponse/${domain}); do
		                ruby ~/tools/relative-url-extractor/extract.rb ${bin}/javascript_work/scriptsresponse/${domain}/$file | tee -a endpoints/${domain}/$file 
		        done
		done

		}
		response
		jsfinder
		endpoints
		}
	jsep




dir=$PWD/${domain}
bin=${dir}/bin

done < ${bin}/roots.txt



#!/bin/bash

usage(){

	echo "Usage: $0 [-d DOMAIN]" >&2
	echo ' -d DOMAIN Specify your domain with address in format without protocol (e.g "chosen_domain.com")'
	echo ' -a ASN Number: Go to the site https://bgp.he.net/ and search for company that you are up to and enter their ASN number without "AS" prefix prefix [YOU NEED TO FIND THE VALID ASN NUMBER that has a IPv4 ranges connected to them!'
	echo ' Furthermore, please fill in the Acquisitions.txt file in order to scan Acquisitions too!'

		exit 1

}

while getopts d: OPTION
do
	case $OPTION in
		d)
		domain="$OPTARG"
		;;
		a)
		ASN="$OPTARG"
		?)
		usage
		;;
	esac
done

initialization.sh
## Acquisitions



#while read p 
#do

#done < Acquisitions


mkdir command_output
dir=$PWD/command_output 
bin=$PWD/command_output/bin
## ASN Enumeration
amass intel --asn $ASN -o $bin/roots.txt

# HERE'S THE PLACE FOR 'WHILE' STATEMENT

## Wappalyzer / Listing Technologies
node ~/tools/wappalyzer/src/drivers/npm/cli.js $domain -P | jq '.technologies[].name' | tee $bin/${domain}_technologies.txt

## Crawling the website with hakrawler to find new roots, subdomain and javascript files

hakrawler -url $domain -depth 1 -js -plain | tee $bin/${domain}_javascript_files.txt
hakrawler -url tesla.com -depth 1 -subs -usewayback -plain | tee -a $bin/${domain}_subdomains.txt
## Analyzing Javascript with SubDomainizer and subscraper

SubDomainizer.py -l ${domain}_javascript_files.txt -o $/bin/${domain}_subdomains_domainizer.txt
uniq -u $bin/${domain}_subdomains_subdomainizer.txt  $bin/${domain}_subdomains.txt | tee -a $bin/${domain}_subdomains.txt


# Subdomain Scraping
amass enum -d $domain -o $bin/${domain}_subdomain_amass.txt
uniq -u $bin/${domain}_subdomains_amass.txt  $bin/${domain}_subdomains.txt | tee -a $bin/{domain}_subdomains.txt
rm $bin/${domain}_subdomains_amass.txt

subfinder -d $domain -o $bin/${domain}_subdomains_subfinder.txt
uniq -u $bin/${domain}_subdomains_subfinder.txt  $bin/${domain}_subdomains.txt | tee -a $bin/${domain}_subdomains.txt
rm $bin/${domain}_subdomains_subfinder.txt

## From cloud ranges
curl 'https://tls.bufferover.run/dns?q=.defcon.org' 2>/dev/null | jq .Results | cut -d ',' -f 3 | tr -d '\"' | tr -d ']' | tr -d '[' | tee $bin/${domain}_subdomains_cloud.txt # YES I KNOW THAT THESE 'TR' LOOK TERRIBLE, WILL CHANGE IT TO SED SOMEDAY OR GREP
uniq -u $bin/${domain}_subdomains_cloud.txt  $bin/${domain}_subdomains.txt | tee -a $bin/${domain}_subdomains.txt
rm $bin/${domain}_subdomains_cloud.txt
#github-subdomains.py -d $domain -o $bin/{domain}_subdomain_github.txt

# Checking if these subdomains are alive

cat $bin/${domain}_subdomains.txt | httprobe | tee $bin/${domain}_alive_subdomains.txt
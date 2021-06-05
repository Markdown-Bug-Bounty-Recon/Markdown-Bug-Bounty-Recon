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

	while read -r alive_subdomain; do
		alive_subdomain_folder_name=$(echo "${alive_subdomain}" | tr / _ ) # Because in creation of directories, the '/' letter is not escaped we need to cut out only domain.com and get rid of 'https://''

		mkdir "${dir}"/tools-io/alive_"${alive_subdomain_folder_name}"
		bin="${dir}"/tools-io/alive_"${alive_subdomain_folder_name}"

		mkdir -p "${bin}"/javascript_work/scripts &
		mkdir -p "${bin}"/javascript_work/endpoints &
		mkdir -p "${bin}"/javascript_work/no-endpoints &
		mkdir -p "${bin}"/javascript_work/output &
		mkdir -p "${bin}"/javascript_work/script-links &


		wait

#		bin=$dir/tools-io/alive_"${alive_subdomain_folder_name}"/javascript_work/
#		gau "${alive_subdomain}" |grep -iE '\.js'|grep -ivE '\.json'|sort -u  >> "${bin}"/scripts/"${alive_subdomain_folder_name}"JS.txt
		#< "${bin}"/scripts/"${alive_subdomain_folder_name}"JS.txt xargs -n2 -I@ bash -c "echo -e '\n[URL]: @\n';linkfinder -i @ -o cli" >> "${bin}"/endpoints/"${alive_subdomain_folder_name}"PathsWithUrl.txt
#		< "${bin}"/endpoints/"${alive_subdomain_folder_name}"PathsWithUrl.txt grep -iv '[URL]:'||sort -u > "${bin}"/no-endpoints/"${alive_subdomain_folder_name}"/paypalJSPathsNoUrl.txt
#		< "${bin}"/no-endpoints/"${alive_subdomain_folder_name}"/"${alive_subdomain_folder_name}"JSPathsNoUrl.txt python3 collector.py "${bin}"/output/"${alive_subdomain_folder_name}"_output

#		getsrc "${alive_subdomain}" >> "${bin}"/script-links/"${alive_subdomain_folder_name}"_output
		#< "${bin}"/scripts/"${alive_subdomain_folder_name}"JS.txt xargs -n2 -I @ bash -c 'echo -e "\n[URL] @\n";python3 linkfinder -i @ -o cli' >> "${bin}"/secrets/"${alive_subdomain_folder_name}"JSSecrets.txt
# ffuf -u "${alive_subdomain}" -w /home/penelope/SecLists/Javascript-URLs/js-wordlist.txt -t 200 >> "${bin}"/endpoints/"${alive_subdomain_folder_name}"PathsWithUrl.txt


	done < "$bin"/"${domain}"_alive_subdomains.txt


done < "${PWD}"/"${domain}"/roots.txt













#jsep()
#{
#  response(){
#  echo "Gathering Response"
#          while read -r x; do
#          NAME=$(echo "$x" | tr / _ )
#          curl -X GET -H "X-Forwarded-For: evil.com" "$x" -I | tee -a "${bin}/javascript_work/headers/$NAME"
#          curl -s -X GET -H "X-Forwarded-For: evil.com" -L "$x" |tee -a "${bin}/javascript_work/responsebody/$NAME"
#  done < "${bin}"/"${domain}"_alive_subdomains.txt
#  }
#
#  jsfinder(){
#  echo "Gathering JS Files"
#  for x in ${bin}/javascript_work/responsebody/; do
#          echo -e "\n\n${RED}${x}${NC}\n\n"
#          END_POINTS=$( <"${bin}/javascript_work/responsebody/${x}"  grep -Eoi "src=\"[^>]+></script>" | cut -d '"' -f 2)
#          for end_point in $END_POINTS; do
#                  len=$(echo "${end_point}" | grep "http" | wc -c)
#                  mkdir "${bin}/javascript_work/scriptsresponse/$x/" > /dev/null 2>&1
#                  URL=${end_point}
#                  if [ "${len}" == 0 ]
#                  then
#                          URL="https://${x}${end_point}"
#                  fi
#                  file=$(basename "${end_point}")
#                  curl -X GET "${URL}" -L  | tee "${bin}/javascript_work/scriptsresponse/${x}/${file}"
#                  js-beautify -f "${bin}/javascript_work/scriptsresponse/${x}/${file}" -o "${bin}/javascript_work/scriptsresponse/${x}/${file}"
#                  echo "${URL}" |  sed  's/http:__//' | sed  's/https:__//' | tee -a "${bin}/javascript_work/scripts/${x}"
#          done
#  done
#  }
#  response
#  jsfinder

#  }
#jsep

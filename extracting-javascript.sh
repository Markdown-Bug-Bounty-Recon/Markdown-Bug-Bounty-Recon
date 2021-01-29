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
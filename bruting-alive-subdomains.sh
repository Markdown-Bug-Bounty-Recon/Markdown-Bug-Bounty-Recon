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

 LAST_INIT_DATE=$(cat "$PWD"/"${domain}"/last-init-date.txt)
 dir=$PWD/${domain}/${LAST_INIT_DATE}
 bin=$dir/tools-io

while read -r alive_subdomain;
do

  alive_subdomain_folder_name=$(echo "${alive_subdomain}" | tr / _ ) # Because in creation of directories, the '/' letter is not escaped we need to cut out only domain.com and get rid of 'https://''

  mkdir "${bin}"/alive_"${alive_subdomain_folder_name}"
  mkdir "${bin}"/alive_"${alive_subdomain_folder_name}"/"${alive_subdomain_folder_name}"_nuclei_op

  nuclei -target "${alive_subdomain}" -t "/home/${USER_EXEC}/tools/nuclei-templates/cves/**/*.yaml" -c 60 -o  "$bin"/alive_"${alive_subdomain_folder_name}"/"${alive_subdomain_folder_name}"_nuclei_op/cves.txt &
  nuclei -target "${alive_subdomain}" -t "/home/${USER_EXEC}/tools/nuclei-templates/files/**/*.yaml" -c 60 -o  "$bin"/alive_"${alive_subdomain_folder_name}"/"${alive_subdomain_folder_name}"_nuclei_op/files.txt &
  nuclei -target "${alive_subdomain}" -t "/home/${USER_EXEC}/tools/nuclei-templates/panels/**/*.yaml" -c 60 -o  "$bin"/alive_"${alive_subdomain_folder_name}"/"${alive_subdomain_folder_name}"_nuclei_op/panels.txt &
  nuclei -target "${alive_subdomain}" -t "/home/${USER_EXEC}/tools/nuclei-templates/security-misconfiguration/**/*.yaml" -c 60 -o  "$bin"/alive_"${alive_subdomain_folder_name}"/"${alive_subdomain_folder_name}"_nuclei_op/security-misconfiguration.txt &
  nuclei -target "${alive_subdomain}" -t "/home/${USER_EXEC}/tools/nuclei-templates/technologies/**/*.yaml" -c 60 -o  "$bin"/alive_"${alive_subdomain_folder_name}"/"${alive_subdomain_folder_name}"_nuclei_op/technologies.txt &
  nuclei -target "${alive_subdomain}" -t "/home/${USER_EXEC}/tools/nuclei-templates/tokens/**/*.yaml" -c 60 -o  "$bin"/alive_"${alive_subdomain_folder_name}"/"${alive_subdomain_folder_name}"_nuclei_op/tokens.txt &
  nuclei -target "${alive_subdomain}" -t "/home/${USER_EXEC}/tools/nuclei-templates/vulnerabilities/**/*.yaml" -c 60 -o  "$bin"/alive_"${alive_subdomain_folder_name}"/"${alive_subdomain_folder_name}"_nuclei_op/vulnerabilities.txt &
  nuclei -target "${alive_subdomain}" -t "/home/${USER_EXEC}/tools/nuclei-templates/subdomain-takeover/**/*.yaml" -c 60 -o  "$bin"/alive_"${alive_subdomain_folder_name}"/"${alive_subdomain_folder_name}"_nuclei_op/subdomain-takeover.txt &
  wait
done < "${bin}"/"${domain}"_alive_subdomains.txt

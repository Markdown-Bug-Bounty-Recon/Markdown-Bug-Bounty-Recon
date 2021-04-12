#!/bin/bash -x

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
dir=$PWD/${domain}/${LAST_INIT_DATE}/"$domain"
bin=$dir/tools-io

mkdir "${dir}"/markdown
markdown_dir=${dir}/markdown


while read -r domain; do
	mkdir "${dir}"/markdown/"${domain}"
	markdown_dir=${dir}/markdown/${domain}

	#Converting these files to .md checklists
	cp "${bin}"/"${domain}"_alive_subdomains.txt "${markdown_dir}"
	#sed -i "s/^/- [ ] /" "${markdown_dir}"/"${domain}"_alive_subdomains.txt
	mv "${markdown_dir}"/"${domain}"_alive_subdomains.txt "${markdown_dir}"/"${domain}"_alive_subdomains.mdpp

	cp "${bin}"/"${domain}"_subdomains.txt "${markdown_dir}"
	#sed -i "s/^/- [ ] /" "${markdown_dir}"/"${domain}"_subdomains.txt
	mv "${markdown_dir}"/"${domain}"_subdomains.txt "${markdown_dir}"/"${domain}"_subdomains.mdpp


	{
	 echo "# ${domain}"
	 wget -qO- "https://raw.githubusercontent.com/Cloufish/Bug-bounty/master/bugbounty_checklist.md"
	 } >> "${markdown_dir}"/"${domain}"_report.mdpp

	 {
	 echo "## ALIVE SUBDOMAINS" >> "${markdown_dir}"/"${domain}"_report.mdpp
	 echo "!INCLUDE \"${markdown_dir}/${domain}_subdomains.mdpp\"" >> "${markdown_dir}"/"${domain}"_report.mdpp
	 } >> "${markdown_dir}"/"${domain}"_report.mdpp

	 while read -r alive_subdomain; do

		 alive_subdomain_folder_name=$(echo "${alive_subdomain}" | tr / _) # Because in creation of directories, the '/' letter is not escaped we need to cut out only domain.com and get rid of 'https://''

	 	 echo "## SUBDOMAINS OVERVIEW" >> "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".mdpp

		 mkdir -p "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"
		 touch "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/notes.mdpp
		 touch "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".mdpp
		 echo "### ${alive_subdomain}" >> "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".mdpp

		 echo "### NOTES" >> "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".mdpp
		 echo "!INCLUDE \"${markdown_dir}/alive_${alive_subdomain_folder_name}/notes.mdpp\"" >> "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".mdpp


	 done < "${bin}"/"${domain}"_alive_subdomains.txt
		  #PUTTING ALL SUBDOMAIN REPORTS TOGETHER INTO DOMAIN REPORT

	 while read -r alive_subdomain; do

		 alive_subdomain_folder_name=$(echo "${alive_subdomain}" | tr / _)
		 echo -e "!INCLUDE \"${markdown_dir}/alive_${alive_subdomain_folder_name}/report_${alive_subdomain_folder_name}.mdpp\"" >> "${markdown_dir}"/"${domain}"_report.mdpp
		 markdown-pp "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".mdpp -o "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".md
		 mv "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".md "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".mdpp

	 done < "${bin}"/"${domain}"_alive_subdomains.txt

		 markdown-pp "${markdown_dir}"/"${domain}"_report.mdpp -o "${markdown_dir}"/"${domain}"_report.md
		 mv "${markdown_dir}"/"${domain}"_report.md "${markdown_dir}"/"${domain}"_report.mdpp
		#HERE WE WILL DO FINAL FETCH FOR BOUNTY RECON REPORT

		 markdown_dir=${dir}/markdown

		 date=$(date +"%Y-%m-%d")
		 machine_name=${domain}
		 touch "${markdown_dir}"/BUG_BOUNTY_REPORT_"${date}".mdpp
		 echo "# ${machine_name}" >> "${markdown_dir}"/BUG_BOUNTY_REPORT_"${date}".mdpp
		 echo -e "!INCLUDE \"${markdown_dir}/${domain}/${domain}_report.mdpp\"" >> "${markdown_dir}"/BUG_BOUNTY_REPORT_"${date}".mdpp




done < "${PWD}"/"${domain}"/roots.txt

markdown-pp "${markdown_dir}"/BUG_BOUNTY_REPORT_"${date}".mdpp -o "${markdown_dir}"/BUG_BOUNTY_REPORT_"${date}".md
rm "${markdown_dir}"/BUG_BOUNTY_REPORT_"${date}".mdpp








# # Make an if statement if report exists and set a flag to create new report
#
# while read -r domain; do
#
#
# mkdir "${dir}"/markdown/"${domain}"
# markdown_dir=${dir}/markdown/${domain}
#
#
# #Converting these files to .md checklists
# cp "${bin}"/"${domain}"_alive_subdomains.txt "${markdown_dir}"
# sed -i "s/^/- [ ] /" "${markdown_dir}"/"${domain}"_alive_subdomains.txt
# mv "${markdown_dir}"/"${domain}"_alive_subdomains.txt "${markdown_dir}"/"${domain}"_alive_subdomains.mdpp
#
# cp "${bin}"/"${domain}"_subdomains.txt "${markdown_dir}"
# sed -i "s/^/- [ ] /" "${markdown_dir}"/"${domain}"_subdomains.txt
# mv "${markdown_dir}"/"${domain}"_subdomains.txt "${markdown_dir}"/"${domain}"_subdomains.mdpp
# {
# echo "# ${domain}"
# wget -qO- "https://raw.githubusercontent.com/Cloufish/Bug-bounty/master/bugbounty_checklist.md"
# } >> "${markdown_dir}"/"${domain}"_report.mdpp
#
# {
# echo "## ALIVE SUBDOMAINS" >> "${markdown_dir}"/"${domain}"_report.mdpp
# echo "!INCLUDE \"${markdown_dir}/${domain}_subdomains.mdpp\"" >> "${markdown_dir}"/"${domain}"_report.mdpp
# } >> "${markdown_dir}"/"${domain}"_report.mdpp
#
# echo "## SUBDOMAINS OVERVIEW" >> "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".mdpp
#
#
#
# 	while read -r alive_subdomain; do
#
# 		alive_subdomain_folder_name=$(echo "${alive_subdomain}" | tr / _) # Because in creation of directories, the '/' letter is not escaped we need to cut out only domain.com and get rid of 'https://''
#
# 		mkdir -p "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"
# 		touch "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/notes.mdpp
# 		touch "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".mdpp
# 		echo "### ${alive_subdomain_folder_name}" >> "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".mdpp
#
# 		#nuclei results will be printed here
# 		echo "### NUCLEI" >> "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".mdpp
#
# 		for nuclei_output in "${bin}"/alive_"${alive_subdomain_folder_name}"/*; do
#
#
# 			nuclei_output_filename=$(echo "${nuclei_output}" | cut -d "." -f 1 )
# 			nuclei_output_uppercase=${nuclei_output_filename^^}
#
# 			echo -e "#### ${nuclei_output_uppercase}" >> "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".mdpp
# 			cat "$bin"/alive_"${alive_subdomain_folder_name}"/"${alive_subdomain_folder_name}"_nuclei_op/"${nuclei_output}" >> "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".mdpp
#
#
# 		done
# 		javascript(){
# 		echo "### Javascript Code (copy to VSCode)" >> "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".mdpp
#
# 		for file in "${bin}"/javascript_work/scriptsresponse/"${alive_subdomain_folder_name}"/*; do
#
#
# 				js_hyperlink=$(grep "${file}" "${bin}"/javascript_work/scripts/"${alive_subdomain_folder_name}")
#                                 {
# 				echo "#### ${file}"
# 				echo "- ${js_hyperlink}"
# 				echo -e "'''js"
# 				< "${bin}"/javascript_work/scriptsresponse/"${alive_subdomain_folder_name}"/"${file}" head -n 50
# 				echo -e "'''"
#                                 } >> "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".mdpp
# 		done
# 		}
#
# 		echo "### NOTES" >> "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".mdpp
# 		echo "!INCLUDE \"${markdown_dir}/alive_${alive_subdomain_folder_name}/notes.mdpp\"" >> "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".mdpp
#
# 	done < "${bin}"/"${domain}"_alive_subdomains.txt
#
# 	echo "## NOT ALIVE SUBDOMAINS" >> "${markdown_dir}"/"${domain}"_report.mdpp
# 	echo "!INCLUDE \"${markdown_dir}/${domain}_subdomains.mdpp\"" >> "${markdown_dir}"/"${domain}"_report.mdpp
#
# 	while read -r subdomain; do
# 		mkdir "${markdown_dir}"/not_alive_"${subdomain}"
# 		touch "${markdown_dir}"/not_alive_"${subdomain}"/notes.md
# 		touch "${markdown_dir}"/not_alive_"${subdomain}"/report_"${subdomain}".mdpp
# 		echo "## ${subdomain}" >> "${markdown_dir}"/not_alive_"${subdomain}"/report_"${subdomain}".mdpp
#
#
# 		echo "### NOTES"
# 		echo "!INCLUDE \"${markdown_dir}/alive_${alive_subdomain_folder_name}/notes.mdpp\"" >> "${markdown_dir}"/not_alive_"${subdomain}"/report_"${subdomain}".mdpp
# 	done < "$bin"/"${domain}"_alive_subdomains_without_protocol.txt
#
# # PUTTING ALL SUBDOMAIN REPORTS TOGETHER INTO DOMAIN REPORT
#
# 	while read -r alive_subdomain; do
#
# 		alive_subdomain_folder_name=$(echo "${alive_subdomain}" | tr / _)
# 		echo -e "!INCLUDE \"${markdown_dir}/alive_${alive_subdomain_folder_name}/report_${alive_subdomain_folder_name}.mdpp\"" >> "${markdown_dir}"/"${domain}"_report.mdpp
# 		markdown-pp "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".mdpp -o "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".md
# 		mv "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".md "${markdown_dir}"/alive_"${alive_subdomain_folder_name}"/report_"${alive_subdomain_folder_name}".mdpp
# 	done < "${bin}"/"${domain}"_alive_subdomains.txt
# 	markdown-pp "${markdown_dir}"/"${domain}"_report.mdpp -o "${markdown_dir}"/"${domain}"_report.md
# 	mv "${markdown_dir}"/"${domain}"_report.md "${markdown_dir}"/"${domain}"_report.mdpp
# #HERE WE WILL DO FINAL FETCH FOR BOUNTY RECON REPORT
#
#
#
# markdown_dir=${dir}/markdown
#
# date=$(date +"%Y-%m-%d")
# machine_name=${PWD##*/}
# touch "${markdown_dir}"/BUG_BOUNTY_REPORT_"${date}".mdpp
# echo "# ${machine_name}" >> "${markdown_dir}"/BUG_BOUNTY_REPORT_"${date}".mdpp
# echo -e "!INCLUDE \"${markdown_dir}/${domain}/${domain}_report.mdpp\"" >> "${markdown_dir}"/BUG_BOUNTY_REPORT_"${date}".mdpp
#
#

# done < "${PWD}"/"${domain}"/roots.txt
#
# markdown-pp "${markdown_dir}"/BUG_BOUNTY_REPORT_"${date}".mdpp -o "${markdown_dir}"/BUG_BOUNTY_REPORT_"${date}".md

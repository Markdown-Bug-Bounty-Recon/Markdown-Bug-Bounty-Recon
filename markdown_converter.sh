#!/bin/bash 



dir=$PWD
bin=$dir/bin

mkdir ${dir}/markdown
markdown_dir=${dir}/markdown

# Make an if statement if report exists and set a flag to create new report

for domain in $(cat ${bin}/roots.txt); do

bin=$dir/bin/$domain

mkdir ${dir}/markdown/${domain}
markdown_dir=${dir}/markdown/${domain}


#Converting these files to .md checklists
cp ${bin}/${domain}_alive_subdomains.txt ${markdown_dir}
sed -i "s/^/- [ ] /" ${markdown_dir}/${domain}_alive_subdomains.txt
mv ${markdown_dir}/${domain}_alive_subdomains.txt ${markdown_dir}/${domain}_alive_subdomains.mdpp

cp ${bin}/${domain}_subdomains.txt ${markdown_dir}	
sed -i "s/^/- [ ] /" ${markdown_dir}/${domain}_subdomains.txt
mv ${markdown_dir}/${domain}_subdomains.txt ${markdown_dir}/${domain}_subdomains.mdpp

echo "# ${domain}"
wget -qO- "https://raw.githubusercontent.com/Cloufish/Bug-bounty/master/bugbounty_checklist.md" >> ${markdown_dir}/${domain}_report.mdpp

echo "## ALIVE SUBDOMAINS" >> ${markdown_dir}/${domain}_report.mdpp
cat "${markdown_dir}/${domain}_subdomains.mdpp" >> ${markdown_dir}/${domain}_report.mdpp
echo "## NOT ALIVE SUBDOMAINS" >> ${markdown_dir}/${domain}_report.mdpp
cat "${markdown_dir}/${domain}_subdomains.mdpp" >> ${markdown_dir}/${domain}_report.mdpp


	for alive_subdomain in $(cat ${bin}/${domain}_alive_subdomains.txt); do
		
		alive_subdomain_folder_name=$(echo ${alive_subdomain} | tr -d "/" | cut -d ":" -f 2) # Because in creation of directories, the '/' letter is not escaped we need to cut out only domain.com and get rid of 'https://''

		mkdir -p ${markdown_dir}/alive_${alive_subdomain_folder_name}
		touch -c ${markdown_dir}/alive_${alive_subdomain_folder_name}/notes.mdpp
		touch -c ${markdown_dir}/alive_${alive_subdomain_folder_name}/report_${alive_subdomain_folder_name}.mdpp
		echo "## ${alive_subdomain_folder_name}" >> ${markdown_dir}/alive_${alive_subdomain_folder_name}/report_${alive_subdomain_folder_name}.mdpp

		#nuclei results will be printed here
		bin=$dir/bin/${domain}		
		echo "### NUCLEI" >> ${markdown_dir}/alive_${alive_subdomain_folder_name}/report_${alive_subdomain_folder_name}.mdpp

		for nuclei_output in $(ls $bin/alive_${alive_subdomain_folder_name}/${alive_subdomain_folder_name}_nuclei_op); do


			nuclei_output_filename=$(echo ${nuclei_output} | cut -d "." -f 1 ) 
			nuclei_output_uppercase=${nuclei_output_filename^^}

			echo -e "#### ${nuclei_output_uppercase}" >> ${markdown_dir}/alive_${alive_subdomain_folder_name}/report_${alive_subdomain_folder_name}.mdpp
			cat $bin/alive_${alive_subdomain_folder_name}/${alive_subdomain_folder_name}_nuclei_op/${nuclei_output} >> ${markdown_dir}/alive_${alive_subdomain_folder_name}/report_${alive_subdomain_folder_name}.mdpp
			

		done
		echo "### Javascript Code"
		bin=$dir/bin
		    
		for file in $(ls ${bin}/javascript_work/scripts/scriptsresponse/${alive_subdomain_folder_name}); do
			if [ -d $file ]
			then
				echo "- ${file}" >> ${markdown_dir}/alive_${alive_subdomain_folder_name}/report_${alive_subdomain_folder_name}.mdpp
				echo -e "'''js" >> ${markdown_dir}/alive_${alive_subdomain_folder_name}/report_${alive_subdomain_folder_name}.mdpp
				cat $file >> ${markdown_dir}/alive_${alive_subdomain_folder_name}/report_${alive_subdomain_folder_name}.mdpp
				echo -e "'''" >> ${markdown_dir}/alive_${alive_subdomain_folder_name}/report_${alive_subdomain_folder_name}.mdpp
		    fi
		done

		
		echo "### NOTES"
		echo "### !INCLUDE ${markdown_dir}/alive_${alive_subdomain_folder_name}/notes.mdpp"

	done
	bin=$dir/bin/${domain}

	for subdomain in $(cat ${bin}/${domain}_subdomains.txt); do
		mkdir ${markdown_dir}/not_alive_${subdomain}
		touch -c ${markdown_dir}/not_alive_${subdomain}/notes.md
		touch -c ${markdown_dir}/not_alive_${subdomain}/report_${subdomain}.mdpp
		echo "## ${alive_subdomain}" >> ${markdown_dir}/not_alive_${subdomain}/report_${subdomain}.mdpp

	done

# PUTTING ALL SUBDOMAIN REPORTS TOGETHER INTO DOMAIN REPORT

	for alive_subdomain in $(cat ${bin}/${domain}_alive_subdomains.txt); do

		alive_subdomain_folder_name=$(echo ${alive_subdomain} | tr -d "/" | cut -d ":" -f 2)
		echo -e "!INCLUDE ${markdown_dir}/alive_${alive_subdomain_folder_name}/report_${alive_subdomain_folder_name}.mdpp" >> ${markdown_dir}/${domain}_report.mdpp
		markdown-pp ${markdown_dir}/alive_${alive_subdomain_folder_name}/report_${alive_subdomain_folder_name}.mdpp -o ${markdown_dir}/alive_${alive_subdomain_folder_name}/report_${alive_subdomain_folder_name}.md
		mv ${markdown_dir}/alive_${alive_subdomain_folder_name}/report_${alive_subdomain_folder_name}.md ${markdown_dir}/alive_${alive_subdomain_folder_name}/report_${alive_subdomain_folder_name}.mdpp		
	done
	markdown-pp ${markdown_dir}/${domain}_report.mdpp -o ${markdown_dir}/${domain}_report.md
	mv ${markdown_dir}/${domain}_report.md ${markdown_dir}/${domain}_report.mdpp
#HERE WE WILL DO FINAL FETCH FOR BOUNTY RECON REPORT

	

markdown_dir=${dir}/markdown

date=$(date +"%Y-%m-%d")
machine_name=${PWD##*/}
touch -c ${markdown_dir}/BUG_BOUNTY_REPORT_${date}.mdpp
echo "# ${machine_name}" >> ${markdown_dir}/BUG_BOUNTY_REPORT_${date}.mdpp
alive_subdomain_folder_name=$(echo ${alive_subdomain} | tr -d "/" | cut -d ":" -f 2)
echo -e "!INCLUDE ${markdown_dir}/${domain}_report.mdpp" >> ${markdown_dir}/BUG_BOUNTY_REPORT_${date}.mdpp



done

markdown-pp ${markdown_dir}/BUG_BOUNTY_REPORT_${date}.mdpp -o ${markdown_dir}/BUG_BOUNTY_REPORT_${date}.md

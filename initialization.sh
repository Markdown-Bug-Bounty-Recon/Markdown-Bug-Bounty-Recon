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

function yes_or_no {
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}

 if [ -z "${USER_EXEC}" ]; then
 	echo "You did not passed another ${USER} account, executing as root user"
 	USER_EXEC=root
 else
 	echo "You passed another ${USER} account"
 fi

mkdir "${domain}"
if [ -f ./${domain}/scope.txt];
then
  echo "DECLARING SCOPE OF YOUR PROGRAM"
  echo "Do you want to declare it? [Y/N]"
  yes_or_no
  if [ $? -eq 0 ];
  then
    vim ./${domain}/scope.txt
  fi
fi

if [ -f ./${domain}/out-of-scope.txt];
then
  echo "DECLARING SCOPE OF YOUR PROGRAM"
  echo "Do you want to declare it? [Y/N]"
  yes_or_no
  if [ $? -eq 0 ];
  then
    vim ./${domain}/out-of-scope.txt
  fi
fi


CURRENTDATE=`date +"%Y-%m-%d"`
echo $CURRENTDATE > $PWD/${domain}/last-init-date.sh
mkdir -p "${domain}"/${CURRENTDATE}/tools-io
dir=$PWD/${domain}/${CURRENTDATE}
bin=$dir/tools-io

if [ -f "./${domain}/Acquisitions.txt" ];then
	echo "There's already text file for Acquisitions"
else
	echo "Do you want to create Acquisitions.txt file to include"
fi

sort "${bin}"/roots.txt | uniq | tee "${bin}"/tmp_roots.txt && mv "${bin}"/tmp_roots.txt "${bin}"/roots.txt

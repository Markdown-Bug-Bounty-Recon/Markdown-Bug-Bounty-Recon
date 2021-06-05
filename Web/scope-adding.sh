#!/bin/bash

while getopts d:a:u: OPTION; do
	case $OPTION in
		d)
		domain="$OPTARG"
		;;
		?)
		usage
		;;
	esac
done

function yes_or_no {
    while true; do
        read -r "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi



bbrf use "$(echo "${domain}" | cut -f 1 -d .)"

echo -n "# SPECIFY EACH OF THE SUBDOMAINS IN NEW LINES; ASTERISK (*) WILDCARDS ARE ALLOWED, BUT NOT REGEX; DO NOT USE HTTP/HTTPS EXTENSION FORMAT; WITH .COM | .PL | .DE AT THE END (THIS IS A MUST)" > ./"${domain}"/scope.txt
echo "DECLARING SCOPE OF YOUR PROGRAM. YOU NEED TO DO THAT TO USE BBRF QUERYING"
read -r -e -p "Do you want to declare it? [Y/N]: " choice
[[ "$choice" == [Yy]* ]] && vim ./"${domain}"/scope.txt || echo "that was a no"

echo -n "# SPECIFY EACH OF THE SUBDOMAINS IN NEW LINES; ASTERISK (*) WILDCARDS ARE ALLOWED, BUT NOT REGEX; DO NOT USE HTTP/HTTPS EXTENSION FORMAT; WITH .COM | .PL | .DE AT THE END (THIS IS A MUST)" > ./"${domain}"/out-of-scope.txt
echo "DECLARING OUT OF SCOPE OF YOUR PROGRAM"
read -r -e -p "Do you want to declare it? [Y/N]: " choice
[[ "$choice" == [Yy]* ]] && vim ./"${domain}"/out-of-scope.txt || echo "that was a no"

# Removing the comment in these files:
sed -i '1d' ./"${domain}"/scope.txt
sed -i '1d' ./"${domain}"/out-of-scope.txt

while read -r domain_in_scope 
do
    bbrf inscope add "${domain_in_scope}"
done < ./"${domain}"/scope.txt


while read -r domain_of_of_scope 
do
    bbrf inscope add "${domain_of_of_scope}"
done < ./"${domain}"/out-of-scope.txt


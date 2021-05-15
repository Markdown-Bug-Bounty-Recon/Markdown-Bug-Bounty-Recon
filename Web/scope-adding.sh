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


#if ! [ -f ./"${domain}"/scope.txt ];
#then
#  echo "DECLARING SCOPE OF YOUR PROGRAM"
#  yes_or_no "Do you want to declare it? [Y/N]" && vim ./"${domain}"/scope.txt
#fi

#if ! [ -f ./"${domain}"/out-of-scope.txt ];
#then
#  echo "DECLARING OUT OF SCOPE OF YOUR PROGRAM"
#  yes_or_no "Do you want to declare it? [Y/N]" && vim ./"${domain}"/out-of-scope.txt

#fi

echo "DECLARING SCOPE OF YOUR PROGRAM"
read -r -e -p "Do you want to declare it? [Y/N]: " choice
[[ "$choice" == [Yy]* ]] && vim ./"${domain}"/scope.txt || echo "that was a no"

echo "DECLARING OUT OF SCOPE OF YOUR PROGRAM"
read -r -e -p "Do you want to declare it? [Y/N]: " choice
[[ "$choice" == [Yy]* ]] && vim ./"${domain}"/out-of-scope.txt || echo "that was a no"


#Removing 'http://www.' prefixes and replacing them with "*." for the grex
< ./"${domain}"/scope.txt grep http | cut -d . -f 2- | awk '{print "*."$0}'
< ./"${domain}"/out-of-scope.txt grep http | cut -d . -f 2- | awk '{print "*."$0}'


grex -f ./"${domain}"/scope.txt > ./"${domain}"/scope.regx

grex -f ./"${domain}"/out-of-scope.txt > ./"${domain}"/out-of-scope.regx

while read -r in-scope; do
	bbrf inscope add "${in-scope}"
done < ./"${domain}"/scope.txt

while read -r out-of-scope; do
	bbrf inscope add "${out-of-scope}"
done < ./"${domain}"/out-of-scope.txt

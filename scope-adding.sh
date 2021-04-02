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


if ! [ -f ./"${domain}"/scope.txt ];
then
  echo "DECLARING SCOPE OF YOUR PROGRAM"
  yes_or_no "Do you want to declare it? [Y/N]"
  if  yes_or_no;
  then
    vim ./"${domain}"/scope.txt
  fi
fi

if ! [ -f ./"${domain}"/out-of-scope.txt ];
then
  echo "DECLARING OUT OF SCOPE OF YOUR PROGRAM"
  yes_or_no "Do you want to declare it? [Y/N]"
  if  yes_or_no;
  then
    vim ./"${domain}"/out-of-scope.txt
  fi
fi


grex -f ./"${domain}"/scope.txt > ./"${domain}"/scope.regx

grex -f ./"${domain}"/out-of-scope.txt > ./"${domain}"/out-of-scope.regx
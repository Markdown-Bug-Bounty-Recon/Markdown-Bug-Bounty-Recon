#!/bin/bash

mkdir $domain
if [ -f "./$domain/Acquisitions.txt" ];then
	echo "There's already text file for Acquisitions"
else
	touch ./$domain/Acquisitions.txt
fi
mkdir ./$domain/command_output
mkdir ./$domain/command_output/
mkdir ./$domain/command_output/acquisitions
mkdir -p ./$domain/command_output/bin/roots

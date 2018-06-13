#!/bin/bash
#version 0.0.0.1
# By JM @ http://git.burnsoft.net
#DESCRIPTION: This script will list the GPIO's listed in the system and their Value
#  You can also pass a number to the script to have it refresh every x seconds
#  EXAMPLE ./gpiomon.sh 5

gpioPath="/sys/class/gpio";

declare -r TRUE=0		#Global True and False Markers, mostly used in use_msgbox
declare -r FALSE=1		#Global True and False Markers, mostly used in use_msgbox
RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'

array=();
lastarray=();
refreshEvery="${1}"
_formatDataForColumn="";

function getValue()
{
	gpio="${1}";
	result=$(cat $gpioPath/gpio$gpio/value);
	if [ "$result" -eq "0" ]; then
		return $FALSE;
	else
		return $TRUE;
	fi
}

function cloneArray()
{
	lastarray = array;
}

function getgpioAndStatus()
{
	re='^-?[0-9]+([.][0-9]+)?$';
	
	for i in $(ls -1Atu $gpioPath | grep "gpio" | cut -c 5- ); do 
		results="$i";
		if [[ $results =~ $re ]] ; then
			if ( getValue "$i" ); then
				array+=("$i TRUE");
			else
				array+=("$i FALSE");
			fi
		fi
	done
}

function drawHeader()
{
	clear;
	printf "%s\n" "+--------------------------------------------+";
	printf "|  %-5s  |  %-5s  |  %-5s  |\n" "GPIO VALUE" "GPIO VALUE" "GPIO VALUE";
	printf "%s\n" "+--------------------------------------------+";
}

function formatDataForColumn()
{
	col="${1}";
	charCount=$(echo -n "$col" | wc -c);
	spacesLeft=$(echo "12 - $charCount" | bc)

	case $spacesLeft in
		12)
			_formatDataForColumn="            ";
			;;
		6)
			_formatDataForColumn="   $col   ";
			;;
		5)
			_formatDataForColumn="   $col  ";
			;; 
		4)
			_formatDataForColumn="  $col  ";
			;;
		3) 
			_formatDataForColumn="  $col ";
			;;
		2)
			_formatDataForColumn=" $col ";
			;;
		1)
			_formatDataForColumn=" $col";
			;;
		0)
			_formatDataForColumn="$col";
			;;
	esac
}
function dumpData()
{
	countIteration=0;
	col1="";
	col2="";
	col3="";

	for i in "${array[@]}"
	do
        	((countIteration++))
        	if [ "$countIteration" -eq "1" ]; then
					formatDataForColumn "$i";
					col1="$_formatDataForColumn";
        	fi

        	if [ "$countIteration" -eq "2" ]; then
					formatDataForColumn "$i";
					col2="$_formatDataForColumn";
        	fi

        	if [ "$countIteration" -eq "3" ]; then
					formatDataForColumn "$i";
					col3="$_formatDataForColumn";
                	countIteration=0;
        	fi

        	if [ "$countIteration" -eq "0" ]; then
                	printf "| %-5s | %-5s | %-5s |\n" "$col1" "$col2" "$col3";
                	col1="";
                	col2="";
                	col3="";
        	fi
	done

	if [ ! -z "$col1" ]; then
		if [ ! -z "$col2" ]; then
			formatDataForColumn "";
			col3="$_formatDataForColumn";
		else 
			formatDataForColumn "";
			col2="$_formatDataForColumn";
			formatDataForColumn "";
			col3="$_formatDataForColumn";
		fi

       	printf "| %-5s | %-5s | %-5s |\n" "$col1" "$col2" "$col3";
	fi
	printf "%s\n" "+--------------------------------------------+";
}

function startData()
{
	if [ ! -z "$refreshEvery" ]; then
		cloneArray
	fi
	array=();
	drawHeader
	getgpioAndStatus
	dumpData
}

startData

if [ ! -z "$refreshEvery" ]; then
	while true; do
		startData
		sleep "$refreshEvery";
		read -t 0.25 -N 1 input
		if [[ $input = "q" ]] || [[ $input = "Q" ]]; then
			echo;
			break;
		fi
	done
fi

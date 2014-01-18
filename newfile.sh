#! /bin/bash
#

#$Author$
# NABEEL ZAIM
#$Date$ 
#$Revision$
#
#PROGRAM PURPOSE: Creates new file and fills it in with initial stuff.
#USAGE: 
### "./newfile.sh alu.sv" creates source/alu.sv
### "./newfile.sh alu_tb.sv" creates testbench/alu_tb.sv

#ARG CHECK
if (( $# != 1 ))
then
    echo "Usage: \"./newfile.sh alu.sv\" creates source/alu.sv"
    echo "Usage: \"./newfile.sh alu_tv.sv\" creates testbench/alu_tb.sv"
    exit 1
fi

file=$1
IFS="."
module=(${file//.sv}) #extracts substring
IFS="	"
targetd="."

if [[ $file == *_tb.sv ]]; then
	echo "Bad file name"
	exit 2
elif [[ $file == *.sv ]]; then
	targetd="source"
else
	echo "Bad file name"
	exit 2
fi

### CREATE SOURCE FILE

file="$targetd/$file"

if [[ -e $file ]]; then #does the file already exist?
	echo "$file already exists!"
	read -p "Continue? Y/n " cont
	if [[ $cont != "Y" ]]; then
		exit 3
	fi
fi
echo "Creating file $file"

touch $file
echo "//File name: 	$file" > ./$file
echo "//Created: 	$(date +'%m/%d/%Y')" >> ./$file
echo "//Author:	Nabeel Zaim (mg232)" >> ./$file
echo "//Lab Section:	437-03" >> ./$file
echo "//Description: 	" >> ./$file
echo "" >> ./$file
echo "module $module" >> ./$file
echo "(" >> ./$file
echo ");" >> ./$file
echo "endmodule" >> ./$file


### CREATE TESTBENCH FILE
tbsuffix="_tb.sv"
tbfile=$(echo "testbench/$module$tbsuffix")
echo $tbfile

#emacs $file &

exit 0


#!/bin/bash

### PATH VARIABLES

TEST_DIR="$PWD"


PROJECT_DIR="$PWD/../"		# <===== EDIT PATH HERE IF push_swap_checker IS NOT IN THE ROOT PATH OF YOUR PROJECT




### COLORS

red="\033[0;31m"
green="\033[0;32m"
clear="\033[0;m"
blue="\033[0;94m"
orange="\033[0;33m"
purple="\033[0;35m"

### HEADER
clear

echo -e "${orange}________________________________________________________________________________________________________\n"
echo -e "__________________________________________ PUSH_SWAP CHECKER ___________________________________________\n"
echo -e "________________________________________________________________________________________________________\n\n${clear}"


[ "$1" = "-h" ] && { echo -e "Usage: ./push_swap_checker.sh [nb_input] [nb_tests] [-r]\n\nOption -r for reverse sort"; exit 0; }
[ "$3" = "-r" ] && REVERSE=1 || REVERSE=0

[[ "$REVERSE" -eq 1 ]] && compil=$( make bonus -C "$PROJECT_DIR" ) || compil=$( make -C "$PROJECT_DIR" )
[ $? -ne 0 ] && { echo -e "[ ${red}KO${clear} ] Compilation Error"; exit 1; }

log="$TEST_DIR/run_tests.log"
rm -f "$log"




### USER INPUT

nb_input="$1"
nb_tests="$2"

check_digit()
{
digit=0
expr "$1" : '^\( *[0-9]* *\)*$' > /dev/null ; [[ $? -eq 0 ]] && digit=1
if [[ $digit -eq 1 ]] ; then
	[[ $1 -gt 0 ]] && digit=2
fi
}

check_digit "$nb_input"
if [[ $digit -ne 2 ]] ; then
	echo "How many random numbers to sort?"
	read
	nb_input="$REPLY"
	check_digit "$nb_input"
	while [[ $digit -ne 2 ]] ; do
		echo "How many random numbers to sort? Only positive numbers and digits are accepted..."
		read
		nb_input="$REPLY"
		check_digit "$nb_input"
	done
fi

check_digit "$nb_tests"
if [[ $digit -ne 2 ]] ; then
	echo "How many tests to run?"
	read
	nb_tests="$REPLY"
	check_digit "$nb_tests"
	while [[ $digit -ne 2 ]] ; do
		echo "How many tests to run? Only positive numbers and digits are accepted..."
		read
		nb_tests="$REPLY"
		check_digit "$nb_tests"
	done
fi




### GENERATE RANDOM LIST		ruby gen => ARG=$(ruby -e "puts (-50...50).to_a.shuffle.join(' ')")
check_double()
{
k=0
double="to_check"
tmp=${ARG[@]}
for nb in $tmp; do
	[[ $nb -ne $new ]] && k=$(( $k + 1))
done
[[ $k -eq $2 ]] && double="no_double"
}

get_modulo()
{
modulo_list=("$@")
random_modulo=$(( $RANDOM % ${#modulo_list[@]} ))
}

gen_modulo()
{
a=1
mod_list="\"1\" "
while [[ $a -lt $nb_input ]]; do
	a=$(( $a + 1 ))
	mod_list+="\"$a\" "
done
get_modulo $mod_list

}

random_list()
{
j=1
gen_modulo
[[ $(( $j % $nb_input )) -eq $random_modulo ]] && ARG="-$RANDOM " || ARG="$RANDOM "
while [[ $j -lt $1 ]] ; do
	double="to_check"
	while [ "$double" != "no_double" ] ; do
		gen_modulo
		[[ $(( $j % $nb_input )) -eq $random_modulo ]] && new="-$RANDOM" || new="$RANDOM"
		check_double "$new" "$j"
	done
	ARG+="$new "
	j=$(( $j + 1 ))
done
}


### CHECK MOVE

check_move()
{
if [ "$res" = "OK" ] ; then
	if [[ $1 -eq 1 ]] ; then
		[[ $2 -eq 0 ]] && grade=5 || grade=0
	elif [[ $1 -eq 2 ]] ; then
		[[ $2 -le 1 ]] && grade=5 || grade=0	
	elif [[ $1 -eq 3 ]] ; then
		[[ $2 -le 3 ]] && grade=5 || grade=0
	elif [[ $1 -eq 5 ]] ; then
		[[ $2 -le 12 ]] && grade=5 || grade=0
	elif [[ $1 -eq 100 ]] ; then
		[[ $2 -lt 700 ]] && grade=5
		[ $2 -ge 700 -a $2 -lt 900 ] && grade=4
		[ $2 -ge 900 -a $2 -lt 1100 ] && grade=3
		[ $2 -ge 1100 -a $2 -lt 1300 ] && grade=2
		[ $2 -ge 1300 -a $2 -lt 1500 ] && grade=1
		[[ $2 -ge 1500 ]] && grade=0
	elif [[ $1 -eq 500 ]] ; then
	        [ $2 -lt 5500 ] && grade=5
	        [ $2 -ge 5500 -a $2 -lt 7000 ] && grade=4
	        [ $2 -ge 7000 -a $2 -lt 8500 ] && grade=3
	        [ $2 -ge 8500 -a $2 -lt 10000 ] && grade=2
	        [ $2 -ge 10000 -a $2 -lt 11500 ] && grade=1
	        [[ $2 -ge 11500 ]] && grade=0
	else
		grade=5
	fi
	[[ $grade -eq 0 ]] && { s="Move grade:\t${red}0/5${clear}\t\tFinal grade:\t❌"; ko=$(( $ko + 1 )); }
	[[ $grade -eq 1 ]] && { s="Move grade:\t${red}1/5${clear}\t\tFinal grade:\t❌"; ko=$(( $ko + 1 )); }
	[[ $grade -eq 2 ]] && { s="Move grade:\t${orange}2/5${clear}\t\tFinal grade:\t🤷"; ko=$(( $ko + 1 )); }
	[[ $grade -eq 3 ]] && { s="Move grade:\t${blue}3/5${clear}\t\tFinal grade:\t✅"; ok=$(( $ok + 1 )); }
	[[ $grade -eq 4 ]] && { s="Move grade:\t${green}4/5${clear}\t\tFinal grade:\t✅"; ok=$(( $ok + 1 )); }
	[[ $grade -eq 5 ]] && { s="Move grade:\t${green}5/5${clear}\t\tFinal grade:\t✅"; ok=$(( $ok + 1 )); }
else
	s="❌"
	ko=$(( $ko + 1 ))
fi
}


### RUN TESTS


i=1
ok=0
ko=0
moves=0
min_moves=999999
max_moves=0
while [[ $i -le $nb_tests ]] ; do
	random_list $nb_input
	if [[ $REVERSE -eq 1 ]] ; then
		cd  "$PROJECT_DIR" && ./push_swap -r "$ARG" > "$TEST_DIR/output"
		res=$( cd "$PROJECT_DIR" && ./checker -r "$ARG" < "$TEST_DIR/output" )
	else
		cd "$PROJECT_DIR" && ./push_swap "$ARG" > "$TEST_DIR/output"
		res=$( cd "$PROJECT_DIR" && ./checker "$ARG" < "$TEST_DIR/output" )
	fi
	moves=$( cat "$TEST_DIR/output" | wc -l )
	[[ $moves -gt $max_moves ]] && max_moves=$moves
	[[ $moves -lt $min_moves ]] && min_moves=$moves
	check_move "$nb_input" "$moves"
	if [ "$res" != "OK" ] ; then
		if [[ $nb_input -le 100 ]] ; then
			echo -e "Test ${i} / ${nb_tests}\nList: ${ARG}\nOutput: ${res}\nOperations: ${moves}\t\t${s}\n\n" >> "$log"
		else
			echo -e "Test ${i} / ${nb_tests}\nList: ${nb_input} random numbers\nOutput: ${res}\nOperations: ${moves}\t\t${s}\n\n" >> "$log"
		fi
	fi
	if [[ $nb_input -gt 100 ]] ; then
		echo -e "\nTest ${i} / ${nb_tests}\nList: ${nb_input} random numbers\nOutput: ${res}\nOperations: ${moves}\t\t${s}\n"
	else
		echo -e "\nTest ${i} / ${nb_tests}\nList: ${ARG}\nOutput: ${res}\nOperations: ${moves}\t\t${s}\n"
	fi
	i=$(( $i + 1 ))
done
rm -f "$TEST_DIR/output"



### GRADE

echo -e "${purple}\n --------------------------- \n|          RESULTS          |\n ---------------------------\n"
echo -e "${blue}Min nb of moves: ${min_moves}"
echo -e "Max nb of moves: ${max_moves}${clear}\n"


if [ $ok -eq $nb_tests ] ; then
	echo -e "${green}Congrats! ${ok} / ${nb_tests}\t:)${clear}"
	ret=0
else
	[[ $ko -le 1 ]] && str="error" || str="errors" 
	echo -e "${red}${ko} ${str} / ${nb_tests}\t:(${clear}"
	ret=1
	if [ -f "$log" ] ; then
#		echo -e "\n\n${orange}Print log errors? (y/n)${clear}"
		cat "$log"
#		read
#		[ "$REPLY" = "y" -o "$REPLY" = "o" ] && cat "$log"
	else
		echo "Not perfect but all tests passed! ===> Number of operations could be optimize..."
		ret=0
	fi
fi

rm -f "$log"


exit $ret

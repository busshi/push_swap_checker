#!/bin/bash


red="\033[0;31m"
green="\033[0;32m"
clear="\033[0;m"
underline="\033[4m"



check()
{
[ $? -ne 0 ] && { error=$(( $error + 1 )); str+="${underline}$1${red} "; }
sleep 3
}



error=0
tests=1000

for nb in 1 2 3 4 5 100 500; do
	[[ $nb -eq 100 ]] && tests=50
	[[ $nb -eq 500 ]] && tests=10
	/bin/bash push_swap_checker.sh $nb $tests
	check $nb
done




if [[ $error -eq 0 ]]; then
	echo -e "\n\n${green}All tests passed!!! Ready for evaluation...${clear}"
else
	echo -e "\n\n⚠️   ${red}Some tests failed with ${str}random numbers! Some optimizations are required...${clear}"
fi

exit $error

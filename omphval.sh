#!/usr/bin/env bash
DOC="Omphval.sh a OpenMP test generator.
Usage:
  omphval.sh gen [--v5]
  omphval.sh run [<test_folder>...]
  omphval.sh display [--working] [--avoid_long_double] [<result_folder>...]
  omphval.sh clean
"

ROGER="
Options:
   gen                 Generate the ./tests directory containting all the tests
     v5                  Generate openmp v5 tests (loop construct for example)
   
   run                 Will run all the test specifier by <test_folder>.
                       The log are stored in the ./results/${uuid}_$(hostname)/<test_folder>/ directory
                       More information are saved in '{compilation,runtime}.log' files of those result folder
                       Use tradional Flags to control the execusion (CXX, CXXFLAGS, MAKEFLAGS, OMP, OMP_TARGET_OFFLOAD, etc)
     <test_folder>       Folder containing the tests to run (default: ./tests/ ) 

   display             Display the Error message of failling tests. 
     <result_folder>     Folder to display (default: ./results/ ) 
     working             Print only the tests who are passing
     avoid_long_double   Don't print long_double tests. If used in conjunction with working, will not print the working long double if they exit

Example:
  - hierarchical parallelism tests
      CXX='icx' CXXFLAGS='-fiopenmp -fopenmp-targets=spir64=-fno-exceptions' MAKEFLAGS='-j8 --output-sync=target' ./omphval.sh run ./tests/hp_*
  - Display all the non working c++11 math tests who are not of type long_double
      ./omphval.sh diplay --avoid_long_double  results/*/math_cpp11
"

# docopt parser below, refresh this parser with `docopt.sh omphval.sh`
# shellcheck disable=2016,1091,2034
docopt() { source omphval/docopt-lib.sh '0.9.15' || { ret=$?
printf -- "exit %d\n" "$ret"; exit "$ret"; }; set -e; trimmed_doc=${DOC:0:197}
usage=${DOC:36:161}; digest=3d39b; shorts=('' '' '')
longs=(--v5 --working --avoid_long_double); argcounts=(0 0 0); node_0(){
switch __v5 0; }; node_1(){ switch __working 1; }; node_2(){
switch __avoid_long_double 2; }; node_3(){ value _test_folder_ a true; }
node_4(){ value _result_folder_ a true; }; node_5(){ _command gen; }; node_6(){
_command run; }; node_7(){ _command display; }; node_8(){ _command clean; }
node_9(){ optional 0; }; node_10(){ required 5 9; }; node_11(){ oneormore 3; }
node_12(){ optional 11; }; node_13(){ required 6 12; }; node_14(){ optional 1; }
node_15(){ optional 2; }; node_16(){ oneormore 4; }; node_17(){ optional 16; }
node_18(){ required 7 14 15 17; }; node_19(){ required 8; }; node_20(){
either 10 13 18 19; }; node_21(){ required 20; }; cat <<<' docopt_exit() {
[[ -n $1 ]] && printf "%s\n" "$1" >&2; printf "%s\n" "${DOC:36:161}" >&2; exit 1
}'; unset var___v5 var___working var___avoid_long_double var__test_folder_ \
var__result_folder_ var_gen var_run var_display var_clean; parse 21 "$@"
local prefix=${DOCOPT_PREFIX:-''}; local docopt_decl=1
[[ $BASH_VERSION =~ ^4.3 ]] && docopt_decl=2; unset "${prefix}__v5" \
"${prefix}__working" "${prefix}__avoid_long_double" "${prefix}_test_folder_" \
"${prefix}_result_folder_" "${prefix}gen" "${prefix}run" "${prefix}display" \
"${prefix}clean"; eval "${prefix}"'__v5=${var___v5:-false}'
eval "${prefix}"'__working=${var___working:-false}'
eval "${prefix}"'__avoid_long_double=${var___avoid_long_double:-false}'
if declare -p var__test_folder_ >/dev/null 2>&1; then
eval "${prefix}"'_test_folder_=("${var__test_folder_[@]}")'; else
eval "${prefix}"'_test_folder_=()'; fi
if declare -p var__result_folder_ >/dev/null 2>&1; then
eval "${prefix}"'_result_folder_=("${var__result_folder_[@]}")'; else
eval "${prefix}"'_result_folder_=()'; fi
eval "${prefix}"'gen=${var_gen:-false}'; eval "${prefix}"'run=${var_run:-false}'
eval "${prefix}"'display=${var_display:-false}'
eval "${prefix}"'clean=${var_clean:-false}'; local docopt_i=0
for ((docopt_i=0;docopt_i<docopt_decl;docopt_i++)); do
declare -p "${prefix}__v5" "${prefix}__working" "${prefix}__avoid_long_double" \
"${prefix}_test_folder_" "${prefix}_result_folder_" "${prefix}gen" \
"${prefix}run" "${prefix}display" "${prefix}clean"; done; }
# docopt parser above, complete command for generating this parser is `docopt.sh --library=omphval/docopt-lib.sh omphval.sh`

l_folder() {
    echo $(find tests -type d | sort -r | awk 'a!~"^"$0{a=$0;print}' | sort)
}

frun() {
    if [ -z "$1" ]
    then
       folders=$(l_folder)
    else
       folders="$@"
    fi 

    uuid=$(date +"%Y-%m-%d_%H-%M")
    result="results/${uuid}_$(hostname)"

    for dir in $folders
    do
        nresult=$result/$(basename $dir)
        echo "Running $dir | Saving log in $nresult"
        mkdir -p $nresult
        env > $nresult/env.log 
        make --no-print-directory -C $dir exe |& tee $nresult/compilation.log
        make --no-print-directory -C $dir run |& tee $nresult/runtime.log
    done
}

fdisplay_filter() {
    if ${__avoid_long_double} ; then grep -v long_double $1 ;else cat $1; fi
}

fdisplay() {

    display_log() {
        file=$1
        if [ -f "$file" ]
        then
            # Make print "***" when the error is fatal (https://www.gnu.org/software/make/manual/make.html#Error-Messages)
            # It make the parsing tedious, so we always removing it, then we remove the first 2 collumn thanks to awk.

            # Some recent version of make print the error message with the line number. We remove it too.

            # We then sort uniq to remove this duplicate (see `run` ). 
            # The sort if just to sort by type of error.
            grep "make:" $file | sed -r 's/\*{3}//g' |  \
                               sed -r 's/Makefile:[0-9]+: //g' | \
                               awk -v dir=$1 -v mode=$2 '{print dir " " mode " " substr($0, index($0, $2))}' | \
                               sort | uniq |  \
                               sort -k3
        fi
    }

    if [ -z "$1" ]
    then
      folders=$( find results -maxdepth 1 -type d | sort -r | head -n 1)
      folders=$folders/*
    else
      folders=$(find "${@:1}" -type d -links 2)
    fi

  
    for head_dir in $folders
    do
        compilation=$(display_log ${head_dir}/compilation.log)
        display=$(display_log ${head_dir}/runtime.log)
        if [ ! -z "$compilation" ] || [ ! -z "$display" ]  
        then
            echo ">> $head_dir"
            if ${__working}
            then
                ./omphval/display_pass.py $(basename $head_dir) $compilation $display | fdisplay_filter
            else
                echo "$compilation" | column -t | fdisplay_filter 
                echo "$display" | column -t | fdisplay_filter
            fi
            echo ""
        fi
    done
}

fclean() {
    for dir in $(l_folder)
    do
        make --no-print-directory -s -C $dir "clean"
    done
}

#  _
# |_) _. ._ _ o ._   _     /\  ._ _
# |  (_| | _> | | | (_|   /--\ | (_| \/
#                    _|           _|
eval "$(docopt "$@")"

$gen && rm -rf tests && ./omphval/gtest.py ${__v5}
$run && fclean && frun ${_test_folder_[@]} 
$display && fdisplay ${_result_folder_[@]}
$clean && fclean
exit 0

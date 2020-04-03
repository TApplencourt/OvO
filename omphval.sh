#!/usr/bin/env bash
DOC="Omphval.sh a OpenMP test generator.
Usage:
  omphval.sh gen [--v5]
  omphval.sh run [<test_folder>...]
  omphval.sh display [--failure | --pass] [--avoid_long_double] [<result_folder>...]
  omphval.sh clean

  Options:
   gen                 Generate the ./tests directory containting all the tests
     v5                  Generate openmp v5 tests (loop construct for example)
   
   run                 Will run all the test specifier by <test_folder>.
                       The log are stored in the ./results/\${uuid}_\$(hostname)/<test_folder>/ directory
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
printf -- "exit %d\n" "$ret"; exit "$ret"; }; set -e; trimmed_doc=${DOC:0:1557}
usage=${DOC:36:170}; digest=5d1ef; shorts=('' '' '' '')
longs=(--v5 --failure --pass --avoid_long_double); argcounts=(0 0 0 0)
node_0(){ switch __v5 0; }; node_1(){ switch __failure 1; }; node_2(){
switch __pass 2; }; node_3(){ switch __avoid_long_double 3; }; node_4(){
value _test_folder_ a true; }; node_5(){ value _result_folder_ a true; }
node_6(){ _command gen; }; node_7(){ _command run; }; node_8(){ _command display
}; node_9(){ _command clean; }; node_10(){ optional 0; }; node_11(){
required 6 10; }; node_12(){ oneormore 4; }; node_13(){ optional 12; }
node_14(){ required 7 13; }; node_15(){ either 1 2; }; node_16(){ optional 15; }
node_17(){ optional 3; }; node_18(){ oneormore 5; }; node_19(){ optional 18; }
node_20(){ required 8 16 17 19; }; node_21(){ required 9; }; node_22(){
either 11 14 20 21; }; node_23(){ required 22; }; cat <<<' docopt_exit() {
[[ -n $1 ]] && printf "%s\n" "$1" >&2; printf "%s\n" "${DOC:36:170}" >&2; exit 1
}'; unset var___v5 var___failure var___pass var___avoid_long_double \
var__test_folder_ var__result_folder_ var_gen var_run var_display var_clean
parse 23 "$@"; local prefix=${DOCOPT_PREFIX:-''}; local docopt_decl=1
[[ $BASH_VERSION =~ ^4.3 ]] && docopt_decl=2; unset "${prefix}__v5" \
"${prefix}__failure" "${prefix}__pass" "${prefix}__avoid_long_double" \
"${prefix}_test_folder_" "${prefix}_result_folder_" "${prefix}gen" \
"${prefix}run" "${prefix}display" "${prefix}clean"
eval "${prefix}"'__v5=${var___v5:-false}'
eval "${prefix}"'__failure=${var___failure:-false}'
eval "${prefix}"'__pass=${var___pass:-false}'
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
declare -p "${prefix}__v5" "${prefix}__failure" "${prefix}__pass" \
"${prefix}__avoid_long_double" "${prefix}_test_folder_" \
"${prefix}_result_folder_" "${prefix}gen" "${prefix}run" "${prefix}display" \
"${prefix}clean"; done; }
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

    if [ -z "$1" ]
    then
      folders=$( find results -maxdepth 1 -type d | sort -r | head -n 1)
      folders=$folders/*
    else
      folders=$(find "${@}" -type d -links 2)
    fi
      
    for head_dir in $folders
    do
        ./omphval/display.py $head_dir ${__failure} ${__pass} ${__avoid_long_double}
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

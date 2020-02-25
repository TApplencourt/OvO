#!/usr/bin/env bash
DOC="Omphval.sh a OpenMP test generator.
Usage:
  omphval.sh gen
  omphval.sh run [<test_folder>...]
  omphval.sh display [<result_folder>...]
  omphval.sh clean
  
Options:
   <test_folder> Folder to execute [default: ./tests/ ]
   <result_folder> Folder to display [default: ./result/ ]
   Use tradional flags to control the execusion (CXX, CXXFLAGS, MAKEFLAGS, OMP, OMP_TARGET_OFFLOAD, etc)

Example:
    CXX='icx' CXXFLAGS='-fiopenmp -fopenmp-targets=spir64=-fno-exceptions' MAKEFLAGS='-j8 --output-sync=target' ./run.sh run ./test/math*
"
# docopt parser below, refresh this parser with `docopt.sh omphval.sh`
# shellcheck disable=2016,1091,2034
docopt() { source omphval/docopt-lib.sh '0.9.15' || { ret=$?
printf -- "exit %d\n" "$ret"; exit "$ret"; }; set -e; trimmed_doc=${DOC:0:536}
usage=${DOC:36:120}; digest=370b8; shorts=(); longs=(); argcounts=(); node_0(){
value _test_folder_ a true; }; node_1(){ value _result_folder_ a true; }
node_2(){ _command gen; }; node_3(){ _command run; }; node_4(){ _command display
}; node_5(){ _command clean; }; node_6(){ required 2; }; node_7(){ oneormore 0
}; node_8(){ optional 7; }; node_9(){ required 3 8; }; node_10(){ oneormore 1; }
node_11(){ optional 10; }; node_12(){ required 4 11; }; node_13(){ required 5; }
node_14(){ either 6 9 12 13; }; node_15(){ required 14; }
cat <<<' docopt_exit() { [[ -n $1 ]] && printf "%s\n" "$1" >&2
printf "%s\n" "${DOC:36:120}" >&2; exit 1; }'; unset var__test_folder_ \
var__result_folder_ var_gen var_run var_display var_clean; parse 15 "$@"
local prefix=${DOCOPT_PREFIX:-''}; local docopt_decl=1
[[ $BASH_VERSION =~ ^4.3 ]] && docopt_decl=2; unset "${prefix}_test_folder_" \
"${prefix}_result_folder_" "${prefix}gen" "${prefix}run" "${prefix}display" \
"${prefix}clean"; if declare -p var__test_folder_ >/dev/null 2>&1; then
eval "${prefix}"'_test_folder_=("${var__test_folder_[@]}")'; else
eval "${prefix}"'_test_folder_=()'; fi
if declare -p var__result_folder_ >/dev/null 2>&1; then
eval "${prefix}"'_result_folder_=("${var__result_folder_[@]}")'; else
eval "${prefix}"'_result_folder_=()'; fi
eval "${prefix}"'gen=${var_gen:-false}'; eval "${prefix}"'run=${var_run:-false}'
eval "${prefix}"'display=${var_display:-false}'
eval "${prefix}"'clean=${var_clean:-false}'; local docopt_i=0
for ((docopt_i=0;docopt_i<docopt_decl;docopt_i++)); do
declare -p "${prefix}_test_folder_" "${prefix}_result_folder_" "${prefix}gen" \
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
      folders=$(find "$@" -type d -links 2)
    fi

  
    for head_dir in $folders
    do
        compilation=$(display_log ${head_dir}/compilation.log)
        display=$(display_log ${head_dir}/runtime.log)
        if [ ! -z "$compilation" ] || [ ! -z "$display" ]  
        then
            echo ">> $head_dir"
            echo "$compilation" | column -t 
            echo "$display" | column -t
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

$gen && ./omphval/gtest.py
$run && fclean && frun ${_test_folder_[@]} 
$display && fdisplay ${_result_folder_[@]}
$clean && fclean
exit 0

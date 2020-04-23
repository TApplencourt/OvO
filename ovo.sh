#!/usr/bin/env bash
DOC="Omphval.sh a OpenMP test generator.
Usage:
  ovo.sh gen
  ovo.sh run [<test_folder>...] [--no_long_double] [--no_loop]
  ovo.sh display [--detailed | --failed | --passed ] [--no_long_double] [--no_loop] [<result_folder>...]
  ovo.sh report  [--no_long_double] [--no_loop]  [<result_folder>] 
  ovo.sh clean
"

# You are Not Expected to Understand This
# docopt parser below, refresh this parser with `docopt.sh ovo.sh`
# shellcheck disable=2016,1091,2034
docopt() { source src/docopt-lib.sh '0.9.15' || { ret=$?
printf -- "exit %d\n" "$ret"; exit "$ret"; }; set -e; trimmed_doc=${DOC:0:306}
usage=${DOC:36:270}; digest=2fa4d; shorts=('' '' '' '' '')
longs=(--no_long_double --no_loop --detailed --failed --passed)
argcounts=(0 0 0 0 0); node_0(){ switch __no_long_double 0; }; node_1(){
switch __no_loop 1; }; node_2(){ switch __detailed 2; }; node_3(){
switch __failed 3; }; node_4(){ switch __passed 4; }; node_5(){
value _test_folder_ a true; }; node_6(){ value _result_folder_ a true; }
node_7(){ _command gen; }; node_8(){ _command run; }; node_9(){ _command display
}; node_10(){ _command report; }; node_11(){ _command clean; }; node_12(){
required 7; }; node_13(){ oneormore 5; }; node_14(){ optional 13; }; node_15(){
optional 0; }; node_16(){ optional 1; }; node_17(){ required 8 14 15 16; }
node_18(){ either 2 3 4; }; node_19(){ optional 18; }; node_20(){ oneormore 6; }
node_21(){ optional 20; }; node_22(){ required 9 19 15 16 21; }; node_23(){
optional 6; }; node_24(){ required 10 15 16 23; }; node_25(){ required 11; }
node_26(){ either 12 17 22 24 25; }; node_27(){ required 26; }
cat <<<' docopt_exit() { [[ -n $1 ]] && printf "%s\n" "$1" >&2
printf "%s\n" "${DOC:36:270}" >&2; exit 1; }'; unset var___no_long_double \
var___no_loop var___detailed var___failed var___passed var__test_folder_ \
var__result_folder_ var_gen var_run var_display var_report var_clean
parse 27 "$@"; local prefix=${DOCOPT_PREFIX:-''}; local docopt_decl=1
[[ $BASH_VERSION =~ ^4.3 ]] && docopt_decl=2
unset "${prefix}__no_long_double" "${prefix}__no_loop" "${prefix}__detailed" \
"${prefix}__failed" "${prefix}__passed" "${prefix}_test_folder_" \
"${prefix}_result_folder_" "${prefix}gen" "${prefix}run" "${prefix}display" \
"${prefix}report" "${prefix}clean"
eval "${prefix}"'__no_long_double=${var___no_long_double:-false}'
eval "${prefix}"'__no_loop=${var___no_loop:-false}'
eval "${prefix}"'__detailed=${var___detailed:-false}'
eval "${prefix}"'__failed=${var___failed:-false}'
eval "${prefix}"'__passed=${var___passed:-false}'
if declare -p var__test_folder_ >/dev/null 2>&1; then
eval "${prefix}"'_test_folder_=("${var__test_folder_[@]}")'; else
eval "${prefix}"'_test_folder_=()'; fi
if declare -p var__result_folder_ >/dev/null 2>&1; then
eval "${prefix}"'_result_folder_=("${var__result_folder_[@]}")'; else
eval "${prefix}"'_result_folder_=()'; fi
eval "${prefix}"'gen=${var_gen:-false}'; eval "${prefix}"'run=${var_run:-false}'
eval "${prefix}"'display=${var_display:-false}'
eval "${prefix}"'report=${var_report:-false}'
eval "${prefix}"'clean=${var_clean:-false}'; local docopt_i=0
for ((docopt_i=0;docopt_i<docopt_decl;docopt_i++)); do
declare -p "${prefix}__no_long_double" "${prefix}__no_loop" \
"${prefix}__detailed" "${prefix}__failed" "${prefix}__passed" \
"${prefix}_test_folder_" "${prefix}_result_folder_" "${prefix}gen" \
"${prefix}run" "${prefix}display" "${prefix}report" "${prefix}clean"; done; }
# docopt parser above, complete command for generating this parser is `docopt.sh --library=src/docopt-lib.sh ovo.sh`

#We don't use the most straitforward `find . -type d -links 2`
#Because on MaxOS and the Travis PowerPC links includes current,parent and sub directories but also files.  
#  LC_ALL=C is to get the tradional  sort order. Solve issue with reduction , reduction_atomic
fl_folder(){
    local folders=$(find $(realpath "${@}") -type d |  LC_ALL=C sort | uniq | awk '$0 !~ last "/" {print last} {last=$0} END {print last}')
    echo $(realpath ${folders} --relative-to=$PWD)
}

fl_test_src() {
    if [ -z "$1" ]
    then
        echo $(fl_folder "test_src")
    else
        echo $(fl_folder "${@}")
    fi
}

frun() {
    local uuid=$(date +"%Y-%m-%d_%H-%M")
    local result="test_result/${uuid}_$(hostname)"

    for dir in $(fl_test_src $@)
    do
        nresult=$result/${dir#*/}
        echo "Running $dir | Saving log in $nresult"

        mkdir -p "$nresult"
        env > "$nresult"/env.log
        echo $(${CXX:-c++} --version) > "$nresult"/compilers.log
        echo $(${FC:-gfortran} --version) >> "$nresult"/compilers.log

        if [[ ${__no_long_double} && ${__no_loop} ]]
        then
            make --no-print-directory -C "$dir" exe_no_long_double_no_loop |& tee "$nresult"/compilation.log
        elif ${__no_long_double}
        then
            make --no-print-directory -C "$dir" exe_no_long_double |& tee "$nresult"/compilation.log
        elif ${__no_loop}
        then
            make --no-print-directory -C "$dir" exe_no_loop |& tee "$nresult"/compilation.log
        else
            make --no-print-directory -C "$dir" exe |& tee "$nresult"/compilation.log
        fi
        make --no-print-directory -C "$dir" run |& tee "$nresult"/runtime.log
    done
}

fdisplay() {

    if [ -z "$1" ]
    then
      # Get the last modified folder in results, then list all the tests avalaible inside.
      local folder="$(ls test_result | sort | tail -n 1)"
      local name=$folder
    else
      local folder="${@}" 
      local name=""  
    fi
    ./src/display.py "${name}" "${__detailed}" "${__failed}" "${__passed}" "${__no_long_double}" "${__no_loop}" $(fl_folder ${folder})
}

fdisplayc() {
    #Print only if one folder exist
    local folders=( $(realpath -qe ${@:2}) )
    if [[ ${#folders} -ne 0 ]]; then
        echo $1 && fdisplay ${folders[@]}
    fi
}

freport() {
    if [ -z "$1" ]
    then
      # Get the last modified folder in results, then list all the tests avalaible inside.
      local folder="$(ls -d test_result/* | sort | tail -n 1)"
   else
      local folder="$1"
    fi

    echo ">> $folder"

    fdisplayc "cpp math"  $folder/cpp/{math,complex}_*
    fdisplayc "cpp hierarchical parallelism" $folder/cpp/hierarchical_parallelism/
    fdisplayc "fortran math" $folder/fortran/{math,complex}
    fdisplayc "fortran hierarchical parallelism" $folder/fortran/hierarchical_parallelism/
	
    echo "Summary" && fdisplay $folder
}

fclean() {
    for dir in $(fl_test_src $@)
    do
        make -s -C "$dir" "clean"
    done
    
}

#  _
# |_) _. ._ _ o ._   _     /\  ._ _
# |  (_| | _> | | | (_|   /--\ | (_| \/
#                    _|           _|
DOCOPT_DOC_CHECK=false
eval "$(docopt "$@")"

$gen && rm -rf -- ./test_src && ./src/gtest.py 
$run && fclean "${_result_folder_[@]}" && frun "${_test_folder_[@]}"
$display && fdisplay "${_result_folder_[@]}"
$report && freport "${_result_folder_[@]}"
$clean && fclean
exit 0

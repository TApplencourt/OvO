#!/usr/bin/env bash
DOC="Omphval.sh a OpenMP test generator.
Usage:
  ovo.sh gen
  ovo.sh run [<test_folder>...] [--no_long_double] [--no_loop]
  ovo.sh display [--failure | --pass] [--no_long_double] [--no_loop] [<result_folder>...]
  ovo.sh clean
"

# You are Not Expected to Understand This
# docopt parser below, refresh this parser with `docopt.sh ovo.sh`
# shellcheck disable=2016,1091,2034
docopt() { source src/docopt-lib.sh '0.9.15' || { ret=$?
printf -- "exit %d\n" "$ret"; exit "$ret"; }; set -e; trimmed_doc=${DOC:0:223}
usage=${DOC:36:187}; digest=f003f; shorts=('' '' '' '')
longs=(--no_long_double --no_loop --failure --pass); argcounts=(0 0 0 0)
node_0(){ switch __no_long_double 0; }; node_1(){ switch __no_loop 1; }
node_2(){ switch __failure 2; }; node_3(){ switch __pass 3; }; node_4(){
value _test_folder_ a true; }; node_5(){ value _result_folder_ a true; }
node_6(){ _command gen; }; node_7(){ _command run; }; node_8(){ _command display
}; node_9(){ _command clean; }; node_10(){ required 6; }; node_11(){ oneormore 4
}; node_12(){ optional 11; }; node_13(){ optional 0; }; node_14(){ optional 1; }
node_15(){ required 7 12 13 14; }; node_16(){ either 2 3; }; node_17(){
optional 16; }; node_18(){ oneormore 5; }; node_19(){ optional 18; }; node_20(){
required 8 17 13 14 19; }; node_21(){ required 9; }; node_22(){
either 10 15 20 21; }; node_23(){ required 22; }; cat <<<' docopt_exit() {
[[ -n $1 ]] && printf "%s\n" "$1" >&2; printf "%s\n" "${DOC:36:187}" >&2; exit 1
}'; unset var___no_long_double var___no_loop var___failure var___pass \
var__test_folder_ var__result_folder_ var_gen var_run var_display var_clean
parse 23 "$@"; local prefix=${DOCOPT_PREFIX:-''}; local docopt_decl=1
[[ $BASH_VERSION =~ ^4.3 ]] && docopt_decl=2
unset "${prefix}__no_long_double" "${prefix}__no_loop" "${prefix}__failure" \
"${prefix}__pass" "${prefix}_test_folder_" "${prefix}_result_folder_" \
"${prefix}gen" "${prefix}run" "${prefix}display" "${prefix}clean"
eval "${prefix}"'__no_long_double=${var___no_long_double:-false}'
eval "${prefix}"'__no_loop=${var___no_loop:-false}'
eval "${prefix}"'__failure=${var___failure:-false}'
eval "${prefix}"'__pass=${var___pass:-false}'
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
declare -p "${prefix}__no_long_double" "${prefix}__no_loop" \
"${prefix}__failure" "${prefix}__pass" "${prefix}_test_folder_" \
"${prefix}_result_folder_" "${prefix}gen" "${prefix}run" "${prefix}display" \
"${prefix}clean"; done; }
# docopt parser above, complete command for generating this parser is `docopt.sh --library=src/docopt-lib.sh ovo.sh`

#We don't use the most straitforward `find . -type d -links 2`
#Because on MaxOS and the Travis PowerPC links includes current,parent and sub directories but also files.
fl_folder(){
    find "${@}" -type d | sort | awk '$0 !~ last "/" {print last} {last=$0} END {print last}'
}

fl_test_src() {
    if [ -z "$1" ]
    then
        local folders=$(fl_folder "test_src")
    else
        local folders=$(fl_folder "${@}")
    fi
    echo $(realpath ${folders}  --relative-to=$PWD)
}

frun() {
    uuid=$(date +"%Y-%m-%d_%H-%M")
    result="test_result/${uuid}_$(hostname)"

    # Remove '.' in front of the path
    # so `./ovo.sh run ./test_src/hp_*` and `./ovo.sh run test_src/hp_*` will work. 
    for dir in $(realpath $(fl_test_src $@)  --relative-to=.)
    do
        nresult=$result/${dir#*/}
        echo "Running $dir | Saving log in $nresult"

        mkdir -p "$nresult"
        env > "$nresult"/env.log
        if ${__no_long_double}
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
      folders="$(find test_result -maxdepth 1 -type d | tail -n 1)"
    else
      folders="${@}"   
    fi

    folders_leaf=$(find "${folders}" -type d -links 2)
    ./src/display.py "${__failure}" "${__pass}" "${__no_long_double}" "${__no_loop}" $folders_leaf
}

fclean() {
    for dir in $(fl_test_src $@)
    do
        make --no-print-directory -s -C "$dir" "clean"
    done
}

#  _
# |_) _. ._ _ o ._   _     /\  ._ _
# |  (_| | _> | | | (_|   /--\ | (_| \/
#                    _|           _|
eval "$(docopt "$@")"

$gen && rm -rf -- ./test_src && ./src/gtest.py "${__v5}"
$run && fclean "${_result_folder_[@]}" && frun "${_test_folder_[@]}"
$display && fdisplay "${_result_folder_[@]}"
$clean && fclean
exit 0

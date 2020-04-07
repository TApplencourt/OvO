#!/usr/bin/env bash
DOC="Omphval.sh a OpenMP test generator.
Usage:
  ovo.sh gen [--v5]
  ovo.sh run [<test_folder>...] [--no_long_double] [--legacy_omp]
  ovo.sh display [--failure | --pass] [--no_long_double] [--legacy_omp] [<result_folder>...]
  ovo.sh clean

  Options:
   gen                 Generate the ./tests directory containting all the tests
     v5                  Generate openmp v5 tests (loop construct for example)
   
   run                 Will run all the test specifier by <test_folder>.
                       The log are stored in the ./results/\${uuid}_\$(hostname)/<test_folder>/ directory
                       More information are saved in '{compilation,runtime}.log' files of those result folder
                       Use tradional Flags to control the execusion (CXX, CXXFLAGS, MAKEFLAGS, OMP, OMP_TARGET_OFFLOAD, etc)
     <test_folder>       Folder containing the tests to run (default: ./tests/ ) 

   display             Display the Error message of failling tests. 
     <result_folder>     Folder to display (default: ./test_result/ ) 
     avoid_long_double   Don't print long_double tests. If used in conjunction with working, will not print the working long double if they exit

Example:
  - hierarchical parallelism tests
       OMP_TARGET_OFFLOAD=mandatory CXX='icc' CXXFLAGS='-qnextgen -fiopenmp -fopenmp-targets=spir64=-fno-exceptions' MAKEFLAGS='-j8 --output-sync=target' ./ovo.sh run ./tests/hp_*
  - Display a sumarry of result the result.
      ./ovol.sh diplay --avoid_long_double  results/*/math_cpp11
"

# You are Not Expected to Understand This
# docopt parser below, refresh this parser with `docopt.sh ovo.sh`
# shellcheck disable=2016,1091,2034
docopt() { source src/docopt-lib.sh '0.9.15' || { ret=$?
printf -- "exit %d\n" "$ret"; exit "$ret"; }; set -e; trimmed_doc=${DOC:0:1525}
usage=${DOC:36:200}; digest=b38b3; shorts=('' '' '' '' '')
longs=(--v5 --no_long_double --legacy_omp --failure --pass)
argcounts=(0 0 0 0 0); node_0(){ switch __v5 0; }; node_1(){
switch __no_long_double 1; }; node_2(){ switch __legacy_omp 2; }; node_3(){
switch __failure 3; }; node_4(){ switch __pass 4; }; node_5(){
value _test_folder_ a true; }; node_6(){ value _result_folder_ a true; }
node_7(){ _command gen; }; node_8(){ _command run; }; node_9(){ _command display
}; node_10(){ _command clean; }; node_11(){ optional 0; }; node_12(){
required 7 11; }; node_13(){ oneormore 5; }; node_14(){ optional 13; }
node_15(){ optional 1; }; node_16(){ optional 2; }; node_17(){
required 8 14 15 16; }; node_18(){ either 3 4; }; node_19(){ optional 18; }
node_20(){ oneormore 6; }; node_21(){ optional 20; }; node_22(){
required 9 19 15 16 21; }; node_23(){ required 10; }; node_24(){
either 12 17 22 23; }; node_25(){ required 24; }; cat <<<' docopt_exit() {
[[ -n $1 ]] && printf "%s\n" "$1" >&2; printf "%s\n" "${DOC:36:200}" >&2; exit 1
}'; unset var___v5 var___no_long_double var___legacy_omp var___failure \
var___pass var__test_folder_ var__result_folder_ var_gen var_run var_display \
var_clean; parse 25 "$@"; local prefix=${DOCOPT_PREFIX:-''}; local docopt_decl=1
[[ $BASH_VERSION =~ ^4.3 ]] && docopt_decl=2; unset "${prefix}__v5" \
"${prefix}__no_long_double" "${prefix}__legacy_omp" "${prefix}__failure" \
"${prefix}__pass" "${prefix}_test_folder_" "${prefix}_result_folder_" \
"${prefix}gen" "${prefix}run" "${prefix}display" "${prefix}clean"
eval "${prefix}"'__v5=${var___v5:-false}'
eval "${prefix}"'__no_long_double=${var___no_long_double:-false}'
eval "${prefix}"'__legacy_omp=${var___legacy_omp:-false}'
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
declare -p "${prefix}__v5" "${prefix}__no_long_double" "${prefix}__legacy_omp" \
"${prefix}__failure" "${prefix}__pass" "${prefix}_test_folder_" \
"${prefix}_result_folder_" "${prefix}gen" "${prefix}run" "${prefix}display" \
"${prefix}clean"; done; }
# docopt parser above, complete command for generating this parser is `docopt.sh --library=src/docopt-lib.sh ovo.sh`

# May not work on macOS (https://stackoverflow.com/a/4269862/7674852)
#!/bin/bash
l_tests_src=$(find test_src -type d -links 2)

frun() {
    if [ -z "$1" ]
    then
       folders=${l_tests_src}
    else
       folders=$(find "${@}" -type d -links 2)
    fi

    uuid=$(date +"%Y-%m-%d_%H-%M")
    result="test_result/${uuid}_$(hostname)"

    for dir in $folders
    do
        nresult=$result/${dir#*/}
        echo "Running $dir | Saving log in $nresult"
        mkdir -p "$nresult"
        env > "$nresult"/env.log
        if ${__no_long_double} && ${__legacy_omp}
        then
            make --no-print-directory -C "$dir" exe_no_long_double_no_loop |& tee "$nresult"/compilation.log
        elif ${__no_long_double}
        then
            make --no-print-directory -C "$dir" exe_no_long_double |& tee "$nresult"/compilation.log
        elif ${__legacy_omp}
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
      folders="$(find test_result -maxdepth 1 -type d | tail -n 1)/*"
    else
      folders=$(find "${@}" -type d -links 2)
    fi

    for head_dir in $folders
    do
        ./src/display.py "$head_dir" "${__failure}" "${__pass}" "${__avoid_long_double}"
    done
}

fclean() {
    for dir in ${l_tests_src}
    do
        make --no-print-directory -s -C "$dir" "clean"
    done
}

#  _
# |_) _. ._ _ o ._   _     /\  ._ _
# |  (_| | _> | | | (_|   /--\ | (_| \/
#                    _|           _|
eval "$(docopt "$@")"

$gen && rm -rf -- tests_src && ./src/gtest.py "${__v5}"
$run && fclean && frun "${_test_folder_[@]}"
$display && fdisplay "${_result_folder_[@]}"
$clean && fclean
exit 0

#!/usr/bin/env bash

# Find path of all directories who contain a Makefile, those are the test directory
# If not argument are passed, we look for the 'test_src'folder
# The uniq at the end is needed because user can pass the same folder twice in the arguments
find_tests_folder() { find ${@:-test_src} -type f -name 'Makefile' -printf "%h\n" | sort -u ; }

fclean() { for dir in $(find_tests_folder $@); do make --silent -C "$dir" clean; done; }

frun() {
    SYNC=$(make -v | head -n1 |  awk '$NF >= 4 {print "--output-sync"}')
    if [ -n "$SYNC" ]; then NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null); fi
    export MAKEFLAGS="${MAKEFLAGS:--j${NPROC:-1} $SYNC}"
   
    for dir in $(find_tests_folder $@); do
        nresult=$result/${dir#*/}
        echo ">> Running $dir | Saving log in $nresult"
        mkdir -p "$nresult"
        {
            set -x
            env
            ${CXX:-c++} --version
            ${FC:-gfortran} --version
            set +x
        } &> "$nresult"/env.log
        # Compile in parallel
        make --no-print-directory -C "$dir" exe 2>&1 | tee "$nresult"/compilation.log
        # But Run serially
        make -j1 --no-print-directory -C "$dir" run 2>&1 | tee "$nresult"/runtime.log
    done
}

base=$(dirname $0)
#  _
# |_) _. ._ _ o ._   _     /\  ._ _
# |  (_| | _> | | | (_|   /--\ | (_| \/
#                    _|           _|
while (( "$#" )); do
    case "$1" in
        gen)
            shift; $base/src/gtest.py $@; exit
            ;;
        clean)
            shift; fclean; exit
            ;;
        run)
            shift; 
    	    # See if user passed -o as first argument
	    # and set global baraible result used by frun
            if [ "$1" == "-o" ]; then
        	shift; result="test_result/$1"; shift;
    	    else
        	uuid=$(date +"%Y-%m-%d_%H-%M")
        	result="test_result/${uuid}_$(hostname)"
    	    fi 
	    fclean $@ && frun $@; exit
            ;;
        report)
            shift; $base/src/report.py $@; exit
            ;;
        *)
            shift;
            ;;
    esac
done
cat $base/src/template/ovo_usage.txt
exit 0

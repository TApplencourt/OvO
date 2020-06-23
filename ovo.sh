#!/usr/bin/env bash

# Find path of all directories who contain a Makefile, those are the test directory
# If not argument are passed, we look for the 'test_src'folder
# The uniq at the end is needed because user can pass the same folder twice in the arguments
find_tests_folder() { find ${@:-test_src} -type f -name 'Makefile' -printf "%h\n" | sort -u ; }

fclean() { for dir in $(find_tests_folder $@); do make --silent -C "$dir" clean; done; }

frun() {
    local uuid=$(date +"%Y-%m-%d_%H-%M")
    local result="test_result/${uuid}_$(hostname)"

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
        NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null)
        export MAKEFLAGS="${MAKEFLAGS:--j${NPROC:-1} --output-sync}"
        make --no-print-directory -C "$dir" exe |& tee "$nresult"/compilation.log
        # But Run serially
        make -j1 --no-print-directory -C "$dir" run |& tee "$nresult"/runtime.log
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
            shift; $base/src/gtest.py "$@"; exit
            ;;
        clean)
            shift; fclean; exit
            ;;
        run)
            shift; fclean $@ && frun $@; exit
            ;;
        report)
            shift; $base/src/report.py $@; exit
            ;;
    esac
done
cat $base/src/template/ovo_usage.txt
exit 0

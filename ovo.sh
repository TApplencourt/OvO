#!/usr/bin/env bash

# Find path of all directories who contain a Makefile.
# Those are the test directory
# The uniq at the end is needed because user can pass the same folder twice in the arguments
fl_test_src() { find ${@:-test_src} -type f -name 'Makefile' -printf "%h\n" | sort -u ; }

frun() {
    local uuid=$(date +"%Y-%m-%d_%H-%M")
    local result="test_result/${uuid}_$(hostname)"

    for dir in $(fl_test_src $@)
    do
        nresult=$result/${dir#*/}
        echo "Running $dir | Saving log in $nresult"

        mkdir -p "$nresult"
        env > "$nresult"/env.log
        echo "Trying to get more information about compiler used..." >> "$nresult"/env.log
        echo "${CXX:-c++} --version" >> "$nresult"/env.log
        ${CXX:-c++} --version &>> "$nresult"/env.log
        echo "${FC:-gfortran} --version" >> "$nresult"/env.log
        ${FC:-gfortran} --version &>> "$nresult"/env.log

	# Compile in parallel
	NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null)
        export MAKEFLAGS="${MAKEFLAGS:--j${NPROC:-1} --output-sync}"
        make --no-print-directory -C "$dir" exe |& tee "$nresult"/compilation.log
        # But Run serially
        make -j1 --no-print-directory -C "$dir" run |& tee "$nresult"/runtime.log
    done
}

fclean() {
    for dir in $(fl_test_src $@)
    do
        make -s -C "$dir" "clean"
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
        shift
        $base/src/gtest.py "$@"
        exit
        ;;
        run)
        shift
        fclean $@ && frun $@
        exit
        ;;
        report)
        shift
        $base/src/report.py $@
        exit
        ;;
        clean)
        fclean
        exit
        ;;
        *)
        shift
        ;;
esac
done
cat $base/src/template/ovo_usage.txt
exit 0

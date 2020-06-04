#!/usr/bin/env bash
fl_folder(){
    find "${@}" -type f -name 'Makefile' -printf "%h\n" | sort -u
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

        NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null)
        export MAKEFLAGS="${MAKEFLAGS:--j$NPROC --output-sync}"
        # Compile
        make --no-print-directory -C "$dir" exe |& tee "$nresult"/compilation.log
        # Run serially
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
        $base/src/gtest.py $@
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
# Notice the quote...They are need to print multiline string
cat $base/src/template/ovo_usage.txt
exit 0

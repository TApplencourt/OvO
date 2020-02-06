#!/usr/bin/env bash
display_help() {
    echo "$(basename $0) a OpenMP test generator."
    echo "Usage:"
    echo " $0 -h | --help "
    echo " $0 [ -g | --gen ] [ -r | --run] [ -d | --display ] "
    echo
    echo "   -h --help          Show this screen."
    echo "   -g, --gen          Generate the tests"
    echo "   -r, --run          Complile and run the tests"
    echo "   -d, --display      Display the summary of the test"
    echo "   -c, --clean        Clean previously compiled tests"
    echo
    echo "Please use tradional flags to control the execusion (CXX, CXXFLAGS, MAKEFLAGS, OMP, OMP_TARGET_OFFLOAD, etc)"
    echo ""
    echo "Example:"
    echo "CXX='icx' CXXFLAGS='-fiopenmp -fopenmp-targets=spir64=-fno-exceptions' MAKEFLAGS='-j8 --output-sync=target' ./run.sh -g -r -d"
    exit 1
}

l_folder() {
    echo $(find tests -type d | sort -r | awk 'a!~"^"$0{a=$0;print}' | sort)
}

run() {
    uuid=$(date +"%Y-%m-%d_%H-%M")
    result="result/$uuid"

    for dir in $(l_folder)
    do
        nresult=$result/$(basename $dir)
        echo "Running $dir | Saving log in $nresult"
        mkdir -p $nresult
        env > $nresult/env.log 
        make --no-print-directory -C $dir exe |& tee $nresult/compilation.log
        make --no-print-directory -C $dir run |& tee $nresult/runtime.log
    done
}

display() {

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

    newest_dir=$(ls -1t result/ | head -n 1)
    for dir in result/$newest_dir/*
    do
        display_log $dir/compilation.log
        display_log $dir/runtime.log
    done
}

clean() {
    for dir in $(l_folder)
    do
        make --no-print-directory -s -C $dir "clean"
    done
}

#  _
# |_) _. ._ _ o ._   _     /\  ._ _
# |  (_| | _> | | | (_|   /--\ | (_| \/
#                    _|           _|

if [ $# -eq 0 ]; then
    display_help;
fi

while true; do
  case "$1" in
    -h | --help) display_help;;
    -g | --gen ) ./omphval/gtest.py; shift ;;
    -r | --run ) run; shift ;;
    -d | --display ) display | column -t; shift ;;
    -c | --clean) clean; shift ;;
    * ) break ;;
  esac
done

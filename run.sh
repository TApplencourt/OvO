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
    echo
    echo "Please use tradional flags to control the execusion (CXX, CXXFLAGS, MAKEFLAGS, OMP, OMP_TARGET_OFFLOAD, etc)"
    echo ""
    echo "Example:"
    echo "CXX='icx' CXXFLAGS='-fiopenmp -fopenmp-targets=spir64=-fno-exceptions' 'MAKEFLAGS='-j8' ./run.sh -g -r -d"
    exit 1
}

run() {
    for dir in $(find omp_tests -type d | sort -r | awk 'a!~"^"$0{a=$0;print}' | sort)
    do
        echo $dir
        # Carefull we append to the file! Indeed some of the error are stochastic. 
        # So this allow use to run multiple time.
        make --no-print-directory -C $dir exe |& tee -a $dir/compilation.log
        make --no-print-directory -C $dir run |& tee -a $dir/runtime.log
    done
}

display() {

    display_log() {
        file=$1/$2.log
        if [ -f "$file" ]
        then
            # Make print "***" when the error is fatal (https://www.gnu.org/software/make/manual/make.html#Error-Messages)
            # It make the parsing tedious, so we always removing it, then we remove the first 2 collumn thanks to awk.
            # We then sort uniq to remove this duplicate (see `run` ). 
            # The sort -k2 if just to sort by type of error.
            grep make: $file | sed -r 's/\*{3}//g' | awk -v dir=$1 -v mode=$2 '{print dir " " mode " " substr($0, index($0, $2))}' | sort | uniq |sort -k2
        fi
    }
    for dir in $(find omp_tests -type d | sort -r | awk 'a!~"^"$0{a=$0;print}' | sort)
    do
        display_log $dir "compilation"
        display_log $dir "runtime"
    done
}

clean() {
    for dir in $(find omp_tests -type d | sort -r | awk 'a!~"^"$0{a=$0;print}' | sort)
    do
        make --no-print-directory -s -C $dir "clean"
        rm -f -- $dir/{compilation,runtime}.log
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
    -g | --gen ) ./ompval/generator.py; shift ;;
    -r | --run ) run; shift ;;
    -d | --display ) display | column -t; shift ;;
    -c | --clean) clean; shift ;;
    * ) break ;;
  esac
done

#!/usr/bin/env bash
display_help() {
    echo "$(basename $0) a OpenMP test generator"
    echo "Usage:"
    echo " $0 -h | --help "
    echo " $0 [ -g | --gen ] [ -r | --run] [ -d | --display ] "
    echo
    echo "   -h --help          Show this screen."
    echo "   -g, --gen          Generate the tests"
    echo "   -r, --run          Complile and run the tests"
    echo "   -d, --display      Display the summary of the test"
    echo
    echo " Example:"
    echo " CXX='icx' CXXFLAGS='-fiopenmp -fopenmp-targets=spir64=-fno-exceptions'  ./run.sh -g -r -d"
    exit 1
}

run() {
    for dir in $(find omp_tests -type d | sort -r | awk 'a!~"^"$0{a=$0;print}' | sort)
    do
        echo $dir
        make --no-print-directory -C $dir exe |& tee -a $dir/exe.log
        make --no-print-directory -C $dir run |& tee -a $dir/run.log
    done
}

display() {
    for dir in $(find omp_tests -type d | sort -r | awk 'a!~"^"$0{a=$0;print}' | sort)
    do
            cat $dir/exe.log |  grep make: | sed -r 's/\*{3}//g' | awk -v dir=$dir '{print dir " compilation " substr($0, index($0, $2))}' | sort | uniq |sort -k2 
            cat $dir/run.log |  grep make: | sed -r 's/\*{3}//g' | awk -v dir=$dir '{print dir " runtime " substr($0, index($0, $2))}' | sort | uniq | sort -k2 
    done
}

#  _
# |_) _. ._ _ o ._   _     /\  ._ _
# |  (_| | _> | | | (_|   /--\ | (_| \/
#                    _|           _|

if [ $# -eq 0 ]; then
    display_help;
fi

VERBOSE=false;  ASM=false
while true; do
  case "$1" in
    -h | --help) display_help;;
    -g | --gen ) ./ompval/generator.py; shift ;;
    -r | --run ) run; shift ;;
    -d | --display ) display | column -t; break;;
    * ) break ;;
  esac
done

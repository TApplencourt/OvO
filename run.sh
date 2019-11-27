#!/usr/bin/env bash

for dir in $(find omp_tests -type d | sort -r | awk 'a!~"^"$0{a=$0;print}' | sort)
do
	echo $dir
	make --no-print-directory -C $dir exe  |& tee $dir/exe.log
	make --no-print-directory -C $dir run  |& tee $dir/run.log 
done

for dir in $(find omp_tests -type d | sort -r | awk 'a!~"^"$0{a=$0;print}' | sort)
do
    echo ""
    echo "===="
    echo $dir
    echo "===="
    echo "Compilation"
    echo ""
    cat $dir/exe.log |  grep make: | sed -r 's/\*{3}//g' |awk '{print substr($0, index($0, $2))}' | column -t | sort | uniq | sort -k2
    echo ""
    echo "Execution"
    echo ""
    cat $dir/run.log |  grep make: | sed -r 's/\*{3}//g' |awk '{print substr($0, index($0, $2))}' | column -t | sort | uniq | sort -k2
done


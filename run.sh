#!/usr/bin/env bash

for dir in $(find omp_tests -type d | sort -r | awk 'a!~"^"$0{a=$0;print}' | sort)
do
	echo $dir
	echo "Testing Compilation"
	make -C $dir exe 2>&1 | grep make
	echo "Testing Run"
	make -C $dir run 2>&1 | grep make
done
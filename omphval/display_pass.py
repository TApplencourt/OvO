#!/usr/bin/env python3

import sys

tfolder = sys.argv[1]

s_non_working = set()
for line in sys.argv[2:]:
    if line.startswith('[') and line.endswith(']'):
        test = line[1:-1]
        if test.startswith('run_'):
            test = test[4:]
        elif test.endswith('exe'):
            test = test[:-4]
        s_non_working.add(test)

import os
s_test = {f[:-4] for f in os.listdir(f"tests/{tfolder}") if f.endswith('.cpp')}

for i in sorted(s_test-s_non_working):
    print (i)

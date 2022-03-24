#!/bin/bash

# Assumption:
# tesla-52 is the pure dataset obtained from box link, i.e.FSL-Sim2Real-IRVL-2022.7z
# tesla-41 contains test classes that don't overlap with training classes

# TODO: not complete, complete this script
ls -d tesla-52/test_data/*/query/ | cut -d '/' -f 3 >> tesla-52.txt
ls -d tesla-41/test_data/*/query/ | cut -d '/' -f 3 >> tesla-41.txt
diff --side-by-side --suppress-common-lines tesla-41.txt tesla-52.txt | cut -d '>' -f 2 | xargs
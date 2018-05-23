#!/usr/bin/env bash

# echo -n "c,gcc "
# gcc -v 2>&1 | grep "gcc version" | cut -f3 -d" "

echo -n "fortran,gcc "
gfortran -v 2>&1 | grep "gcc version" | cut -f3 -d" "

# echo -n go,
# go version | cut -f3 -d" "

echo -n java,
java -version 2>&1 |grep "version" | cut -f3 -d " " | cut -c 2-9

# echo -n "javascript,V8 "
# nodejs -e "console.log(process.versions.v8)"

echo -n "julia,"
$JULIAHOME/usr/bin/julia -v | cut -f3 -d" "

echo -n "lua,"
# scilua -v 2>&1 | grep Shell | cut -f3 -d" " | cut -f1 -d,
echo scilua v1.0.0-b12

# echo -n "mathematica,"
# echo quit | math -version | head -n 1 | cut -f2 -d" "

# echo -n "matlab,R"
# matlab -nodisplay -nojvm -nosplash -r "version -release, quit" | tail -n3 | head -n1

# echo -n "octave,"
# octave -v | grep version | cut -f4 -d" "

echo -n "python,"
python3 -V 2>&1 | cut -f2 -d" "

echo -n "r,"
R --version | grep "R version" | cut -f3 -d" "

# echo -n "rust,"
# (cd rust; rustc --version | cut -c 7- | sed 's/ ([0-9a-f]* /<br>(/g')

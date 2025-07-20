#!/usr/bin/env bash

# User argument declaring what languages to query:
DEFAULT_LANGUAGES="c:fortran:java:javascript:julia:lua:mathematica:matlab:octave:python:r:rust"
LANGUAGES=${1:-DEFAULT_LANGUAGES}

LANGUAGES=":${LANGUAGES}:"

# Check if ":c:" in languages:
if [[ $LANGUAGES == *":c:"* ]]; then
    echo -n "c,gcc "
    gcc -v 2>&1 | grep "gcc version" | cut -f3 -d" "
fi

if [[ $LANGUAGES == *":fortran:"* ]]; then
    echo -n "fortran,gcc "
    gfortran -v 2>&1 | grep "gcc version" | cut -f3 -d" "
fi

# if [[ $LANGUAGES == *":go:"* ]]; then
#     echo -n go,
#     go version | cut -f3 -d" "
# fi

if [[ $LANGUAGES == *":java:"* ]]; then
    echo -n java,
    java -version 2>&1 | grep "version" | cut -f2 -d "\""
fi

if [[ $LANGUAGES == *":javascript:"* ]]; then
    echo -n "javascript,V8 "
    node -e "console.log(process.versions.v8)"
fi

if [[ $LANGUAGES == *":julia:"* ]]; then
    echo -n "julia,"
    julia -v | cut -f3 -d" "
fi

if [[ $LANGUAGES == *":lua:"* ]]; then
    echo -n "lua,"
    (cd lua; ./ulua/luajit/*/Linux/x64/luajit -v | cut -f2 -d" ")
fi

if [[ $LANGUAGES == *":mathematica:"* ]]; then
    echo -n "mathematica,"
    echo quit | math -version | head -n 1 | cut -f2 -d" "
fi

if [[ $LANGUAGES == *":matlab:"* ]]; then
    echo -n "matlab,R"
    matlab -nodisplay -nojvm -nosplash -r "version -release, quit" | tail -n3 | head -n1 | cut -f5 -d" " | sed "s/'//g"
fi

if [[ $LANGUAGES == *":octave:"* ]]; then
    echo -n "octave,"
    octave-cli -v | grep version | cut -f4 -d" "
fi

if [[ $LANGUAGES == *":python:"* ]]; then
    echo -n "python,"
    python3 -V 2>&1 | cut -f2 -d" "
fi

if [[ $LANGUAGES == *":r:"* ]]; then
    echo -n "r,"
    R --version | grep "R version" | cut -f3 -d" "
fi

if [[ $LANGUAGES == *":rust:"* ]]; then
    echo -n "rust,"
    (cd rust; rustc --version | cut -c 7- | sed 's/ ([0-9a-f]* /<br>(/g')
fi

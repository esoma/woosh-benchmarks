#!/usr/bin/env bash

PYTHON=python3
FIND=find
HOST=$(hostname) || exit 1

while getopts "h:p:f:" OPTION; do
    case $OPTION in
    h)
        HOST=$OPTARG
        ;;
    f)
        FIND=$OPTARG
        ;;
    p)
        PYTHON=$OPTARG
        ;;
    *)
        echo "usage: bench.sh [-h HOSTNAME] -f [FIND] [-p PYTHON]"
        exit 1
        ;;
    esac
done

# prepare the woosh repo
if [[ ! -d "woosh" ]]; then
    git clone "https://github.com/esoma/woosh.git" || exit 1
fi 
#git -C woosh reset HEAD --hard || exit 1
#git -C woosh clean -fd || exit 1
#git -C woosh fetch || exit 1
#git -C woosh pull || exit 1
REV=$(git -C woosh rev-parse HEAD) || exit 1

# make sure the directory exists to house the results for this rev
RAW_REV="raw/$REV"
mkdir -p "$RAW_REV" || exit 1

# setup the python virtual environment
$PYTHON -m venv _env
if [[ -f "_env/Scripts/activate" ]]; then
    # windows
    source _env/Scripts/activate
else
    # everything else
    source _env/bin/activate
fi
pip install pyperf psutil virtualenv Cython || exit 1

# run benchmarks
RAW_HOST_REV_JSON="$RAW_HOST/$REV.json"
if [[ -d "tmp" ]]; then
    rm -rf "tmp" || exit 1
fi
mkdir -p "tmp" || exit 1
if [[ -f "$RAW_HOST_REV_JSON" ]]; then
    echo "skipping $RAW_HOST_REV_JSON...results already exist"
fi

# find woosh benchmark runners
WOOSH_BENCHMARKS=$($FIND woosh/bench -name "bench-woosh-*.py")

# woosh with no pgo
(cd woosh && python setup.py build_ext -f install && cd ..) || exit 1
for WOOSH_BENCHMARK in $WOOSH_BENCHMARKS; do
    JSON="tmp/$(basename $WOOSH_BENCHMARK .py).json"
    if [[ -f "$JSON" ]]; then
        rm "$JSON" || exit 1
    fi
    python $WOOSH_BENCHMARK -o "$JSON" || exit 1
done

# woosh with pgo
(cd woosh/pgo && source ./build-msvc.sh) || exit 1
(cd woosh && python setup.py install) || exit 1
for WOOSH_BENCHMARK in $WOOSH_BENCHMARKS; do
    JSON="tmp/pgo-$(basename $WOOSH_BENCHMARK .py).json"
    if [[ -f "$JSON" ]]; then
        rm "$JSON" || exit 1
    fi
    python $WOOSH_BENCHMARK -o "$JSON" || exit 1
done

# cpytoken with pgo
(cd woosh/cpytoken && source ./pgo-build-msvc.sh) || exit 1
(cd woosh/cpytoken && python setup.py install) || exit 1
CPYTOKEN_BENCHMARKS=$($FIND woosh/bench -name "bench-cpytoken-*.py")
for CPYTOKEN_BENCHMARK in $CPYTOKEN_BENCHMARKS; do
    JSON="tmp/pgo-$(basename $CPYTOKEN_BENCHMARK .py).json"
    if [[ -f "$JSON" ]]; then
        rm "$JSON" || exit 1
    fi
    python $CPYTOKEN_BENCHMARK -o "$JSON" || exit 1
done

# tokenize
TOKENIZE_BENCHMARKS=$($FIND woosh/bench -name "bench-tokenize-*.py")
for TOKENIZE_BENCHMARK in $TOKENIZE_BENCHMARKS; do
    JSON="tmp/$(basename $TOKENIZE_BENCHMARK .py).json"
    if [[ -f "$JSON" ]]; then
        rm "$JSON" || exit 1
    fi
    python $TOKENIZE_BENCHMARK -o "$JSON" || exit 1
done

# cython
CYTHON_BENCHMARKS=$($FIND woosh/bench -name "bench-cython-*.py")
for CYTHON_BENCHMARK in $CYTHON_BENCHMARKS; do
    JSON="tmp/$(basename $CYTHON_BENCHMARK .py).json"
    if [[ -f "$JSON" ]]; then
        rm "$JSON" || exit 1
    fi
    python $CYTHON_BENCHMARK -o "$JSON" || exit 1
done

#!/usr/bin/env bash

PYTHON=python3
FIND=find
HOST=$(hostname) || exit 1
REV=master

while getopts "h:p:f:r:" OPTION; do
    case $OPTION in
    r)
        REV=$OPTARG
        ;;
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
git -C woosh reset master --hard || exit 1
git -C woosh clean -fd || exit 1
git -C woosh pull || exit 1
echo "REV=$REV"
git -C woosh checkout $REV
REV=$(git -C woosh rev-parse HEAD) || exit 1

# skip benchmarks if we already have the results
RAW_REV="result/$REV"
RAW_REV_HOST_JSON="$RAW_REV/$HOST.json"
if [[ -f "$RAW_REV_HOST_JSON" ]]; then
    echo "skipping $RAW_REV_HOST_JSON...results already exist"
    exit 0
fi

# make sure the directory exists to house the results for this rev
mkdir -p "$RAW_REV" || exit 1

# run benchmarks
if [[ -d "tmp" ]]; then
    rm -rf "tmp" || exit 1
fi
mkdir -p "tmp" || exit 1

# setup the python virtual environment
$PYTHON -m venv _env
if [[ -f "_env/Scripts/activate" ]]; then
    # windows
    # https://bugs.python.org/issue32451
    dos2unix _env/Scripts/activate
    source _env/Scripts/activate
else
    # everything else
    source _env/bin/activate
fi
$PYTHON -m pip install -r woosh/requirements.txt || exit 1
$PYTHON -m pip install pyperf psutil virtualenv Cython || exit 1

# find woosh benchmark runners
WOOSH_BENCHMARKS=$($FIND woosh/bench -name "bench-woosh-*.py")
RESULTS=""

echo "woosh with no pgo"
(cd woosh && python setup.py install build --pgo-disable -f) || exit 1
for WOOSH_BENCHMARK in $WOOSH_BENCHMARKS; do
    JSON="tmp/$(basename $WOOSH_BENCHMARK .py).json"
    if [[ -f "$JSON" ]]; then
        rm "$JSON" || exit 1
    fi
    python $WOOSH_BENCHMARK -o "$JSON" || exit 1
    RESULTS="$RESULTS $JSON"
done

echo "woosh with pgo"
(cd woosh && python setup.py install build --pgo-require -f) || exit 1
for WOOSH_BENCHMARK in $WOOSH_BENCHMARKS; do
    JSON="tmp/pgo-$(basename $WOOSH_BENCHMARK .py).json"
    if [[ -f "$JSON" ]]; then
        rm "$JSON" || exit 1
    fi
    python $WOOSH_BENCHMARK -o "$JSON" || exit 1
    RESULTS="$RESULTS $JSON"
done

echo "cpytoken with pgo"
(cd woosh/cpytoken && python setup.py install build --pgo-require -f) || exit 1
CPYTOKEN_BENCHMARKS=$($FIND woosh/bench -name "bench-cpytoken-*.py")
for CPYTOKEN_BENCHMARK in $CPYTOKEN_BENCHMARKS; do
    JSON="tmp/pgo-$(basename $CPYTOKEN_BENCHMARK .py).json"
    if [[ -f "$JSON" ]]; then
        rm "$JSON" || exit 1
    fi
    python $CPYTOKEN_BENCHMARK -o "$JSON" || exit 1
    RESULTS="$RESULTS $JSON"
done

echo "tokenize"
TOKENIZE_BENCHMARKS=$($FIND woosh/bench -name "bench-tokenize-*.py")
for TOKENIZE_BENCHMARK in $TOKENIZE_BENCHMARKS; do
    JSON="tmp/$(basename $TOKENIZE_BENCHMARK .py).json"
    if [[ -f "$JSON" ]]; then
        rm "$JSON" || exit 1
    fi
    python $TOKENIZE_BENCHMARK -o "$JSON" || exit 1
    RESULTS="$RESULTS $JSON"
done

echo "cython"
CYTHON_BENCHMARKS=$($FIND woosh/bench -name "bench-cython-*.py")
for CYTHON_BENCHMARK in $CYTHON_BENCHMARKS; do
    JSON="tmp/$(basename $CYTHON_BENCHMARK .py).json"
    if [[ -f "$JSON" ]]; then
        rm "$JSON" || exit 1
    fi
    python $CYTHON_BENCHMARK -o "$JSON" || exit 1
    RESULTS="$RESULTS $JSON"
done

# convert and dump the data
python convert-pyperf-results.py $RESULTS > $RAW_REV_HOST_JSON
RESULTS_STATUS=$?
rm -rf tmp
if [[ $RESULTS_STATUS != 0 ]]; then
    rm $RAW_REV_HOST_JSON
    exit 1
fi

#!/usr/bin/env bash

MAX=10

COUNT=0
while [ $COUNT -lt $MAX ]; do
    (source ./bench.sh $@ -r "master~$COUNT") || exit 1
    COUNT=$((COUNT+1))
done

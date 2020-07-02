#!/bin/bash

. ./puller.sh

if [ $# -lt 1 ]; then
    echo 'Missing week code argument'
    exit 1
fi

weekCode=$1
outDir=${2:-./out}
timestamp=$(date +%Y-%m-%d_%H-%M-%S)

mkdir -p $outDir
status=$?


if [ $status -ne 0 ]; then
    echo "Without write permission to directory $outDir"
    exit 1
fi

while IFS=',' read code name; do
    codes+=( $code )
    names+=( "$name" )
done < cities.csv

count=${#codes[@]}

for index in $(seq 0 $(( $count - 1 ))); do
    echo "Pulling ${names[$index]} ($(( $index + 1 ))/$count)"
    fetchCityStations 'cookie' $weekCode ${codes[$index]} "${names[$index]}" $outDir/$timestamp.csv
    echo ""
done

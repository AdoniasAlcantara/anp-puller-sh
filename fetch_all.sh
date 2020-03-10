#!/bin/bash

if [ $# -ne 1 ]; then
    echo 'Missing week code argument'
    exit 1
fi

weekCode=$1

. ./puller.sh

while IFS=',' read code name; do
    codes+=( $code )
    names+=( "$name" )
done < cities.csv

count=${#codes[@]}

for index in $(seq 0 $(( $count - 1 ))); do
    echo "Pulling ${names[$index]} ($(( $index + 1 ))/$count)"
    fetchCityStations 'cookie' $weekCode ${codes[$index]} "${names[$index]}"
    echo ""
done
#!/bin/bash

# ANP's site
readonly HOST='http://preco.anp.gov.br'
readonly ACTION='include/Relatorio_Excel_Resumo_Por_Municipio_Posto.asp'

# Fuel types that will be pulled
readonly -A FUEL_TYPES=(
    [gasoline]=487
    [ethanol]=643
    [ngv]=476           # NGV (Natural Gas Vehicle)
    [diesel]=532
    [diesel_s10]=812    # Diesel S10
    [lpg]=462           # LPG (Liquefied Petroleum Gas)
)

fetchCityStations() {
    if [ $# -ne 4 ]; then
        echo "4 arguments expected. $# given."
        exit 1
    fi

    # Command line params
    cookie=$1           # The cookie file to gain access to site
    weekCode=$2         # The current week code
    cityCode=$3         # The city code to fetch
    cityName=$4         # Human-readable city name

    for fuelType in ${!FUEL_TYPES[@]}; do
        echo -n "$fuelType..."

        # Pull data from ANP's site
        wget $HOST/$ACTION \
            --quiet \
            --no-check-certificate \
            --load-cookies $cookie \
            --base $HOST \
            --output-document temp.html \
            --post-data \
                "COD_SEMANA=$weekCode\
                &COD_COMBUSTIVEL=${FUEL_TYPES[$fuelType]}\
                &COD_MUNICIPIO=$cityCode"

        status=$?

        # Skip when wget fails
        if [ $status -ne 0 ]; then
            echo "Unable to download data. Skiping $fuelType for $cityName..."
            continue
        fi

        # Convert charset to UTF-8
        iconv -f WINDOWS-1252 -t UTF-8 -o temp-utf8.html temp.html

        # Convert html file to csv
        ./html2csv.py temp-utf8.html

        # Create output dir if it doesn't exist
        outDir="data/$cityName"
        mkdir -p "$outDir"

        # Remove unnecessary lines from csv file and include city name
        tail -n +3 temp-utf8.html1.csv | sed "s/^\"/\"$cityName\",\"/;/,,,,,,,,/Q" > "$outDir/$fuelType.csv"

        # Clean up
        rm -rf temp.html temp-utf8.html temp-utf8.html*.csv

        echo 'OK'
    done
}
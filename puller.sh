#!/bin/bash

# Directories
readonly WORK_DIR="$(pwd)"
readonly TEMP_DIR='/tmp'

# ANP's site
readonly HOST='http://preco.anp.gov.br'
readonly ACTION='include/Relatorio_Excel_Resumo_Por_Municipio_Posto.asp'

# Fuel types
readonly -A FUEL_TYPES=(
    [GASOLINE]=487
    [ETHANOL]=643
    #[NGV]=476           # NGV (Natural Gas Vehicle)
    [DIESEL]=532
    [DIESEL_S10]=812    # Diesel S10
    #[LPG]=462           # LPG (Liquefied Petroleum Gas)
)

fetchCityStations() {
    if [ $# -ne 5 ]; then
        echo "4 arguments expected. $# given."
        exit 1
    fi

    # Command line params
    cookieFile=$1       # The cookiePath file to gain access to site
    weekCode=$2         # The current week code
    cityCode=$3         # The city code to fetch
    cityName=$4         # Human-readable city name
    outputFile=$5

    for fuelType in ${!FUEL_TYPES[@]}; do
        echo -n "$fuelType..."

        # Pull data from ANP's site
        wget $HOST/$ACTION \
            --quiet \
            --no-check-certificate \
            --load-cookies $cookiePath \
            --base $HOST \
            --output-document $TEMP_DIR/temp.html \
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
        (cd $TEMP_DIR && iconv -f WINDOWS-1252 -t UTF-8 -o temp-utf8.html temp.html)

        # Convert html file to csv
        (cd $TEMP_DIR && $WORK_DIR/html2csv.py temp-utf8.html)

        # Remove unnecessary lines from csv file and include city name and fuel type
        tail -n +3 $TEMP_DIR/temp-utf8.html1.csv | sed \
            -e "s/^/$fuelType,$cityName,/" >> $outputFile

        # Clean up
        (cd $TEMP_DIR && rm -rf temp.html temp-utf8.html temp-utf8.html*.csv)

        echo 'OK'
    done
}

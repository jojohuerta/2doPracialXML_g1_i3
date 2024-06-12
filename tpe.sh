#!/bin/bash

API_KEY="zY4yZ4cOmu4puVLXSW9hb9xBJMOhcoLj9K17OrSy"

es_numero() {
    local valor="$1"
    if [[ "$valor" =~ ^-?[0-9]+$ ]]; then
        echo "es numero"
        return 0  # Es un número
    else
        echo "no es numero"
        return 1  # No es un número
    fi
}

es_numero_valido() {
    local valor="$1"
    if es_numero "$valor" && [ "$valor" -ge 2013 ] && [ "$valor" -le 2024 ]; then
        echo "es numero valido"
        return 0  # Es un número
    else
        echo "No es numero valido"
        return 1  # No es un número
    fi
}


es_parametro_valido() {
    local valor="$1"
    case "$valor" in
sc|xf|cw|go|mc)
            return 0  # Es un valor válido
            ;;
        *)
            return 1  # No es un valor válido
            ;;
    esac
}

if  es_numero_valido "$2" && es_parametro_valido "$1"; then
    if  [ ! -d "./data/$1/$2" ]; then
        echo a
        mkdir -p "./data/$1/$2"
        curl "https://api.sportradar.com/nascar-ot3/$1/$2/drivers/list.xml?api_key=$API_KEY" -o "./data/$1/$2/driver_list.xml"
        sleep 2
        curl "https://api.sportradar.com/nascar-ot3/$1/$2/standings/drivers.xml?api_key=$API_KEY" -o "./data/$1/$2/driver_standings.xml"
        sleep 2 

    fi

else
    echo "Parametros incorrectos"
fi

java net.sf.saxon.Query ./extract_nascar_data.xq param1="$1" param2="$2" > nascar_data.xml
    
if  [ -d "./data/$1/$2" ]; then
    java net.sf.saxon.Transform -s:nascar_data.xml -xsl:generate_fo.xsl -o:nascar_page.fo
    ./fop-2.9-bin/fop-2.9/fop/fop -fo nascar_page.fo -pdf nascar_report.pdf
fi


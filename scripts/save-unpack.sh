#!/usr/bin/env bash

set -euo pipefail


DESTINATION_FOLDER=
ASSUME_YES=0
JQ_FORMAT=1

usage() {
    echo "Usage: save-unpack.sh [-yF] [-d path/to/new/location] -- path/to/save.run"
    echo '-y: Assume yes to prompts.'
    echo '-F: Disable jq formatting.'
    echo '-d: The path to save the newly unpacked save. Defaults to the same location as the save itself.'
}

check_args() {
    if [ -z "${SOURCE}" ]; then
        usage
        exit 1
    fi

    if [ ! -f "${SOURCE}" ]; then
        echo "'${SOURCE}' does not exist or is not accessible."
        exit 1
    fi

    if [ ! -d "${DESTINATION_FOLDER}" ]; then
        echo "'${DESTINATION_FOLDER}' does not exist or is not accessible."
        exit 1
    fi

    if [ ! "${SOURCE##*.}" = 'run' ]; then
        echo 'This script expects a packed save file.'
        exit 1
    fi
}

check_requirements() {
    declare -a required_commands=('jq' 'iconv' 'gunzip' 'gzip')
    for CMD in "${required_commands[@]}"
    do
        if ! command -v "${CMD}" >/dev/null 2>&1; then
            echo "${CMD} is required. Please install it."
            exit 1
        fi
    done
}

convert_encoding() {
    iconv -f utf-16 -t utf-8 -o "${1}.utf16" -- "${1}" && mv "${1}.utf16" "${1}"
}

decompress_save() {
    if [ "${ASSUME_YES}" -eq 1 ]; then
        cp "${1}" "${2}.gz" && gunzip -f -- "${2}.gz"
    else
        cp "${1}" "${2}.gz" && gunzip -- "${2}.gz"
    fi
    
    if [ -f "${2}.gz" ]; then
        rm "${2}.gz"
    fi
}

reformat_file() {
    cat "${1}" | jq > "${1}.jq" && mv "${1}.jq" "${1}"
}

while getopts ':yhFd:' OPTION; do
    case "${OPTION}" in
        d) DESTINATION_FOLDER="${OPTARG}" ;;
        y) ASSUME_YES=1 ;;
        F) JQ_FORMAT=0 ;;
        h) 
            usage 
            exit 0
            ;;
        *)
            echo "Invalid Option: -$OPTARG" 1>&2
            exit 1
            ;;
   esac
done
shift $((OPTIND - 1))

SOURCE="`readlink -f "${1}"`"
if [ -z "${DESTINATION_FOLDER}" ]; then
    DESTINATION_FOLDER=`dirname ${SOURCE}`
fi

check_args
check_requirements

SAVE_NAME="`basename "${SOURCE}"`"
BASE_SAVE_NAME="`basename -s '.run' "${SOURCE}"`"
NEW_SAVE_NAME="${BASE_SAVE_NAME}.json"

DESTINATION="`readlink -f ${DESTINATION_FOLDER}`/${NEW_SAVE_NAME}"

echo "Unpack '${SOURCE}' to '${DESTINATION}'"

while [ "${ASSUME_YES}" -eq 0 ]; do
    read -p "Continue? [y/n] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
done

while [ "${ASSUME_YES}" -eq 0 ] && [ -f "${DESTINATION}" ]; do
    read -p "Destination file exists. Continue? [y/n] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
done

decompress_save "${SOURCE}" "${DESTINATION}"
convert_encoding "${DESTINATION}"

if [ "${JQ_FORMAT}" -eq 1 ]; then
    reformat_file "${DESTINATION}"
fi

exit 0

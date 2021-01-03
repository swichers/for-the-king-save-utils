#!/usr/bin/env bash

set -euo pipefail

DESTINATION_FOLDER=
SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})

usage() {
    echo "Usage: saves-copy.sh -d path/to/backup/location -- path/to/game/saves"
    echo '-d: The path to save backups.'
}

check_args() {
    if [ -z "${SOURCE}" ]; then
        usage
        exit 1
    fi

    if [ ! -d "${SOURCE}" ]; then
        echo "'${SOURCE}' does not exist or is not accessible."
        exit 1
    fi

    if [ ! -d "${DESTINATION_FOLDER}" ]; then
        echo "'${DESTINATION_FOLDER}' does not exist or is not accessible."
        exit 1
    fi
}

copy_saves() {
    OIFS="$IFS"
    IFS=$'\n'
    for SAVE in `ls "${1}/"*.run`
    do
        "${SCRIPT_DIR}/save-copy.sh" -d "${2}" -- "${SAVE}"
    done
    IFS="$OIFS"
}

while getopts ':hd:' OPTION; do
    case "${OPTION}" in
        d) DESTINATION_FOLDER="${OPTARG}" ;;
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

echo "Copying all saves found in '${SOURCE}'"
echo

copy_saves "${SOURCE}" "${DESTINATION_FOLDER}"

exit 0

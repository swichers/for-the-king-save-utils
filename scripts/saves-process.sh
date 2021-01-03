#!/usr/bin/env bash

set -euo pipefail


DESTINATION_FOLDER=
ASSUME_YES=0
SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})


usage() {
    echo "Usage: saves-process.sh -d path/to/backup/location -- path/to/game/saves"
    echo '-d: The path to save processed saves.'
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

make_subfolders() {
    for SUBFOLDER in backups unpack repack
    do
        if [[ ! -e  "${1}/${SUBFOLDER}" ]]; then
            echo "Creating ${1}/${SUBFOLDER}"
            mkdir "${1}/${SUBFOLDER}"
        fi
    done
}

unpack_saves() {
    OIFS="$IFS"
    IFS=$'\n'
    for SAVE in `ls "${1}/backups/"*.run`
    do
        "${SCRIPT_DIR}/save-unpack.sh" -y -d "${1}/unpack" -- "${SAVE}"
    done
    IFS="$OIFS"
}

while getopts ':hyd:' OPTION; do
    case "${OPTION}" in
        d) DESTINATION_FOLDER="${OPTARG}" ;;
        y) ASSUME_YES=1 ;;
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
DESTINATION_FOLDER="`readlink -f "${DESTINATION_FOLDER}"`"

echo "Processing saves."
echo "Will copy new saves and unpack all saves into formatted JSON."
echo
echo "Backed up and processed files will be stored in '${DESTINATION_FOLDER}'"
echo

while [ "${ASSUME_YES}" -eq 0 ]; do
    read -p "Continue? [y/n] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
done

make_subfolders "${DESTINATION_FOLDER}"

echo

"${SCRIPT_DIR}/saves-copy.sh" -d "${DESTINATION_FOLDER}/backups" -- "${SOURCE}" 

echo

unpack_saves "${DESTINATION_FOLDER}"

echo
echo "Done"
echo

exit 0

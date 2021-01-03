#!/usr/bin/env bash

set -euo pipefail

DESTINATION_FOLDER=

usage() {
    echo "Usage: save-copy.sh -d path/to/backup/location -- path/to/game/save.run"
    echo '-d: The path to save backups.'
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
}

copy_save() {
    local filemtime
    local formatted_date
    local fnbase
    local fnmtime
    filemtime=`stat -c %Y "${1}"`
    formatted_date=`date --iso-8601=minutes --date="@${filemtime}"`
    fnbase=`basename -s '.run' "${1}"`
    fnmtime="${fnbase}.${formatted_date}"

    # Make a backup if necessary
    if [[ ! -e "${2}/${fnmtime}.run" ]]; then
        echo "Copying ${1} to ${2}/${fnmtime}.run"
        cp "${1}" "${2}/${fnmtime}.run"
    else
        echo "Already copied: ${1}"
    fi
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
DESTINATION_FOLDER="`readlink -f "${DESTINATION_FOLDER}"`"

copy_save "${SOURCE}" "${DESTINATION_FOLDER}"

exit 0

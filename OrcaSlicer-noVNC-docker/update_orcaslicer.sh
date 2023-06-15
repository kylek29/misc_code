#!/bin/bash

# Utility script to update an OrcaSlicer install in-place without rebuilding the Docker
# USAGE: Place the script somewhere (e.g. your prints folder)
#   Add Permissions: chmod +x update_orcaslicer.sh
#   Run Script: chmod +x ./update_orcaslicer.sh


# Helper variables / setup
set -e

echo "--------"
echo "Running the Update OrcaSlicer script"
echo "--------"

# Function: update_orcaslicer()

update_orcaslicer() {
    { # try
    cd /orcaslicer \
    && latestOrcaslicer=$(/orcaslicer/get_release_info.sh url) \
    && echo "-- Latest OrcaSlicer found: ${latestOrcaslicer}" \
    && orcaslicerReleaseName=$(/orcaslicer/get_release_info.sh name) \
    && echo "-- Getting OrcaSlicer: ${orcaslicerReleaseName}" \
    && curl -sSL ${latestOrcaslicer} > ${orcaslicerReleaseName} \
    && echo "-- Download successful, performing some cleanup." \
    && rm -f /orcaslicer/releaseInfo.json \
    && echo "-- Unpacking the download to /orcaslicer/orcaslicer-dist folder." \
    && unzip ${orcaslicerReleaseName} -d /orcaslicer/orcaslicer-dist \
    && echo "-- Setting folder and file permissions." \
    && chmod 775 /orcaslicer/orcaslicer-dist/OrcaSlicer_ubu64.AppImage \
    && echo "-- Moving last install to /orcaslicer/squashfs-root.last folder." \
    && mv -f /orcaslicer/squashfs-root /orcaslicer/squashfs-root.last \
    && echo "-- Running AppImage Extract." \
    && /orcaslicer/orcaslicer-dist/OrcaSlicer_ubu64.AppImage --appimage-extract \
    && echo "-- Final Cleanup." \
    && rm -f /orcaslicer/${orcaslicerReleaseName} \
    && echo "-- Completed ..."\
    && echo "-- NOTICE: old version moved to /orcaslicer/squashfs-root.last folder."\
    && echo "--    To Cleanup old install, rerun this script with -c flag."

    } || { # catch
        echo "ERROR: Something went wrong!"
    }
}

cleanup_old_install() {
    rm -rf /orcaslicer/squashfs-root.last\
    && echo "-- Cleanup completed, old verson removed."
}

check_old_install() {
    local v=$(strings /orcaslicer/squashfs-root/bin/orca-slicer | grep -i '^orcaslicer [0-9].\?[0-9]*')
    echo "   --- Currently installed version: ${v}"
}

# Argument Group for Determining Function to Use

option="${1}" 
case ${option} in 
   -c)  echo "Running the CLEANUP function .."
        cleanup_old_install
        ;; 
   -i)  echo "Running the INSTALL function .."
        update_orcaslicer
        ;; 
   -v)  echo "Checking the installed VERSION .."
        check_old_install
        ;; 
   *)  
        echo "`basename ${0}` "
        echo "  :usage:  "
        echo "    -> Install: -i"
        echo "    -> Clean Up: -c"
        echo "    -> Check Installed Version: -v"
        echo "    -> Help: -?"
        exit 1 # Command to come out of the program with status 1
        ;; 
esac 

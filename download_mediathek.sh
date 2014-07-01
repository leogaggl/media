#!/bin/bash

# ------------------------------------------------------------------
# [Author] Leo Gaggl
#          http://www.gaggl.com
#
#          This script downloads a media file from 
#          ARD Mediathek.
#          http://github.com/leogaggl/download_media/
#
# Dependency:
#     http://stedolan.github.io/jq/
#     UBUNTU: sudo apt-get install jq
# ------------------------------------------------------------------
          
##########################################
## Functions
##########################################

die () {
    echo >&2 "$@"
    exit 1
}

##########################################
## Local Variables
##########################################
[ "$#" > 0 ] || die "1 argument required, $# provided"
MEDIAID=${BASH_ARGV[0]}

## Default Variables
MEDIATHEK_URL="http://www.ardmediathek.de/play/media/"
MEDIATHEK_POSTFIX="?devicetype=pc"
QUALITY=3	       ## override with -q
FILENAME=''     ## override with -f
## 0 ... Low Quality
## 3 ... High Quality

##########################################
# Processing Options
##########################################

while getopts ":q:f:h" opt; do
  case $opt in
    q)	## Download quality setting
      QUALITY=$OPTARG
      ;;
    f)  ## Filename to save
      FILENAME=$OPTARG
      ;;
    h)	## Help
      echo "Usage: ./download_mediathek.sh -f filename.mp4 -q 0-3 MEDIA_ID"
	  exit 1
      ;;	  	  
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

##########################################
## Get download URL from ID
##########################################

JSON_URL="${MEDIATHEK_URL}${MEDIAID}${MEDIATHEK_POSTFIX}"
#echo 'JSON: '${JSON_URL}
DOWNLOADURL=$(curl --silent $JSON_URL | jq -r '._mediaArray[1]._mediaStreamArray['$QUALITY']._stream')
#echo 'Downloading: ' ${DOWNLOADURL}

##########################################
## Download
##########################################

if [ -n "$FILENAME" ]; then
  wget -O ${FILENAME} ${DOWNLOADURL}
else
  wget ${DOWNLOADURL}
fi	

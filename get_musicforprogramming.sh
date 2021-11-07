#!/bin/sh
# Auteur :      thuban <thuban@yeuxdelibad.net>
# licence :     MIT

# Description :
# Depends 

URL="http://musicforprogramming.net/rss.php"

DL="ftp -o-"
#DL="wget -qO-"

DLCMD="ftp"
#DLCMD="wget"

DLLIST=$($DL $URL |grep "guid" | grep -o "http://.*\.mp3")

for z in $DLLIST; do
    echo -e "$DLCMD "$z"\n"
done

exit 0

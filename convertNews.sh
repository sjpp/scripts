#!/bin/bash
# |-------------------------------------------------------------
# | Nom         : convertNews.sh
# | Description : Custom script to convert blag articles in news
# | Auteur      : sjpp
# | Mise à jour : 14/07/2017
# | Licence     : GNU GLPv2 ou ultérieure
# |-------------------------------------------------------------

orig=$(basename "$1")

echo "$orig" | tr " " "_" | tr -d "," | xargs vim

clean="$(echo "$orig" | tr " " "_" | tr -d ",")"
dest="$clean".md

pandoc -f html -t markdown+hard_line_breaks -s -o "$dest" "$clean"

cat "$dest" | xsel -i -b

#!/bin/bash
# |-------------------------------------------------------------
# | Nom         : tag_compilations.sh
# | Description : Ce script sert à intervertir les tags ARTIST
# | 			: et COMPOSER des chansons appartenant à
# |				: une compilation
# | Auteur      : sjpp
# | Mise à jour : 14/07/2017
# | Licence     : GNU GLPv2 ou ultérieure
# |-------------------------------------------------------------

for file in *
do artist=$(tagreader $1 | grep -e "^ARTIST" | awk '{print $3}' | sed 's/\"//g')
    tagwriter -R COMPOSER $artist -T $1 ; tagwriter -a "Various Artists" -T $1
done

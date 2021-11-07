#!/bin/bash
# |-------------------------------------------------------------
# | Nom         : xc.sh
# | Description : Copy file content from terminal under Wayland
# | Auteur      : sjpp
# | Mise à jour : 2021/11/05
# | Licence     : GNU GLPv2 ou ultérieure
# |-------------------------------------------------------------

cat "$1" | wl-copy

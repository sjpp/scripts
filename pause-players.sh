#!/bin/bash
# |-------------------------------------------------------------
# | Nom         : pause-players.sh
# | Description : Simple script to pause whatever player is used
# |             : (used in dwm)
# | Auteur      : sjpp
# | Mise à jour : 14/07/2017
# | Licence     : GNU GLPv2 ou ultérieure
# |-------------------------------------------------------------

[ $(pgrep ncmpcpp) ] && mpc toggle
[ $(pgrep deadbeef) ] && deadbeef --toggle-pause

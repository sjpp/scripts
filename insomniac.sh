#!/bin/bash
# |-------------------------------------------------------------
# | Nom         : insomniac.sh
# | Description : Activer/désactiver à la volée le verrouillage
# |             : et l'extinction de l'écran
# | Auteur      : sjpp
# | Mise à jour : 14/07/2017
# | Licence     : GNU GLPv2 ou ultérieure
# |-------------------------------------------------------------

# |-----------------------------------------------------------
# | Définition des variables :
# |-----------------------------------------------------------

_SETTINGS=("org.gnome.desktop.screensaver lock-enabled" \
	"org.gnome.desktop.session idle-delay")

# |-----------------------------------------------------------
# | Fonctions :
# |-----------------------------------------------------------

CheckState () {
    _STATES=($(gsettings get ${_SETTINGS[0]}) \
	    $(gsettings get ${_SETTINGS[1]}))
}

# |------------------------------------------------------------
# | Exécution du script :
# |------------------------------------------------------------

CheckState

for _STATE in ${_STATES[*]}
do
# Pour débogguer :
# echo "$_STATE" | tr "\n" " "
case "$_STATE" in
    "false" ) gsettings set ${_SETTINGS[0]} true
              _NEWSTATE="actifs" ;;
    "true"  ) gsettings set ${_SETTINGS[0]} false
              _NEWSTATE="inactifs" ;;
    "600"   ) gsettings set ${_SETTINGS[1]} "uint32 0" ;;
    "0"     ) gsettings set ${_SETTINGS[1]} "uint32 600" ;;
esac
done

if [ $? -eq 0 ]
then
    notify-send --hint=int:transient:1 -t 2 "Insomniac mode !" \
	    "Verrouillage et extinction auto $_NEWSTATE"
fi

exit 0

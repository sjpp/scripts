#!/bin/bash
# |-------------------------------------------------------------
# | Nom         : coffee
# | Description : Activer/désactiver à la volée le verrouillage
# |             : d'écran
# | Auteur      : sjpp
# | Mise à jour : 07/07/2017
# | Licence     : GNU GLPv2 ou ultérieure
# |-------------------------------------------------------------

# |-----------------------------------------------------------
# | Définition des variables :

_SETTINGS0="org.gnome.desktop.screensaver lock-enabled"
_SETTINGS1="org.gnome.desktop.session idle-delay"

# |-----------------------------------------------------------
# | Fonctions :
# |-----------------------------------------------------------

CheckState () {
    _STATE=$(gsettings get $_SETTINGS0)
}

# |------------------------------------------------------------
# | Exécution du script :
# |------------------------------------------------------------

CheckState
echo "$_STATE"
case "$_STATE" in
    "false" ) gsettings set $_SETTINGS0 true
              gsettings set $_SETTINGS1 0
              _NEWSTATE="actif" ;;
    "true" ) gsettings set $_SETTINGS0 false
             gsettings set $_SETTINGS1 300
              _NEWSTATE="inactif" ;;
esac

if [ $? -eq 0 ]
then
    notify-send --hint=int:transient:1 -t 2 "Coffee !" "Verrouillage auto $_NEWSTATE"
fi

exit 0

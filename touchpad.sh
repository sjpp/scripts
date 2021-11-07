#!/bin/bash
# |-------------------------------------------------------------
# | Nom         : touchpad
# | Description : Activer/désactiver à la volée le touchpad
# | Auteur      : Sébastien Poher 
# | Mise à jour : 07/04/2017
# | Licence     : GNU GLPv2 ou ultérieure
# |-------------------------------------------------------------

# |-----------------------------------------------------------
# | Définition des variables :

_KEY="org.gnome.desktop.peripherals.touchpad send-events"

# |-----------------------------------------------------------
# | Fonctions :
# |-----------------------------------------------------------

CheckState () {
    _STATE=$(gsettings get $_KEY)
}

# |------------------------------------------------------------
# | Exécution du script :
# |------------------------------------------------------------

CheckState
case "$_STATE" in
    "'enabled'" ) gsettings set $_KEY 'disabled'
                  _NEWSTATE="désactivé"  ;;
    "'disabled'" ) gsettings set $_KEY 'enabled'
                  _NEWSTATE="activé"  ;;
esac

if [ $? -eq 0 ]
then
    notify-send --hint=int:transient:1 -t 2 "Touchpad" "Touchpad $_NEWSTATE"
fi

exit 0

#!/bin/bash
# |-------------------------------------------------------------
# | Nom         : wops (Workspace on Primary Switcher
# | Description : Activer/désactiver à la volée les espaces
# |             : de travail sur tous les écrans ou seulement
# |             : l'écran principal
# | Auteur      : Sébastien Poher 
# | Mise à jour : 30/03/2022
# | Licence     : GNU GLPv2 ou ultérieure
# |-------------------------------------------------------------

# |-----------------------------------------------------------
# | Définition des variables :

_SETTINGS="org.gnome.mutter workspaces-only-on-primary"

# |-----------------------------------------------------------
# | Fonctions :
# |-----------------------------------------------------------

CheckState () {
    _STATE=$(gsettings get org.gnome.mutter workspaces-only-on-primary)
}

# |------------------------------------------------------------
# | Exécution du script :
# |------------------------------------------------------------

CheckState
echo "$_STATE"
case "$_STATE" in
    "false" ) gsettings set $_SETTINGS true
              _NEWSTATE="fixe" ;;
    "true" ) gsettings set $_SETTINGS false
              _NEWSTATE="mobile" ;;
esac

if [ $? -eq 0 ]
then
    notify-send --hint=int:transient:1 -t 2 "WOPS" "Espace secondaire $_NEWSTATE"
fi

exit 0

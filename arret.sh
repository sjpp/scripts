#!/bin/bash
# |-------------------------------------------------------------
# | Nom         : arret.sh
# | Description : dwm power management
# | Auteur      : sjpp
# | Mise à jour : 14/07/2017
# | Licence     : GNU GLPv2 ou ultérieure
# |-------------------------------------------------------------

prompt=" "
bg_color="#282a36"
selfont_color="#000000"
selbg_color="#AB0B55"

commande=$(echo -e "veille\nhibernation\narrêt\nredémarrer" \
    | dmenu -p "$prompt" \
    -sb "$selbg_color" \
    -sf "$selfont_color" \
    -nb "$bg_color")

case $commande in
    veille)
        exec slock &
        systemctl suspend
        ;;
    hibernation)
        exec slock &
        systemctl hibernate
        ;;
    arrêt)
        exec slock &
        systemctl poweroff
        ;;
    redémarrer)
        exec slock &
        reboot
        ;;
esac

exit 0

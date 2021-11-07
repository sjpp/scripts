#!/bin/bash
# |-------------------------------------------------------------
# | Nom         : gestuser.sh
# | Description : getopts template and example
# | Auteur      : sjpp
# | Mise à jour : 14/07/2017
# | Licence     : GNU GLPv2 ou ultérieure
# |-------------------------------------------------------------

# Page 272

# L'ajout de : permet la gestion des erreurs"
while getopts ":cxu:g:" option
do
    echo "getopts a trouvé l'option $option"
    case "$option" in
        c) echo "Archivage"
            echo "Indice de la prochaine option a traiter : $OPTIND"
            ;;
        x) echo "Extraction"
            echo "Indice de la prochaine option a traiter : $OPTIND"
            ;;
        u) echo "Liste des utilisateurs à traiter: $OPTARG"
            echo "Indice de la prochaine option a traiter : $OPTIND"
            ;;
        g) echo "Liste des groupes à traiter: $OPTARG"
            echo "Indice de la prochaine option a traiter : $OPTIND"
            ;;
        :) echo "l'option $OPTARG requiert un argument. Bye"
            exit 1
            ;;
        \?) echo "OPTION INVALIDE - Bye"
            exit 1
            ;;
    esac
done
echo "Analyse des options terminées"
shift $((OPTIND-1))
echo "Liste des arguments: $*"

exit 0


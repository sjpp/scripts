#!/bin/bash
# |----------------------------------------------------------------------------
# | Nom         : sqlBackupCron
# | Description : Script de planification, exécution et suppression
# |             : des backups SQL via mariabackup (full et incremental)
# | Dépendances : mariabackup, mariadb
# | Auteur      : Sébastien Poher 
# | Mise à jour : 09/08/2019
# | Version     : 0.1
# | Licence     : GNU GLPv3 ou ultérieure
# |----------------------------------------------------------------------------

# |----------------------------------------------------------------------------
# | Usage : à utiliser de préférence en cron:
# | - /etc/cron.daily/sqlbackups-daily     : /usr/local/bin/sqlBackupCron.sh daily
# | - /etc/cron.weekly/sqlbackups-weekly   : /usr/local/bin/sqlBackupCron.sh weekly
# | - /etc/cron.monthly/sqlbackups-monthly : /usr/local/bin/sqlBackupCron.sh monthly
# |----------------------------------------------------------------------------

# |----------------------------------------------------------------------------
# | Définition des variables :
# |----------------------------------------------------------------------------

_FULLBACKUPCMD="/usr/bin/mariabackup"
_INCBACKUPCMD="/usr/bin/mariabackup"
_BACKBASEDIR="/home/probesys/sqlbackup"
_BACKLSNDIRFULL="$_BACKBASEDIR/fullz"
_BACKLSNDIRINC="$_BACKBASEDIR/incrz"
_BACKMONTHLYDIR="$_BACKBASEDIR/full/monthly"
_BACKWEEKLYDIR="$_BACKBASEDIR/full/weekly"
_BACKDAILYDIR="$_BACKBASEDIR/incremental/daily"
_NBMONTHLY=2
_NBWEEKLY=4
_NBDAILY=6

# |----------------------------------------------------------------------------
# | Fonctions :
# |----------------------------------------------------------------------------

annonce () {
    if [[ $# -ne 2 ]]
    then
        echo -e "\t\033[1;31mCette fonction prend 2 paramètres: <couleur> <message>\033[0;00m"
        exit 1
    fi

    case $1 in
        red     ) echo -e "\n\033[1;31m$2\033[0;00m\n" ;;
        green   ) echo -e "\n\033[1;32m$2\033[0;00m\n" ;;
        yellow  ) echo -e "\n\033[1;33m$2\033[0;00m\n" ;;
        magenta ) echo -e "\n\033[1;35m$2\033[0;00m\n" ;;
        cyan    ) echo -e "\n\033[1;36m$2\033[0;00m\n" ;;
        gras    ) echo -e "\033[1;37m$2\033[0;00m" ;;
        norm    ) echo -e "\033[37m$2\033[0;00m" ;;
        *       ) echo -e "\n\t\033[1;31m/!\ : Couleur non prise en charge\033[0;00m\n" ;;
    esac
}

printUsage () {
    echo -e "Usage: $0 [interval]
    interval can be: monthly, weekly or daily"
}

checkDeps () {
    # Make sure mariabackup is present on system
    if ! command -v "$_BACKUPBINARY" >/dev/null 2>&1 ; then
        annonce red "Error: $_BACKUPBINARY not installed or not found"
        exit 2
    fi
}

mkDirs () {
    # make sure main backup dirs are present
    for dir in "$_BACKDAILYDIR" "$_BACKWEEKLYDIR" "$_BACKMONTHLYDIR" "$_BACKLSNDIRFULL" "$_BACKLSNDIRINC"
    do
        if [ ! -d "$dir" ]
        then
            mkdir -p "$dir"
        fi
    done
}

isEmpty () {
    if [ $# -ne 1 ] ; then
        annonce red "${FUNCNAME[0]} : Missing argument"
        exit 2
    fi
    # Check if directory passed as argument is empty (rc = 0 ) or not (rc =1 )
    if [ -d "$1" ] && [ -z "$(ls -1 "$1")" ] ; then
        echo 0
    else
        echo 1
    fi
}

makeBackup () {
    # $1 is $_intervalDIR ; $2 is $_NBinterval ; $3 is backup type (full or inc)
    # those 3 args are compulsory
    if [ $# -ne 3 ] ; then
        annonce red "${FUNCNAME[0]} : Missing argument"
        exit 2
    fi
    # if dirs does not exist, create as much as defined in $_NBinterval
    for i in $(seq 1 "$2") ; do
        if [ ! -d "$1"/"$i" ] ; then
            mkdir -p "$1"/"$i"
        fi
    done
    # rotate existing dirs
    rm -rf "${1:?}"/"${2:?}"
    # then move each other one to n+1
    for i in $(seq $(( $2 - 1 )) -1 1) ; do
        mv "$1"/"$i" "$1"/$(( i + 1 ))
    done
    # recreate the first one...
    mkdir -p "$1"/1
    # ...and finally backup in it
    case "$3" in
        "FULL" ) ulimit -n 100000
                 "$_FULLBACKUPCMD" --backup --user=root --extra-lsndir="$_BACKLSNDIRFULL" --stream=xbstream | gzip > "$1"/1/backup.stream.gz ;;
        "INC"  ) ulimit -n 100000
                 "$_INCBACKUPCMD" --backup --user=root --extra-lsndir="$_BACKLSNDIRINC" --incremental-basedir="$_BACKLSNDIRFULL" --stream=xbstream | gzip > "$1"/1/backup.stream.gz ;;
        *      ) annonce red "${FUNCNAME[0]} : Invalid argument" ;;
    esac
}


# |----------------------------------------------------------------------------
# | Exécution du script :
# |----------------------------------------------------------------------------

if [ $# -ne 1 ] ; then
    annonce red "${FUNCNAME[0]} : Missing argument"
    printUsage
    exit 2
else
    case "$1" in
        "monthly" ) mkDirs ; makeBackup $_BACKMONTHLYDIR $_NBMONTHLY FULL ;;
        "weekly"  ) mkDirs ; makeBackup $_BACKWEEKLYDIR $_NBWEEKLY FULL ;;
        "daily"   ) mkDirs ; makeBackup $_BACKDAILYDIR $_NBDAILY INC ;;
    esac
fi

exit $?

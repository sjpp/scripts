#!/bin/bash
# |----------------------------------------------------------------------------
# | Name         :
# | Description  : Easily deploy a Nextcloud stack with Podman
# |              :
# | Dependencies : podman, btrfs
# | Author       : Sébastien Poher 
# | Updated      : 2020-08-27
# | Licence      : GNU GLPv3 ou ultérieure
# |----------------------------------------------------------------------------

# |----------------------------------------------------------------------------
# | Usage :
# |
# |
# |
# |----------------------------------------------------------------------------

# |----------------------------------------------------------------------------
# | Variables :
# |----------------------------------------------------------------------------

set -e
PATH=:PATH:/sbin:/usr/bin:/usr/sbin
PODS_HOMEDIR="/home/sjpp/podman/script"
FREE_DISK_SPACE=$(df -h --output=avail /home | sed -n '2{p;q}' | tr -d "[:alpha:]")
FREE_MEM=$(($(grep MemAvailable /proc/meminfo | awk '{ print $2 }') / 1024))

# |----------------------------------------------------------------------------
# | Functions :
# |----------------------------------------------------------------------------

Echo () {
    if [[ $# -ne 2 ]]
    then
        echo -e "\t\033[1;31mThis function takes 2 parameters: <color> <message>\033[0;00m"
        exit 1
    fi

    case $1 in
        red     ) echo -e "\n\033[1;31m""$2""\033[0;00m\n" ;;
        green   ) echo -e "\n\033[1;32m""$2""\033[0;00m\n" ;;
        yellow  ) echo -e "\n\033[1;33m""$2""\033[0;00m\n" ;;
        magenta ) echo -e "\n\033[1;35m""$2""\033[0;00m\n" ;;
        cyan    ) echo -e "\n\033[1;36m""$2""\033[0;00m\n" ;;
        bold    ) echo -e "\033[1;37m""$2""\033[0;00m" ;;
        norm    ) echo -e "\033[37m""$2""\033[0;00m" ;;
        *       ) echo -e "\n\t\033[1;31m/!\ : Color not supported\033[0;00m\n" ;;
    esac
}

# |----------------------------------------------------------------------------
# | Run script :
# |----------------------------------------------------------------------------

# Get Nextcloud instance full name
while read -r -p "Nextcloud instance FQDN: " TRY_INSTANCE
do
    if ! echo "$TRY_INSTANCE" | grep -q -P '(?=^.{4,253}$)(^(?:[a-zA-Z0-9](?:(?:[a-zA-Z0-9\-]){0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$)' ; then
        Echo red "$TRY_INSTANCE is not a valid FQDN." >&2
        continue
    elif [[ -d "$PODS_HOMEDIR"/"$TRY_INSTANCE" ]] ; then
        Echo red "Instance directory seems to exist." >&2
        exit 1
    else
        INSTANCE="$TRY_INSTANCE"
        break
    fi
done

# Check disk quota (is number ? enough free space ?)
while read -r -p "Disk quota (in GB): " TRY_DISK_QUOTA
do
    re='^[0-9]+$'
    if ! [[ "$TRY_DISK_QUOTA" =~ $re ]] ; then
        Echo red "Quota must be an integer." >&2
        continue
    elif [[ "$TRY_DISK_QUOTA" -gt "$FREE_DISK_SPACE" ]] ; then
        Echo red "Can't allocate quota, not enough disk space." >&2
        continue
    else
        DISK_QUOTA="$TRY_DISK_QUOTA"
        break
    fi
done

# Check memory quota
while read -r -p "Memory quota (in MB): " TRY_MEM_QUOTA
do
    re='^[0-9]+$'
    if ! [[ "$TRY_MEM_QUOTA" =~ $re ]] ; then
        Echo red "Quota must be an integer." >&2
        continue
    elif [[ "$TRY_MEM_QUOTA" -gt "$FREE_MEM" ]] ; then
        Echo red "Can't allocate quota. Quota is higher than system memory." >&2
        continue
    else
        MEM_QUOTA="$TRY_MEM_QUOTA"
        break
    fi
done

# Check if local pod port is in use
while read -r -p "Local web port for pod: " TRY_PORT
do
    if [[ $(ss -4 -n -H -o state listening "( sport = $TRY_PORT )" | awk '{ print $4 }' | cut -d":" -f2) -eq "$TRY_PORT" ]] ; then
        Echo red "Port is already in use." >&2
        continue
    else
        PORT="$TRY_PORT"
        break
    fi
done

# Get instance configuration info
read -r -p "Provide database admin password: " DB_ROOT_PWD
read -r -p "Provide database user password: " DB_USER_PWD
read -r -p "Provide Nextcloud admin password: " NC_ADMIN_PWD

# Confirm provided parameters
Echo bold "\nInstallation summary:"
echo -e "Instance name (FQDN): \033[1;32m""$INSTANCE""\033[0;00m"
echo -e "Disk quota: \033[1;32m""$DISK_QUOTA""\033[0;00m"
echo -e "Memory quota: \033[1;32m""$MEM_QUOTA""\033[0;00m"
echo -e "Instance port: \033[1;32m""$PORT""\033[0;00m"
echo -e "Database admin password: \033[1;32m""$DB_ROOT_PWD""\033[0;00m"
echo -e "Database user password: \033[1;32m""$DB_USER_PWD""\033[0;00m"
echo -e "Nextcloud admin password: \033[1;32m""$NC_ADMIN_PWD""\033[0;00m"

while read -p "Confirm the above parameters and proceed (y|n)? " CONFIRM
do
    case "$CONFIRM" in
        o|O|y|Y ) Echo green "$INSTANCE $DISK_QUOTA $MEM_QUOTA $PORT $NC_ADMIN_PWD $DB_USER_PWD $DB_ROOT_PWD" ; break ;;
        n|N     ) Echo yellow "Installation aborted, exiting." ; exit 1 ;;
        *       ) Echo red "Invalid answer (y|n)" ;;
    esac
done


# Create subvolume and set its quota
#sudo btrfs subvolume create "$PODS_HOMEDIR"/"$INSTANCE"
#sudo btrfs quota enable "$PODS_HOMEDIR"/"$INSTANCE"
#sudo btrfs qgroup limit "$DISK_QUOTA"G "$PODS_HOMEDIR"/"$INSTANCE"
mkdir -p "$PODS_HOMEDIR"/"$INSTANCE"/{db_data,nc_data}
#
# Create the instance pod
podman pod create --name "$INSTANCE" -p "$PORT":80

# Add containers to the pod
podman run --security-opt label=disable -d --restart=always \
    --pod="$INSTANCE" \
    -e MYSQL_ROOT_PASSWORD="$DB_ROOT_PWD" \
    -e MYSQL_DATABASE="nc" \
    -e MYSQL_USER="nc_user" \
    -e MYSQL_PASSWORD="$DB_USER_PWD" \
    -v "$PODS_HOMEDIR"/"$INSTANCE"/db_data:/var/lib/mysql:z \
    --name="$INSTANCE"-db mariadb

podman run --security-opt label=disable -d --restart=always \
    --pod="$INSTANCE" \
    -e NEXTCLOUD_TRUSTED_DOMAINS="$INSTANCE" \
    -e NEXTCLOUD_ADMIN_USER="admin" \
    -e NEXTCLOUD_ADMIN_PASSWORD="$NC_ADMIN_PWD" \
    -e MYSQL_DATABASE="nc" \
    -e MYSQL_USER="nc_user" \
    -e MYSQL_PASSWORD="$DB_USER_PWD" \
    -e MYSQL_HOST="127.0.0.1" \
    -v "$PODS_HOMEDIR"/"$INSTANCE"/nc_data:/var/www/html:z \
    --name="$INSTANCE"-app \
    --memory="$MEM_QUOTA"m nextcloud


#!/bin/bash
# |-------------------------------------------------------------
# | Nom         : mkdocs-podman.sh
# | Description : launch conterized mkdocs material
# | Auteur      : sjpp
# | Mise à jour : 2021/11/07
# | Licence     : GNU GLPv2 ou ultérieure
# |-------------------------------------------------------------

PODMAN=$(which podman)
  
sub_help(){
    echo -e "Usage: mkdocs <subcommand>\n
Subcommands:
 build \t\t\tBuild site
 gh-deploy \t\tDeploy to Github Pages"
}
  
sub_dev_server(){
    $PODMAN run --rm -it -p 127.0.0.1:8000:8000 -v ${PWD}:/docs:Z \
		squidfunk/mkdocs-material:latest
}

sub_build(){
    $PODMAN run --rm -it -v ${PWD}:/docs:Z \
		squidfunk/mkdocs-material:latest build
}
  
sub_gh-deploy(){
	run --rm -it -v ~/.ssh:/root/.ssh:Z -v ${PWD}:/docs:Z \
		squidfunk/mkdocs-material:latest gh-deploy
}
  
SUBCOMMAND=$1
case $SUBCOMMAND in
	"" )
		sub_dev_server
		;;
	"help" | "-h" | "--help" )
        sub_help
        ;;
    "build" | "gh-deploy" )
        sub_${SUBCOMMAND}
		;;
	* )
	echo -e "Error: '$SUBCOMMAND' is not a known subcommand.\n
	Run 'mkdocs help' for a list of known subcommands." >&2
	exit 1
        ;;
esac

exit "$?"

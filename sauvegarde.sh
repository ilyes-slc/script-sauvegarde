#!/bin/bash


#	ERRORS
SUCCESS=100
E_ARCHIVE_NOT_FOUND=101		#FILE ARCHIVE.TAR.GZ NOT FOUND 
E_ARCHIVES_FOUND=102		#MANY FILES.TAR.GZ FOUND
E_BAD_ARGUMENTS=103			#BAD NUMBER OF ARGUMENTS

#	COLORS
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


#fonction qui prend en parametre le valeur de retour d'un fonction (qui la precede) et affiche un message
gestion_erreur(){
	case $1 in
		$SUCCESS )
	echo
	echo -e "${BLUE}[*] opertaion terminated ..${NC}"
	echo
		;;
		$E_BAD_ARGUMENTS)
	echo
	echo -e "${RED}[!] failed : bad number of arguments ..${NC}"
	echo	
		;;
		$E_ARCHIVES_FOUND)
	echo
	echo -e "${RED}[!] failed : multiple archives found ..${NC}"
	echo	
		;;
		$E_ARCHIVE_NOT_FOUND)
	echo
	echo -e "${RED}[!] failed : no archive found ..${NC}"
	echo	
		;;

	esac
}



#fonction usage
show_usage(){
echo usage :
echo "sauvegarde.sh: [-h] [-g] [-m] [-v] [-n] [-r] [-a] [-s] chemin.."
}
export -f show_usage
#appel de fonction pour la tester





#fonction HELP permet d'afficher le help a partir d'un fichier texte
HELP(){
	help=$(cat README.md)
	if [[ $# -eq 1 ]]; then
		echo $help
	else
		yad --center --width=750 --height=250 --image="gtk-dialog-info" --title="HELP" --text="$(cat README.md)"
	fi
}
#appel de fonction pour la tester
#
export -f HELP
#HELP 1





#fonction qui permet d’afficher le nombre de fichier et la taille totale occupée des fichiers modifiés dans les dernières 24heures.
nbr_taille(){
	find -mtime -1 >> tmp
	taille=0
	nbr=0
	#tmp : fichier temporaire contenant touts les fichiers et dossiers modifiés last 24 hours
	#tmp a sûpprimer a la fin du bloc
	while IFS= read -r line
	do
	 #echo "$line"
	 if [[ $(ls -la $line  | cut -d "r" -f 1) = "-" ]]; then
	 	if [[ $line != "./tmp" ]]; then
	 		#statements
	 		#statements
	 		size=$(ls -la $line  | cut -d " " -f 5)
	 		taille=$((taille + size))
	 		nbr=$((nbr + 1))
	 		fi	 	
	 fi

	done < tmp
	rm tmp
	if [[ $# -eq 1 ]]; then
		
		echo la  taille toccupé par les fichiers modifiés dans les dernières 24heures est $taille byte
		echo nombre = $nbr
	else
		yad --height=150 --width=500 --center --text="<span foreground='yellow'><b><big>fichiers modifiés dans les 24 dernières <big>heures</big></big></b></span>" \
--form --field=nombre:RO "$nbr" --field=taille:RO "$taille"
	fi
	return $SUCCESS

}
export -f nbr_taille
#nbr_taille 1 


#		fonction qui permet d’archiver dans une « archive tar » (fichier *.tar.gz) tous les
#		+fichiers de votre répertoire personnel (/home/votre-nom) qui ont été modifiés dans les
#		+dernières 24 heures
archiver(){
	echo cette opertaion peut prendre quelques instants

	tar czvf archive.tar.gz --newer-mtime '1 days ago' /home/* &> /dev/null

	echo terminated ...	
	echo fichiers de votre répertoire personnel qui ont été modifiés dans les dernières 24 heures sont archvées dans archive.tar.gz
	return $SUCCESS
}
export -f  archiver
#fonction qui permet de renommer l’archive avec la date et l’heure de la modification.
renommer_archive(){
	if [[ -f archive.tar.gz ]]; then
		#statements
		name=$(date -r archive.tar.gz '+%F')
		mv archive.tar.gz $name.tar.gz
		return $SUCCESS
	else
		return $E_ARCHIVE_NOT_FOUND
	fi
}
export -f renommer_archive
#fonction permet de sauvegarder les informartions sur les fichiers archivés dans un fichier passé en argument
sauvegarder_infos(){
	if [[ $# -ge 2 ]]; then
		return $E_BAD_ARGUMENTS
	else
		if [[ $# -eq 1 ]]; then
			name_file=$1
			else
			name_file=`yad --center --entry --entry-label="nom de fichier ?"`
		fi
		if [[ $(find *.tar.gz | wc -l) -eq 0 ]]; then
			#statements
			return $E_ARCHIVE_NOT_FOUND
		elif [[ $(find *.tar.gz | wc -l) -ge 2 ]]; then
			#statements
			return $E_ARCHIVES_FOUND
		else
			tar -tvf *.tar.gz > $name_file
			return $SUCCESS
		fi
	fi
}
export -f sauvegarder_infos

#fonction show usage en menu graphique
yad_show_usage(){
	(
	yad --center --width=750 --image="gtk-dialog-info" --title="usage" --text="usage: sauvegarde.sh: [-h] [-g] [-m] [-v] [-n] [-r] [-a] [-s] chemin.."
	)
}
export -f yad_show_usage


version(){
	if [[ $# -eq 1 ]]; then
		#statements
		echo -e "\e[1;92m Author: Ilyes Zaidi  \e[0m "
		echo -e "\e[1;92m version: 1.1 \e[0m "
	else
		yad --height=50 --width=500 --center --text="<span foreground='yellow'><b><big>author : Ilyes Zaidi  --------------  <big>version : 1.1</big></big></b></span>"
	fi
}
export -f version
#version arg

cmdmain=(
   yad
   --center --width=400
   --image="gtk-dialog-info"
   --title="YAD interface graphique"
   --text="Click a link to see a demo."
   --button="Exit":1
   #--button="Show usage":2
   --form
      --field="Show usage":btn "bash -c yad_show_usage "  
    #  input=`yad --entry  --entry-label="nom fichier"` 
      --field="24 heures":btn "bash -c nbr_taille"
      --field="archiver home(dernières 24 heures":btn "bash -c archiver "
      --field="renommer l'archive":btn "bash -c renommer_archive"
      --field="exporter les infos":btn "bash -c sauvegarder_infos"
      --field="author and version":btn "bash -c version"
      --field="HELP":btn "bash -c HELP"

)


interface_graphique(){
	while true; do
	    "${cmdmain[@]}"
	    exval=$?
	    case $exval in
	        1|252) break;;
	    esac
	done
}
#interface_graphique;

menu(){
	
echo -e " ███████ ██     ██ ██   ██    ██ ███████ ███████ "
echo -e " ██      ██     ██ ██    ██  ██  ██      ██      "
echo -e " ███████ ██     ██ ██     ████   █████   ███████ "
echo -e "      ██ ██     ██ ██      ██    ██           ██ "
echo -e " ███████ ██     ██ ███████ ██    ███████ ███████ "
echo -e "                                                 "
echo -e ""

	echo "1-	Pour afficher le help détaillé à partir d’un fichier texte"
	echo "2-	Interface graphque (YAD)"
	echo "3-	Afficher le nom des auteurs et version du code."
	echo "4-	afficher le nombre de fichier et la taille totale occupée des fichiers modifiés dans les dernières 24heures."
	echo "5-	archiver home(dernières 24 heures"
	echo "6-	renommer l’archive avec la date et l’heure de la modification."
	echo "7-	sauvegarder les informations sur les fichier archivés."
	echo "9-	QUIT"
}

#		tester la présence d’au moins un argument, sinon il affiche l’usage sur la
#++		sortie d’erreur et échoue.
if [[ $# -eq "0" ]]; then
	show_usage
	exit
fi

while getopts "nars:mgvh" option
do
echo "getopts a trouvé l'option $option"
case $option in
	h)
		clear
		HELP textuel
		#menu
	;;

	g)
		clear
		interface_graphique
	;;

	v)	
		clear
		version textuel
		#menu
	;;

	n)	
		clear
		nbr_taille textuel
		gestion_erreur $?
		#menu
	;;

	a)
		clear
		archiver
		gestion_erreur $?
		#menu
	;;

	s)
		clear
		sauvegarder_infos $OPTARG
		gestion_erreur $?

	;;

	r)
		clear
		renommer_archive
		gestion_erreur $?
		#menu
	;;



	m)
		clear
		menu

		while (true)
	do

		echo "Votre choix : "
	read choice
	case $choice in

			1)
	clear
	HELP textuel
	menu
			;;

			2)
	clear
	interface_graphique
	menu
			;;

			3)
	clear
	version textuel
	menu
			;;

            4)
	clear
	nbr_taille textuel
	gestion_erreur $?
	menu
			;;

			5)
	clear
	archiver
	gestion_erreur $?
	menu
			;;

			6)
	clear
	renommer_archive
	gestion_erreur $?	
	menu
			;;

			7)
	clear
	echo "donner le nom de fichier a dans lequel on va enregistrer les infos"
	read nom
	sauvegarder_infos $nom
	gestion_erreur $?	
	menu
			;;


			9)
	clear
	echo "Au revoir si $USER"
			exit
			;;


			*)
	clear
	echo "mauvais choix"		 			
	menu
			;;
	
	esac

	done
	;;

esac
done
echo "Analyse des options terminée"
exit 0
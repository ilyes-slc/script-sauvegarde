#!/bin/bash



SUCCESS=100
E_ARCHIVE_NOT_FOUND=101		#FILE ARCHIVE.TAR.GZ NOT FOUND 
E_ARCHIVES_FOUND=102		#MANY FILES.TAR.GZ FOUND
E_BAD_ARGUMENTS=103			#BAD NUMBER OF ARGUMENTS




#fonction usage
show_usage(){
echo usage :
echo "sauvegarde.sh: [-h] [-g] [-m] [-v] [-n] [-r] [-a] [-s] chemin.."
}
export -f show_usage
#appel de fonction pour la tester
show_usage;
echo --------------------
echo




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
HELP 1
echo --------------------
echo




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
	

}
export -f nbr_taille
nbr_taille 1 
echo --------------------
echo


#		fonction qui permet d’archiver dans une « archive tar » (fichier *.tar.gz) tous les
#		+fichiers de votre répertoire personnel (/home/votre-nom) qui ont été modifiés dans les
#		+dernières 24 heures
archiver(){
	echo cette opertaion peut prendre quelques instants

	tar czvf archive.tar.gz --newer-mtime '1 days ago' /home/* &> /dev/null

	echo terminated ...
	echo fichiers de votre répertoire personnel qui ont été modifiés dans les dernières 24 heures sont archvées dans archive.tar.gz
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
		fi
	fi
}
export -f sauvegarder_infos

#while IFS= read -r line; do ls -la $line >> tmp2; done < tmp
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
version arg

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
interface_graphique;
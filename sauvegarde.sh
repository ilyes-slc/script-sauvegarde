#!/bin/bash



SUCCESS=100
E_FILE=101		#FILE ARCHIVE.TAR.GZ NOT FOUND 



#fonction usage
show_usage(){
echo usage :
echo "sauvegarde.sh: [-h] [-g] [-m] [-v] [-n] [-r] [-a] [-s] chemin.."
}
#appel de fonction pour la tester
show_usage;
echo --------------------
echo




#fonction HELP permet d'afficher le help a partir d'un fichier texte
HELP(){
	cat README.md
}
#appel de fonction pour la tester
#
HELP;
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
	echo la  taille toccupé par les fichiers modifiés dans les dernières 24heures est $taille byte
	echo nombre = $nbr

}

nbr_taille;
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


renommer_archive(){
	if [[ -f archive.tar.gz ]]; then
		#statements
		name=$(date -r archive.tar.gz '+%F')
		mv archive.tar.gz $name.tar.gz
		return $SUCCESS
	else
		return $E_FILE
	fi
}
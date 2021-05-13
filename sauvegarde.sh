#!/bin/bash
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



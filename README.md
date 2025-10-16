
#  R6BO-Translation-mod


Ce projet a pour but de traduire le jeu Rainbow Six: Black Ops en français ou toute autre langue.

  

##  Contenu du mod


Ce mod traduit les éléments suivants du jeu :

* Les biographies des opérateurs et leur profil,
* Les briefings de mission,
* Les Intels de mission,
* Les descriptions des kits d'équipement (armes, uniformes, etc),
* Quelques infobulles pour les aides contextuelles,

**Bonus** - Les traductions des mods suivants sont déjà inclus :

* Playable operator,
* Playable John Clark,
* Splinter Cell Combo,
* Raven Shield weapons,
* Additional uniforms,
* Tom Clancy's Operators

  

##  Installation

### Structure du projet 

    /R6BO-Translation-mod/
        ├── .gitignore
        ├── README.md          
        ├── scripts/           
        │   ├── construct_json.py
        │   ├── split_json.py
        │   ├── translate.sh
        │   ├── translation-by-gemini.py
        │   └── unload_json.py
        ├── source_files/  		# <-- Fichiers originaux    
	    │   ├── plot/
	    │   └── text/
        ├── translated_files/   # <-- Fichiers traduits
        |   ├── Translation - <ISO>/ 
        │ 	│  ├── plot/
        │	│  └── text/
        ├── working_files/       # <-- Fichiers JSON intermédiaires
        │   ├── bios_part_1.json
        │   └── ...
        └── zipped_files/		# <-- Traductions zippées pour faciliter le partage

  ### Pré-requis

*	Python,
*	iconv,
*	Clef API pour Gémini depuis Google AI Studio,
*	zip,

### Usage
Après avoir rassemblé tous les fichiers à traduire dans le dossier "source_files", lancez le fichier main.sh en précisant le code ISO de la langue souhaitée.
_Exemple:_

    ./main.sh fr
    ./main.sh de
    ./main.sh it


 

##  Contribuer

  

Si vous souhaitez contribuer à la traduction, veuillez forker le projet et soumettre une pull request avec vos modifications.
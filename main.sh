#!/bin/bash

# Script principal pour lancer la traduction.
# Il se charge d'appeler le script technique avec les bons paramètres.

set -e # Arrête le script si une commande échoue

# Vérifie qu'un code de langue est fourni
if [ -z "$1" ]; then
  echo "Usage: $0 <code_langue>"
  echo "Exemple: $0 fr"
  exit 1
fi

echo "Checking requirements..."
./scripts/check_requirements.sh


LANGUAGE_CODE=$1
SOURCE_DIR="source_files"
SCRIPTS_DIR="scripts"

echo "Launch of translation for language: $LANGUAGE_CODE"

# Exécute le script de traduction depuis son propre dossier pour qu'il trouve les autres scripts python
(cd "$SCRIPTS_DIR" && ./translate.sh "../$SOURCE_DIR" "$LANGUAGE_CODE")

echo "Translation finished."
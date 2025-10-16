import argparse
import time
from google import genai
import sys

"""
Variables
"""

language_model = "gemini-2.5-flash"
#language_model = "gemini-2.5-flash-lite"
temporisation_rpm = 15 #can be replace by "2" with gemini-2.5-flash-lite

# Set up argument parser
parser = argparse.ArgumentParser(description="Translate text using Gemini.")
parser.add_argument("--lang", type=str, required=True, help="The target language for translation.")
parser.add_argument("--input", type=str, required=True, help="Path to the JSON file to translate.")

# Parse arguments
args = parser.parse_args()

# Read the JSON content from the file path provided in --input
try:
    with open(args.input, 'r', encoding='utf-8') as f:
        json_content = f.read()
except FileNotFoundError:
    print(f"Erreur : Le fichier '{args.input}' n'a pas été trouvé.", file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f"Une erreur est survenue lors de la lecture du fichier : {e}", file=sys.stderr)
    sys.exit(1)

# Create the prompt using the arguments and the file content
prompt = (
    f"Tu es un traducteur professionnel. Le JSON ci-dessous contient des paires clé-valeur."
    "La clé est un chemin de fichier et ne doit JAMAIS être traduite ou modifiée."
    f"Traduis UNIQUEMENT les valeurs (qui sont des chaînes de caractères) du JSON en **{args.lang}**. "
    "Les valeurs originales sont des chaînes de caractères sur plusieurs lignes. Préserve la structure multi-lignes et les caractères spéciaux comme les tabulations."
    "Le ton doit être **naturel et professionnel dans un contexte militaire**. "
    "Renvoye-moi UNIQUEMENT l'objet JSON traduit. La sortie doit être un unique objet JSON valide, sans aucun autre texte ou explication."
    "Assure-toi que tous les caractères spéciaux dans les valeurs JSON (comme les guillemets, les sauts de ligne, les tabulations) sont correctement échappés pour produire une chaîne JSON valide."
    f"\n\nJSON A TRADUIRE :\n{json_content}"
)

client = genai.Client()

response = client.models.generate_content(
    model=language_model,
    contents=prompt,
)

translated_text = response.text.strip()

# Nettoyer la réponse pour supprimer les délimiteurs de bloc de code Markdown
if translated_text.startswith("```json"):
    translated_text = translated_text[7:]
if translated_text.endswith("```"):
    translated_text = translated_text[:-3]

# S'assurer qu'il n'y a pas d'espaces blancs au début ou à la fin
translated_text = translated_text.strip()
print(translated_text)
   


# Pause pour respecter la limite de requêtes par minute (RPM)
time.sleep(temporisation_rpm)
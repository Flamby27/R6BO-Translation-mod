#!/bin/bash

set -e

###################################################################################################
#                                           Description                                           #
###################################################################################################

# This script is destinated to translate all text files for the project Rainbow Six Black Ops 2.0

###################################################################################################
#                                           Variables                                             #
###################################################################################################


###################################################################################################
#                                           Functions                                             #
###################################################################################################

function display_help
{
      echo
      echo "Usage: $0 [path to translate] [ISO code for language]" >&2
      echo
      echo "   example : $0 ./0-Source fr"
      echo
      echo
}

function yes_or_no {
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;
            [Nn]*) return 1 ;;
        esac
    done
}

function compress_for_deploy
{
   local destination_mod_dir_zip=$1
   echo
   if yes_or_no "Do you want to create an archive of your new translated package?"; then
      zip -r "../zipped_files/Translation - $iso_code.zip" "$destination_mod_dir_zip"
   fi
}

function translate_file
{
    local json_filepath=$1
    local target_lang=$2

    # -i specifies the input file
    # -o specifies the output file
    #trans -brief -no-autocorrect -engine "bing" -input "$filepath" -output "$temp_filepath" -target "$target_lang" && mv "$temp_filepath" "$filepath"
    python3 translation-by-gemini.py --input "$json_filepath" --lang "$target_lang" > "$json_filepath".tmp && mv "$json_filepath".tmp "$json_filepath"
}

function create_json_file
{
    local filepath=$1
    local json_filepath=$2
    local filepath_content=$(cat "$filepath")

    python3 construct_json.py --filepath "$filepath" --content "$filepath_content" --json_file "$json_filepath"
}

function unload_json_file
{
    local json_filepath=$1
    python3 unload_json.py --json_filepath "$json_filepath"

}

function change_encoding
{
    local filepath=$1
    local new_encoding=$2
    local temp_filepath="$filepath.tmp"
   
    encoding=$(file --mime-encoding -b "$filepath") 
    
    # After translation, the file is likely UTF-8.
    # If encoding is unknown, we'll assume Windows-1252.
    if [[ $encoding == "unknown-8bit" ]]; then
        encoding="WINDOWS-1252"
    fi

    iconv -f "$encoding" -t "$new_encoding" -o "$temp_filepath" "$filepath" && mv "$temp_filepath" "$filepath"
}

###################################################################################################
#                                           Main                                                  #
###################################################################################################
echo
echo
echo '8888888b.   .d8888b.  888888b.    .d88888b.   .d8888b.       .d8888b.        88888888888                                 888          888    d8b                                                     888'
echo '888   Y88b d88P  Y88b 888  "88b  d88P" "Y88b d88P  Y88b     d88P  Y88b           888                                     888          888    Y8P                                                     888'
echo '888    888 888        888  .88P  888     888        888     888    888           888                                     888          888                                                            888'
echo '888   d88P 888d888b.  8888888K.  888     888      .d88P     888    888           888  888d888  8888b.  88888b.  .d8888b  888  8888b.  888888 888  .d88b.  88888b.        88888b.d88b.   .d88b.   .d88888'
echo '8888888P"  888P "Y88b 888  "Y88b 888     888  .od888P"      888    888           888  888P"       "88b 888 "88b 88K      888     "88b 888    888 d88""88b 888 "88b       888 "888 "88b d88""88b d88" 888'
echo '888 T88b   888    888 888    888 888     888 d88P"          888    888           888  888     .d888888 888  888 "Y8888b. 888 .d888888 888    888 888  888 888  888       888  888  888 888  888 888  888'
echo '888  T88b  Y88b  d88P 888   d88P Y88b. .d88P 888"       d8b Y88b  d88P           888  888     888  888 888  888      X88 888 888  888 Y88b.  888 Y88..88P 888  888       888  888  888 Y88..88P Y88b 888'
echo '888   T88b  "Y8888P"  8888888P"   "Y88888P"  888888888  Y8P  "Y8888P"            888  888     "Y888888 888  888  88888P" 888 "Y888888  "Y888 888  "Y88P"  888  888       888  888  888  "Y88P"   "Y88888'
echo ''
echo ''
echo ''
echo ''
echo ' __        ___            __     '
echo '|__)\ /   |__|    /\ |\/||__)\ / '
echo '|__) |    |  |___/~~\|  ||__) |  '
echo ''
echo ''

############
# Help menu
############
if [[ "$1" == "--help" || "$1" == "-h" || "$1" == "" || "$2" == "--help" || "$2" == "-h" || "$2" == "" ]];
then
   display_help
   exit 0
fi

############
# Configuration
############
origin_dir=$1
# Convert ISO code to uppercase for normalization
iso_code=$(echo "$2" | tr '[:lower:]' '[:upper:]')
destination_mod_dir="../translated_files/Translation - $iso_code"
log_file="translation.log"
# Clear log file
> "$log_file"
json_dir="../working_files"

sleep 2s
echo 
echo "############"
echo "# Step 1 : Prepare workspaces"
echo "############"
echo
sleep 2s


echo "Searching for files to translate in: '$origin_dir' for language '$iso_code'"
# Create the destination directory
mkdir -p "$destination_mod_dir"
# Recreate the directory structure and copy files
cp -r "$origin_dir"/* "$destination_mod_dir"/
echo "Arborescence créée et fichiers copiés dans $destination_mod_dir"

# Find all files in the directory and loop through them
echo "Processing files... Logs will be available in translation.log"

# Set the directory for intermediate JSON files and ensure it's clean
echo "Cleaning working directory: $json_dir"
rm -rf "$json_dir"/*
mkdir -p "$json_dir"

sleep 2s
echo 
echo "############"
echo "# Step 2 : - Encode files in UTF-8 for translation"
echo "#          - Insert all files content in a JSON file including filename and content"
echo "############"
echo
sleep 2s

find "$destination_mod_dir" -type f | while read -r filepath; do
    relative_path=${filepath#"$destination_mod_dir/"}
    
    group_name=""
    if [[ $relative_path == text/* ]]; then
        temp_path=${relative_path#text/}
        group_name=$(echo "$temp_path" | cut -d/ -f1)
    else
        group_name=$(echo "$relative_path" | cut -d/ -f1)
    fi
    
    if [[ "$group_name" == "text" || "$group_name" == "english" || -z "$group_name" ]]; then
        echo "Skipping file (group '$group_name'): $filepath" >> "$log_file"
        continue
    fi

    json_filepath="$json_dir/$group_name.json"

    printf "  - Processing %-30s for %s section      " "${filepath##*/}" "$group_name"
    # 1. Prepare files for translation work 
    change_encoding "$filepath" "UTF-8//TRANSLIT" >> "$log_file" 2>&1
    
    
    # Add file to the group's JSON
    create_json_file "$filepath" "$json_filepath" >> "$log_file" 2>&1
    echo "-> JSON [OK]"
done

sleep 2s
echo 
echo "############"
echo "# Step 3 : - Split JSON files if necessary to avoid overloading the API"
echo "############"
echo
sleep 2s

# Split large JSON files before translation
echo "Splitting large JSON files if necessary..."
threshold=50 # Max number of keys per JSON file

# Create a temporary list of files to check, to avoid issues with find and loops
json_file_list=$(mktemp)
find "$json_dir" -type f -name "*.json" > "$json_file_list"

while read -r json_filepath; do
    if [ ! -f "$json_filepath" ]; then
        continue # a previous split might have removed this file
    fi

    # Get number of keys, handle potential json parsing errors
    num_keys=$(/opt/python/bin/python -c "import json; import sys; fpath=sys.argv[1]; print(len(json.load(open(fpath, encoding='utf-8'))))" "$json_filepath" 2>/dev/null || echo 0)
    
    if [ "$num_keys" -gt "$threshold" ]; then
        echo "File '$json_filepath' has $num_keys keys, which is over the threshold of $threshold. Splitting..."
        /opt/python/bin/python split_json.py --input "$json_filepath" --chunk_size "$threshold" >> "$log_file" 2>&1
    fi
done < "$json_file_list"

rm "$json_file_list"
echo "Splitting done [OK]"

sleep 2s
echo 
echo "############"
echo "# Step 4 : - JSON file go to translation"
echo "#          - Translated JSON are unloaded as their original files"
echo "############"
echo
sleep 2s

# Now translate each JSON file
find "$json_dir" -type f -name "*.json" | while read -r json_filepath; do
    printf "Translating JSON file: %-90s" "$json_filepath"
    # 2. Translate the file content
    translate_file "$json_filepath" "$iso_code" >> "$log_file" 2>&1
    echo "JSON file is translated [OK]"

    echo "Unloading JSON file... "
    unload_json_file "$json_filepath"
    echo "Unloading done [OK]"
done

sleep 2s
echo 
echo "############"
echo "# Step 5 : - Re-Encode files in WINDOWS-1252 to be fully understood by the game for translation"
echo "#          - Optionally ZIP the result to make the sharing easier"
echo "############"
echo
sleep 2s

# 3. Change the encoding of the translated file for the game
find "$destination_mod_dir" -type f | while read -r filepath; do
    printf "  - Processing %-90s" "$filepath"
    change_encoding "$filepath" "WINDOWS-1252//TRANSLIT" >> "$log_file" 2>&1
    echo "[OK]"
done


#Ask for archive creation to make the sharing easier
compress_for_deploy "$destination_mod_dir"

echo "Script finished."
exit 0


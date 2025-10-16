import json
import argparse
import os

def unload_json(json_filepath):
    """
    Reads a JSON file and creates files based on its content.
    The JSON file should be a dictionary where keys are file paths
    and values are the content to be written to those files.
    """
    try:
        with open(json_filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"Error: The file {json_filepath} was not found.")
        return
    except json.JSONDecodeError:
        print(f"Error: The file {json_filepath} is not a valid JSON file.")
        return

    if not isinstance(data, dict):
        print("Error: The JSON content is not a dictionary.")
        return

    for filepath, content in data.items():
        try:
            # Create the directory if it doesn't exist
            directory = os.path.dirname(filepath)
            if directory:
                os.makedirs(directory, exist_ok=True)

            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Successfully created file: {filepath}")
        except Exception as e:
            print(f"Error creating file {filepath}: {e}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Create files from a JSON file.')
    parser.add_argument('--json_filepath', help='The path to the JSON file.')
    args = parser.parse_args()

    unload_json(args.json_filepath)
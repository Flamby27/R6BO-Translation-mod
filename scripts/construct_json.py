import json
import argparse
import os

def construct_json(filepath, content, json_file):
    """
    Constructs a JSON file with the given filepath as key and content as value.
    If the JSON file already exists, it updates it with the new key-value pair.
    """
    data = {}

    if os.path.exists(json_file):
        with open(json_file, 'r', encoding='utf-8') as f:
            try:
                data = json.load(f)
            except json.JSONDecodeError:
                # File is empty or not valid JSON, start with an empty dict
                pass

    data[filepath] = content

    with open(json_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Construct a JSON file from filepath and content.')
    parser.add_argument('--filepath', required=True, help='The filepath to use as the key in the JSON.')
    parser.add_argument('--content', required=True, help='The content to use as the value in the JSON.')
    parser.add_argument('--json_file', default='all_texts.json', help='The path to the JSON file.')
    args = parser.parse_args()

    construct_json(args.filepath, args.content, args.json_file)

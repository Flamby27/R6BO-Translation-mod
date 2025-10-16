import json
import argparse
import os
import sys

def split_json(input_filepath, chunk_size):
    """
    Splits a large JSON file (containing a dictionary) into smaller chunks.
    Each chunk will be a separate JSON file containing a subset of the original dictionary.
    """
    try:
        with open(input_filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"Error reading or parsing JSON file {input_filepath}: {e}", file=sys.stderr)
        return

    if not isinstance(data, dict):
        print(f"Error: JSON content in {input_filepath} is not a dictionary.", file=sys.stderr)
        return

    items = list(data.items())
    total_items = len(items)

    if total_items <= chunk_size:
        print(f"No splitting needed for {input_filepath} ({total_items} items).")
        return

    num_chunks = (total_items + chunk_size - 1) // chunk_size
    base_filename = os.path.splitext(os.path.basename(input_filepath))[0]
    dir_name = os.path.dirname(input_filepath)

    print(f"Splitting {input_filepath} ({total_items} items) into {num_chunks} chunks of ~{chunk_size} items each.")

    for i in range(num_chunks):
        chunk_data = dict(items[i*chunk_size:(i+1)*chunk_size])
        chunk_filename = f"{base_filename}_part_{i+1}.json"
        chunk_filepath = os.path.join(dir_name, chunk_filename)
        
        with open(chunk_filepath, 'w', encoding='utf-8') as f:
            json.dump(chunk_data, f, ensure_ascii=False, indent=4)
        print(f"Created chunk: {chunk_filepath}")

    # Remove the original large file
    os.remove(input_filepath)
    print(f"Removed original file: {input_filepath}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Split a large JSON file into smaller chunks.')
    parser.add_argument('--input', required=True, help='The path to the large JSON file.')
    parser.add_argument('--chunk_size', type=int, default=50, help='Number of keys per chunk.')
    args = parser.parse_args()
    split_json(args.input, args.chunk_size)

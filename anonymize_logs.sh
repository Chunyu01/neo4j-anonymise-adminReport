#!/bin/bash

# Detect operating system and set appropriate hash command
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  HASH_CMD="sha256sum"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  HASH_CMD="shasum -a 256"
else
  echo "Unsupported OS: $OSTYPE"
  exit 1
fi

# Function to generate a hash of a string
hash_value() {
  local value="$1"
  echo -n "$value" | $HASH_CMD | awk '{print $1}' | cut -c 1-8  # Take the first 8 characters of the hash
}

# Function to anonymize IP addresses and domain names on the right side of '='
anonymize_file() {
  local file="$1"
  local tempfile=$(mktemp)

  # Process each line, find IPs or domains on the right-hand side of '=' and hash them
  awk -F'=' '{
    if ($2 ~ /[0-9]{1,3}(\.[0-9]{1,3}){3}/) {
      ip = $2
      sub(/[0-9]{1,3}(\.[0-9]{1,3}){3}/, "'$(hash_value '"ip"')'", $2)
    } else if ($2 ~ /[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}/) {
      domain = $2
      sub(/[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}/, "'$(hash_value '"domain"')'", $2)
    }
    print $1"="$2
  }' "$file" > "$tempfile"

  # Replace the original file with the anonymized version
  mv "$tempfile" "$file"
}

# Function to remove trailing equals signs from lines
remove_trailing_equals() {
  local file="$1"
  awk '/=$/ { sub(/=$/, ""); } { print }' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
}

# Find the first .zip file in the current directory
ZIP_FILE=$(find . -maxdepth 1 -name "*.zip" | head -n 1)

# Check if a zip file is found
if [ -z "$ZIP_FILE" ]; then
  echo "No zip file found in the current directory."
  exit 1
fi

# Paths
EXTRACT_DIR="extracted_logs"    # Directory to extract files to
BASE_NAME="${ZIP_FILE%.zip}"    # Get base name of the zip file without extension
NEW_FOLDER="${BASE_NAME}_anonymized_folder"  # New folder for the anonymized zip file
NEW_ZIP_FILE="${NEW_FOLDER}/${BASE_NAME}_anonymized.zip"  # New zip file name in the new folder

# Step 1: Create new folder for the anonymized file
echo "Creating new folder: $NEW_FOLDER"
mkdir -p "$NEW_FOLDER"

# Step 2: Extract the zip file
echo "Extracting $ZIP_FILE..."
mkdir -p "$EXTRACT_DIR"
unzip -q "$ZIP_FILE" -d "$EXTRACT_DIR"

# Step 3: Find and anonymize relevant files (e.g., neo4j.conf, .log files), excluding __MACOSX
echo "Anonymizing IP addresses and domain names..."
find "$EXTRACT_DIR" \( -name "*.conf" -o -name "*.log" \) ! -path "*/__MACOSX/*" ! -name ".*" | while read -r file; do
  echo "Processing $file..."
  anonymize_file "$file"
  remove_trailing_equals "$file"  # Remove trailing equals signs
done

# Step 4: Repackage the anonymized files into a new zip file within the new folder
echo "Creating anonymized zip file in $NEW_FOLDER..."
cd "$EXTRACT_DIR" || exit
zip -qr "../$NEW_ZIP_FILE" .
cd ..

# Step 5: Cleanup
echo "Cleaning up..."
rm -rf "$EXTRACT_DIR"

echo "Anonymization complete. Anonymized file saved as $NEW_ZIP_FILE."

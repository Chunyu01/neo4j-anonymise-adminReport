# neo4j-anonymise-adminReport
# Neo4j Configuration and Logs Anonymization Script for Linux

This project provides a bash script to anonymize sensitive data (IP addresses and domain names) in Neo4j configuration files and logs on a Linux environment. The script is designed to anonymize only the values on the right-hand side of the `=` sign, ensuring that the keys (the left-hand side) remain unchanged.

## Features

- **Anonymizes IP addresses**: Converts IP addresses to `x.x.x.x`.
- **Anonymizes domain names**: Converts domain names to `anonymized.domain`.
- **Handles ports**: Works with IP addresses and domain names that include ports (e.g., `10.0.0.0:7687`, `example.com:7474`).
- **Automatic OS detection**: Detects whether the script is running on Linux or macOS and uses the appropriate hashing tool (sha256sum for Linux and shasum for macOS).
- **Automatically detects the zip file**: The script looks for any .zip file in the current directory and processes the first one it finds.
- **Creates a new folder**: The anonymized zip file is placed inside a new folder to keep the output separate from the original files.

## Prerequisites

Make sure you have the following tools installed on your Linux system:

- **Bash**: The script is written in bash and requires a Unix-like environment.
- **zip**: A tool to repackage files after anonymization.
- **unzip**: A tool to extract the contents of a zip file.

### Installing Dependencies

For Ubuntu/Debian-based systems, you can install the required tools by running:

```bash
sudo apt update
sudo apt install zip unzip
```
## Usage

### Step 1: Download the Anonymization Script

Save the following script as `anonymize_logs.sh`:
[anonymize logs]./anonymize_logs.sh
### Step 2: Make the Script Executable
Run the following command to give execution permission to the script:

```bash
chmod +x anonymize_logs.sh
```
### Step 3: Run the Script
You can now run the script to anonymize a zip file containing the neo4j.conf and log files:
```bash
./anonymize_logs.sh
```

### Step 4: Input and Output

- Input: The script automatically detects a .zip file in the current directory (e.g., Chunyus_MacBook_Pro.local-2024-09-26_175357.zip) and processes it.
- Output: The script generates a new anonymized zip file in a folder named after the original zip file with _anonymized_folder appended (e.g., Chunyus_MacBook_Pro.local-2024-09-26_175357_anonymized_folder/Chunyus_MacBook_Pro.local-2024-09-26_175357_anonymized.zip).

### Example

Here’s an example of how a file is processed:

#### Before Anonymization:
```bash
server.bolt.listen_address=10.0.0.0:7687
server.http.listen_address=example.com:7474
```
#### After Anonymization:
```bash
server.bolt.listen_address=3a5f6e1b:7687
server.http.listen_address=4a2b1e3c:7474
```
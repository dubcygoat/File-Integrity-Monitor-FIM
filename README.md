# File Integrity Monitor (FIM)

This repository contains a PowerShell script that monitors the integrity of files in a specified folder. It calculates the hash value of each file and compares it with a baseline to detect any modifications or new files.

## Prerequisites

- PowerShell version 5.1 or later
- PSSlack module installed (`Import-Module PSSlack`)

## Usage

1. Run the script in a PowerShell environment.
2. The script will prompt you to select a folder to monitor.
3. Once a folder is selected, the script will create a baseline file (`baseline.txt`) containing the hash values of all files in the folder.
4. The script will continuously monitor the folder for changes.
5. If a file is modified, the script will log the event in a log file (`log.txt`) and send a notification to Slack using the provided webhook URI.
6. If a new file is created, the script will log the event and display a message in the console.

## Customization

- You can adjust the monitoring interval by modifying the `Start-Sleep` command in the script.
- The script uses the `Get-LastModifiedBy` function to determine the last modified user of a file. You can customize this function according to your requirements.


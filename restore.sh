#!/usr/bin/env bash 

if [ "$#" -ne 2 ]; then 
    echo "Invalid number of arguments"
    echo "argument 1 --> source directory"
    echo "argument 2 --> quarantine directory"
    exit 1
fi 

SOURCE_DIR="$1"
QUARANTINE_DIR="$2"

if [ ! -d "$SOURCE_DIR" ] || [ ! -d "$QUARANTINE_DIR" ]; then
    echo "Directories doesnt exist "
    exit 1
fi 

while true; do 
    
    # create an array to hold all the files inside the quarantine directory
    quarantined_files=()
    # loop through all the objects inside the directory to get the files only
    for file_path in "$QUARANTINE_DIR"/*; do 
        [ -f "$file_path" ] && quarantined_files+=("$file_path")
    done
    #check if the quarantined array is empty or not 
    if [ "${#quarantined_files[@]}" -eq 0 ]; then 
        echo "No malicious files to review."
        exit 0 
    fi
    
    echo "---------------------"
    echo "##Quarantined Files##"
    for index in "${!quarantined_files[@]}"; do 
        file_name=$(basename "${quarantined_files[$index]}")
        echo "$((index+1)) $file_name"
    done
     
    read -rp "select file by a number: " file_choice
    
    selected_file_path="${quarantined_files[$((file_choice-1))]}"
    selected_file_name=$(basename "$selected_file_path")
    
    echo "-----------------------------------------"
    echo "####Display action menu####"
    echo "what action for $selected_file_name"
    echo "1 - restore the file to $SOURCE_DIR"
    echo "2 - permenantly delete the file from $QUARANTINE_DIR"
    echo "3 - Leave the file unchanged "
    read -rp "select a choice: " action_choice
    
    if [ "$action_choice" -eq 1 ]; then 
        cp "$selected_file_path" "$SOURCE_DIR/$selected_file_name"
        rm "$selected_file_path"
        echo "Restored $selected_file_name to $SOURCE_DIR."
    
    elif [ "$action_choice" -eq 2 ]; then
        rm -f "$selected_file_path"
        echo "$selected_file_name is permenantly deleted."
        
    elif [ "$action_choice" -eq 3 ]; then
       echo "Skipped $selected_file_name."
 
    else 
      echo "Invalid option , Back to the menu"
    fi 
done
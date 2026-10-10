


# 1/ check the number of the arguments received is 3 
# "$#" --> special variable carry the number of arguments received
# -ne --> flag stands for not equal
if [ "$#" -ne 2 ]; then 
    echo "Error --> invalid number of arguments "
    echo "First argument --> source directory"
    echo "second argument --> Quarantine directory"
    exit 1
fi

# 2/ defining the global variables
SOURCE_DIR=$1
QUARANTINE_DIR=$2
WHITELIST_FILE="whitelist.txt"

# 3/ checks if the source directory exists or not 
# ! -d --> return true if directory doesnt exist 
if [ ! -d "$SOURCE_DIR" ]; then 
    echo "Source directory doesnt exit "
    exit 1
fi 

mkdir -p "$QUARANTINE_DIR"
touch "$WHITELIST_FILE"

scan_directory(){
    for file_path in "$SOURCE_DIR"/*; do
        
        # check if the object is a file and not directory 
        # if directory continue to the next loop
        [ -f "$file_path" ] || continue
        
        # get the file name to check for the extension using basename
        # local before variable name --> keeps variable only declared inside the function
        local file_name 
        local is_malicious=0
        file_name=$(basename "$file_path")
        
        # check if the file name exists in the whitelist or not 
        if grep -qx "$file_name" "$WHITELIST_FILE"; then 
            continue
        fi
        
        #check if the file anme contain a flagged extension 
        if [[ "$file_name" == *.exe || \
              "$file_name" == *.bat || \
              "$file_name" == *.vbs || \
              "$file_name" == *.scr || \
              "$file_name" == *.ps1 ]]; then 
                  is_malicious=1
        fi
        
        #check the content insie the file for weird words
        if [ $is_malicious -eq 0 ]; then 
            # grep --> searching for content inside a file 
            # -i --> case insensitive
            # -q --> quiet mode returns status without prinitng the matched lines
            # -E --> extended regex to allow or operator between the keywords
            if grep -iqE "virus|trojan|malware|worm|ransomware" "$file_path"; then 
                is_malicious=1
            fi
        fi
        
        # taking an action if the file is malicious 
        if [ "$is_malicious" -eq 1 ]; then 
            echo "$file_name is malicious and it is DELETED"
            cp "$file_path" "$QUARANTINE_DIR/$file_name"
            rm "$file_path"
        fi 
    done
}

scan_directory
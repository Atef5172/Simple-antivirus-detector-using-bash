#!usr/bin/env bash 

################################################################### Arguments Validation

# 1/ check the number of the arguments received is 3 
# "$#" --> special variable carry the number of arguments received
# -ne --> flag stands for not equal
if ["$#" -ne 3 ]; then 
    echo "Error --> invalid number of arguments "
    echo "First argument --> source directory"
    echo "second argument --> Quarantine directory"
    echo "Third argument --> interval in seconds"
    exit 1
fi 

# 2/ Global variables to store arguments
SOURCE_DIR="$1"
QUARANTINE_DIR="$2"
INTERVAL_SEC="$3"
# 3/ Global variables to store snapshpts
LAST_INFO="directory-info.last"
NEW_INFO="directory_info.new"

# 3/ checks if the source directory exists or not 
# ! -d --> return true if directory doesnt exist 
if [ ! -d $SOURCE_DIR ]; then 
    echo "Source directory doesnt exit "
    exit 1
fi 

 
# 4/ creates  a quarantine directory if doesnt already exsts
# -p flag that prevents the error if directory alrady exists
mkdir -p "$QUARANTINE_DIR"

############################################################################# scan directory function

scan_directory(){
    for file_path in "$SOURCE_DIR/*"; do
        
        # check if the object is a file and not directory 
        # if directory continue to the next loop
        [ -f "$file_path" ] || continue
        
        # get the file name to check for the extension using basename
        # local before variable name --> keeps variable only declared inside the function
        local file_name 
        local is_malicious=0
        file_name=$(basename "$file_path")
        
        #check if the file anme contain a flagged extension 
        if [[ "$file_name" == *.exe || \
              "$file_name" == *.bat || \
              "$file_name" == *.vbs || \
              "$file_name" == *.scr || \
              "$file_name" == *.ps1 ]]; then 
                  is_malicious=1
        fi
        
        #check the content insie the file for weird words
        if [ $is_malicious -ne 0 ]; then 
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
            echo "$file_name is weird and i will delete it"
            cp "$file_path" "$QURANTINE_DIR/$file_name"
            rm "$file_name"
        fi 
    done
}







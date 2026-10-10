#!usr/bin/env bash 


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









SOURCE_DIR ?= test_dir
MALICIOUS_DIR ?= quarantine_dir
INTERVAL_SEC ?= 2

prepare:
	mkdir -p $(MALICIOUS_DIR)
	mkdir -p $(SOURCE_DIR)
	
create-some-files: prepare 
	echo "I am a harmless file" > $(SOURCE_DIR)/messi.txt
	echo "I am a dagerous file extension" > $(SOURCE_DIR)/ronaldo.exe
	echo "I contain harm content virus" > $(SOURCE_DIR)/harmcontent.txt


run-antivirus : prepare
	./antivirusd.sh $(SOURCE_DIR) $(MALICIOUS_DIR) $(INTERVAL_SEC)
restore : prepare 
	./restore.sh $(SOURCE_DIR) $(MALICIOUS_DIR)
	
clear :
	rm -f directory-info.last directory-info.new whitelist.txt
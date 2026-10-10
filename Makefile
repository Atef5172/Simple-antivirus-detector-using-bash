
SOURCE_DIR ?= test_dir
MALICIOUS_DIR ?= quarantine_dir
INTERVAL_SEC ?= 2

prepare:
	mkdir -p $(MALICIOUS_DIR)
	MKDIR -P $(SOURCE_DIR)

run-antivirus : prepare
	       ./antivirus.sh $(SOURCE_DIR) $(MALICIOUS_DIR) $(INTERVAL_SEC)
restore : prepare 
          ./restore.sh $(SOURCE_DIR) $(MALICIOUS_DIR)
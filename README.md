
## 1. Overview & Folder Hierarchy

This project contains a Bash-based antivirus suite built for Linux (Ubuntu) environments. It periodically monitors a specified directory for file modifications, quarantines flagged malicious files, provides an interactive restoration tool with persistent whitelisting, and offers automated execution via `make`.

### Repository Hierarchy

```text
.
├── .gitignore               # Ignored files and patterns for Git version control
├── Makefile                 # Build automation for running daemon, restore tool, and cleanup
├── README.md                # Project documentation and user manual
├── antivirus_algorithm.txt  # Pseudocode/algorithm notes for the antivirus daemon
├── restore_algorithm.txt    # Pseudocode/algorithm notes for the restore tool
├── antivirus.sh             # Polling monitoring daemon script (Part 1 + Bonus 2)
├── restore.sh               # Interactive quarantine review & restore tool (Part 2 + Bonus 2)
├── directory-info.last      # Snapshot file recording previous directory state
├── directory-info.new       # Snapshot file recording current directory state
├── quarantine_dir/          # Directory storing quarantined malicious files
├── test_dir/                # Monitored target directory containing test files
└── whitelist.txt            # Persistent database recording false positives/safe files (Bonus 2)
```

---

## 2. Prerequisites & Ubuntu Installation

The scripts require standard GNU utilities commonly available on Ubuntu systems.

### Installation & Prerequisites
1. Ensure system dependencies (`bash`, `coreutils`, `make` , `cron`) are installed:
   ```bash
   sudo apt update
   sudo apt install -y bash coreutils make cron 
   ```
2. Verify execution permissions on all shell scripts:
   ```bash
   chmod +x antivirus.sh restore.sh
   ```

---

## 3. Step-by-Step Usage Instructions

### Method A: Running via `Makefile` 

1. **Generate Test Files:**
   Populates `test_dir` with sample files (clean files, flagged extensions, flagged content):
   ```bash
   make create-some-files
   ```

2. **Start the Antivirus Daemon:**
   Automatically creates `quarantine_dir` if it does not exist and launches `antivirus.sh`:
   ```bash
   make run-antivirus
   ```
   *(By default, this monitors `test_dir` every 2 seconds).*

3. **Run the Restore Tool:**
   Launches the interactive restoration interface:
   ```bash
   make restore
   ```

4. **Clean Baseline Snapshots and Temporary Files:**
   Resets snapshot tracking and whitelist state:
   ```bash
   make clean
   ```

### Method B: Direct Script Execution

1. **Antivirus Daemon (`antivirus.sh`):**
   Execute with source directory, quarantine directory, and check interval in seconds:
   ```bash
   ./antivirus.sh <source_directory> <quarantine_directory> <interval_sec>
   ```
   *Example:* `./antivirus.sh test_dir quarantine_dir 2`

2. **Restore Tool (`restore.sh`):**
   Execute with source directory and quarantine directory:
   ```bash
   ./restore.sh <source_directory> <quarantine_directory>
   ```
   *Example:* `./restore.sh test_dir quarantine_dir`

---

## 4. Detection Rules & Code Line Locations

All detection logic is defined inside `antivirus.sh` within the `scan_directory()` function:

### 1. Flagged Extensions
- **Hardcoded List:** `.exe`, `.bat`, `.vbs`, `.scr`, `.ps1`
- **Code Location:** `antivirus.sh` inside `scan_directory()`:
  ```bash
  if [[ "$file_name" == *.exe || \
        "$file_name" == *.bat || \
        "$file_name" == *.vbs || \
        "$file_name" == *.scr || \
        "$file_name" == *.ps1 ]]; then 
      is_malicious=1
  fi
  ```

### 2. Flagged Content Keywords
- **Hardcoded Keywords (Case-Insensitive):** `virus`, `trojan`, `malware`, `worm`, `ransomware`
- **Code Location:** `antivirus.sh` inside `scan_directory()`:
  ```bash
  if [ "$is_malicious" -eq 0 ]; then 
      if grep -iqE "virus|trojan|malware|worm|ransomware" "$file_path"; then 
          is_malicious=1
      fi
  fi
  ```

---

## 5. Whitelist Mechanism 

To prevent restored false positives from being re-flagged on subsequent scans, the suite uses a shared persistent file named `whitelist.txt`.

### How a File Gets Added to the Whitelist
1. When a user runs `restore.sh` and selects **Option 1 (Restore file)**, `restore.sh` moves the file back to the source directory.
2. `restore.sh` queries `whitelist.txt`. If the filename is not yet listed, it appends the filename to `whitelist.txt`:
   ```bash
   if ! grep -qx "$selected_file_name" "$WHITELIST_FILE"; then 
       echo "$selected_file_name" >> "$WHITELIST_FILE"
   fi
   ```

### How the Daemon Checks the Whitelist
At the start of every file check inside `scan_directory()` in `antivirus.sh`, the daemon evaluates:
```bash
if grep -qx "$file_name" "$WHITELIST_FILE"; then 
    continue
fi
```
If an exact match is found in `whitelist.txt`, the scanner skips extension and content evaluations, keeping the restored file safe in the source directory across daemon restarts.

---

## 6. Cron Job Setup 

### Prerequisites
- Ensure the `cron` service is running on Ubuntu:
  ```bash
  sudo systemctl status cron
  ```

### Configuration Manual
1. Open the user crontab editor:
   ```bash
   crontab -e
   ```
2. Add a line to run a scan job periodically:
   ```cron
   * * * * * /bin/bash /absolute/path/to/antivirus-cron.sh /absolute/path/to/test_dir /absolute/path/to/quarantine_dir 
   ```

### Cron Expression: Every 3rd Friday of the Month at 12:31 AM
```cron
31 0 15-21 * 5
```

#### Expression Breakdown:
- `31`: Executed at minute 31.
- `0`: Executed at hour 0 (12 AM midnight).
- `15-21`: Days of the month between 15 and 21 (the 3rd Friday of any month always lands within this date range).
- `*`: Applies to every month.
- `5`: Restricts execution specifically to Friday (where 0=Sun, 5=Fri).
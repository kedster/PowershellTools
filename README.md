# PowershellTools
Tools I have found useful, in PS1

## Overview

This PowerShell script uses `System.IO.FileSystemWatcher` to **monitor a log file in real time**. When new lines are written to the file, it evaluates them for specific patterns (e.g., `"ERROR"` or `"SUCCESS"`) and can trigger custom actions such as alerting or logging.

Designed for automation pipelines, deployments, or long-running applications that write logs during execution.

---

## ✅ Features

- Watches a specified `.log` file for live updates
- Detects and responds to `"ERROR"` or `"SUCCESS"` entries
- Runs continuously in the console
- Easy to extend with email alerts, Splunk integration, or Event Log entries

---

## 🔧 Configuration

Edit the top section of the script to specify the log file to watch:

```powershell
$logFilePath = "C:\Logs\deployment.log"
```
______________________________________________________________________________________________________________________________________________________________________


# Windows 7 to Windows 10 Migration Script (2013–2017)

## Purpose
7 TO 10
This script automates pre-migration steps for moving from Windows 7 to Windows 10, used widely in enterprise rollouts between 2013–2017.

## What It Does

- Backs up each user profile from `C:\Users\`
- Preserves:
  - PST files (Outlook)
  - AppData (Local, Roaming, LocalLow)
  - Temp folders
- Collects system and BIOS information
- Optionally launches a Windows 10 task sequence or setup script

## Usage

```powershell
.\Migrate-Win7ToWin10.ps1 -BackupPath "\\Server\Backups\PC1234" -TSCommand "C:\Scripts\Start-Win10.cmd"

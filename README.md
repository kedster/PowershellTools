# PowershellTools
Tools I have found useful, in PS1
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

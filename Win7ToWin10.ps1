<#
.SYNOPSIS
    Enterprise-grade migration prep from Windows 7 to Windows 10.

.DESCRIPTION
    Backs up user profiles, PST files, AppData folders, and Temp data
    prior to launching a Windows 10 migration (in-place or wipe-load).

.PARAMETER BackupPath
    Network or external storage location (UNC or local path).

.PARAMETER TSCommand
    Optional. Command to start Windows 10 installation or task sequence (e.g., SCCM/MDT).

.NOTES
    Designed for enterprise use between 2013–2017 with local domain user accounts.
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$BackupPath,

    [Parameter(Mandatory=$false)]
    [string]$TSCommand
)

function Backup-UserProfiles {
    $profiles = Get-WmiObject Win32_UserProfile | Where-Object { $_.Special -eq $false -and $_.LocalPath -like "C:\Users\*" }

    foreach ($profile in $profiles) {
        $userPath = $profile.LocalPath
        $username = Split-Path $userPath -Leaf
        $userDest = Join-Path $BackupPath $username

        Write-Host "`nBacking up user: $username"

        # Backup full profile
        robocopy $userPath $userDest\Profile /MIR /Z /XA:H /W:5 /R:2 /NFL /NDL /NP

        # Backup AppData explicitly
        foreach ($appDataType in "AppData\Local", "AppData\Roaming", "AppData\LocalLow") {
            $source = Join-Path $userPath $appDataType
            if (Test-Path $source) {
                robocopy $source "$userDest\$appDataType" /E /Z /XA:H /W:5 /R:2 /NFL /NDL /NP
            }
        }

        # Backup Temp folders
        $tempPath = Join-Path $userPath "AppData\Local\Temp"
        if (Test-Path $tempPath) {
            robocopy $tempPath "$userDest\Temp" /E /Z /XA:H /W:5 /R:2 /NFL /NDL /NP
        }

        # Backup all PST files in profile
        $psts = Get-ChildItem -Path $userPath -Recurse -Include *.pst -ErrorAction SilentlyContinue
        foreach ($pst in $psts) {
            $relPath = $pst.FullName.Substring($userPath.Length).TrimStart('\')
            $targetPath = Join-Path $userDest\PSTs $relPath
            New-Item -ItemType Directory -Path (Split-Path $targetPath) -Force | Out-Null
            Copy-Item $pst.FullName -Destination $targetPath -Force
        }
    }
}

function Export-SystemInfo {
    $sysinfo = Join-Path $BackupPath "SystemInfo.txt"
    systeminfo > $sysinfo
    Get-WmiObject Win32_ComputerSystem | Out-File (Join-Path $BackupPath "ComputerSystem.txt")
    Get-WmiObject Win32_BIOS | Out-File (Join-Path $BackupPath "BIOS.txt")
}

function Start-Migration {
    if ($TSCommand) {
        Write-Host "Launching task sequence or Windows setup..."
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c $TSCommand"
    } else {
        Write-Warning "No TSCommand specified. Manual setup step required."
    }
}

# --- MAIN EXECUTION ---
Write-Host "=== Windows 7 to Windows 10 Migration Script ===`n"
if (!(Test-Path $BackupPath)) {
    New-Item -Path $BackupPath -ItemType Directory -Force | Out-Null
}

Backup-UserProfiles
Export-SystemInfo
Start-Migration

Write-Host "`nMigration preparation complete."

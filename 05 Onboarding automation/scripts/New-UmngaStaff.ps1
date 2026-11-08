<#
.SYNOPSIS
    Creates Umnga staff accounts from a CSV file.
.DESCRIPTION
    Reads a CSV with GivenName, Surname, SamAccountName, Department and Group.
    For each row it checks that the department OU and the group exist, skips users that
    already exist, creates the rest in their department OU, adds them to their group,
    and writes a log. The starting password is typed at the prompt and is never stored.
    Every new account must change its password at first sign in.
.PARAMETER CsvPath
    The CSV file to read.
.PARAMETER LogFolder
    The folder where log files are written.
.EXAMPLE
    .\New-UmngaStaff.ps1 -WhatIf
.EXAMPLE
    .\New-UmngaStaff.ps1
.NOTES
    Author: Hlumelo. Lab use only. Every name in the CSV is invented.
    Changes: creates Active Directory users and group memberships.
    Undo: Remove-ADUser -Identity <logon name> for each user created (lab only).
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$CsvPath = "C:\Scripts\umnga_new_staff.csv",
    [string]$LogFolder = "C:\Scripts\logs"
)

Import-Module ActiveDirectory

# Where the department OUs live, and the domain name used for logon names
$departmentsOu = "OU=Departments,OU=Umnga,DC=umnga,DC=local"
$domainName = "umnga.local"

# A log file named with the date and time. The log is written even during a WhatIf run.
New-Item -ItemType Directory -Path $LogFolder -Force -WhatIf:$false | Out-Null
$logFile = Join-Path $LogFolder ("onboarding_{0}.log" -f (Get-Date -Format "yyyyMMdd_HHmmss"))

function Write-Log {
    param([string]$Message)
    $line = "{0}  {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Write-Host $line
    Add-Content -Path $logFile -Value $line -WhatIf:$false
}

# Ask for the starting password. It stays a secure string and is never written anywhere.
$startPassword = Read-Host "Type the starting password for the new accounts" -AsSecureString

$created = 0; $preview = 0; $skipped = 0; $failed = 0
Write-Log "Start. CSV: $CsvPath. WhatIf: $WhatIfPreference"

foreach ($row in (Import-Csv -Path $CsvPath)) {
    $sam = $row.SamAccountName
    $fullName = "$($row.GivenName) $($row.Surname)"
    $ouDn = "OU=$($row.Department),$departmentsOu"

    # Check 1: the department OU must exist
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouDn'")) {
        Write-Log "ERROR    $sam  department OU not found: $($row.Department)"
        $failed++
        continue
    }

    # Check 2: the group must exist
    if (-not (Get-ADGroup -Filter "Name -eq '$($row.Group)'")) {
        Write-Log "ERROR    $sam  group not found: $($row.Group)"
        $failed++
        continue
    }

    # Check 3: skip anyone who already exists, so a second run creates nothing new
    if (Get-ADUser -Filter "SamAccountName -eq '$sam'") {
        Write-Log "SKIPPED  $sam  already exists"
        $skipped++
        continue
    }

    # Create the user and add them to the group, or only report it under WhatIf
    if ($PSCmdlet.ShouldProcess($sam, "Create in $($row.Department) and add to $($row.Group)")) {
        try {
            New-ADUser -Name $fullName -GivenName $row.GivenName -Surname $row.Surname `
                -DisplayName $fullName -SamAccountName $sam -UserPrincipalName "$sam@$domainName" `
                -Path $ouDn -AccountPassword $startPassword -ChangePasswordAtLogon $true `
                -Enabled $true -ErrorAction Stop
            Add-ADGroupMember -Identity $row.Group -Members $sam -ErrorAction Stop
            Write-Log "CREATED  $sam  in $($row.Department), member of $($row.Group)"
            $created++
        }
        catch {
            Write-Log "ERROR    $sam  $($_.Exception.Message)"
            $failed++
        }
    }
    else {
        Write-Log "WOULD CREATE  $sam  in $($row.Department), member of $($row.Group)"
        $preview++
    }
}

Write-Log "Finished. Created: $created. Would create: $preview. Skipped: $skipped. Errors: $failed."
Write-Log "Log file: $logFile"

# Scripts: 05 Onboarding automation

One script and one sample CSV, both run in the lab on UMNGA-DC1. The output of each run is in the evidence folder of the project.

## Rules for every script in this folder

1. Start with a comment header: purpose, author, what it changes, how to undo it.
2. Comment each block in plain language.
3. Never hard code a password or key. Use Get-Credential or Read-Host with a secure string.
4. Support the WhatIf switch wherever a command changes something.
5. Only commit scripts that I have run in the lab, with the output kept in the evidence folder.

## Files

1. New-UmngaStaff.ps1 reads a CSV of new staff, checks each row, creates the user in the right department OU, adds the user to the department group and forces a password change at first sign in. It supports -WhatIf, skips users that already exist, logs every line to a timestamped file, and ends with a summary.
2. umnga_new_staff.csv is the twelve row sample list I ran. All names are invented. Two rows are tests on purpose: dubel already exists from project 02, and nkosip names a department, Housing, that has no OU.

## How I ran it

On UMNGA-DC1, from C:\Scripts, in an elevated PowerShell window, with the starting password typed at the prompt:

```powershell
cd C:\Scripts
.\New-UmngaStaff.ps1 -WhatIf     # preview, changes nothing
.\New-UmngaStaff.ps1             # the real run
.\New-UmngaStaff.ps1             # a second run, creates nothing
```

The starting password is never stored in the script, the CSV or the log, and I did not record the password I used in this repository.

## How to undo it

`Remove-ADUser -Identity <SamAccountName>` removes an account the script created, and removing the account also removes its group membership. I did not run this. Run it with -WhatIf first, and check the CSV so that only accounts the script created are removed. I created the user dubel by hand in project 02, and the script never created it.

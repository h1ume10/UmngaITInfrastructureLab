# Troubleshooting log: 05 Onboarding automation

This log lists only what happened in the lab. No command failed with an unexpected error and nothing needed fixing. The two errors the script printed were planted on purpose. I wrote them up so a reader can see how I read each one and why the script behaved as it did.

## 1. A department that does not exist: ERROR on nkosip

1. Symptom: on every run the script printed "ERROR nkosip department OU not found: Housing", counted one error in the summary, and carried on with the next row.
2. Cause: the CSV row for Pat Nkosi names the department Housing and the group GG_Housing. Neither exists in umnga.local. I added the row to test the first check. The script looks up OU=Housing,OU=Departments,OU=Umnga,DC=umnga,DC=local, finds nothing, logs the error and does not try to create the user.
3. Fix: none was needed, because the script did what it was designed to do. To fix the row in real life, either correct the department in the CSV or create the OU and group first, then run again. The next run would create the user.
4. Takeaway: report a bad row and keep going. One bad row in a list should not stop the rest, and the summary line shows that something needs attention.

## 2. A user that already exists: SKIPPED on dubel

1. Symptom: the preview and the real run both printed "SKIPPED dubel already exists". The second run printed the same for all ten users created in the real run.
2. Cause: I created dubel (Lungile Dube, ICT) by hand in project 02, and I also put the user in the CSV on purpose. The check Get-ADUser by SamAccountName finds the account and the script skips it, so it does not try to create a second account or fail with a name clash.
3. Fix: none was needed. The summary counts these as Skipped.
4. Takeaway: the existence check is what makes the script safe to run twice. The second run shows it: Created 0, Skipped 11, user count still 17.

## 3. The preview prints two lines for each user

1. Symptom: in the WhatIf run, each of the ten users printed a "What if: Performing the operation" line from PowerShell and then a WOULD CREATE line from the script.
2. Cause: the first line is the built in output of ShouldProcess, and the second is the script's own log line. Both are expected.
3. Fix: none. I kept both lines, because the first is the standard PowerShell message and the second goes into the log.

## Observations, not faults

1. The log file name carries the time the script started, before the password was typed, so it is a few seconds earlier than the Start line. In the real run the file is onboarding_20261108_171842.log and the Start line is 17:18:49.
2. The three log files have different sizes, 1315, 1266 and 919 bytes, because the runs printed different lines. The preview run also wrote its log, because the log writes are exempt from WhatIf.
3. The title bars of the baseline, CSV and syntax screenshots read "Stage 3 before DHCP" on DC1, and the two effective access screenshots read "Stage 4 before script" on SVR1. These are snapshot labels that were current when I took the screenshots. I added no snapshot on SVR1, because nothing changed there.
4. The password prompt prints asterisks, one for each typed character, so a screenshot shows the length of the password and nothing else.
5. A File Explorer tooltip covers the end of the log file name in the WhatIf screenshot.
6. The PasswordLastSet value of khumalos is empty. That is how Active Directory shows an account whose password must be changed at the first sign in. I did not test it with a real sign in.

## Not recorded

1. The starting password, on purpose.
2. The contents of the three log files.
3. A screenshot of the user count of 7 after the preview run. It comes from pasted output.
4. The full Effective Access list for the two new users. Each screenshot shows six rows.
5. The PasswordLastSet value of the nine other new users.
6. A real sign in as a new user.

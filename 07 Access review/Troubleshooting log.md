# Troubleshooting log: 07 Access review

This log lists what went wrong or looked wrong in the lab, what caused it, and what I did. The first four entries are real faults I had to fix. The next three are things that surprised me and turned out to be normal or unexplained. After them are the observations I made and the things I did not record.

## 1. Six wrong passwords and no lockout: a typo in the logon name

1. Symptom: I sent six wrong passwords to the domain controller as UMNGA\lockoutt. All six returned system error 1326 (the user name or password is incorrect). The sixth did not return 1909, there was no 4740 event, and the account was not locked.
2. Cause: Get-ADUser lockoutt said the user was not found. A Get-ADUser -Filter on the display name showed the logon name had been saved as locoutt, one letter short. The wrong passwords went to a user that does not exist, so no account counted them. A query of the Security log showed 12 failed logon events (4625) in that period.
3. Fix: I renamed the logon name and the user principal name with Set-ADUser and repeated the six attempts. Five returned 1326 and the sixth returned 1909.
4. Takeaway: error 1326 does not tell you whether the user or the password is wrong. When a lockout does not happen, check that the account name exists before changing the policy.

## 2. runas /netonly on the domain controller, then a credential error for tauk

1. Symptom: testing as tauk failed twice with "Either the target name is incorrect or the server has rejected the client credentials", first with a runas /netonly window and then with Get-Credential.
2. Cause, part one: runas /netonly did not work on the domain controller itself, so it was the wrong method for that machine. Cause, part two, and the real one: Get-ADUser tauk showed PasswordExpired True and an empty PasswordLastSet. The Stage 5 script creates accounts with a forced password change at first sign in, and an account in that state cannot sign in over the network until the change is made.
3. Fix: I reset the password at a hidden prompt, cleared ChangePasswordAtLogon, and ran the test again with Get-Credential UMNGA\tauk and the -Server parameter. I did the same for dubel before his tests.
4. Takeaway: if a credential is refused for an account you never signed in with, read PasswordExpired and PasswordLastSet before suspecting the delegation. The forced change is correct for real new staff. It is a nuisance only for lab test users.

## 3. The Unlock proof was in the wrong place

1. Symptom: I expected BadLogonCount to be 0 after the account unlocked, and it stayed at 5.
2. Cause: the lock was not removed by anyone. At about 16:52 the 15 minute duration ran out and the account unlocked by itself. The counter of bad attempts is not cleared when the lock expires. I had predicted the wrong result.
3. Fix: I described that picture as proof of the duration and not of unlocking. The proof of unlocking is the delegated Unlock-ADAccount as tauk in step 5.
4. Takeaway: a locked account that is unlocked and a lock that expires look the same in LockedOut, and they differ in the event log and in the counter. Check the counter before claiming which one happened.

## 4. The Description column printed blank

1. Symptom: Get-ADGroup listed the three new groups with an empty Description column.
2. Cause: Description is not one of the properties Get-ADGroup returns by default, and the command did not ask for it with -Properties. A blank column was a display result and not proof that the field was empty.
3. Fix: none. I decided to leave the descriptions and did not read them back, so I make no claim about them.
4. Takeaway: an empty column in a table can mean "not requested". Add -Properties before drawing a conclusion.

## 5. UMNGA-CORE1 timed out once

1. Symptom: the first Invoke-Command against both servers returned the entries for UMNGA-SVR1 and a WinRM timeout for UMNGA-CORE1.
2. Cause: not diagnosed. About nine minutes later Test-NetConnection to port 5985 succeeded on both servers and the command returned both. I believe the server was starting or slow, but I did not confirm it.
3. Fix: I retried. No setting was changed.
4. Takeaway: a single timeout is a reason to retest the port, not to change WinRM.

## 6. Allow Administrator account lockout appeared by itself

1. Symptom: after I set the threshold, the editor showed a fourth setting, "Allow Administrator account lockout: Enabled", that I had not set.
2. Cause: not investigated. The setting appeared when I defined the threshold, and I take it to be a Windows Server 2025 setting. It means the built in Administrator can be locked out.
3. Fix: none. I recorded the setting, did not test it and listed it as a finding.
4. Takeaway: read every value in a policy window after you change it, and not only the one you meant to set.

## 7. A password length was visible in a screenshot

1. Symptom: in 07_step07_dubel_before_dc1.png the row of password stars showed that the password has 16 characters.
2. Cause: the password prompt of Get-Credential was captured while it was open.
3. Fix: I covered the row with a dark rectangle and cropped the picture to confirm it is hidden. No password text was ever visible.
4. Takeaway: a hidden prompt can still leak the length. Take the screenshot after the prompt is closed.

## Observations

1. The event 4740 screenshot first showed only the Subject section. I retook it so that the Account That Was Locked Out and Caller Computer Name are visible.
2. Phone photos of the screen were not used as evidence. Three were taken, and the VirtualBox screenshots replaced them.
3. The correct password test was run on UMNGA-DC1, not UMNGA-SVR1 as planned. The captions and the README say DC1.
4. Remote commands as dubel failed with Access is denied before the Group Policy applied and worked after it. That is the proof that the policy, and not an earlier right, gave him access.

## Not recorded

1. Whether the Description fields of the three new groups were saved.
2. A test of the Unlock account box in Active Directory Users and Computers.
3. A test that tauk can reset dubel's password, and a test that the helpdesk cannot reach OUs outside Departments.
4. The cause of the UMNGA-CORE1 timeout.
5. Logon, privilege use and object access audit settings, and the members of Print Operators.
6. Any test from a Windows 11 client.

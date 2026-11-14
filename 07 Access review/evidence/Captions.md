# Evidence captions: 07 Access review

All 28 files are in this folder. Each was checked for passwords, licence keys, tenant names, employer data and MAC addresses. None was found. In 07_step07_dubel_before_dc1.png the row of stars of a password prompt showed the length of the password, and it is covered with a dark rectangle. The title bars show the snapshot label "Stage 7 start". All names, accounts and passwords are invented lab data, and no password text appears in any image.

Every capture is headline evidence. The names follow the pattern project, step, subject and machine, so the last part tells you where the picture was taken.

Step 1: baseline

1. 07_step01_domain_admins_dc1.png: Active Directory Users and Computers on UMNGA-DC1, members of Domain Admins. One member, Administrator (umnga.local/Users).
2. 07_step01_builtin_administrators_dc1.png: members of the Builtin Administrators group on UMNGA-DC1: Administrator, Domain Admins and Enterprise Admins.
3. 07_step01_lockout_policy_before_dc1.png: the Default Domain Policy settings report on UMNGA-DC1. The Account Lockout Policy section lists only "Account lockout threshold: 0 invalid logon attempts", so accounts are never locked.

Step 2: role based security groups

4. 07_step02_groups_ou_dc1.png: the OU Groups on UMNGA-DC1 with the Group Scope and Group Type columns. Ten groups: the seven department groups and GG_ICT_Helpdesk and GG_ICT_ServerAdmins are Security Group Global, and DL_Servers_L... is Security Group Domain Local. The Description column is empty.
5. 07_step02_dl_servers_localadmins_members_dc1.png: the Members tab of DL_Servers_LocalAdmins. One entry, a group in umnga.local/Umnga/Groups starting GG_ICT_Serv.
6. 07_step02_group_membership_powershell_dc1.png: PowerShell on UMNGA-DC1. Get-ADGroup lists the three groups with GroupScope Global, Global and DomainLocal, all Security. The Description column is blank because the property was not requested.
7. 07_step02_group_membership2_powershell_dc1.png: Get-ADGroupMember lists Kagiso Tau (tauk) in GG_ICT_Helpdesk and Lungile Dube (dubel) in GG_ICT_ServerAdmins, and DL_Servers_LocalAdmins holding GG_ICT_ServerAdmins. The recursive list reaches Lungile Dube (dubel).

Step 3: the lockout policy

8. 07_step03_lockout_policy_set_dc1.png: the Group Policy Management Editor on UMNGA-DC1, Account Lockout Policy of the Default Domain Policy: Account lockout duration 15 minutes, Account lockout threshold 5 invalid logon attempts, Allow Administrator account lockout Enabled, Reset account lockout counter after 15 minutes.
9. 07_step03_lockout_policy_powershell_dc1.png: gpupdate /force at 16:08 completes for computer and user policy. Get-ADDefaultDomainPasswordPolicy shows LockoutThreshold 5, LockoutDuration 00:15:00 and LockoutObservationWindow 00:15:00.

Step 4: cause a lockout and trace it

10. 07_step04_wrong_attempts_svr1.png: PowerShell on UMNGA-SVR1 at 16:37. Six net use attempts against the address of the domain controller as UMNGA\lockoutt. Five return system error 1326 and the sixth returns system error 1909, the account is locked out.
11. 07_step04_locked_out_dc1.png: the Account tab of Test Lockout on UMNGA-DC1 at 16:38. "Unlock account. This account is currently locked out on this Active Directory Domain Controller", with the box not ticked.
12. 07_step04_event_4740_dc1.png: Event Viewer, Security log on UMNGA-DC1, event 4740 at 2026/11/14 16:37:15. Account That Was Locked Out UMNGA\lockoutt, Caller Computer Name UMNGA-SVR1.
13. 07_step04_lockout_powershell_dc1.png: PowerShell on UMNGA-DC1 at 16:49. Search-ADAccount -LockedOut lists Test Lockout as locked. The Get-WinEvent query for 4740 returns one row: 16:37:15, lockoutt, UMNGA-SVR1. A separate check shows BadLogonCount 5.
14. 07_step04_unlocked_dc1.png: PowerShell on UMNGA-DC1 at 16:53. Search-ADAccount -LockedOut returns nothing and Get-ADUser shows LockedOut False and BadLogonCount 5. The lock ran out by itself at about 16:52, so it shows the 15 minute duration and does not show an administrator unlocking.
15. 07_step04_correct_password_dc1.png: PowerShell on UMNGA-DC1 at 16:54. net use with the correct password, typed at a hidden prompt, reports "The command completed successfully". This was run on UMNGA-DC1, not on UMNGA-SVR1.

Step 5: give the helpdesk the right to unlock

16. 07_step05_delegation_wizard_dc1.png: the Delegation of Control wizard on OU Departments for GG_ICT_Helpdesk. Property specific and General are ticked, and Read lockoutTime and Write lockoutTime are ticked in the list.
17. 07_step05_helpdesk_unlock_dc1.png: PowerShell on UMNGA-DC1 at 17:10, with the credential of UMNGA\tauk. Search-ADAccount -LockedOut lists lockoutt as locked. Unlock-ADAccount prints nothing. A second search prints nothing. Add-ADGroupMember "Domain Admins" -Members tauk fails with "Insufficient access rights to perform the operation", and Domain Admins still lists only Administrator.

Step 6: who holds power

18. 07_step06_privileged_groups_dc1.png: PowerShell on UMNGA-DC1 at 17:12. Domain Admins, Enterprise Admins, Schema Admins and Administrators have 1 member each, Administrator. Account Operators, Server Operators and Backup Operators have 0.
19. 07_step06_local_admins_gui_svr1.png: Computer Management on UMNGA-SVR1 at 17:17, the local Administrators group: Administrator and UMNGA\Domain Admins.
20. 07_step06_local_administrators_dc1.png: PowerShell on UMNGA-DC1 at 17:23. Invoke-Command lists the local Administrators of both servers: UMNGA\Domain Admins (Group) and the local Administrator (User) on UMNGA-SVR1 and UMNGA-CORE1.

Step 7: local administrators by Group Policy

21. 07_step07_dubel_before_dc1.png: PowerShell on UMNGA-DC1 at 17:26. Invoke-Command as dubel against UMNGA-SVR1 fails with "Connecting to remote server UMNGA-SVR1 failed with the following error message : Access is denied". The password stars are covered.
22. 07_step07_gpo_local_group_dc1.png: the Local Group item in the GPO Umnga Servers Local Admins at 17:33: Action Update, Group name Administrators (built-in), member UMNGA\DL_Servers_LocalAdmins with Action Add to this group.
23. 07_step07_local_administrators_after_dc1.png: PowerShell on UMNGA-DC1 at 17:36 after gpupdate /force on both servers. Each server lists three local administrators: UMNGA\DL_Servers_LocalAdmins, UMNGA\Domain Admins and its own Administrator.
24. 07_step07_dubel_after_dc1.png: at 17:37 Invoke-Command as dubel returns umnga\dubel and UMNGA-SVR1, then umnga\dubel and UMNGA-CORE1.

Step 8: user rights

25. 07_step08_user_rights_gui_svr1.png: Local Security Policy on UMNGA-SVR1, User Rights Assignment, Allow log on locally: Administrators, Backup Operators and Users.
26. 07_step08_user_rights_dc1.png: PowerShell on UMNGA-DC1. The secedit user rights of the three machines with the SIDs translated to names: log on locally, log on through Remote Desktop Services, back up, restore, debug programs, take ownership and shut down.

Step 9: who changed the groups

27. 07_step09_audit_policy_dc1.png: auditpol /get /category:"Account Management" on UMNGA-DC1 at 17:51. Security Group Management, User Account Management and Computer Account Management are set to Success. Distribution Group Management, Application Group Management and Other Account Management Events read No Auditing.
28. 07_step09_group_change_events_dc1.png: Get-WinEvent for events 4728 and 4729 at 17:54. Four rows: a 4729 and a 4728 at 17:53:49 and 17:53:39 for Test Lockout and GG_ICT_Helpdesk, and two 4728 rows at 15:30:03 and 15:29:44 for Lungile Dube and Kagiso Tau. ChangedBy reads Administrator on all four.

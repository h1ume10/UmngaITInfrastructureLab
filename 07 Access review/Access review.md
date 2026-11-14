# Umnga Access Review

Umnga Local Municipality, ICT. Reviewed on 14 November 2026 in the lab domain umnga.local (UMNGA-DC1, UMNGA-SVR1, UMNGA-CORE1). Every statement below was read from the lab and is shown in the evidence screenshots listed in the [project README](README.md). All names are invented.

## Summary

1. Power in the domain sits in one account. Domain Admins, Enterprise Admins and Schema Admins each have one member, the Administrator, and every group change I made was logged under that name. The log cannot say which person acted.
2. The domain now locks an account after 5 wrong passwords for 15 minutes. Before this review the threshold was 0, so nothing was ever locked and guessing was unlimited.
3. A helpdesk group can unlock accounts and reset passwords on the department OUs, and cannot change group membership. I proved both.
4. A server admin group is a local administrator on UMNGA-SVR1 and UMNGA-CORE1 by Group Policy. I proved it with a before and after test.
5. The main finding: the helpdesk's right to reset passwords reaches the ICT OU, where the server admin account lives. That is a path from helpdesk to server admin. I read it from the design and did not test it.

## Who holds power

| Where | Group | Members | Source |
|---|---|---|---|
| Domain | Domain Admins | Administrator | Step 6 |
| Domain | Enterprise Admins | Administrator | Step 6 |
| Domain | Schema Admins | Administrator | Step 6 |
| Domain | Administrators (Builtin) | Administrator | Step 6 |
| Domain | Account Operators | none | Step 6 |
| Domain | Server Operators | none | Step 6 |
| Domain | Backup Operators | none | Step 6 |
| UMNGA-SVR1 | local Administrators | UMNGA\DL_Servers_LocalAdmins, UMNGA\Domain Admins, UMNGA-SVR1\Administrator | Step 7 |
| UMNGA-CORE1 | local Administrators | UMNGA\DL_Servers_LocalAdmins, UMNGA\Domain Admins, UMNGA-CORE1\Administrator | Step 7 |

The Administrator on each server is a local account of that server. There are three shared Administrator accounts in the lab: the domain one, the one on UMNGA-SVR1 and the one on UMNGA-CORE1.

## Role groups

| Group | Scope | Members | Purpose |
|---|---|---|---|
| GG_ICT_Helpdesk | Global | tauk | Unlock accounts and reset passwords on OU Departments |
| GG_ICT_ServerAdmins | Global | dubel | Local administrator on the member servers |
| DL_Servers_LocalAdmins | Domain local | GG_ICT_ServerAdmins | The one entry the Group Policy adds to the local Administrators group |

The pattern is accounts into global groups, global groups into a domain local group, and the permission to the domain local group. A person who changes role moves between global groups and no permission list changes.

## Lockout policy

| Setting | Value |
|---|---|
| Account lockout threshold | 5 invalid logon attempts |
| Account lockout duration | 15 minutes |
| Reset account lockout counter after | 15 minutes |
| Allow Administrator account lockout | Enabled (appeared when I set the threshold, not tested) |

Set in the Default Domain Policy. Proven with an invented account: five wrong passwords returned error 1326, the sixth returned error 1909 (account locked out).

## When a user says they are locked out

1. On UMNGA-DC1 run Search-ADAccount -LockedOut to see whether the account is really locked.
2. Read the lockout event to find the computer that caused it:

```powershell
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4740} -MaxEvents 3 | Select-Object TimeCreated, @{n='Account';e={$_.Properties[0].Value}}, @{n='CallerComputer';e={$_.Properties[1].Value}} | Format-Table -AutoSize
```

3. Unlock only after the cause is fixed. If the caller computer is the user's own PC, look for a saved old password there, such as a mapped drive, a phone or a service. If the caller is a machine the user does not own, treat it as a possible attack and tell the ICT manager.
4. The helpdesk unlocks with Unlock-ADAccount (tested as tauk with a credential and the DC1 server name). Waiting 15 minutes also works, because the lock expires by itself.
5. A wrong logon name does not lock anything. Error 1326 against a user that does not exist leaves no lockout and no event 4740. Check the spelling of the logon name before suspecting an attack.

## What each right allows

| Right | Who holds it | Source |
|---|---|---|
| Log on locally, servers | Administrators, Users, Backup Operators | Step 8 |
| Log on locally, DC1 | Administrators, Account Operators, Server Operators, Print Operators, Backup Operators, domain controllers group | Step 8 |
| Log on through Remote Desktop Services | CORE1: Administrators, Remote Desktop Users. DC1: Administrators. SVR1: Authenticated Users, Administrators, Remote Desktop Users | Step 8 |
| Back up and restore files | Administrators, Backup Operators (and Server Operators on DC1) | Step 8 |
| Debug programs, take ownership | Administrators only, on all three | Step 8 |
| Shut down the system | Administrators, Backup Operators (and Server Operators, Print Operators on DC1) | Step 8 |

These are the Windows defaults. I did not change any of them.

## Findings and recommendations

1. High: the helpdesk can reset the password of the server admin. GG_ICT_Helpdesk can reset passwords on OU Departments, and dubel sits in OU ICT, under it. Whoever can reset dubel's password can sign in as dubel and become a local administrator on both servers. Recommended fix: keep admin accounts in a separate OU the helpdesk has no rights on, and delegate password resets only on staff OUs. Not tested.
2. High: one shared Administrator for every admin job. The audit trail names the Administrator for every change. Recommended fix: a named admin account for each person who administers, separate from the daily account, and a protected, rarely used break glass Administrator.
3. Medium: Allow Administrator account lockout is Enabled. With a single admin account, a few guesses from any machine can lock the domain Administrator for 15 minutes. Recommended fix: name admin accounts first, alert on event 4740 for admin accounts, and decide with the ICT manager whether to keep the setting.
4. Medium: the lockout policy sits in the Default Domain Policy. Recommended fix: a separate GPO linked to the domain with a higher link order, so the default policy stays untouched.
5. Medium: Users may log on locally on both member servers, and on UMNGA-SVR1 Authenticated Users may sign in through Remote Desktop Services. Any domain user may be able to sign in at the server console or over a Remote Desktop connection. Recommended fix: remove Users from the local sign in right on servers and confirm what the RDS role added. The RDS collection is a separate control and was not retested.
6. Low: audit coverage stops at account management. Logon events, privilege use and object access were not enabled or read. Recommended fix: enable and forward them to one place.
7. Low: the review covers three machines, one test account and two role users. A real review repeats this for every server and for the Windows 11 client, which the lab does not have yet.

## Not covered

1. Whether the helpdesk can in fact reset dubel's password (finding 1 is from the design).
2. The delegated password reset, tested as tauk. I reset the passwords of tauk and dubel as Administrator.
3. The Unlock account box in Active Directory Users and Computers.
4. Print Operators membership, logon event auditing, a Windows 11 client.

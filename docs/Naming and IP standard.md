# Umnga naming and IP standard

Status: in use. I applied it to the three servers in project 01 and extended it in each later project. Each section below says which project added it.
Maintained by: ICT unit, Umnga Local Municipality (fictional)

## Naming pattern

UMNGA, then a role code, then a number. Letters in capitals. Maximum 15 characters, so the name is valid as a NetBIOS name.

Role codes:

1. DC for domain controllers
2. SVR for general member servers
3. CORE for Server Core member servers
4. PRN for network printers (UMNGA-PRN1 exists only as a DNS record in the lab)
5. TMP for a temporary test machine (UMNGA-TMP1 was a Windows Setup environment used once in project 03, never installed or joined to the domain)

Names in use: UMNGA-DC1, UMNGA-SVR1, UMNGA-CORE1.

## Network

1. Network name in VirtualBox: UmngaNet (Internal Network)
2. Address range: 192.168.20.0/24, mask 255.255.255.0
3. Domain: umnga.local, NetBIOS name UMNGA (built in project 02)
4. Default gateway: none, because UmngaNet has no router
5. DNS: 192.168.20.10 (UMNGA-DC1) on every member server. The domain controller uses itself. No second DNS server is listed.

## Address plan

1. 192.168.20.1 to .9: reserved for network equipment and future infrastructure
2. 192.168.20.10: UMNGA-DC1
3. 192.168.20.11: UMNGA-SVR1
4. 192.168.20.12: UMNGA-CORE1
5. 192.168.20.13 to .49: reserved for future servers
6. 192.168.20.50 to .99: reserved for other static devices. 192.168.20.50 is used by the DNS record UMNGA-PRN1, which stands in for a printer. No device exists.
7. 192.168.20.100 to .199: DHCP scope Umnga Staff Devices on UMNGA-SVR1 (built in project 03). The first lease, 192.168.20.100, went to the temporary test client.
8. 192.168.20.200 to .254: spare

## Active Directory naming (project 02, phase A)

1. Top OU: Umnga. Its children are Departments, Servers and Groups.
2. Department OUs are named exactly as the department: Municipal Manager Office, Finance, Corporate Services, Community Services, Technical Services, Planning and Economic Development, ICT.
3. Security groups: GG_ followed by the department without spaces, type Security, scope Global. The seven in use are GG_MunicipalManagerOffice, GG_Finance, GG_CorporateServices, GG_CommunityServices, GG_TechnicalServices, GG_PlanningEconomicDev and GG_ICT.
4. User logon name: surname followed by the first initial, in lower case, for example ndlovut. If two people would share a name, add a number. All users in the lab are invented.
5. Passwords: each new account gets a temporary password with a forced change at first logon. Passwords are never written in this document or anywhere in the repository.
6. DNS records: only for devices that cannot register themselves. Aliases (CNAME) are lower case and describe the function, for example dns.

## Group Policy naming (project 02, phase B)

1. GPO names follow the pattern Umnga, then the target, then the purpose, in title case. Example in use: Umnga Servers Logon Notice.
2. A GPO is linked only to the OU it is meant for. The domain link is kept for the Default Domain Policy.
3. I do not edit the Default Domain Policy or the Default Domain Controllers Policy. Changes go in new GPOs, with one exception: the account lockout policy in project 07 (see Access review naming).

## Core services naming (project 03)

1. DHCP scope names: Umnga followed by the purpose in title case. Example in use: Umnga Staff Devices.
2. DHCP options in use: 006 DNS Servers 192.168.20.10 and 015 DNS Domain Name umnga.local. No router option, because UmngaNet has no gateway.
3. Reverse zone: 20.168.192.in-addr.arpa, with PTR records for every static server.
4. DNS aliases (CNAME): lower case and named for the function, never for the server. In use: dns and intranet. The alias intranet points to UMNGA-SVR1.umnga.local.
5. Internal pages use the file name index.html in the default content folder.
6. In the lab, UMNGA-SVR1 hosts DHCP, IIS and Remote Desktop Services. A real organisation would spread these roles.
7. The RDS collection is QuickSessionCollection. Access to it is given to the group GG_ICT only.

## Storage and file server naming (project 04)

1. Extra virtual disk files for UMNGA-SVR1 are named SVR1_pool followed by a number, for example SVR1_pool1. One file was replaced and is named SVR1_pool3b.
2. Storage pool: Umnga Pool. Virtual disk: Departments, a mirror, thin provisioned. Volume label: Departments, NTFS, drive letter E:. The CD drive keeps D:.
3. Department folders sit in the root of E: and are named exactly as the department without spaces, which is also the part of the group name after GG_. The seven in use are MunicipalManagerOffice, Finance, CorporateServices, CommunityServices, TechnicalServices, PlanningEconomicDev and ICT.
4. Each folder is shared under its own folder name, with access based enumeration on. The share permission stays broad (Everyone, Full control in the lab) and NTFS does the restricting.
5. NTFS permissions are granted to the group GG_ plus the department name, never to a person. The group gets Modify on its own folder. SYSTEM and Administrators stay on every folder. Inheritance is turned off, and Users and Authenticated Users are removed.
6. The built in administrative share E$ exists because Windows creates one for every drive. It is not a department share.
7. The File Server role service (FS-FileServer) runs on UMNGA-SVR1 in the lab. A real organisation would put it on its own server.

## Script and CSV naming (project 05)

1. Scripts use PowerShell Verb-Noun names with the Umnga prefix in the noun, for example New-UmngaStaff.ps1. They live in C:\Scripts on the server that runs them and in the scripts folder of the project in the repository.
2. The input list is a CSV named umnga_new_staff.csv with the header GivenName, Surname, SamAccountName, Department and Group. The Department value must match the name of an OU under OU=Departments,OU=Umnga exactly, and the Group value must match a GG_ group exactly. Only invented names go in the sample file.
3. A user SamAccountName is the surname followed by the first letter of the given name, in lower case, for example khumalos. The user principal name is the SamAccountName followed by @umnga.local. The display name is the given name and surname.
4. Logs go to C:\Scripts\logs. Each run writes a file named onboarding_ followed by the date and time as yyyyMMdd_HHmmss and the extension .log. Logs never contain passwords.
5. The starting password is typed at a prompt on every run. It is never stored in a script, a CSV, a log or this repository.

## Server care naming (project 06)

1. A temporary NAT adapter is called Ethernet 2 inside Windows and Adapter 2 in VirtualBox. It goes on one member server only, never on the domain controller. It does not register in DNS, and it is removed when the job is done. Its address, 10.0.3.15, is the VirtualBox default and is not part of UmngaNet.
2. Firewall rules created by ICT start with Umnga, then the service and the source, for example Umnga Intranet HTTP from UmngaNet. The built in rules keep their Windows names.
3. The Event Viewer custom view is named Umnga Errors and Warnings.
4. The backup disk is a virtual disk file named UMNGA-SVR1-backup.vdi, 3 GB, dynamically allocated. Inside Windows it is drive F:, NTFS, volume label UmngaBackup.
5. The test folders are C:\UmngaBackupTest for backup and restore, and C:\EicarTest for the antivirus test. The EICAR folder is removed straight after the test. Both hold only invented content.
6. Servers take their time from UMNGA-DC1, which the care routine checks with w32tm.

## Access review naming (project 07)

1. Role groups: GG_ICT_ followed by the role, global scope, type Security, held in OU Groups. In use: GG_ICT_Helpdesk and GG_ICT_ServerAdmins. They hold accounts and nothing else.
2. Domain local groups: DL_ followed by the target and the right, domain local scope, type Security, held in OU Groups. In use: DL_Servers_LocalAdmins. It receives global groups and is the only name that a permission or a Group Policy item points to.
3. The pattern is accounts into global groups, global groups into a domain local group, permission to the domain local group. A person who changes role moves between global groups.
4. GPO in use: Umnga Servers Local Admins, linked to OU Servers. It uses a Group Policy Preferences local group item with the action Update and adds DL_Servers_LocalAdmins to the local Administrators group. I do not use Restricted Groups for this, because it replaces the whole membership.
5. Account lockout policy, set in the Default Domain Policy as the one exception to the rule above, because domain account policies apply only from a GPO linked to the domain: threshold 5, duration 15 minutes, reset counter 15 minutes. A separate GPO with a higher link order is planned.
6. Delegation: GG_ICT_Helpdesk may reset user passwords and read and write lockoutTime on user objects in OU Departments. It has no right on group membership.
7. Test account: lockoutt (Test Lockout) in OU ICT, invented and temporary. A test never uses the built in Administrator.
8. The role users tauk (helpdesk) and dubel (server admin) are the lab's invented stand ins. Named admin accounts for each administrator are planned and do not exist yet.

## Snapshots

1. I take a snapshot only after a state is checked, and name it after the state, for example "Stage1 baseline clean".
2. A snapshot taken before a risky change is named "Stage N before" followed by the change, for example "Stage 3 before DHCP", "Stage 6 before NAT" or "Stage 6 before updates". N is the build step in the order I built the lab. The VM title bar shows the current snapshot name, so these names appear in some screenshots.
3. A snapshot taken after a stage is checked is named "Stage N verified". Project 07 screenshots show "Stage 7 start", the state before the access review, and the checked state is "Stage 7 verified".

## Rules

1. Every server gets a static address from this plan before it joins anything.
2. A new address is added to this document before it is used.
3. A new OU, group pattern, GPO name pattern, scope name or record type is added to this document before it is used.
4. No passwords, keys or personal data are recorded in this document.

## Names that keep their punctuation

Hostnames (UMNGA-DC1), cmdlet and script names (New-UmngaStaff.ps1), file names that appear on screen (umnga_new_staff.csv, onboarding logs) and VirtualBox snapshot names are kept exactly as they appear in the lab. The repository folders and documents are named in plain words with spaces.

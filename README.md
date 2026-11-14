# Umnga IT Infrastructure Lab

A small Windows Server 2025 environment for a made up municipality, built in a personal VirtualBox lab. Each project adds a layer on top of the one before: servers, directory and policy, everyday services, file storage, automation, server care and access control. Every README records what I built, why I chose it, what I saw, and what I did not test.

Umnga Local Municipality is fictional. It has about 60 office staff in seven departments: Municipal Manager's Office, Finance, Corporate Services, Community Services, Technical Services, Planning and Economic Development, and ICT. It is not based on any real municipality. The domain is umnga.local (NetBIOS name UMNGA). No employer systems, tenants or data are used anywhere in this repository, and every person in it is invented.

## What exists now

Three servers on an isolated network, one domain, seven departments with their own groups and file shares, a PowerShell script that onboards new staff from a CSV file, a care routine for the file server that covers updates, logs, performance, firewall, antivirus and backup, and an access review with role groups, an account lockout policy and a report of who holds admin rights. The domain holds 18 users. All seven projects are complete.

## Architecture

```mermaid
flowchart TB
    subgraph NET["UmngaNet internal network 192.168.20.0/24"]
        DC1["UMNGA-DC1 192.168.20.10 domain controller, AD DS, DNS and reverse zone"]
        SVR1["UMNGA-SVR1 192.168.20.11 member server, DHCP, IIS, RDS and file server"]
        CORE1["UMNGA-CORE1 192.168.20.12 Server Core member server"]
        TMP1["UMNGA-TMP1 temporary test client, Setup environment, switched off"]
    end
    subgraph AD["Domain umnga.local, NetBIOS name UMNGA"]
        UM["OU Umnga"]
        DEP["OU Departments: 7 department OUs, 18 users"]
        SRV["OU Servers"]
        GRP["OU Groups: 9 GG_ groups and 1 DL_ group"]
        UM --> DEP
        UM --> SRV
        UM --> GRP
        GPO["GPO: Umnga Servers Logon Notice"]
        GPO -->|"linked to"| SRV
        GPO2["GPO: Umnga Servers Local Admins"]
        GPO2 -->|"linked to"| SRV
        LOCK["Default Domain Policy: lockout after 5 attempts for 15 minutes"]
        UM -.->|"applies to the domain"| LOCK
    end
    DC1 -->|"hosts directory"| UM
    DC1 -.->|"5 FSMO roles"| AD
    SVR1 -->|"joined, computer account in"| SRV
    CORE1 -->|"joined, computer account in"| SRV
    SVR1 -.->|"DNS 192.168.20.10"| DC1
    CORE1 -.->|"DNS 192.168.20.10"| DC1
    SVR1 -->|"DHCP scope .100 to .199 lends a lease"| TMP1
    GRP -.->|"GG_ICT may use RDS"| SVR1
    DC1 -->|"intranet and RDP"| SVR1
    subgraph STOR["Storage on UMNGA-SVR1"]
        POOL["Umnga Pool: three 5 GB virtual disks"]
        VD["Virtual disk Departments: mirror, thin, 5 GB"]
        VOL["Drive E: NTFS, seven department folders, each shared by name"]
        POOL --> VD
        VD --> VOL
    end
    SVR1 -->|"hosts"| POOL
    GRP -.->|"each GG_ group has Modify on its own folder"| VOL
    subgraph SCR["Onboarding on UMNGA-DC1, C:\Scripts"]
        PS1["New-UmngaStaff.ps1: WhatIf preview, checks, skip existing, log"]
        CSV["umnga_new_staff.csv: 12 invented rows"]
        LOG["logs: one timestamped log for each run"]
        CSV --> PS1
        PS1 --> LOG
    end
    DC1 -->|"hosts"| PS1
    PS1 -->|"creates 10 users in their OUs and adds each to its GG_ group"| DEP
    subgraph CARE["Server care on UMNGA-SVR1"]
        FW["Firewall rule: port 80 only from 192.168.20.0/24, Domain profile"]
        DEF["Microsoft Defender: real time protection, EICAR test detected"]
        BKP["Drive F: 3 GB backup disk, Windows Server Backup, one file restored"]
    end
    SVR1 -->|"protected by"| FW
    SVR1 -->|"scanned by"| DEF
    SVR1 -->|"backed up to"| BKP
    subgraph ACC["Access review"]
        HD["GG_ICT_Helpdesk: unlock accounts and reset passwords on OU Departments"]
        SA["GG_ICT_ServerAdmins"]
        DL["DL_Servers_LocalAdmins"]
        SA -->|"member of"| DL
    end
    DL -->|"added to local Administrators by GPO"| SVR1
    DL -->|"added to local Administrators by GPO"| CORE1
    HD -.->|"delegated on"| DEP
```

## Projects

| No. | Project | What it delivers |
|---|---|---|
| 01 | [IT foundation](01%20IT%20foundation) | Three named, addressed and baselined servers and a naming and IP standard |
| 02 | [Identity and policy](02%20Identity%20and%20policy) | A domain with DNS, OUs, groups, users, a logon notice policy and a read of the FSMO roles |
| 03 | [Core services](03%20Core%20services) | Reverse DNS, DHCP, an internal web page and Remote Desktop Services for the ICT group |
| 04 | [Departmental file server](04%20Departmental%20file%20server) | A mirrored storage pool and seven department shares locked down with NTFS |
| 05 | [Onboarding automation](05%20Onboarding%20automation) | A PowerShell script that creates new staff from a CSV, safely and repeatably |
| 06 | [Server care routine](06%20Server%20care%20routine) | A routine for updates, logs, performance, firewall, Defender and backup, with a restore test |
| 07 | [Access review](07%20Access%20review) | Role groups, an account lockout policy, a delegated unlock right and a report of who holds admin rights |

All seven projects share the [naming and IP standard](docs/Naming%20and%20IP%20standard.md), which grew with them.

## The story so far

### 01 IT foundation

ICT started with rules before machines. I wrote a naming and IP standard, then built three servers to follow it: UMNGA-DC1 and UMNGA-SVR1 with the full desktop, and UMNGA-CORE1 as a Server Core machine with no desktop. Each got a fixed address on UmngaNet, the South African time zone and a clean snapshot. The first problems were a VM attached to the wrong network, a firewall that blocks ping by default, and a menu tool that did not apply an address. I diagnosed and logged each one.

### 02 Identity and policy

UMNGA-DC1 became the first domain controller of umnga.local, with DNS on the same server. The directory follows the municipality: a top OU called Umnga, one OU for each department, and places for servers and groups. Each department has a global security group and an invented user, so permissions can later go to groups instead of people. Both member servers joined the domain. One Group Policy Object, a legal notice shown at sign in, is linked to the Servers OU only, and gpresult and the sign in screen show it arrived. With one domain controller, DC1 holds all five FSMO roles. The lab keeps umnga.local, and the README explains why a real organisation would choose differently.

### 03 Core services

A reverse lookup zone closed a gap in the DNS. UMNGA-SVR1 became the DHCP server for 192.168.20.100 to .199, authorised in the directory. To test it, I booted a temporary machine into Windows Setup without installing it, and it received the first address in the pool. IIS publishes an internal page that staff reach as intranet. Remote Desktop Services lets the ICT group, and only that group, open a session on the server. Two sign in errors are logged, one diagnosed and one not.

### 04 Departmental file server

I pooled three small virtual disks with Storage Spaces and made a mirrored, thin provisioned disk from them, formatted as drive E:. The console wizards offered only one of the three disks, so PowerShell finished the job. Each of the seven departments has a folder and a share. The real lock is NTFS: inheritance is off, the broad entries are removed, and only that department's group has Modify. A check with the Effective Access tab showed that a Finance user could change files in the Finance folder and a Planning user could not open it. That was a calculation and not a real sign in. A mirror on one laptop drive shows the design and protects nothing.

### 05 Onboarding automation

Creating accounts was the most repeated job, so I turned it into a script. New-UmngaStaff.ps1 reads a CSV of new staff. For each row it checks that the department OU and group exist and that the user does not, then creates the user, adds the user to the department group and forces a password change at first sign in. It previews with WhatIf, skips existing users, reports a bad row and carries on, and writes a timestamped log. I tested it with a twelve row list that held one existing user and one department that does not exist. The preview said it would create ten, the real run created ten, and the second run created none and skipped eleven. The directory then held 17 users.

### 06 Server care routine

A server that nobody looks after fails in quiet ways, so I wrote down what to look at on UMNGA-SVR1 and proved each check once. Updates came through a temporary NAT card that I removed afterwards. I built a custom view in Event Viewer and found where Windows records an update install. A baseline only counted when the server was idle, which took a long wait for Windows to finish servicing, and I kept the busy captures to show the difference. The built in web rule was open to every address, so I replaced it with one that only accepts UmngaNet, and proved it both ways. Defender caught the EICAR test string and left events 1116 and 1117. Windows Server Backup copied a test folder to a separate disk, and a file I deleted on purpose came back with its text. The README is honest about what is missing: one cumulative update I never saw installed, a backup on the same laptop, and several events I did not diagnose.

### 07 Access review

Two questions kept landing on ICT: why are staff locked out, and who holds powerful rights on the servers? At the start the domain never locked an account, because the threshold was 0, and every admin job was done as one shared Administrator. I built role groups in the pattern accounts, global groups, a domain local group, permission, and set a lockout policy of 5 attempts and 15 minutes. A typo in a test account's logon name taught me that error 1326 does not tell you whether the user exists, and the corrected test locked the account on the sixth try and event 4740 named the computer that caused it. I delegated unlock and password reset on the department OUs to a helpdesk group, and the helpdesk account could unlock a user and could not add itself to Domain Admins. A Group Policy Preferences item made a server admin group a local administrator on both servers, and a before and after test showed the change. I then read out who holds admin rights and sign in rights on all three machines, and showed that group changes are logged but every one is logged as the shared Administrator. The main finding is that the helpdesk's password reset reaches the OU where the server admin account lives. I did not test that path.

## How each project is laid out

Every project folder has the same parts:

1. README.md: the scenario, objectives, the state at the end, design decisions with reasons, build steps with what I saw, verification and limitations
2. evidence: screenshots and a captions file
3. Troubleshooting log.md: what broke, what caused it, how I fixed it, and what I did not record
4. scripts: only where I wrote and ran a script (project 05)
5. a one page deliverable where the project ends in a routine or a report (projects 06 and 07)

Each README has a Limitations section. I list what I did not test, such as a real sign in or a failed mirror disk, and I do not let a calculation or a console view stand in for a test.

## Planned follow ups

1. Test DHCP, the department shares and a new user sign in from a Windows 11 client, which does not exist in the lab yet.
2. Patch and back up UMNGA-DC1 and UMNGA-CORE1 with the same routine, and move the backup copy off the laptop.
3. Find out what the Kernel-Boot and Hyper-V events mean before the Hyper-V project.
4. Move admin accounts to an OU the helpdesk cannot reach, and test that a helpdesk account cannot reset their passwords.
5. Create named admin accounts for each administrator, and keep the shared Administrator as a protected break glass account.
6. Move the lockout policy into its own GPO, and remove Users from the local sign in right on the member servers.
7. Enable and read logon and privilege use auditing, and send the logs to one place.

## Safety rules for this repository

1. No passwords, licence keys, employer data or personal data.
2. I blur or crop screenshots before I commit them.
3. Evaluation media only. No product keys appear anywhere.
4. Any later cloud work uses a free or trial test tenant only.

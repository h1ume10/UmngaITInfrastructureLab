# 06 Server care routine: updates, logs, performance, firewall, Defender and backup

Status: complete (14 November 2026)
Deliverable: [Umnga Server Care Routine](Server%20care%20routine.md)
Builds on: [04 Departmental file server](../04%20Departmental%20file%20server), [03 Core services](../03%20Core%20services)

## Scenario

By now UMNGA-SVR1 does a lot. It leases addresses, serves the intranet page, lets the ICT group open remote sessions and holds the department shares. Nothing in the lab looks after it. A patch can go stale, a service can fail on every boot, a process can eat the processor, a port can stay open to the whole network, the antivirus can be switched off and nobody finds out until the day a disk dies and there is no copy. ICT wants one short routine that says what to look at, what normal looks like on this server, and where the evidence is. I built the routine by doing each job once on UMNGA-SVR1 and keeping what I saw.

## Objectives

1. Check the update state, give the server internet for a short time, install updates and read the history afterwards.
2. Read the Windows logs, build a custom view of errors and warnings, and find the update events.
3. Record what a busy server and a quiet server look like with Task Manager, Resource Monitor, Performance Monitor and Get-Counter.
4. Read the firewall profiles, and replace the broad web rule with one that only accepts the Umnga network.
5. Confirm Microsoft Defender Antivirus is on and prove it detects a threat with the harmless EICAR test string.
6. Back up a folder to a separate disk with Windows Server Backup, delete a file on purpose and restore it.
7. Remove the temporary internet connection and check DNS is clean.

## State at the end of the project

1. UMNGA-SVR1 runs Windows Server 2025 Standard Evaluation, build 26100. The .NET Framework security update KB5127690 was installed on 8 November, and the update history lists one quality update, two definition updates and one other update. The monthly cumulative security update KB5126646 was offered at the same time, but I never saw it listed as installed (see Limitations).
2. The Event Viewer custom view Umnga Errors and Warnings held 67 events when I looked. A one line PowerShell query groups the recurring problem events by ID.
3. A quiet baseline for UMNGA-SVR1 with 2 virtual processors and 4 GB of memory: Task Manager 0% CPU, 1,7 of 4,0 GB memory in use (42%), 0% disk. Performance Monitor averaged 4,1% CPU over 1 minute 40 seconds. Six Get-Counter samples gave 7,4% to 18,9% CPU, about 2,25 GB of memory available, and disk time between 0,00% and 0,06%.
4. All three firewall profiles are on. The built in rule World Wide Web Services (HTTP Traffic-In) is disabled. A new rule, Umnga Intranet HTTP from UmngaNet, allows TCP port 80 only from 192.168.20.0/24 on the Domain profile. From UMNGA-DC1 the port test succeeded and the web request returned 200. With the rule pointed at the wrong subnet, the same test failed.
5. Defender is running with real time protection on and definitions 0 days old. The EICAR test string written to C:\EicarTest\eicar.txt was detected at 12:46:11 and quarantined at 12:46:35. I removed the test folder.
6. The temporary NAT adapter is gone. Ethernet 2 was disabled in Windows on 14 November and unticked in the VM settings. DNS holds one A record for UMNGA-SVR1, 192.168.20.11.
7. UMNGA-SVR1 has a new 3 GB virtual disk, drive F:, label UmngaBackup. One backup of C:\UmngaBackupTest was taken at 14:12:56 with result code 0. A file deleted at 14:24 was recovered at 14:25 with its original text.

![The restore, with the file back and its text intact](evidence/06_step08_restore_svr1.png)

## Design decisions

1. Everything is done on UMNGA-SVR1 only. It carries the most roles, so it gains the most from a routine. UMNGA-DC1 and UMNGA-CORE1 were not patched or backed up in this project.
2. The server gets internet through a temporary second network card attached to NAT, not by giving UmngaNet a gateway. UmngaNet has no router and I want it to stay isolated. The card is on SVR1 only, never on the domain controller, and it comes off at the end.
3. Before I used the NAT card I told Windows not to register its address in DNS (Set-DnsClient with RegisterThisConnectionsAddress set to false) and gave it an interface metric of 50. This keeps the name UMNGA-SVR1 pointing at 192.168.20.11 only.
4. I let Windows Update do the installing through Settings and checked the result with Get-HotFix, the update history and Event Viewer. The point of the step is the habit of checking afterwards, so the check matters more than the install method.
5. For logs I built one custom view of errors and warnings in place of reading three whole logs, and I wrote the recurring IDs into a PowerShell query that groups them. A routine has to be quick enough to be repeated.
6. A baseline is only a baseline when the server is idle. After the servicing that follows updates, the Windows Modules Installer Worker (TiWorker) kept the processor busy for more than an hour. I kept the busy screenshots as evidence of what servicing looks like and took the baseline only after TiWorker had been absent for five minutes in a row.
7. For the firewall I replaced a broad rule with a narrow one. The built in IIS rule was open to any address on every profile, so adding one more allow rule would have changed nothing. The new rule names the service, the source and the profile.
8. I proved the rule in both directions. It let DC1 in, and when I pointed it at the wrong subnet it kept DC1 out. A rule that has only ever been seen allowing traffic has not been shown to restrict it.
9. For Defender I used the EICAR test string and real time protection, not a real sample. EICAR is text that every antivirus is built to flag, and it carries no risk. I wrote it to a test folder and removed the folder afterwards.
10. For backup I used the Windows Server Backup cmdlets (New-WBPolicy, Add-WBFileSpec, New-WBBackupTarget and Start-WBBackup) because they name exactly what is backed up and where it goes. I restored with wbadmin, which takes the backup version, one item and a target. A backup counts when a restore has worked.
11. The backup disk is a separate virtual disk added to the VM, formatted NTFS as its own volume. It is not the same disk as the data.
12. I took snapshots named for the state before a risky change ("Stage 6 before NAT", "Stage 6 before updates"), as the naming standard says.

## Implementation

### 1. Starting point

On UMNGA-SVR1 I opened Settings, Windows Update, Update history, then ran Get-HotFix and Get-ComputerInfo for the operating system name and build.

Observed: the update history says "You haven't installed any updates yet." Get-HotFix lists three items, all installed on 14 January 2026: KB5072725 (Security Update), KB5073379 (Security Update) and KB5066131 (Update). The operating system is Microsoft Windows Server 2025 Standard Evaluation, build 26100.

![Update history before](evidence/06_step01_update_history_svr1.png)

![Installed hotfixes and the build](evidence/06_step01_hotfix_build_svr1.png)

Evidence: 06_step01_update_history_svr1.png, 06_step01_hotfix_build_svr1.png

### 2. A temporary route to the internet

I took a snapshot named "Stage 6 before NAT" and added a second adapter to UMNGA-SVR1 attached to NAT. Inside Windows I stopped it registering in DNS, gave it a higher interface metric, and tested name resolution and a connection to the internet.

Observed:

1. The VirtualBox settings show Adapter 2 enabled and attached to NAT, type Intel PRO/1000 MT Desktop.
2. Get-NetIPAddress shows Ethernet 2 at 10.0.3.15 and Ethernet at 192.168.20.11.
3. Get-DnsClient shows RegisterThisConnectionsAddress False for Ethernet 2 and True for Ethernet.
4. Resolve-DnsName microsoft.com returns an A record (150.171.109.2) and an AAAA record.
5. Test-NetConnection to www.microsoft.com on port 443 succeeds and leaves through Ethernet 2 from 10.0.3.15.

![The NAT adapter in VirtualBox](evidence/06_step02_nat_adapter_settings_svr1.png)

![Address, DNS registration and name lookup](evidence/06_step02_internet_check_svr1.png)

![The connection test to the internet](evidence/06_step02_internet_check2_svr1.png)

Evidence: 06_step02_nat_adapter_settings_svr1.png, 06_step02_internet_check_svr1.png, 06_step02_internet_check2_svr1.png

### 3. Install updates and check the result

On 8 November at 18:13 I opened Windows Update and let it download and install. Later I read the update service state, the history and the hotfix list.

Observed:

1. Windows Update offered five items, all at "Downloading 0%": a Security Intelligence Update for Microsoft Defender Antivirus (KB2267602, version 1.463.191.0), an update for the Windows Security platform (KB5007651), the 2026 10 Security Update (KB5126646, build 26100.33650), the 2026 10 .NET Framework Security Update (KB5127690), and the Windows Malicious Software Removal Tool version 5.146 (KB890830).
2. At 20:03 the update services read UsoSvc Running (Automatic) and wuauserv Running (Manual). The query of the Windows Update policy key printed nothing. Test-NetConnection to www.update.microsoft.com on port 443 succeeded through Ethernet 2. The page behind the window showed "Downloading 100%".
3. At 20:05 the update history read Quality Updates (1): the 2026 10 .NET Framework Security Update (KB5127690), successfully installed on 2026/11/08. It also listed Definition Updates (2) and Other Updates (1).
4. At 20:07 Get-HotFix listed KB5127690 (installed 2026/11/08) above the three January items. The build number was still 26100. DHCPServer, TermService and W3SVC were all Running, so the three roles from earlier projects survived the update.

The step took about 1 hour 52 minutes from the first screen to the history screen, most of it waiting for downloads through the NAT card.

![The five updates offered](evidence/06_step03_updates_found_svr1.png)

![The update services and the connection to Microsoft](evidence/06_step03_update_service_check_svr1.png)

![The update history afterwards](evidence/06_step03_update_history_after_svr1.png)

![Hotfixes and role services after the update](evidence/06_step03_hotfix_after_svr1.png)

Evidence: 06_step03_updates_found_svr1.png, 06_step03_update_service_check_svr1.png, 06_step03_update_history_after_svr1.png, 06_step03_hotfix_after_svr1.png

### 4. Read the logs

In Event Viewer on UMNGA-SVR1 I filtered the System log for event ID 19 (update installed), built a custom view called Umnga Errors and Warnings, filtered the Security log for event ID 4624 (successful sign in), then ran one PowerShell query for the problem IDs I kept seeing. I also checked where the server gets its time.

Observed:

1. The System log held 8 313 events. Filtered to ID 19 it showed 24. One entry, from WindowsUpdateClient at 2026/11/08 18:18:25, reads "Installation Successful: Windows successfully installed the following update: Update for Windows Security platform KB5007651 (Version 10.0.29680.1000)". Another WindowsUpdateClient entry sits at 18:14:05.
2. The custom view Umnga Errors and Warnings shows 67 events. The top of the list holds DNS Client Events warnings (ID 8036, at 19:08:18, 19:03:03, 18:57:43 and 18:52:27), a DHCP-Server warning (10020), a DNS Client warning (1014), a Wininit warning (15), Kernel-Boot (124 error, 156 warning), a Hyper-V-Hypervisor error (41), a Service Control Manager error (7043 at 18:48:40) and a WinSrvExt warning (100). Event 8036 reads "The system failed to update and remove host (A or AAAA) resource records (RRs) for network adapter with settings", followed by an adapter GUID.
3. The Security log held 26 232 events, 2 943 of them event 4624, with the newest at 20:16:59. The open event reads "An account was successfully logged on", Security ID NULL SID.
4. A Get-WinEvent query over the last day for IDs 41, 50, 124, 156 and 1014, grouped by ID, shows five groups: DNS-Client 1014 (Warning), Kernel-Boot 124 (Error), Hyper-V-Hypervisor 41 (Error), Kernel-Boot 156 (Warning) and Time-Service 50 (Warning).
5. w32tm /query /source returns UMNGA-DC1.umnga.local. w32tm /query /status shows stratum 2, last successful sync 2026/11/08 20:28:15, a poll interval of 128 seconds, and a root dispersion of 27,3268406 seconds.

The cluster of boot events between 18:48 and 18:52 shows UMNGA-SVR1 starting up then. I did not record what triggered it.

![Update installed events in the System log](evidence/06_step04_system_log_wu_events_svr1.png)

![The custom view of errors and warnings](evidence/06_step04_custom_view_svr1.png)

![Successful sign ins in the Security log](evidence/06_step04_security_log_4624_svr1.png)

![The grouped error query](evidence/06_step04_error_summary_svr1.png)

![The time source and status](evidence/06_step04_time_status_svr1.png)

Evidence: 06_step04_system_log_wu_events_svr1.png, 06_step04_custom_view_svr1.png, 06_step04_security_log_4624_svr1.png, 06_step04_error_summary_svr1.png, 06_step04_time_status_svr1.png

### 5. Busy and quiet: a performance baseline

I looked at the server with Task Manager, Resource Monitor, Performance Monitor and Get-Counter, first while it was busy after the update, then again once it was quiet.

Observed while busy:

1. Resource Monitor on 8 November at 20:37 shows 97% CPU. TiWorker.exe (Windows Modules Installer Worker) averages 26,52 and perfmon.exe averages 25,90. Disk shows 5 MB/sec and memory 52% used.
2. Performance Monitor at 20:45 shows six counters. The % Processor Time line sits near the top of the graph with an average of 98,642, a minimum of 82,019 and a maximum of 100.
3. A Get-Counter query of every process at 20:50 ranks tiworker at 69 and system at 16, with the rest at 0.
4. After the restart on 14 November, Task Manager at 09:09 shows 95% CPU, 2,4 of 4,0 GB memory (60%) and an up time of 1 hour 10 minutes. The Processes view at 09:12 shows Windows Modules Installer Worker at 48% CPU, using 271,7 MB.
5. The first wait loop printed "TiWorker gone after 4 minutes" at 08:13:15, yet TiWorker was running again by 09:09. A second loop that needs five absent minutes in a row printed its result at 09:30:54.

Observed while quiet:

1. Task Manager at 09:35 shows CPU 0%, memory 1,7 of 4,0 GB (42%), disk C: 0% and an up time of 1 hour 36 minutes.
2. Resource Monitor at 09:39 shows 6% CPU on the Overview tab and 4% on the CPU tab. perfmon.exe averages 2,59 and sqlservr.exe averages 2,43. Memory is 42% used and disk 5% at its busiest.
3. Performance Monitor at 09:45 shows one counter, % Processor Time of Processor Information (_Total), over 1 minute 40 seconds: last 1,252, average 4,127, minimum 0 and maximum 14,952.
4. Get-Counter at 09:50 printed six lines, five seconds apart. CPU read 7,4%, 8,1%, 7,6%, 7,6%, 14,3% and 18,9%. Free memory read 2258 MB, 2258, 2258, 2257, 2258 and 2258. Disk time read 0,01%, 0,06% and then 0,00%. An earlier run of the same command, which I did not screenshot, gave CPU between 6,6% and 12,0%, memory between 2250 and 2252 MB, and disk time up to 0,16%.

![Busy: Task Manager performance view](evidence/06_step05_busy_task_manager_svr1.png)

![Busy: Task Manager processes view](evidence/06_step05_busy_task_manager_processes_svr1.png)

![Busy: Resource Monitor](evidence/06_step05_busy_resource_monitor_svr1.png)

![Busy: Performance Monitor](evidence/06_step05_busy_perfmon_svr1.png)

![Busy: processes ranked by CPU](evidence/06_step05_busy_process_counter_svr1.png)

![TiWorker gone for one check](evidence/06_step05_tiworker_gone_once_svr1.png)

![TiWorker absent for five minutes in a row](evidence/06_step05_tiworker_gone_five_minutes_svr1.png)

![Quiet: Task Manager](evidence/06_step05_quiet_task_manager_svr1.png)

![Quiet: Resource Monitor overview](evidence/06_step05_quiet_resource_monitor_svr1.png)

![Quiet: Resource Monitor CPU tab](evidence/06_step05_quiet_resource_monitor_cpu_svr1.png)

![Quiet: Performance Monitor](evidence/06_step05_quiet_perfmon_svr1.png)

![Quiet: Get-Counter text baseline](evidence/06_step05_quiet_getcounter_svr1.png)

Evidence: the twelve 06_step05 files listed in the [Captions](evidence/Captions.md)

### 6. The firewall

On 14 November I read the three profiles and the HTTP rules, replaced the broad web rule with a scoped one, and tested from UMNGA-DC1.

Observed:

1. Get-NetFirewallProfile shows Domain, Private and Public all Enabled True, with default inbound and outbound actions NotConfigured, which means the Windows defaults.
2. Get-NetConnectionProfile shows Ethernet as DomainAuthenticated with LocalNetwork access, and Ethernet 2 as Public with Internet access.
3. Among 15 inbound rules with HTTP in the name, World Wide Web Services (HTTP Traffic-In) and (HTTPS Traffic-In) are both enabled, on profile Any, action Allow. Get-NetTCPConnection shows something listening on port 80, with the local address :: (all addresses).
4. I created Umnga Intranet HTTP from UmngaNet (inbound, TCP port 80, remote address 192.168.20.0/24, Domain profile, Allow) and disabled the built in HTTP rule. The next listing shows the built in rule False on profile Any and the new rule True on profile Domain. The address filter reads 192.168.20.0/255.255.255.0.
5. From UMNGA-DC1 at 10:16, Test-NetConnection to UMNGA-SVR1 on port 80 gave TcpTestSucceeded True and Invoke-WebRequest returned 200.
6. I then changed the rule's remote address to 192.168.99.0/24. At 12:42 the same test from DC1 gave TcpTestSucceeded False. I changed the address back to 192.168.20.0/24.

![Profiles and network categories](evidence/06_step06_firewall_profiles_svr1.png)

![HTTP rules before the change](evidence/06_step06_http_rules_svr1.png)

![The new scoped rule and the disabled broad rule](evidence/06_step06_new_rule_svr1.png)

![The website reachable from DC1](evidence/06_step06_http_test_dc1.png)

![The same test blocked with the wrong subnet](evidence/06_step06_http_blocked_dc1.png)

Evidence: 06_step06_firewall_profiles_svr1.png, 06_step06_http_rules_svr1.png, 06_step06_new_rule_svr1.png, 06_step06_http_test_dc1.png, 06_step06_http_blocked_dc1.png

### 7. Defender, and taking the internet card away

I read Defender's status, wrote the EICAR test string to a test folder, asked Defender and Event Viewer what they recorded, and deleted the test folder. Then I disabled the NAT adapter and checked DNS from DC1.

Observed:

1. Get-MpComputerStatus at 12:44 shows AMServiceEnabled, AntivirusEnabled and RealTimeProtectionEnabled all True, signature version 1.463.291.0, last updated 2026/11/14 01:18:46, signature age 0 days, and an empty QuickScanEndTime.
2. Set-Content wrote the EICAR text to C:\EicarTest\eicar.txt and printed no error.
3. At 12:47 Get-MpThreatDetection shows InitialDetectionTime 2026/11/14 12:46:11, ActionSuccess True and the resource file:_C:\EicarTest\eicar.txt. Get-WinEvent shows event 1117 at 12:46:35 and event 1116 at 12:46:11 in the Windows Defender Operational log.
4. Remove-Item removed the test folder and Test-Path printed False.
5. Disable-NetAdapter at 12:50 leaves Ethernet 2 Disabled and Ethernet Up. The only IPv4 addresses are 192.168.20.11 and the loopback address.
6. At 12:51 on DC1, Get-DnsServerResourceRecord for UMNGA-SVR1 shows one A record, 192.168.20.11.

I did not run a scan. The definitions arrived through Windows Update in step 3, so I did not need to run an update by hand.

![Defender status before the test](evidence/06_step07_defender_status_svr1.png)

![Defender detection and the Event Viewer events](evidence/06_step07_detection_svr1.png)

![The NAT adapter disabled](evidence/06_step07_nat_disabled_svr1.png)

![DNS records for UMNGA-SVR1](evidence/06_step07_dns_records_dc1.png)

Evidence: 06_step07_defender_status_svr1.png, 06_step07_detection_svr1.png, 06_step07_nat_disabled_svr1.png, 06_step07_dns_records_dc1.png

### 8. Backup and restore

I installed Windows Server Backup, made five small test files, powered UMNGA-SVR1 off, removed the NAT card in VirtualBox and added a 3 GB disk. After starting the server again I formatted the new disk, backed the test folder up, deleted one file and restored it.

Observed:

1. Install-WindowsFeature Windows-Server-Backup returned Success True, RestartNeeded No, ExitCode Success. C:\UmngaBackupTest holds staff_note_1.txt to staff_note_5.txt, 19 bytes each.
2. The VirtualBox Network page shows Adapter 2 with Enable Network Adapter unticked. I covered the MAC address field before committing the screenshot. The Storage page lists UMNGA-SVR1-backup.vdi on the SATA controller beside the system disk, the three pool disks and the guest additions disc.
3. Get-Disk shows disk 0 (60 GB, MBR), disk 4 (3 GB, RAW) and disk 5 (Departments, 5 GB, GPT). I formatted disk 4 only: drive F:, label UmngaBackup, NTFS, 2,98 GB.
4. Start-WBBackup finished. Get-WBSummary reads LastSuccessfulBackupTime 2026/11/14 14:12:56, LastBackupResultHR 0 and NumberOfVersions 1. Get-WBBackupSet reads VersionId 11/14/2026-12:12 (UTC).
5. At 14:24 I deleted staff_note_3.txt, and Get-ChildItem listed four files.
6. At 14:25 wbadmin start recovery recovered the file from the 14:12 backup into C:\UmngaBackupTest. The output says "Successfully recovered", total bytes recovered 19, total files recovered 1, total files failed 0. Five files are listed again and Get-Content prints "Umnga test file 3".

![Windows Server Backup installed and the test files](evidence/06_step08_backup_feature_svr1.png)

![Adapter 2 switched off in VirtualBox](evidence/06_step08_vbox_network_svr1.png)

![The backup disk attached in VirtualBox](evidence/06_step08_vbox_storage_svr1.png)

![The disks seen by Windows](evidence/06_step08_disks_svr1.png)

![The backup disk formatted as F:](evidence/06_step08_backup_disk_svr1.png)

![The backup finished](evidence/06_step08_backup_done_svr1.png)

![The file deleted on purpose](evidence/06_step08_file_deleted_svr1.png)

![The file recovered, with its text](evidence/06_step08_restore_svr1.png)

Evidence: 06_step08_backup_feature_svr1.png, 06_step08_vbox_network_svr1.png, 06_step08_vbox_storage_svr1.png, 06_step08_disks_svr1.png, 06_step08_backup_disk_svr1.png, 06_step08_backup_done_svr1.png, 06_step08_file_deleted_svr1.png, 06_step08_restore_svr1.png

## Verification

1. Update history and Get-HotFix show KB5127690 installed on 8 November, and the three earlier roles were still running afterwards.
2. Event Viewer holds a record of at least one update install (event 19 at 18:18:25) and a custom view of 67 errors and warnings.
3. A quiet baseline exists in four forms, and a busy one in four forms, so the two can be compared.
4. The web port is reachable from inside UmngaNet and the scoped rule is what allows it. It was blocked when the rule named a different subnet.
5. Defender is on, up to date, and detected and quarantined the EICAR test string with events 1116 and 1117.
6. The NAT adapter is disabled and DNS holds only 192.168.20.11 for UMNGA-SVR1.
7. A backup exists with result code 0, and a file deleted on purpose came back with its text.

## Limitations

1. The cumulative update KB5126646 (build 26100.33650) was offered on 8 November. At 20:05 and 20:07 it was not in the update history or in Get-HotFix. I did not check again after the restart on 14 November, so I cannot say whether it installed. The long run of TiWorker after that restart looks like servicing, but I did not prove it.
2. The baseline is one short capture of an idle server with 2 virtual processors and 4 GB of memory. It is not a day of data. I did not set up a Data Collector Set to keep a log over time, and I never recorded free disk space.
3. The busy captures were taken while Windows was servicing, so they show a worst case and not normal load. perfmon.exe itself used about a quarter of the processor in the busy Resource Monitor view, so the tool added to the load it was measuring.
4. sqlservr.exe averaged about 2% CPU on the quiet server. I believe it is the internal database of the Remote Desktop Services role, but I did not check which service owns it.
5. I did not open the events I list as warnings and errors (8036, 1014, 10020, 7043, 124, 156, 41 and Time-Service 50), except the text of 8036. I believe the Kernel-Boot and Hyper-V events come from a virtual machine without hardware virtualization, but I did not prove it. The custom view screenshot does not show its filter settings.
6. The time sync result shows a root dispersion of 27 seconds. I did not investigate it.
7. Only one machine, UMNGA-DC1, tested the scoped web rule, and the block test used a wrong subnet and not a real outside machine. I did not take a screenshot after changing the rule back to 192.168.20.0/24, and I did not test the web page again after the backup step. The built in HTTPS rule is still open to any address, and I left the default Cast to Device, DIAL and IPHTTPS rules alone.
8. Defender was proven only by real time protection and one test string. I ran no scan (QuickScanEndTime was empty), did not read the exclusions or cloud protection settings, and did not run a manual definition update.
9. The backup covers one folder of five 19 byte files. It sits on a virtual disk that lives on the same laptop as the server, so it would not survive the loss of the laptop. It is a single manual backup with no schedule, no retention, no system state and no bare metal recovery. I did not back up the Departments drive or the domain controller, and I did not restore to a different location or onto a rebuilt server.
10. The backup disk is attached to the server it protects. A threat that can write to the server can reach the backup.
11. I did not test any of this from a Windows 11 client, because the lab does not have one yet.

## Files

1. [Server care routine](Server%20care%20routine.md)
2. [Captions](evidence/Captions.md)
3. [Troubleshooting log](Troubleshooting%20log.md)
4. [Naming and IP standard](../docs/Naming%20and%20IP%20standard.md)

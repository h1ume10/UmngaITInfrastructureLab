# Evidence captions: 06 Server care routine

All 43 files are in this folder. Each was checked for passwords, licence keys, tenant names, employer data and MAC addresses. One MAC address was found, in 06_step08_vbox_network_svr1.png, and the field is covered with a grey box. The Task Manager screenshots show the processor model of the laptop that hosts the lab, as the virtual machine reports it, and I left it in.

Thirty seven captures are headline evidence and six are marked supporting. The busy captures in step 5 are kept as "before" evidence for the quiet baseline, and the two TiWorker checks show why the first baseline attempt was not valid.

Step 1: starting point

1. 06_step01_update_history_svr1.png: Settings, Windows Update, Update history on UMNGA-SVR1 at 17:46 on 8 November. It reads "You haven't installed any updates yet." The title bar shows the snapshot label "Stage 5 verified".
2. 06_step01_hotfix_build_svr1.png: PowerShell on UMNGA-SVR1 at 17:47. Get-HotFix sorted by InstalledOn lists KB5072725 (Security Update), KB5073379 (Security Update) and KB5066131 (Update), all 2026/01/14. Get-ComputerInfo shows Microsoft Windows Server 2025 Standard Evaluation, build 26100. A Search tooltip sits above the taskbar.

Step 2: a temporary route to the internet

3. 06_step02_nat_adapter_settings_svr1.png (supporting): a cropped view of the VirtualBox Network page, Adapter 2 tab, with Enable Network Adapter ticked, Attached to NAT and Adapter Type Intel PRO/1000 MT Desktop (82540EM). It is a crop of the settings window, so it has no title bar or time.
4. 06_step02_internet_check_svr1.png: PowerShell on UMNGA-SVR1 at 18:07. Set-DnsClient with RegisterThisConnectionsAddress false and Set-NetIPInterface with metric 50 for Ethernet 2. Get-NetIPAddress lists Ethernet 2 at 10.0.3.15, Ethernet at 192.168.20.11 and the loopback address. Get-DnsClient shows RegisterThisConnectionsAddress False for Ethernet 2. Resolve-DnsName microsoft.com returns an AAAA and an A record (150.171.109.2). The last line is the Test-NetConnection command, still running. The title bar shows "Stage 6 before NAT".
5. 06_step02_internet_check2_svr1.png (supporting): the same window at 18:08, scrolled. Test-NetConnection to www.microsoft.com on port 443 shows RemoteAddress 184.28.85.164, InterfaceAlias Ethernet 2, SourceAddress 10.0.3.15 and TcpTestSucceeded True.

Step 3: install updates and check the result

6. 06_step03_updates_found_svr1.png: Settings, Windows Update at 18:13. "Complete updates to help keep your device secure" with five items, all Downloading 0%: Security Intelligence Update for Microsoft Defender Antivirus KB2267602 (Version 1.463.191.0), Update for Windows Security platform KB5007651 (Version 10.0.29680.1000), 2026 10 Security Update KB5126646 (26100.33650), 2026 10 .NET Framework Security Update KB5127690, and Windows Malicious Software Removal Tool x64 v5.146 KB890830. A File Explorer tooltip sits over the taskbar. The title bar shows "Stage 6 before updates".
7. 06_step03_update_service_check_svr1.png (supporting): PowerShell over the Windows Update page at 20:03. Get-Service shows UsoSvc Running (Automatic) and wuauserv Running (Manual). The Get-ItemProperty query of the WindowsUpdate policy key printed nothing. Test-NetConnection to www.update.microsoft.com on port 443 shows RemoteAddress 132.196.74.18, InterfaceAlias Ethernet 2, TcpTestSucceeded True. Behind the window the page reads "Downloading 100%".
8. 06_step03_update_history_after_svr1.png: Update history at 20:05. Quality Updates (1) is open and lists 2026 10 .NET Framework Security Update (KB5127690), "Successfully installed on 2026/11/08". Definition Updates (2) and Other Updates (1) are collapsed.
9. 06_step03_hotfix_after_svr1.png: PowerShell at 20:07. Get-HotFix lists KB5127690 (Update, 2026/11/08), then KB5072725 and KB5073379 (2026/01/14). The build number is 26100. Get-Service shows DHCPServer, TermService and W3SVC Running.

Step 4: read the logs

10. 06_step04_system_log_wu_events_svr1.png: Event Viewer, System log at 20:16. The header reads "Number of events: 8 313" and the filter line reads "Event ID: 19. Number of events: 24". The selected entry is WindowsUpdateClient at 2026/11/08 18:18:25: "Installation Successful: Windows successfully installed the following update: Update for Windows Security platform KB5007651 (Version 10.0.29680.1000) Current Channel (Broad)".
11. 06_step04_custom_view_svr1.png: Event Viewer, Custom Views, Umnga Errors and Warnings at 20:19, 67 events. The top rows run from 19:08:18 back to 18:48:20 and include DNS Client Events 8036, DHCP-Server 10020, DNS Client 1014, Wininit 15, Kernel-Boot 124 and 156, Hyper-V-Hypervisor 41, Service Control Manager 7043 and WinSrvExt 100. The selected event, 8036, shows the start of its text and an adapter GUID. A File Explorer tooltip sits over the taskbar.
12. 06_step04_security_log_4624_svr1.png: Event Viewer, Security log at 20:21. The header reads "Number of events: 26 232" and the filter shows event 4624 with 2 943 events, newest at 20:16:59, all Audit Success, category Logon. The open event reads "An account was successfully logged on", Security ID NULL SID.
13. 06_step04_error_summary_svr1.png: PowerShell at 20:25. A Get-WinEvent query on the System log for IDs 41, 50, 124, 156 and 1014 over the last day, grouped by ID with one event from each group. The result lists 1014 DNS-Client (Warning), 124 Kernel-Boot (Error), 41 Hyper-V-Hypervisor (Error), 156 Kernel-Boot (Warning) and 50 Time-Service (Warning).
14. 06_step04_time_status_svr1.png: PowerShell at 20:30. w32tm /query /source returns UMNGA-DC1.umnga.local. w32tm /query /status shows Leap Indicator 0, Stratum 2, Root Delay 0.0019494s, Root Dispersion 27.3268406s, ReferenceId 0xC0A8140A (source IP 192.168.20.10), Last Successful Sync Time 2026/11/08 20:28:15, Poll Interval 7 (128s).

Step 5: busy and quiet

15. 06_step05_busy_resource_monitor_svr1.png: Resource Monitor, Overview, at 20:37 on 8 November. CPU 97% usage, 100% Maximum Frequency. TiWorker.exe (Windows Modules Installer Worker) shows CPU 27 and average 26.52, perfmon.exe 37 and 25.90, System 6 and 4.55. Disk 5 MB/sec with 36% highest active time, memory 52% used physical memory.
16. 06_step05_busy_perfmon_svr1.png: Performance Monitor at 20:45 on 8 November, six counters: % Processor Time (Processor Information, _Total), Available MBytes, two Bytes Total/sec counters for the network interface, % Disk Time and % Processor Time (Processor). The graph sits at the top. Average 98,642, minimum 82,019, maximum 100,000, duration 1:40.
17. 06_step05_busy_process_counter_svr1.png: PowerShell at 20:50 on 8 November. Get-Counter on every process, with the total and idle removed, sorted by CookedValue, top six. tiworker 69, system 16, then four svchost entries at 0.
18. 06_step05_busy_task_manager_svr1.png: Task Manager, Performance, CPU, at 09:09 on 14 November. Utilization 95% at 1,19 GHz, 117 processes, 1126 threads, up time 0:01:10:01, memory 2,4 of 4,0 GB (60%), virtual processors 2, virtual machine Yes.
19. 06_step05_busy_task_manager_processes_svr1.png: Task Manager, Processes, at 09:12. CPU 48%, memory 55%, disk 13%. Windows Modules Installer Worker uses 48,0% CPU and 271,7 MB. SQL Server Windows NT 64 Bit is listed at 0% and 52,4 MB. A Start tooltip sits at the bottom.
20. 06_step05_tiworker_gone_once_svr1.png: PowerShell at 09:02 on 14 November. The first wait loop (check every 60 seconds until TiWorker is gone) prints "TiWorker gone after 4 minutes. Time now: 2026/11/14 08:13:15".
21. 06_step05_tiworker_gone_five_minutes_svr1.png: PowerShell at 09:31. The stricter loop, which needs five absent checks in a row, prints "TiWorker absent for 5 minutes in a row. Time now: 11/14/2026 09:30:54".
22. 06_step05_quiet_task_manager_svr1.png: Task Manager, Performance, CPU, at 09:35. Utilization 0%, 114 processes, 1045 threads, up time 0:01:36:24, memory 1,7 of 4,0 GB (42%), disk 0 (C:) 0%, Disk 4 (E:) Spaces 0%.
23. 06_step05_quiet_resource_monitor_svr1.png: Resource Monitor, Overview, at 09:39. CPU 6% usage. perfmon.exe averages 2.59, sqlservr.exe 2.43, System Interrupts 1.57. Disk 512 KB/sec with 5% highest active time, network 6 Kbps, memory 42% used.
24. 06_step05_quiet_resource_monitor_cpu_svr1.png (supporting): Resource Monitor, CPU tab, at 09:39. 4% CPU usage and 2% services CPU usage. perfmon.exe averages 2.08 and sqlservr.exe 1.99.
25. 06_step05_quiet_perfmon_svr1.png: Performance Monitor at 09:45 with one counter, % Processor Time of Processor Information (_Total). Last 1,252, average 4,127, minimum 0,000, maximum 14,952, duration 1:40. The graph stays near the bottom.
26. 06_step05_quiet_getcounter_svr1.png: PowerShell at 09:50 (the command line was cleared before the screenshot). Six lines from Get-Counter, five seconds apart, 09:50:18 to 09:50:43. CPU 7,4%, 8,1%, 7,6%, 7,6%, 14,3% and 18,9%. Free RAM 2258 MB (2257 once). Disk 0,01%, 0,06%, then 0,00%.

Step 6: the firewall

27. 06_step06_firewall_profiles_svr1.png: PowerShell at 09:54. Get-NetFirewallProfile shows Domain, Private and Public Enabled True, DefaultInboundAction and DefaultOutboundAction NotConfigured. Get-NetConnectionProfile shows Ethernet DomainAuthenticated with LocalNetwork and Ethernet 2 Public with Internet. A Start tooltip sits at the bottom.
28. 06_step06_http_rules_svr1.png: PowerShell at 09:55. Inbound rules with HTTP in the name, 15 rows. Both World Wide Web Services (HTTP Traffic-In) and (HTTPS Traffic-In) are Enabled True on profile Any with Allow. Windows Remote Management (HTTP-In) is enabled on Domain and Private, and again on Public. Core Networking IPHTTPS, DIAL protocol server and Cast to Device streaming server rules are enabled on their listed profiles.
29. 06_step06_new_rule_svr1.png: PowerShell at 10:15. World Wide Web Services (HTTP Traffic-In): Enabled False, profile Any, Allow. Umnga Intranet HTTP from UmngaNet: Enabled True, profile Domain, Allow. RemoteAddress 192.168.20.0/255.255.255.0.
30. 06_step06_http_test_dc1.png: PowerShell on UMNGA-DC1 at 10:16. Test-NetConnection to UMNGA-SVR1, RemotePort 80, TcpTestSucceeded True. The web request status code is 200. The title bar shows "Stage 5 verified".
31. 06_step06_http_blocked_dc1.png: PowerShell on UMNGA-DC1 at 12:42. The same test with the rule pointed at 192.168.99.0/24: RemotePort 80, TcpTestSucceeded False. The title bar shows "Stage 5 verified".

Step 7: Defender and the NAT card

32. 06_step07_defender_status_svr1.png: PowerShell at 12:44. Get-MpComputerStatus: AMServiceEnabled, AntivirusEnabled and RealTimeProtectionEnabled True, AntivirusSignatureVersion 1.463.291.0, AntivirusSignatureLastUpdated 2026/11/14 01:18:46, AntivirusSignatureAge 0, QuickScanEndTime empty. A Search tooltip sits above the taskbar.
33. 06_step07_detection_svr1.png: PowerShell at 12:47. Get-MpThreatDetection: InitialDetectionTime 2026/11/14 12:46:11, ActionSuccess True, Resources {file:_C:\EicarTest\eicar.txt}. Get-WinEvent on the Windows Defender Operational log lists 12:46:35 ID 1117 and 12:46:11 ID 1116. The folder listing before them printed nothing.
34. 06_step07_nat_disabled_svr1.png: PowerShell at 12:50. Get-NetAdapter shows Ethernet 2 Disabled and Ethernet Up. Get-NetIPAddress shows 192.168.20.11 on Ethernet and 127.0.0.1 on the loopback interface.
35. 06_step07_dns_records_dc1.png: PowerShell on UMNGA-DC1 at 12:51. Get-DnsServerResourceRecord for UMNGA-SVR1 in umnga.local lists one A record, 192.168.20.11. The title bar shows "Stage 5 verified".

Step 8: backup and restore

36. 06_step08_backup_feature_svr1.png: PowerShell at 13:38. The commands and their output together: a folder with five staff_note files created, Install-WindowsFeature Windows-Server-Backup returns Success True, RestartNeeded No, ExitCode Success, and Get-ChildItem lists staff_note_1.txt to staff_note_5.txt at 19 bytes each.
37. 06_step08_vbox_network_svr1.png (supporting): the VirtualBox Settings window for UMNGA-SVR1, Network, Adapter 2 tab, with Enable Network Adapter unticked. The MAC address field is covered with a grey box.
38. 06_step08_vbox_storage_svr1.png (supporting): VirtualBox Settings, Storage. The SATA controller (AHCI, port count 6) lists UMNGA-SVR1.vdi, VBoxGuestAdditions.iso, SVR1_pool1.vdi, SVR1_pool2.vdi, SVR1_pool3b.vdi and UMNGA-SVR1-backup.vdi.
39. 06_step08_disks_svr1.png: PowerShell at 14:04. Get-Disk lists disk 0 (VBOX HARDDISK, 60 GB, MBR, Online), disk 4 (VBOX HARDDISK, 3 GB, RAW, Online) and disk 5 (Departments, 5 GB, GPT, Online). A Microsoft Edge tooltip sits above the taskbar.
40. 06_step08_backup_disk_svr1.png: PowerShell at 14:06. Format-Volume output: DriveLetter F, FileSystemLabel UmngaBackup, FileSystem NTFS, SizeGB 2,98.
41. 06_step08_backup_done_svr1.png: PowerShell at 14:23. Get-WBSummary: LastSuccessfulBackupTime 2026/11/14 14:12:56, LastBackupResultHR 0, NumberOfVersions 1. Get-WBBackupSet: BackupTime 2026/11/14 14:12:56, VersionId 11/14/2026-12:12. A Search tooltip sits at the bottom.
42. 06_step08_file_deleted_svr1.png: PowerShell at 14:24. Get-ChildItem lists staff_note_1.txt, 2, 4 and 5, 19 bytes each. staff_note_3.txt is missing.
43. 06_step08_restore_svr1.png: PowerShell at 14:25. wbadmin: "You have chosen to recover the file(s) C:\UmngaBackupTest\staff_note_3.txt from the backup created on 2026/11/14 14:12 to C:\UmngaBackupTest\". "Successfully recovered", total bytes recovered 19, total files recovered 1, total files failed 0, with a restore log in C:\WINDOWS\Logs\WindowsServerBackup. Get-ChildItem lists five files, and Get-Content prints "Umnga test file 3". A Start tooltip sits at the bottom.

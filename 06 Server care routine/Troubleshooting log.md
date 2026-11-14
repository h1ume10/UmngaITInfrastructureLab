# Troubleshooting log: 06 Server care routine

This log lists what went wrong or looked wrong in the lab, what caused it, and what I did. The first two entries are real faults I had to fix. The next two are things that surprised me and turned out to be normal. After them are the events I saw and did not diagnose, and what I did not record.

## 1. The server was never idle: the first baselines were not baselines

1. Symptom: on 8 November the Resource Monitor showed 97% CPU and Performance Monitor averaged 98,642%. After the restart on 14 November, Task Manager showed 95%, then 48%, and the processes view listed Windows Modules Installer Worker (TiWorker) at 48%. A first wait loop printed "TiWorker gone after 4 minutes" at 08:13:15, but TiWorker was busy again at 09:09.
2. Cause: after updates, Windows keeps servicing the update files in the background, and the Windows Modules Installer Worker can disappear for a few minutes and then start again. A single check that finds it absent is not enough. The processor looked busy, but the process using it was Windows servicing itself, not one of the server roles.
3. Fix: I wrote a loop that checks every 60 seconds and only stops when the worker has been absent for five checks in a row. It printed its result at 09:30:54. Task Manager at 09:35 then read 0% CPU, and the quiet baseline followed. I kept the busy screenshots as "before" evidence and named them with the word busy.
4. Takeaway: take a baseline only when the server is idle, and decide what "idle" means before you measure. A busy reading is still useful, because it shows what servicing looks like on this server. Also note that the monitoring tool uses processor time: perfmon.exe averaged about 26% in the busy view.

## 2. Get-NetFirewallRule: Parameter set cannot be resolved

1. Symptom: the command I ran to list the HTTP rules failed with "Get-NetFirewallRule : Parameter set cannot be resolved using the specified named parameters" and the error id AmbiguousParameterSet. Only the port 80 check in the same line printed anything.
2. Cause: I used the -DisplayName and -Direction parameters together in one call. In that command they belong to different parameter sets, so PowerShell cannot pick one.
3. Fix: I asked for all inbound rules with -Direction Inbound and filtered by name afterwards with Where-Object on DisplayName. It returned the 15 rules.
4. Takeaway: when PowerShell says a parameter set cannot be resolved, two of the switches in the line do not go together. Read the error, drop one parameter, and filter the result in the next step.

## 3. No error when writing the EICAR file

1. Symptom: I expected a red error when writing the EICAR test string, and Set-Content printed nothing. The folder was empty a few seconds later.
2. Cause: Defender did not block the write. It scanned the file after the write and removed it. Defender recorded the detection at 12:46:11 (event 1116) and the quarantine action 24 seconds later at 12:46:35 (event 1117).
3. Fix: none was needed. The proof of detection is in Get-MpThreatDetection (ActionSuccess True) and in the Windows Defender Operational log, not in the console.
4. Takeaway: a quiet command is not a failed test. Ask the antivirus what it recorded.

## 4. One new web rule would have changed nothing

1. Symptom: the plan said to add an inbound rule for the IIS site. The listing showed the built in rule World Wide Web Services (HTTP Traffic-In) already enabled, on every profile, from any address.
2. Cause: installing the IIS role in project 03 adds that rule and turns it on.
3. Fix: I added a narrow rule and disabled the broad one. The test from DC1 still worked, and it failed when I changed the rule's address to a different subnet.
4. Takeaway: read the rules that exist before you add a new one. A new allow rule next to an open one adds nothing.

## Events I saw and did not diagnose

These appeared in the Umnga Errors and Warnings view or in the last day's events. I read the list and, for 8036, one message. I did not open the others, so I do not claim a cause.

1. DNS Client Events 8036 (warning), repeated four times between 18:52 and 19:08: the system failed to update and remove host records for a network adapter, named in the event by its GUID. I did not match the GUID to Ethernet 2. It may be linked to the temporary NAT adapter, which did not register in DNS, but I did not check.
2. DNS Client 1014 (warning), DHCP-Server 10020 (warning), Wininit 15 (warning) and WinSrvExt 100 (warning).
3. Service Control Manager 7043 (error) at 18:48:40.
4. Kernel-Boot 124 (error) and 156 (warning) and Hyper-V-Hypervisor 41 (error) at 18:52:01. They appear at start up. I believe they come from a virtual machine running without hardware virtualization, which matters for the Hyper-V project later, but I did not prove it.
5. Time-Service 50 (warning). w32tm shows UMNGA-SVR1 takes its time from UMNGA-DC1, stratum 2, with a last good sync at 20:28:15 and a root dispersion of 27 seconds.

## Observations, not faults

1. The cumulative update KB5126646 was in the list on 8 November and I never saw it as installed. Get-HotFix at 20:07 lists only KB5127690 as new. I did not recheck after the restart, so this stays open.
2. The title bars show snapshot labels that were current when I took each screenshot: "Stage 5 verified" in step 1, "Stage 6 before NAT" in step 2 and "Stage 6 before updates" from step 3 onward, on UMNGA-SVR1, and "Stage 5 verified" on UMNGA-DC1. They are labels and not statements about the state.
3. The screenshots are in the regional format of the lab, so numbers use a decimal comma (4,127) and dates sit in two orders (2026/11/14 and 11/14/2026). Get-Counter and PowerShell output use the same comma.
4. The command lines I pasted into PowerShell in step 2 show curly quotation marks around Ethernet 2, and PowerShell accepted them.
5. The task manager screenshots show the processor of the laptop that hosts the lab, as the virtual machine reports it.
6. The backup version ID is in UTC (11/14/2026-12:12), two hours behind the local backup time 14:12:56.
7. The Performance Monitor screenshot taken for the quiet baseline shows only one counter. The first attempt on 8 November had six counters and was taken while the server was busy.
8. The MAC address field in the VirtualBox network screenshot is covered with a grey box before the image went into the repository.

## Not recorded

1. Free disk space on the server, before or after the updates.
2. Whether the cumulative update KB5126646 installed, and what the build revision is now.
3. The settings of the custom view filter, and the text of the events I did not open.
4. A screenshot of the firewall rule after I changed its address back to 192.168.20.0/24, and a web test after the backup step.
5. A Defender scan and a manual definition update.
6. The folder contents of the backup disk, and the size of the backup.
7. The first Get-Counter run (CPU 6,6% to 12,0%, memory 2250 to 2252 MB), which I have only as pasted output.

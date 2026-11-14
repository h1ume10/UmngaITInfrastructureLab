# Umnga Server Care Routine

Applies to: UMNGA-SVR1, the member server that carries DHCP, IIS, Remote Desktop Services and the department file shares.
Source: the commands below are the ones I ran in [06 Server care routine](README.md). The schedule is my proposal and I have not run it over time.
Run from: an elevated PowerShell on UMNGA-SVR1, except where it says UMNGA-DC1.

## Weekly, about 20 minutes

1. **Updates.** Open Windows Update and read what is offered. Afterwards run the check below and compare it with last week. Do not start installing on a day when the server must stay up. Installs can leave Windows busy for an hour or more afterwards.

```powershell
Get-HotFix | Sort-Object InstalledOn -Descending | Format-Table HotFixID, Description, InstalledOn -AutoSize
Get-Service DHCPServer, W3SVC, TermService | Format-Table Name, Status -AutoSize
```

   Normal: the new update appears with today's date, and all three services read Running. Not normal: a service Stopped, or an update offered for weeks that never installs.

2. **Logs.** Open the custom view Umnga Errors and Warnings and read the top of the list. Then group the known problem IDs for the last day.

```powershell
Get-WinEvent -FilterHashtable @{LogName='System'; Id=41,50,124,156,1014; StartTime=(Get-Date).AddDays(-1)} | Group-Object Id | ForEach-Object { $_.Group | Select-Object -First 1 } | Format-Table Id, ProviderName, LevelDisplayName -AutoSize
```

   Seen in this lab: boot events 41, 124 and 156 appear around a start up. I have not found their cause, so note them and do not call them safe. Not normal: a new source or ID I have not seen, or the same warning every few minutes.

3. **Time.** The server should take its time from UMNGA-DC1.

```powershell
w32tm /query /source
w32tm /query /status
```

   Normal: the source is UMNGA-DC1.umnga.local, stratum 2, and the last successful sync is recent.

4. **Defender.**

```powershell
Get-MpComputerStatus | Format-List AMServiceEnabled, AntivirusEnabled, RealTimeProtectionEnabled, AntivirusSignatureVersion, AntivirusSignatureLastUpdated, AntivirusSignatureAge
```

   Normal: the first three read True and the signature age is 0 or 1 day. Not normal: any False, or an age that keeps growing.

5. **Backup.**

```powershell
Get-WBSummary | Format-List LastSuccessfulBackupTime, LastBackupResultHR, NumberOfVersions
```

   Normal: the last successful backup is recent and the result code is 0. Anything else needs looking at the same day.

## Monthly, about an hour

1. **Firewall.** Check the profiles are on and that the web rule is still the scoped one.

```powershell
Get-NetFirewallProfile | Format-Table Name, Enabled, DefaultInboundAction, DefaultOutboundAction -AutoSize
Get-NetFirewallRule -DisplayName "Umnga Intranet HTTP from UmngaNet" | Format-Table DisplayName, Enabled, Profile, Action -AutoSize
```

   Normal: Domain, Private and Public all Enabled True, and the Umnga rule Enabled True on Domain. From UMNGA-DC1 the page must still load:

```powershell
Test-NetConnection UMNGA-SVR1 -Port 80 | Format-List ComputerName, RemotePort, TcpTestSucceeded
```

2. **Performance.** Take a baseline only when the server is idle. Wait until the Windows Modules Installer Worker has been gone for five minutes in a row, and then read:

```powershell
Get-Counter -Counter "\Processor Information(_Total)\% Processor Time","\Memory\Available MBytes","\PhysicalDisk(_Total)\% Disk Time" -SampleInterval 5 -MaxSamples 6
```

   My quiet baseline: CPU 7,4% to 18,9% in six samples (4,1% averaged over 1 minute 40 seconds in Performance Monitor), about 2,25 GB of memory available, disk time near 0. When the server looks slow, find the process first:

```powershell
Get-Counter '\Process(*)\% Processor Time' | Select-Object -ExpandProperty CounterSamples | Where-Object { $_.InstanceName -notin '_total','idle' } | Sort-Object CookedValue -Descending | Select-Object -First 6 InstanceName, @{n='CPUpercent';e={[math]::Round($_.CookedValue)}} | Format-Table -AutoSize
```

3. **Restore test.** A backup counts only if a restore works. Delete one test file from C:\UmngaBackupTest, then recover it from the latest version:

```powershell
Get-WBBackupSet | Format-List BackupTime, VersionId
wbadmin start recovery -version:<VersionId> -itemType:File -items:C:\UmngaBackupTest\staff_note_3.txt -recoveryTarget:C:\UmngaBackupTest\ -quiet
```

   Normal: "Successfully recovered", total files failed 0, and the file reads the same as before.

4. **Test the antivirus.** Write the EICAR test string to a test folder, ask Defender what it recorded, then delete the folder. A quiet console is normal, because Defender removes the file after the write. The proof is in Get-MpThreatDetection and events 1116 and 1117 in the Windows Defender Operational log.

## Rules

1. Never leave a NAT adapter on a server. If a server needs internet for updates, add one to that server only, never to the domain controller, stop it registering in DNS, and take it off afterwards.
2. Before you add a firewall rule, list the rules that already exist. Allow traffic from the networks that need it, on the profiles that need it, and name the rule after the service and the source.
3. Do not take a baseline while Windows is servicing. A busy reading is evidence of servicing, not of the normal load.
4. A quiet command is not a failed command. Check what the system recorded.
5. Keep the backup somewhere the server cannot damage. In the lab it is a second virtual disk on the same laptop, which protects against a deleted file and nothing more.

## What this routine does not cover

Patching and backing up UMNGA-DC1 and UMNGA-CORE1, a scheduled backup with retention, a scan of the whole server, performance logging over a day, and a restore onto a rebuilt server. The [README](README.md) lists each of these under Limitations.

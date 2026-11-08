# 01 IT foundation: servers, network and a naming standard

Status: complete (6 November 2026)
Deliverable: Umnga IT Foundation Baseline
Next project: [02 Identity and policy](../02%20Identity%20and%20policy)

## Scenario

Umnga Local Municipality is a made up municipality with about 60 office staff. It has just set up its first ICT servers and has no rule for how they are named or addressed. Every later service (directory, DHCP, file shares, remote access) will sit on these machines, so I agreed a naming and IP standard first and then built each server the same way. That gives every later project a documented starting point.

## Objectives

1. Build three Windows Server 2025 machines on an isolated network called UmngaNet.
2. Write a naming and IP standard ([Naming and IP standard](../docs/Naming%20and%20IP%20standard.md)).
3. Show that each server has the right name, address and time zone, and can reach the other two.
4. Capture a baseline from each server and take a clean snapshot of each.

## Machines

| Name | Address | Install type | Planned role |
|---|---|---|---|
| UMNGA-DC1 | 192.168.20.10 | Desktop Experience | Domain controller |
| UMNGA-SVR1 | 192.168.20.11 | Desktop Experience | Member server |
| UMNGA-CORE1 | 192.168.20.12 | Server Core | Member server managed without a desktop |

## Design decisions

1. One isolated VirtualBox Internal Network called UmngaNet. It keeps lab traffic off the host and the home network, and it behaves like a small office switch with no router and no DHCP.
2. Evaluation media only, with no licence keys anywhere. That keeps keys out of screenshots and the repository.
3. Desktop Experience on DC1 and SVR1, Server Core on CORE1. The desktop makes the work easy to see. Core gives me practice with the smaller install that production teams prefer.
4. Names follow the pattern UMNGA, role code, number, and stay inside the 15 character NetBIOS limit. A name should say what a machine is for.
5. Static addresses by role: .10 directory, .11 member server, .12 Core. Other machines look servers up, so their addresses must not change.
6. No gateway and no DNS server yet. UmngaNet has no router, and DNS is set up properly once the domain controller exists.
7. South Africa Standard Time on every server. Logs, Kerberos and scheduled tasks depend on consistent time.
8. Snapshots are taken only after a state is checked, and are named after the state, for example "Stage1 baseline clean". A snapshot of a broken build is worse than none.

## Implementation

### 1. Virtual machines and network

Created UMNGA-DC1, UMNGA-SVR1 and UMNGA-CORE1 in VirtualBox. DC1 and SVR1 have 4096 MB of memory and CORE1 has 2048 MB. Each has 2 processors. The disks are dynamically allocated: 60 GB for DC1 and SVR1, 40 GB for CORE1. Adapter 1 on each machine is attached to the Internal Network UmngaNet.

Evidence: 01_step01_vm_network_dc1.png, 01_step01_vm_network_svr1.png. I did not take a screenshot of the CORE1 network settings.

### 2. Windows Server 2025 installation

Installed from the evaluation ISO without a product key. DC1 and SVR1 use the Desktop Experience option. CORE1 uses the Standard Evaluation option without it.

Evidence: 01_step02_edition_choice_dc1.png, 01_step02_edition_choice_svr1.png, 01_step02_edition_choice_core1.png

### 3. Guest Additions

Installed the VirtualBox Guest Additions on DC1 for screen and mouse integration. Clipboard sharing may not work on Server Core.

Evidence: 01_step03_guest_additions_dc1.png

### 4. Computer names

Renamed the machines in Server Manager (DC1, SVR1) and with sconfig (CORE1). The PowerShell equivalent is `Rename-Computer -NewName "UMNGA-DC1" -Restart`.

Evidence: 01_step04_computer_name_dc1.png, 01_step04_computer_name_svr1.png, 01_step04_computer_name_core1.png

### 5. Static addresses

Set 192.168.20.10, .11 and .12 with mask 255.255.255.0 and no gateway. On CORE1 sconfig did not apply the address, so I set it in PowerShell instead (`New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.20.12 -PrefixLength 24`). See the troubleshooting log.

Evidence: 01_step05_ipconfig_dc1.png, 01_step05_ipconfig_svr1.png, 01_step05_ipconfig_core1.png

### 6. Time zone

Set (UTC+02:00) Harare, Pretoria on all three servers. The PowerShell equivalent is `Set-TimeZone -Id "South Africa Standard Time"`.

Evidence: 01_step06_timezone_dc1.png, 01_step06_timezone_svr1.png, 01_step06_timezone_core1.png

### 7. Connectivity

The first pings from DC1 failed in two ways: a timeout to SVR1 and "destination host unreachable" to CORE1. Windows Firewall blocks incoming ping by default, so I enabled the "File and Printer Sharing (Echo Request - ICMPv4-In)" rules on each server. I did this on purpose and only on the isolated lab network. After that all six pings between the three servers replied.

Evidence: 01_step07_firewall_rule_svr1.png, 01_step07_firewall_rule_core1.png, 01_step07_ping_after_dc1.png, 01_step07_ping_after_svr1.png, 01_step07_ping_after_core1.png. I did not capture the failing pings from before the change.

### 8. Baseline and snapshots

Ran four read only commands on each server: `hostname`, `Get-NetIPAddress -AddressFamily IPv4`, `Get-TimeZone`, and a check of the install type. Took a snapshot named "Stage1 baseline clean" on each VM.

Evidence: 01_step08_baseline_dc1.png, 01_step08_baseline_svr1.png, 01_step08_baseline_core1.png, 01_step08_snapshots.png

## Verification

1. On all three servers the baseline matched the standard: correct computer name, correct static address with prefix length 24, address origin Manual, time zone South Africa Standard Time, and install type Server on DC1 and SVR1 and Server Core on CORE1.
2. After I enabled the echo request rules, all six pings between the three servers replied.
3. A snapshot named "Stage1 baseline clean" exists on all three VMs.

## Limitations

1. I have no screenshots of the CORE1 network settings or of the failed pings.
2. I typed the baseline commands by hand. No script was used.
3. The command that reads the install type failed on the first attempt, and I did not record the form that finally worked. See the troubleshooting log.

## Files

1. [Captions](evidence/Captions.md)
2. [Troubleshooting log](Troubleshooting%20log.md)
3. [Naming and IP standard](../docs/Naming%20and%20IP%20standard.md)

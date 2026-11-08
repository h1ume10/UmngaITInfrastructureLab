# Troubleshooting log: 01 IT foundation

This log lists only what happened in the lab. Where I did not prove a cause, I say so.

## 1. DC1 showed 10.0.2.15

1. Symptom: ipconfig on UMNGA-DC1 showed 10.0.2.15, not an address on UmngaNet.
2. Cause: 10.0.2.x is the range VirtualBox NAT hands out, so Adapter 1 was attached to NAT.
3. Fix: I shut the VM down, set Adapter 1 to Internal Network UmngaNet and started it again. ipconfig then showed a 169.254 address, which is correct on a network with no DHCP. I then set the static address 192.168.20.10.
4. Takeaway: check the adapter attachment first. 10.0.2.15 means NAT.

## 2. First pings failed in two different ways

1. Symptom: from DC1, ping to 192.168.20.11 (SVR1) timed out, and ping to 192.168.20.12 (CORE1) reported destination host unreachable.
2. Cause: a timeout means the packets were sent and not answered, which fits Windows Firewall blocking incoming ping. Host unreachable means DC1 could not find a machine at that address, which fit entry 3 below.
3. Fix: I enabled the File and Printer Sharing (Echo Request - ICMPv4-In) rules on SVR1 (firewall console), CORE1 (PowerShell) and DC1. After that all six pings between the servers replied.
4. Takeaway: the exact wording of a failure points to different causes, so read it before changing anything.

## 3. CORE1 did not accept its static IP from sconfig

1. Symptom: after I entered the address in sconfig, CORE1 still showed 169.254.
2. Cause: Get-NetAdapter showed one adapter, so it was not a wrong adapter choice. Get-NetIPAddress showed PrefixOrigin WellKnown, which means the address was self assigned and no manual address existed. I think sconfig did not accept an empty default gateway, but I did not prove that.
3. Fix: I set the address in PowerShell with New-NetIPAddress, prefix length 24 and no gateway. The 169.254 address disappeared, and the later baseline showed the correct address.
4. Takeaway: read the result back. PrefixOrigin shows how an address got there.

## 4. Error reading the install type from the registry

1. Symptom: during the baseline, the fourth command reported that a path starting with HKLM could not be found.
2. Cause: most likely the quotes around a path containing a space were lost or changed, so PowerShell stopped reading at the space. I did not prove this.
3. Fix: I retyped the command. I did not record which form finally worked, the corrected registry command or Get-ComputerInfo.
4. Takeaway: paths with spaces need straight quotes.

## Observation, not a fault

SVR1 showed the Product ID as not activated. That is normal for an evaluation install, which runs for 180 days without a key.

## Not recorded

1. Screenshots of the CORE1 network settings and of the failed pings.
2. The final working form of the install type command.

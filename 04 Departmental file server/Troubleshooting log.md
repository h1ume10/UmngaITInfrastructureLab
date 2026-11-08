# Troubleshooting log: 04 Departmental file server

This log lists only what happened in the lab. Where I did not prove a cause, I say so.

## 1. The system disk was attached twice instead of a third new disk

1. Symptom: Storage Pools showed "No storage pools exist". Disk Management showed two new 5 GB disks that asked to be initialised, and a 60 GB disk marked Offline that carried the same partitions as the system disk.
2. Cause: the third disk I added in VirtualBox was the existing system file UMNGA-SVR1.vdi, chosen with Choose existing disk, and not a new disk. Windows saw the same disk twice and marked the copy Offline. The VirtualBox storage list showed UMNGA-SVR1.vdi twice.
3. Fix: with SVR1 powered off, I removed the second attachment of UMNGA-SVR1.vdi only, without deleting the file, and attached SVR1_pool3.vdi in its place. I cancelled the Initialize Disk box on the new disks so they stayed blank.
4. Takeaway: look at the disk list in VirtualBox before you start the server, and never initialise disks you plan to pool.

## 2. A new disk file showed a red error in VirtualBox

1. Symptom: SVR1_pool3.vdi showed a red icon in the Storage settings, with no virtual size and no actual size.
2. Cause: not found. VirtualBox could not read the file, and its creation probably did not finish. I did not inspect the file.
3. Fix: I removed that attachment and created a fresh 5 GB dynamically allocated disk called SVR1_pool3b. Get-PhysicalDisk then showed three 5 GB disks.
4. Takeaway: when a disk shows an error icon, replace it with a new disk, and check that the list shows sizes before you start the server.

## 3. The pool wizard offered one disk, although PowerShell showed three

1. Symptom: the New Storage Pool wizard listed one physical disk. Get-PhysicalDisk showed DeviceId 1, 2 and 3 as 5 GB, CanPool True, and Get-Disk showed them RAW and Online. The Storage Pools page had also shown no pool at first.
2. Cause: the three disks show the same UniqueId, ATAVBOX HARDDISK, because VirtualBox gives no serial number. That is the probable reason the wizard collapsed them into one row. I did not test it.
3. Fix: I created the pool with New-StoragePool in PowerShell. Get-PhysicalDisk -StoragePool lists disks 1, 3 and 2 as members, and Server Manager shows capacity 13.5 GB although its physical disk list shows one row. I did not capture the command output.
4. Takeaway: when a console and PowerShell disagree, trust the object output and say which one you used. Real disks carry unique serial numbers, so this is a limit of the lab.

## 4. The New Volume wizard found no virtual disk

1. Symptom: the wizard said "No related virtual disks exist" for Departments, although New-VirtualDisk had reported OK and Healthy.
2. Cause: the same display problem as entry 3. Get-Disk showed the disk as number 4, RAW, Offline.
3. Fix: I initialised, partitioned and formatted the disk with one PowerShell pipeline. Afterwards Get-Disk shows GPT, Online, IsOffline False, and Get-Volume shows E: labelled Departments, NTFS, Healthy.
4. Takeaway: read the disk state before formatting, and confirm it again afterwards.

## 5. Two typing slips in PowerShell

1. Symptom: the pipeline failed with "The term Initialise-Disk is not recognized as the name of a cmdlet". A Get-Disk command also showed a blank partition style column, because I typed the property as ParitionStyle.
2. Cause: PowerShell uses the American spelling in Initialize-Disk, and a mistyped property name prints an empty column and no error.
3. Fix: I retyped the commands with the correct spelling. Both then ran as expected.
4. Takeaway: when a cmdlet is not recognised, check the spelling first. Read the column headers of a table as well as its values.

## 6. The Effective Access tab showed the previous user's result

1. Symptom: with the Planning user selected, the list still showed Modify level ticks.
2. Cause: I had not clicked View effective access after changing the user, so the list still showed the first result.
3. Fix: I selected the Planning user again and clicked View effective access. The list then showed every item crossed out. I checked the Finance user again the same way and it showed Modify level ticks.
4. Takeaway: click View effective access after every change of user, and keep the user line in view in the screenshot.

## 7. Two screenshots without the user line

1. Symptom: the two effective access screenshots do not show the user line, because it was scrolled out of view, and a taskbar pop up covers part of each.
2. Decision: I kept the screenshots as they are. The captions and the README say that the account names come from my notes.
3. Takeaway: scroll to the top of a window and move the mouse away from the taskbar before taking a screenshot.

## Observations, not faults

1. Get-SmbShare for paths under E:\ lists eight shares, not seven. The extra one is E$, the built in administrative share that Windows creates for every drive, with the path E:\. It does not come from my script.
2. Every folder shows a CREATOR OWNER entry. It is a default entry on the root of a new drive, and it was copied onto each folder when inheritance was turned off. It applies to subfolders and files only, and gives whoever creates an item control over that item.
3. New-VirtualDisk reported a footprint on the pool of 1 GB for a 5 GB thin mirror, and a storage efficiency of 25 percent. Thin provisioning hands out space as it is used.
4. The early Disk Management screenshot shows the VirtualBox snapshot label that was current at the time, "Stage 3 before RDS", because no newer snapshot existed yet.
5. The Server Manager quota pane says File Server Resource Manager must be installed. I did not install it in this project.

## Not recorded

1. The output of the New-StoragePool command.
2. A check that the three disks had different UniqueId values before the pool was made. The screenshot taken afterwards shows them identical.
3. A screenshot of Get-SmbShareAccess for Finance. My notes say Everyone with Full access.
4. How Windows or VirtualBox reported the damaged SVR1_pool3.vdi file, beyond the red icon.
5. The members of GG_Finance, and the groups of the Planning user.

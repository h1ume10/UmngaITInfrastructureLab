# Troubleshooting log: 03 Core services

This log lists only what happened in the lab. Where I did not prove a cause, I say so.

## 1. The reverse zone showed no PTR records at first

1. Symptom: after I created the reverse zone, it listed only the Start of Authority and Name Server records.
2. Cause: the servers register their own PTR records, and the view had not been refreshed. The records appeared after I refreshed the zone view. I did not record whether I also ran ipconfig /registerdns.
3. Fix: refreshed the zone view. The three PTR records for .10, .11 and .12 appeared.
4. Takeaway: refresh the console before assuming a record is missing, and do not create one by hand until a refresh has been tried.

## 2. No disk space for a full test client

1. Symptom: DHCP needed a client to test the scope, and there was no disk space for another installed virtual machine.
2. Cause: a full install is not needed to ask DHCP for an address. The Windows Server Setup environment runs from memory and has a network card.
3. Fix: I created UMNGA-TMP1 with the Windows Server ISO and booted it into Setup without installing.
4. Takeaway: this test did not use a domain joined client, and the README says so.

## 3. The test VM did not reach the Setup screen

1. Symptom: UMNGA-TMP1 did not show the Setup screen on the first start. The ISO was attached to the optical drive and an empty virtual disk was also attached.
2. Cause: the VM tried the empty disk and found nothing to start. The VirtualBox temporary boot device menu then appeared on screen.
3. Fix: pressed c for the CD-ROM in that menu. The Setup screen loaded.

## 4. The client showed no adapter until wpeinit was run

1. Symptom: the first ipconfig /all in the Setup command prompt showed a blank host name.
2. Cause: the Setup command prompt does not always start the network card. After wpeinit, the adapter appeared with a lease. I am not certain of the exact order of my commands.
3. Fix: ran wpeinit, then ipconfig /all again. The client showed 192.168.20.100 from 192.168.20.11.
4. Takeaway: in the Setup environment, run wpeinit before testing the network.

## 5. The RDS wizard was opened on the wrong path

1. Symptom: the role services page of a role based installation was open with every box empty. It was not the Remote Desktop Services installation path.
2. Cause: Add Roles and Features offers two installation types, and the role based one only installs role pieces without a deployment. Nothing had been installed at that point.
3. Fix: I cancelled, then chose Remote Desktop Services installation, Quick Start, Session based desktop deployment. It installed successfully, SVR1 restarted, and Remote Desktop Services appeared in Server Manager.

## 6. The first remote sign in was refused: password must be changed

1. Symptom: mstsc to UMNGA-SVR1.umnga.local as the ICT user showed "You must change your password before logging on the first time."
2. Cause: the accounts from project 02 have "User must change password at next logon" set. Remote Desktop cannot show the change screen, so it blocks the sign in. The setting is working as designed.
3. Fix: I signed in once at the SVR1 console as the same user, changed the temporary password there, and then connected by Remote Desktop. I did not record the new password anywhere.
4. Takeaway: change a new user's temporary password at a console first, or tell the user to do so before they try Remote Desktop.

## 7. A later sign in was refused: not authorised for remote login

1. Symptom: "The connection was denied because the user account is not authorized for remote login."
2. Cause: not found. Likely causes were a user outside GG_ICT or a group missing from Remote Desktop Users on SVR1. Get-ADGroupMember GG_ICT and Get-LocalGroupMember "Remote Desktop Users" would check this, and I did not run either. Signing in as dubel fixed it. I did not record which username I tried first.
3. Fix: signed in as UMNGA\dubel. The session opened and whoami returned umnga\dubel.
4. Takeaway: the message means the account is not on the allowed list, so check which account was typed before changing any group. I have no screenshot of this message.

## 8. A MAC address in a screenshot

1. Symptom: the client ipconfig screenshot showed the MAC address on two lines.
2. Fix: I blurred the Physical Address and DHCPv6 DUID values before keeping the file.

## Observations, not faults

1. nslookup printed "DNS request timed out" and Server: UnKnown before each answer. It was looking for a name for its own server address ::1, which has no reverse record. The answers themselves were correct.
2. In one DHCP screenshot the Reservations folder showed an expand arrow. I did not create a reservation.

## Not recorded

1. A screenshot of the "not authorised" message, and the result of the membership checks.
2. The password the user set at the SVR1 console, which must never be recorded.
3. The IIS firewall rule state, and the replication and dynamic update settings of the reverse zone.

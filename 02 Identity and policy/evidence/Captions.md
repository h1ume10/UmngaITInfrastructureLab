# Evidence captions: 02 Identity and policy

The project has two phases, A (directory) and B (policy and roles). Files carry the prefix 02a_ or 02b_. Every file was opened and checked before it was kept for passwords, licence keys, credentials boxes, tenant names and personal data. The Product ID fragment and a DNS warning visible in three early captures were cropped out, and the MAC address on the CORE1 capture was blurred.

## Phase A: directory

### Shown in the README

1. 02a_step03_new_forest_dc1.png: the promotion wizard on UMNGA-DC1 with Add a new forest selected and the root domain name umnga.local.
2. 02a_step03_promotion_script_dc1.png: the View script page showing the Install-ADDSForest command, with DomainName umnga.local, NetBIOS name UMNGA and Win2025 levels. No password appears in it.
3. 02a_step05_zone_records_dc1.png: DNS Manager on DC1 with the zone umnga.local selected, listing the alias dns (CNAME to umnga-dc1.umnga.local) and the host UMNGA-PRN1 (A record, 192.168.20.50).
4. 02a_step06_ou_tree_dc1.png: Active Directory Users and Computers with the tree expanded: Umnga, Departments with the seven department OUs, Servers and Groups.
5. 02a_step07_groups_dc1.png: the Groups OU with seven security groups, all with Type Security Group, Global.
6. 02a_step08_users_dc1.png: Get-ADUser output on DC1 listing the seven invented users and the OU each one sits in. The Municipal Manager Office user is Nomsa Duka with logon dukan.
7. 02a_step09_join_welcome_svr1.png: the message "Welcome to the umnga.local domain" on UMNGA-SVR1. The server still shows Workgroup behind it and the address 192.168.20.11. The VM title bar shows the snapshot "Stage2A before SVR1 join".
8. 02a_step10_servers_ou_dc1.png: OU Servers on DC1 containing UMNGA-CORE1 and UMNGA-SVR1.

### Supporting files

1. 02a_step02_adds_role_installed_dc1.png: the Add Roles and Features result on UMNGA-DC1: installation succeeded, configuration required, with the link "Promote this server to a domain controller".
2. 02a_step03_domain_signin_dc1.png: the sign in screen of DC1 after promotion, offering UMNGA\Administrator. It shows the account name only. The successful sign in is from my notes.
3. 02a_step04_dns_set_svr1.png: on SVR1, Get-DnsClientServerAddress showing 192.168.20.10, then Resolve-DnsName for umnga.local and UMNGA-DC1.umnga.local, both answering 192.168.20.10.
4. 02a_step04_dns_set_core1.png: the same on CORE1, including Get-NetAdapter and the Set-DnsClientServerAddress command. The MAC address is blurred.
5. 02a_step05_resolve_svr1.png: on SVR1, Resolve-DnsName answering 192.168.20.50 for UMNGA-PRN1.umnga.local and the CNAME dns.umnga.local pointing to umnga-dc1.umnga.local, which resolves to 192.168.20.10.
6. 02a_step08_first_user_dc1.png: the Member Of tab of Thabo Ndlovu showing Domain Users and GG_Finance.
7. 02a_step09_computers_ou_dc1.png: OU Servers with UMNGA-SVR1 only, before CORE1 was joined.

## Phase B: policy and roles

1. 02b_step02_gpo_linked_servers_dc1.png: Group Policy Management on UMNGA-DC1 with OU Servers selected. The Linked Group Policy Objects tab lists Umnga Servers Logon Notice with link order 1, Enforced No, Link Enabled Yes and GPO Status Enabled. The VM title bar shows the snapshot "Stage 2B before GPO".
2. 02b_step02_gpo_settings_dc1.png: the Settings tab of the same GPO. Under Computer Configuration, Security Options, Interactive Logon, the message title is "Umnga ICT Notice" and the message text is "Umnga Local Municipality. Authorised use only. Activity may be monitored." User Configuration shows no settings.
3. 02b_step03_logon_notice_svr1.png: the sign in screen of UMNGA-SVR1 after a sign out, showing the notice with the title Umnga ICT Notice and the message text. This shows the policy reached the server.
4. 02b_step03_gpresult_core1.png: the CORE1 command window running gpresult /scope computer /r. It shows the computer account in OU=Servers,OU=Umnga,DC=umnga,DC=local, the policy applied from UMNGA-DC1.umnga.local, and Umnga Servers Logon Notice and Default Domain Policy under Applied Group Policy Objects. The empty Local Group Policy is listed as filtered out.
5. 02b_step04_fsmo_roles_dc1.png: netdom query fsmo on DC1, showing the Schema master, Domain naming master, PDC, RID pool manager and Infrastructure master all on UMNGA-DC1.umnga.local.

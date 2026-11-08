# Evidence captions: 01 IT foundation

All 24 screenshots were taken in VirtualBox on the three lab servers. Each was checked before it was saved for passwords, licence keys, the Product ID, tenant names and personal data. Screenshots that showed a MAC address were blurred.

I did not take two screenshots: the CORE1 network settings, and the failed pings from DC1 before the firewall change. The README says so.

1. 01_step01_vm_network_dc1.png: UMNGA-DC1 network settings with Adapter 1 attached to the Internal Network UmngaNet.
2. 01_step01_vm_network_svr1.png: UMNGA-SVR1 network settings with Adapter 1 attached to the Internal Network UmngaNet.
3. 01_step02_edition_choice_dc1.png: the edition choice for DC1, Standard Evaluation with Desktop Experience.
4. 01_step02_edition_choice_svr1.png: the edition choice for SVR1, Standard Evaluation with Desktop Experience.
5. 01_step02_edition_choice_core1.png: the edition choice for CORE1, Standard Evaluation without Desktop Experience.
6. 01_step03_guest_additions_dc1.png: the VirtualBox Guest Additions installed on DC1.
7. 01_step04_computer_name_dc1.png: the computer name UMNGA-DC1.
8. 01_step04_computer_name_svr1.png: the computer name UMNGA-SVR1.
9. 01_step04_computer_name_core1.png: the `hostname` command on CORE1 printing UMNGA-CORE1.
10. 01_step05_ipconfig_dc1.png: DC1 with address 192.168.20.10, mask 255.255.255.0 and no gateway.
11. 01_step05_ipconfig_svr1.png: SVR1 with address 192.168.20.11, mask 255.255.255.0 and no gateway.
12. 01_step05_ipconfig_core1.png: CORE1 with address 192.168.20.12, mask 255.255.255.0 and no gateway.
13. 01_step06_timezone_dc1.png: DC1 set to (UTC+02:00) Harare, Pretoria.
14. 01_step06_timezone_svr1.png: SVR1 set to (UTC+02:00) Harare, Pretoria.
15. 01_step06_timezone_core1.png: CORE1 set to (UTC+02:00) Harare, Pretoria.
16. 01_step07_firewall_rule_svr1.png: the Echo Request inbound rules enabled on SVR1.
17. 01_step07_firewall_rule_core1.png: the Echo Request rules read back as enabled on CORE1 in PowerShell.
18. 01_step07_ping_after_dc1.png: DC1 pinging SVR1 and CORE1 with replies.
19. 01_step07_ping_after_svr1.png: SVR1 pinging DC1 and CORE1 with replies.
20. 01_step07_ping_after_core1.png: CORE1 pinging DC1 and SVR1 with replies.
21. 01_step08_baseline_dc1.png: the DC1 baseline: name, address, time zone and install type.
22. 01_step08_baseline_svr1.png: the SVR1 baseline: name, address, time zone and install type.
23. 01_step08_baseline_core1.png: the CORE1 baseline: name, address with origin Manual, time zone and install type.
24. 01_step08_snapshots.png: the snapshot list showing "Stage1 baseline clean" on each VM.

# Troubleshooting log: 02 Identity and policy

This log lists only what happened in the lab. Where I did not prove a cause, I say so. Phase A is the directory build and phase B is policy and roles.

## Phase A: directory

### 1. A concern about using .local

1. Symptom: not a fault. Before the promotion wizard I read that umnga.local causes problems in some environments.
2. Cause: the concern is valid for production. The suffix .local is reserved for multicast DNS, and it cannot be verified as a custom domain in Microsoft 365 or Entra ID, so a different UPN suffix would be needed. The usual workaround is split DNS, where an internal and an external zone share a public name. A private lab with its own DNS server does not need it.
3. Decision: I kept umnga.local for the lab and noted the production caveat in the README.
4. Takeaway: a choice that is fine in a lab can be wrong in production, so write down which one you made and why.

### 2. "Error when launching" when opening PowerShell or cmd

1. Symptom: opening PowerShell or cmd showed an error beginning "Error when launching '%SystemRoot%\system32...". I did not record which server showed it or the 0x error code.
2. Cause: not found. The wording resembles the message Windows Terminal shows when it cannot start a shell. I guessed that Windows Terminal had not been set up for the new domain profile, but I did not prove it, and a web search found nothing that confirmed a cause.
3. Workaround: start PowerShell with Win+R, or with Task Manager, Run new task.
4. Outcome: later screenshots show PowerShell opening normally in a Windows Terminal window on SVR1 and on DC1, so the problem did not last. I did not record what cleared it.
5. Takeaway: write down the exact error code and the machine when an error appears. Without them I cannot diagnose it afterwards.

### 3. The OU listing returned 12 rows, not 11

1. Symptom: Get-ADOrganizationalUnit returned 12 rows while my plan had 11 OUs.
2. Cause: the command lists every OU in the domain. The extra row was the built in Domain Controllers OU created at promotion. The other 11 names matched the plan.
3. Fix: none needed. My expected count was wrong, not the build.

### 4. A cut off column and uneven group icons

1. Symptom: in the first Groups screenshot the Type column was cut off, so the scope was not visible, and three of the seven icons looked a different colour from the others.
2. Cause: I could only confirm the scope by widening the column. After I retook the screenshot all seven read Security Group, Global with the same icon. I did not find the cause of the colour difference.
3. Fix: retook the screenshot with the columns widened.

### Not recorded in phase A

1. Any warnings shown by the promotion Prerequisites Check.
2. The output of the member count check for the seven groups.

## Phase B: policy and roles

No fault occurred. Every step gave the expected result.

### Observation, not a fault

1. The empty Local Group Policy is listed in gpresult as filtered out ("Not Applied (Empty)"). That is normal when no local policy is set.

### Not recorded in phase B

1. A screenshot of the CORE1 sign in screen with the notice. The CORE1 result rests on the gpresult output.

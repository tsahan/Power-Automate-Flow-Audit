# Power Automate Flow Auditor 
 A PowerShell script that returns all flows from all environments where the authorized user is an Environment Admin. For Global admins, it searches across all environments in the tenant. 
 
## 1. Prerequisites
- Node.js
- CLI for Microsoft 365
- The Power Apps Admin PowerShell module
- A service account is added as an owner to all flows using [this script.](set-AdminFlowOwnerRole.ps1)
- Azure AD app registration for automation: Power Automate OAuth is created for this. (Optional)

### 1.1 How to Install the CLI for Microsoft 365
`npm install -g @pnp/cli-microsoft365`

### 1.2 How to Install the Power Apps Admin PowerShell module
`Install-Module -Name Microsoft.PowerApps.Administration.PowerShell`

## 2. Results
 The output is a csv file with the following information for each flow:
 - FlowDisplayName
 - FlowStatus
 - EnvironmentDisplayName
 - Users
 - LastRunStatus
 - LastRunTime
 - CreatedTime
 - LastModifiedTime
 - FlowName
 - EnvironmentName

### 2.1 Notations
 - NoUser: Found a user id once was associated with a flow, but cannot find the user email of it.
 - NoUID: Found a user record once was associated with a flow, but cannot find the user id or email of it.
 - Blank space in the users field: Couldn't identify a user associated with a flow.

## 3. Adding Owner to a Flow
Use [this script](set-AdminFlowOwnerRole.ps1) to add an account to all flows. You can modify the script for adding a different user or adding an owner to only a specific flow after obtaining user and flow ids. Check References for more information about getting ids.

## 4. Error Handling
In case of TLS related errors that may occur on the servers, use this command in PowerShell:

`[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12`

## 5. Remarks
- Fetching last run status and last run time requires authorized user to be an owner in flows searched.
- Microsoft doesn't keep run logs that are older than 28 days in accordance with the General Data Protection Regulation (GDPR). So, if a flow was activated more than 28 days ago, the last run time will be blank.

## 6. References
- [CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/)
- [Microsoft.PowerApps.Administration.PowerShell](https://learn.microsoft.com/en-us/powershell/module/microsoft.powerapps.administration.powershell/?view=pa-ps-latest)


> Developed by Tugce Sahan, 2022.

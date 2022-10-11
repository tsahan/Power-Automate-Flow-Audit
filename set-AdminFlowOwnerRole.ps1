$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}

# get environments
$envs = m365 flow environment list --output json | ConvertFrom-JSON

# set variable to name property - select evironement using index value
# $environment = ""

# uid for the automation account, modify uid to add a different account.
$uid = ""

foreach ($environment in $envs.name) {
	# find flows
	$flows = m365 flow list --environment $environment --asAdmin --output json | ConvertFrom-JSON

	# display number of flows
	Write-Host "Found $($flows.Count) Flows to check..." -ForegroundColor Magenta
	
	foreach ($flow in $flows) {
	   
		# find the runs of each flows
		Set-AdminFlowOwnerRole -PrincipalType User -PrincipalObjectId $uid -RoleName CanEdit -FlowName $flow.name -EnvironmentName $environment       
	}
}

Write-Host 'Done!'
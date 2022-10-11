$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}

# get environments
$envs = m365 flow environment list --output json | ConvertFrom-JSON

# check environment data as we need to use the relevant environment name property 
# $envs.name

# set variable to name property - select evironment using index value
# $envs[1].name

foreach ($env in $envs) {

	# find flows
	$flows = m365 flow list --environment $env.name --asAdmin --output json | ConvertFrom-JSON

	# display number of flows
	Write-Host "Found $($flows.Count) flows to check in $($env.displayName)" -ForegroundColor Magenta
	
	foreach ($flow in $flows) {
        
        $users = @()

        Get-AdminFlowOwnerRole -EnvironmentName $env.name -FlowName $flow.name | `
        ForEach-Object { if ($_.PrincipalObjectId) { `
        $user = Get-UsersOrGroupsFromGraph -ObjectId $_.PrincipalObjectId; if ($user) {$users += $user.UserPrincipalName} else {$users += 'NoUser'}} else {$users += 'NoUID'}}

        $users_str = "{$($users -join ', ')}"
                   
        # find the runs of each flows
		$flowruns  = m365 flow run list -f $flow.name -e $env.name | ConvertFrom-JSON            
		
		if($flowruns.count -gt 0){
		
			# Write-Host "Checking...   $($flow.displayName) " -ForegroundColor Yellow
			# get the latest run of the workflow
			$run = $flowruns[0] 

			# display on screen message
			# If ($run.status -eq "Succeeded"){
				# Write-Host "$($run.status)  :  $([DateTime] $run.starttime)" -ForegroundColor Green
			# }else{
				# Write-Host "$($run.status) :  $([DateTime] $run.starttime)" -ForegroundColor Red
			# }

			$logs += @([PSCustomObject]@{
				FlowDisplayName = $flow.displayName
                FlowStatus = $flow.properties.state	            
                EnvironmentDisplayName = $env.displayName
                Users = $users_str                             			
				LastRunStatus = $run.status
				LastRunTime = [DateTime] $run.starttime
                CreatedTime = $flow.properties.createdTime
                LastModifiedTime = $flow.properties.lastModifiedTime
                FlowName = $flow.name
                EnvironmentName = $env.name})
			
		}
		else{
			$logs += @([PSCustomObject]@{
				FlowDisplayName = $flow.displayName
                FlowStatus = $flow.properties.state	            
                EnvironmentDisplayName = $env.displayName
                Users = $users_str                             			
				LastRunStatus = ''
				LastRunTime = ''
                CreatedTime = $flow.properties.createdTime
                LastModifiedTime = $flow.properties.lastModifiedTime
                FlowName = $flow.name
                EnvironmentName = $env.name})
		}
			
	}
}

Write-Host 'Completed checking flows across all environments.' -ForegroundColor Green

if ($logs){
	$logs | Export-Csv -Path "Flows_Audit_$(Get-Date -f yyyy-MM-dd-HH-mm).csv" -NoTypeInformation
}





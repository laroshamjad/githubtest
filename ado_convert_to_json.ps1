[CmdletBinding()]
param (
    [string]$ado_pat, # Azure DevOps PAT
    [string]$ado_org, # Azure devops org without the URL, eg: "MyAzureDevOpsOrg"
    [string]$ado_project, # Team project name that contains the work items, eg: "TailWindTraders"
    [string]$ado_area_path, # Area path in Azure DevOps to migrate; uses the 'UNDER' operator)
    [bool]$ado_migrate_closed_workitems = $false, # migrate work items with the state of done, closed, resolved, and removed
    [bool]$ado_production_run = $false, # tag migrated work items with 'migrated-to-github' and add discussion comment
    [bool]$gh_update_assigned_to = $false, # try to update the assigned to field in GitHub
    [string]$gh_assigned_to_user_suffix = "", # the emu suffix, ie: "_corp"
    [bool]$gh_add_ado_comments = $false # try to get ado comments
)

# Set the auth token for az commands
$env:AZURE_DEVOPS_EXT_PAT = $ado_pat;

az devops configure --defaults organization="https://dev.azure.com/$ado_org" project="$ado_project"

# Add the WIQL to not migrate closed work items
if (!$ado_migrate_closed_workitems) {
    $closed_wiql = "[State] <> 'Done' and [State] <> 'Closed' and [State] <> 'Resolved' and [State] <> 'Removed' and"
}

$wiql = "select [ID], [Title], [System.Tags] from workitems where $closed_wiql [System.AreaPath] UNDER '$ado_area_path' and not [System.Tags] Contains 'copied-to-github' order by [ID]";

$query = az boards query --wiql $wiql | ConvertFrom-Json

Remove-Item -Path ./temp_comment_body.txt -ErrorAction SilentlyContinue
Remove-Item -Path ./temp_issue_body.txt -ErrorAction SilentlyContinue

# Initialize an array to store work items' details
$workitems_details = @()
$count = 0;

# Process each work item
ForEach($workitem in $query) {
    $workitemId = $workitem.id;

    $details_json = az boards work-item show --id $workitem.id --output json
    $details = $details_json | ConvertFrom-Json

    # Add the work item details to the array
    $workitems_details += $details

    $count++;

    Write-Host "Processed work item $($workitem.id)"
}

# Output the work items' details to a JSON file
$workitems_details | ConvertTo-Json -Depth 10 | Out-File -FilePath ./workitems_details.json -Encoding ASCII

Write-Host "Total items processed: $($count)"

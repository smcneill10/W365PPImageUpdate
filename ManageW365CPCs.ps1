# Need to have PowerShell 7 or higher https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.3

# Need to have the https://pedholtlab.com/get-started-with-windows-365-and-powershell/
# https://learn.microsoft.com/en-us/powershell/microsoftgraph/authentication-commands?view=graph-powershell-1.0

#MS Graph API permissions for Cloud PCs https://learn.microsoft.com/en-us/graph/permissions-reference#cloud-pc-permissions

Function Get-CloudPCData  
    {
    write-host ""
    write-host ""
    write-host ""
    $CPCs = Get-MgDeviceManagementVirtualEndpointCloudPc -Property DisplayName, UserPrincipalName, ManagedDeviceName, ID, Status, ProvisioningPolicyId, ProvisioningPolicyName, ImageDisplayName, ServicePlanName, PowerState

    $Counter = 0
    foreach ($CPC in $CPCs)
    {
        $counter++
        $RunningStatus = "Running"
        If ($null -ne $CPC.PowerState)
            {
                $runningStatus = $CPC.Powerstate

                Write-Host "Select" $Counter "for" $CPC.ManagedDeviceName "    " $runningStatus
            }
        Else
            {
                write-Host "Select" $Counter "for" $CPC.ManagedDeviceName 
            }
    }
  
    Write-host "Select 0 to exit"
    Write-Host ""
  
    [int]$Selection1 = Read-Host "enter number for more info and to Manage a CPC "
    If ($Selection1 -eq 0) {Write-Host "Thanks and See Ya"; Break}
    If ($Selection1 -gt $counter) {Write-host ""; Write-host "Out of band selection, please select again" -backgroundcolor Red; Get-CloudPCData}
    $choosenCPC = $selection1 -1
    Write-host ""
    Write-host $choosenCPC
    $FGColor = "white"
    $BKColor = "Green"

    #   Write-Host "Select" $Counter "to manage this Cloud PC Management"  -ForegroundColor $FGColor 
        Write-Host "" -BackgroundColor $BKColor
        Write-Host "Cloud PC Display Name:" $CPCs[$choosenCPC].DisplayName -ForegroundColor $FGColor -BackgroundColor $BKColor
        Write-Host "Cloud PC User Name:" $CPCs[$choosenCPC].UserPrincipalName -ForegroundColor $FGColor -BackgroundColor $BKColor
        write-host "CLoud PC NETBIOS Name:" $CPCs[$choosenCPC].ManagedDeviceName -ForegroundColor $FGColor -BackgroundColor $BKColor
        Write-Host "Cloud PC ID:"  $CPCs[$choosenCPC].Id -ForegroundColor $FGColor -BackgroundColor $BKColor
        Write-Host "Cloud PC Status:"  $CPCs[$choosenCPC].Status -ForegroundColor $FGColor -BackgroundColor $BKColor
        Write-Host "Cloud PC Provisioning Policy ID:"$CPCs[$choosenCPC].ProvisioningPolicyId -ForegroundColor $FGColor -BackgroundColor $BKColor
        Write-Host "Cloud PC Provisioning Policy Name:"$CPCs[$choosenCPC].ProvisioningPolicyName -ForegroundColor $FGColor -BackgroundColor $BKColor
        Write-Host "Cloud PC Provisioning Policy Image Name:"$CPCs[$choosenCPC].ImageDisplayName -ForegroundColor $FGColor -BackgroundColor $BKColor
        Write-Host "Cloud PC Sevice Plan Name:"$CPCs[$choosenCPC].ServicePlanName -ForegroundColor $FGColor -BackgroundColor $BKColor
        If ($null -ne $CPCs[$choosenCPC].PowerState )
        {Write-Host "Cloud PC Power State:"$CPCs[$choosenCPC].PowerState -ForegroundColor $FGColor -BackgroundColor $BKColor}
        Write-Host ""


    # https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.devicemanagement.actions/restart-mgdevicemanagementvirtualendpointcloudpc?view=graph-powershell-beta
    [int]$Selection2 = Read-Host "Enter 1 for START, Enter 2 for STOP, Enter 3 for RESTART, Enter 4 for CONNECT HISTORY, Enter 5 for BACK, Enter 6 to EXIT "

    Switch ($Selection2)
    {
    #1 { Start-MgDeviceManagementVirtualEndpointCloudPcOn -CloudPCId $CPCs[$choosenCPC].Id }
    1 {Start-MgDeviceManagementVirtualEndpointCloudPcOn -CloudPCId $CPCs[$choosenCPC].Id}
    1 {write-host 'Starting'  $CPCs[$choosenCPC].DisplayName}
    1 {Get-CloudPCData}
    2 { Start-MgDeviceManagementVirtualEndpointCloudPcOff -CloudPCId $CPCs[$choosenCPC].Id }
    2 {write-host 'Stopping ' $CPCs[$choosenCPC].DisplayName}
    2 {Get-CloudPCData}
    3 { Restart-MgDeviceManagementVirtualEndpointCloudPc -CloudPcId $CPCs[$choosenCPC].Id }
    3 {write-host 'Re-Starting ' $CPCs[$choosenCPC].DisplayName}
    3 {Get-CloudPCData}
    4 {write-host 'Connectivity test for '$CPCs[$choosenCPC].DisplayName }
    4 {write-host ""}
    4 {Get-MgDeviceManagementVirtualEndpointCloudPcConnectivityHistory  -CloudPcId $CPCs[$choosenCPC].Id |out-file -filepath .\connectlog.txt }
    4 {$ConnectHistory = Get-Item .\connectlog.txt}
    4 {if ($ConnectHistory.Length -gt 1) {get-content -path .\connectlog.txt} Else {Write-host "" -backgroundcolor Red; Write-host "No connection history available" -backgroundcolor Red}}
    4 {[int]$exportConHis = Read-Host "Enter 1 to Export; 2 to Continue"}
    4 {if ($exportConHis -eq 1) {$SaveHistoryPath = read-host "enter location for file export (user must have access, c:\location\filename.txt)"; Get-MgDeviceManagementVirtualEndpointCloudPcConnectivityHistory  -CloudPcId $CPCs[$choosenCPC].Id |out-file -filepath $SaveHistoryPath }; Write-host ""; Write-host "File exported as" $savehistorypath}; Else {Get-cloudpcData}
    4 {}
    4 {Get-CloudPCData}
    5 {Clear-host}
    5 {Get-CloudPCData}
    6 {Write-Host 'See Ya'}
    6 {break}
    Default { ‘unable to determine value of entered’ }
    }
}


#Connect to CloudPC Graph API 
Connect-MgGraph -Scopes "CloudPC.ReadWrite.All, User.Read.All","Group.Read.All, CloudPC.read.all"
# Set Graph API to Beta
Select-MgProfile Beta

#Gathers the connection info, comment out the Clear-Host line below to see this info, helps with connectivity issues
Get-MgContext
Clear-Host


#Get Gallery Images
$GalleryImagesRaw = Get-MgDeviceManagementVirtualEndpointGalleryImage

# Will need to create logic to determine newest Image for Win 10 and 11 and both versions
#This version just assumes location of latest versions is array
#$LatestW11OS = $GalleryImagesRaw[0]
$LatestW11M365 = $GalleryImagesRaw[1]

#Get Provisioning Policies
$ProvisionPolicysRaw = get-MgDeviceManagementVirtualEndpointprovisioningpolicy

Write-Host ""
Write-Host "Here are your existing Windows 365 Provisioning Policies"
$provisionpolicysraw |Format-Table -property Displayname,provisioningType,enablesinglesignon,Imagedisplayname
$DemoPolicyFound = $False
foreach ($PolicyRaw in $provisionPolicysRaw) 
    {
    if ($PolicyRaw.DisplayName -like "*Demo Policy*")
        {
        $LatestPolicy = $PolicyRaw
        $DemoPolicyFound = $True
        If ($LatestPolicy.ImageID -eq $LatestW11M365.Id)
            {
            
            Write-Host "Latest Gallery Image in use for"$LatestPolicy.DisplayName"="$LatestW11M365.DisplayName
            Write-Host
            Write-Host "No chages made"
            Write-Host
            }
        Else
            {
            Write-host "Updating"$LatestPolicy.DisplayName"to"$LatestW11M365.Displayname
            Update-MgDeviceManagementVirtualEndpointProvisioningPolicy -CloudPcProvisioningPolicyId $LatestPolicy.Id -ImageDisplayName $LatestW11M365.DisplayName -ImageId $LatestW11M365.Id
            Write-host "...."
            Write-host "...."
            Write-host "...."
            $ProvisionPolicysRaw2 = get-MgDeviceManagementVirtualEndpointprovisioningpolicy

            Write-Host "Here are the updated Provisioning Policies"
            $provisionpolicysraw2 |Format-Table -property Displayname,provisioningType,enablesinglesignon,Imagedisplayname
            }
        }
    }

If (-not $DemoPolicyFound)
    {
    Write-host "Demo Policy not found"
    }



#Call the Manage_cpc function   
Get-CloudPCData




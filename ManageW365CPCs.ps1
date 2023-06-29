# Need to have PowerShell 7 or higher https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.3

# Need to have the https://pedholtlab.com/get-started-with-windows-365-and-powershell/
# https://learn.microsoft.com/en-us/powershell/microsoftgraph/authentication-commands?view=graph-powershell-1.0

#MS Graph API permissions for Cloud PCs https://learn.microsoft.com/en-us/graph/permissions-reference#cloud-pc-permissions

#Function to gather CPC info and allow for mgmt
Function Get-CloudPCData  
    {
    write-host "" -BackgroundColor $BKColorInfo -ForegroundColor $FGColor
    $CPCs = Get-MgDeviceManagementVirtualEndpointCloudPc -Property DisplayName, UserPrincipalName, ManagedDeviceName, ID, Status, ProvisioningPolicyId, ProvisioningPolicyName, ImageDisplayName, ServicePlanName, PowerState

    $Counter = 0
    foreach ($CPC in $CPCs)
    {
        $counter++
        $RunningStatus = "Running"
        If ($null -ne $CPC.PowerState)
            {
                $runningStatus = $CPC.Powerstate

                Write-Host "Select" $Counter "for" $CPC.ManagedDeviceName "    " $runningStatus -BackgroundColor $BKColorInfo
            }
        Else
            {
                write-Host "Select" $Counter "for" $CPC.ManagedDeviceName  -BackgroundColor $BKColorInfo -ForegroundColor $FGColor
            }
    }
  
    Write-host "Select 0 to exit" -BackgroundColor $BKColorInfo -ForegroundColor $FGColor
    Write-Host "" -BackgroundColor $BKColorInfo -ForegroundColor $FGColor
  
    [int]$Selection1 = Read-Host "enter number for more info and to Manage a CPC " 
    If ($Selection1 -eq 0) {Write-Host "Thanks and See Ya" -BackgroundColor $BKColorInfo -ForegroundColor $FGColor; Break} 
    If ($Selection1 -gt $counter) {Write-host ""; Write-host "Out of band selection, please select again" -ForegroundColor $FGColor -backgroundcolor $BKColorBad; Get-CloudPCData}
    $choosenCPC = $selection1 -1

    #$FGColor = "white"
    #$BKColor = "Green"

    #   Write-Host "Select" $Counter "to manage this Cloud PC Management"  -ForegroundColor $FGColor 
        Write-Host "" -BackgroundColor $BKColorInfo -ForegroundColor $FGColor
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
        Write-Host "" -BackgroundColor $BKColorInfo -ForegroundColor $FGColor


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
    3 {Restart-MgDeviceManagementVirtualEndpointCloudPc -CloudPcId $CPCs[$choosenCPC].Id }
    3 {write-host 'Re-Starting ' $CPCs[$choosenCPC].DisplayName}
    3 {Get-CloudPCData}
    4 {Get-CPCConnectHistory $CPCs[$choosenCPC].DisplayName $CPCs[$choosenCPC].Id}
    #4 {Clear-Host}
    4 {Get-CloudPCData}
    5 {Clear-host}
    5 {Get-CloudPCData}
    6 {Write-Host 'See Ya'}
    6 {break}
    Default {Get-CloudPCData }
    }
}

#Function for getting the Connectivity History
Function Get-CPCConnectHistory ($CPCCHDisplay, $CPCCHID)
{
    write-host 'Connectivity test for ' $CPCCHDisplay 
    #Get the users temp folder location
    $TempFolder = $env:TEMP
    $TempFolder
    
    Get-MgDeviceManagementVirtualEndpointCloudPcConnectivityHistory  -CloudPcId $CPCCHID |out-file -filepath ($TempFolder + "\connectlog.txt") 
    $ConnectHistory = Get-Item ($TempFolder + "\connectlog.txt")
    if ($ConnectHistory.Length -gt 1) 
        {
            Out-File -FilePath ($TempFolder + "\connectlogclean.txt") 
            foreach ($line in Get-Content ($TempFolder + "\connectlog.txt"))
            {
                If ($Line -match "deviceHealthCheck")
                {}
                Else
                {
                    $line |Out-file -FilePath ($TempFolder + "\connectlogclean.txt") -append
                }
            }
            get-content -path ($TempFolder + "\connectlogclean.txt")    
        }
    Else
        {
            Write-host "" -backgroundcolor Red; Write-host "No connection history available" -backgroundcolor $bkcolor
        }
    
    [int]$exportConHis = Read-Host "Enter 1 to Export; 2 to Continue"
    if ($exportConHis -eq 1) 
        {
            $SaveHistoryPath = read-host "enter location for file export (user must have access, c:\location\filename.txt)"
            $Connectionhistoryexport = get-content ($TempFolder + "\connectlogclean.txt")
            Write-host ""
            
            $Connectionhistoryexport | Out-File -FilePath $SaveHistoryPath
            $connectionhistoryexport
            Write-host "File exported as" $savehistorypath
        } 
    Else 
        {
            Get-cloudpcData
        }
     
}

#Function for getting the Provisioning policy info
Function Get-ProvisionPolicyInfo
{
    #Get Gallery Images
    $GalleryImagesRaw = Get-MgDeviceManagementVirtualEndpointGalleryImage

    # Will need to create logic to determine newest Image for Win 10 and 11 and both versions
    #This version just assumes location of latest versions is array
    #$LatestW11OS = $GalleryImagesRaw[0]
    $LatestW11M365 = $GalleryImagesRaw[1]

    #Get Provisioning Policies
    $ProvisionPolicysRaw = get-MgDeviceManagementVirtualEndpointprovisioningpolicy

    Write-Host "" -BackgroundColor $BKColorInfo -ForegroundColor $FGColor
    Write-Host "Here are your existing Windows 365 Provisioning Policies" -BackgroundColor $BKColorInfo -ForegroundColor $FGColor
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
                
                Write-Host "Latest Gallery Image in use for"$LatestPolicy.DisplayName"="$LatestW11M365.DisplayName -BackgroundColor $BKColorInfo -ForegroundColor $FGColor
                Write-Host -BackgroundColor $BKColorInfo -ForegroundColor $FGColor
                Write-Host "No chages made" -BackgroundColor $BKColorInfo -ForegroundColor $FGColor
                Write-Host -BackgroundColor $BKColorInfo -ForegroundColor $FGColor
                }
            Else
                {
                Write-host "Updating"$LatestPolicy.DisplayName"to"$LatestW11M365.Displayname -BackgroundColor $BKColorInfo -ForegroundColor $FGColor
                Update-MgDeviceManagementVirtualEndpointProvisioningPolicy -CloudPcProvisioningPolicyId $LatestPolicy.Id -ImageDisplayName $LatestW11M365.DisplayName -ImageId $LatestW11M365.Id
                Write-host "...."-BackgroundColor $BKColorInfo -ForegroundColor $FGColor
               
                $ProvisionPolicysRaw2 = get-MgDeviceManagementVirtualEndpointprovisioningpolicy

                Write-Host "Here are the updated Provisioning Policies" -BackgroundColor $BKColorInfo -ForegroundColor $FGColor
                $provisionpolicysraw2 |Format-Table -property Displayname,provisioningType,enablesinglesignon,Imagedisplayname
                }
            }
        }

    If (-not $DemoPolicyFound)
        {
        Write-host "Demo Policy not found" -BackgroundColor $BKColorBad -ForegroundColor $FGColor
        }
}
#write a function to get the username of the user

#Display Preferences
$FGColor = "white"
$BKColor = "Black"
$BKColorBad = "Red"
$BKColorGood = "Green"
$BKColorinfo = "black"

#Connect to CloudPC Graph API 
Connect-MgGraph -Scopes "CloudPC.ReadWrite.All, User.Read.All","Group.Read.All, CloudPC.read.all"
# Set Graph API to Beta
Select-MgProfile Beta

#Gathers the connection info, comment out the Clear-Host line below to see this info, helps with connectivity issues
Write-host "Here is the connection information used:" -BackgroundColor $BKColorInfo -ForegroundColor $FGColor
Get-MgContext
#Clear-Host



# Write a function to get the username of the logged in user
 $username = Get-ChildItem env:username
 $username = $username.value
 $username

#call the Provisioning Policy Info Fuction
Get-ProvisionPolicyInfo

#Call the Manage_cpc function   
Get-CloudPCData





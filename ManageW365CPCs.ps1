# Need to have PowerShell 7 or higher https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.3

# Need to have the https://pedholtlab.com/get-started-with-windows-365-and-powershell/
# https://learn.microsoft.com/en-us/powershell/microsoftgraph/authentication-commands?view=graph-powershell-1.0

#MS Graph API permissions for Cloud PCs https://learn.microsoft.com/en-us/graph/permissions-reference#cloud-pc-permissions


#Display Preferences
$FGColor = "white"
$BKColor = "Black"
$BKColorBad = "Red"
$BKColorGood = "Green"
$BKColorinfo = "black"

#Function to gather CPC info and allow for mgmt
Function Get-CloudPCData  
{
    #search for a CPC
    #create a searchable hashtable of all Windows 365 Cloud PCs
    $CPCs = Get-MgDeviceManagementVirtualEndpointCloudPc -Property DisplayName, UserPrincipalName, ManagedDeviceName, ID, Status, ProvisioningPolicyId, ProvisioningPolicyName, ImageDisplayName, ServicePlanName, PowerState
    $CPCs = $CPCs | Select-Object DisplayName, UserPrincipalName, ManagedDeviceName, ID, Status, ProvisioningPolicyId, ProvisioningPolicyName, ImageDisplayName, ServicePlanName, PowerState
    $CPCs = $CPCs | Sort-Object -Property DisplayName
    $CPCs = $CPCs | Out-GridView -PassThru -Title "Select a Cloud PC to manage"
    $CPCs = $CPCs | Select-Object DisplayName, UserPrincipalName, ManagedDeviceName, ID, Status, ProvisioningPolicyId, ProvisioningPolicyName, ImageDisplayName, ServicePlanName, PowerState
           

    
        $choosenCPC = $selection1 -1
        #Create an output using gridview to show the properties of the selected CPC
        $CPCs[$choosenCPC] | out-file -filepath ($TempFolder + "\CPCInfo.txt") 

        #create hashtable of the selected CPC
        $CPCHash =@{}

        foreach ($line in Get-Content ($TempFolder + "\CPCInfo.txt"))
        {
            $lineSplit = $line -split ":"
            Write-host $lineSplit[0] $lineSplit[1] -BackgroundColor $BKColorInfo -ForegroundColor $FGColor
            $CPCHash.Add($lineSplit[0],$lineSplit[1])
        }
         
        $CPCHash | Out-GridView -PassThru -Title "Cloud PC Info"
        
        #output the choices for the optional actions menu
        $ActionsMenu = @{}
        $ActionsMenu.Add("start", 1)
        $ActionsMenu.Add("stop", 2)
        $ActionsMenu.Add("restart", 3)
        $ActionsMenu.Add("connectivity history", 4)
        $ActionsMenu.Add("back", 5)
        $ActionsMenu.Add("exit", 6)
        $ActionsMenu | Out-GridView -PassThru -Title "Optional Actions"

    #Ask for the optional action
    #[int]$Selection2 = Read-Host "Enter your selection"
    $Selection2 = $ActionsMenu[$Selection2]
    #Switch for the optional actions
    Switch ($Selection2)
    {
    1 {Start-MgDeviceManagementVirtualEndpointCloudPcOn -CloudPCId $CPCs[$choosenCPC].Id}
    1 {write-host 'Starting'  $CPCs[$choosenCPC].DisplayName}
    1 {Get-CloudPCData}
    2 { Start-MgDeviceManagementVirtualEndpointCloudPcOff -CloudPCId $CPCs[$choosenCPC].Id }
    2 {write-host 'Stopping ' $CPCs[$choosenCPC].DisplayName}
    2 {Get-CloudPCData}
    3 {Restart-MgDeviceManagementVirtualEndpointCloudPc -CloudPcId $CPCs[$choosenCPC].Id }
    3 {write-host 'Re-Starting ' $CPCs[$choosenCPC].DisplayName}
    3 {Get-CloudPCData}
    4 {Get-CPCConnectHistory $CPCs[$choosenCPC].DisplayName $CPCs[$choosenCPC].Id $CPCs[$choosenCPC].ManagedDeviceName}
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
Function Get-CPCConnectHistory ($CPCCHDisplay, $CPCCHID, $CPCCHNBName)
{
    $ConnectHistoryInstance = 'Connectivity test for ' + $CPCCHDisplay + ' with ID ' + $CPCCHID

    #Get the connection history and store in txt file in user temp folder
    Get-MgDeviceManagementVirtualEndpointCloudPcConnectivityHistory  -CloudPcId $CPCCHID |out-file -filepath ($TempFolder + "\connectlog.txt") 
    $ConnectHistory = Get-Item ($TempFolder + "\connectlog.txt")
    if ($ConnectHistory.Length -gt 1) 
        {
            #output the connection history to the screen removing the deviceHealthCheck lines
            Out-File -FilePath ($TempFolder + "\connectlogclean.txt") 
            $ConnectHistoryInstance | Out-file -FilePath ($TempFolder + "\connectlogclean.txt") -append
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
    #Ask if the user wants to export the connection history
    [int]$exportConHis = Read-Host "Enter 1 to Export; 2 to Continue"
    if ($exportConHis -eq 1) 
        {
            #export to default location or custom location
            $Datetime = Get-Date -Format "dddd MM-dd-yyyy HH:MM"
            $SaveHistoryPathLocation = $env:USERPROFILE + '\onedrive\documents\' + $CPCCHNBName + ' '+ $Datetime + '.txt'
            $SaveHistoryPathLocation 
            Write-host "Enter 1 for default export location"  $SaveHistoryPathLocation
            Write-host "Enter 2 for custom export location (user must have access, c:\location\filename.txt)" 
            $SaveHistoryPath = read-host "enter 1 for default location or 2 custome location "
            if ($SaveHistoryPath -eq 1) 
                {
                    $SaveHistoryPath = $SaveHistoryPathLocation
                }
            else 
                {
                    $SaveHistoryPath = read-host "Enter the full path and filename"
                }
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
#Call th Get-CloudPCData function
Get-CloudPCData
}

#Connect to CloudPC Graph API 
Connect-MgGraph -Scopes "CloudPC.ReadWrite.All, User.Read.All","Group.Read.All, CloudPC.read.all"
# Set Graph API to Beta
Select-MgProfile Beta

#Gathers the connection info, comment out the Clear-Host line below to see this info, helps with connectivity issues
Write-host "Here is the connection information used:" -BackgroundColor $BKColorInfo -ForegroundColor $FGColor
Get-MgContext
Clear-Host
#Get the users temp folder location
$TempFolder = $env:TEMP
$ProvPolicies = Read-host "Enter 1 to first check Provisioning Policies; 2 to continue"
if ($ProvPolicies -eq 1) 
    {
    #Call the Provisioning Policy Info Fuction
    Get-ProvisionPolicyInfo
    }
else 
    {
    #Call the Manage_cpc function 
    Get-CloudPCData
    }


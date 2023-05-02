# Need to have PowerShell 7 or higher https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.3

# Need to have the https://pedholtlab.com/get-started-with-windows-365-and-powershell/
# https://learn.microsoft.com/en-us/powershell/microsoftgraph/authentication-commands?view=graph-powershell-1.0

# Set Graph API to Beta
Select-MgProfile Beta

#Connect to CloudPC Graph API 
Connect-MgGraph -Scopes "CloudPC.ReadWrite.All" 

#TEST
#get-mgcontext

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



#TESTING
#adding a comment
#Adding another

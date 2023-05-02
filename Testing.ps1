#write function to connect to azure active directory
function Connect-AzureAD {
    $AzureADConnection = Connect-AzureAD
    return $AzureADConnection
}

#write function to get all users from azure active directory
function Get-AzureADUser {
    $AzureADUser = Get-AzureADUser
    return $AzureADUser
}

#write function to get all Windows 365 Cloud PCs
function Get-Windows365CloudPC {
    $Windows365CloudPC = Get-Windows365CloudPC
    return $Windows365CloudPC
}

Get-Windows365CloudPC | Select-Object -Property DisplayName, UserPrincipalName, CloudPCStatus, CloudPCStatusDetails, CloudPCStatusLastUpdatedTime, CloudPCStatusTransitionTime, CloudPCStatusTransitionDetails, CloudPCStatusTransitionUserPrincipalName, CloudPCStatusTransitionUserName, CloudPCStatusTransitionUserType, CloudPCStatusTransitionUserDisplayName, CloudPCStatusTransitionUserEmailAddress, CloudPCStatusTransitionUserObjectId, CloudPCStatusTransitionUserTenantId, CloudPCStatusTransitionUserUserPrincipalName, CloudPCStatusTransitionUserUserType, CloudPCStatusTransitionUserUserDisplayName, CloudPCStatusTransitionUserUserEmailAddress, CloudPCStatusTransitionUserUserObjectId, CloudPCStatusTransitionUserUserTenantId, CloudPCStatusTransitionUserUserState, CloudPCStatusTransitionUserUserStateChangedTime, CloudPCStatusTransitionUserUserStateChangedDetails, CloudPCStatusTransitionUserUserStateChangedUserPrincipalName, CloudPCStatusTransitionUserUserStateChangedUserName, CloudPCStatusTransitionUserUserStateChangedUserType, CloudPCStatusTransitionUserUserStateChangedUserDisplayName, CloudPCStatusTransitionUserUserStateChangedUserEmailAddress, CloudPCStatusTransitionUserUserStateChangedUserObjectId, CloudPCStatusTransitionUserUserStateChangedUserTenantId, CloudPCStatusTransitionUserUserStateChangedUserUserPrincipalName, CloudPCStatusTransitionUserUserStateChangedUserUserType, CloudPCStatusTransitionUserUserStateChangedUserUserDisplayName, CloudPCStatusTransitionUserUserStateChangedUserUserEmailAddress, CloudPCStatusTransitionUserUserStateChangedUserUserObjectId, CloudPCStatusTransitionUserUserStateChangedUserUserTenantId, CloudPCStatusTransitionUserUserStateChangedUserUserState, CloudPCStatusTransitionUserUserStateChangedUserUserStateChangedTime, CloudPCStatusTransitionUserUserStateChangedUserUserStateChangedDetails, CloudPCStatusTransitionUserUserStateChangedUserUserStateChangedUserPrincipalName, CloudPCStatusTransitionUserUserStateChangedUserUserStateChangedUserName, CloudPCStatusTransitionUserUserStateChangedUserUserStateChangedUserType, CloudPCStatusTransitionUserUserStateChangedUserUserStateChangedUserDisplayName, CloudPCStatusTransitionUserUserStateChangedUserUserStateChangedUserEmailAddress, CloudPCStatusTransitionUserUserStateChangedUserUserStateChangedUserObjectId, CloudPCStatusTransitionUserUserStateChangedUserUserStateChangedUserTenantId, CloudPCStatusTransitionUserUserStateChangedUserUserStateChangedUserUserPrincipalName, CloudPCStatusTransitionUserUserStateChangedUserUserStateChangedUserUserType, CloudPCStatusTransitionUserUserStateChangedUserUserStateChangedUserUserDisplayName, CloudPCStatusTransitionUserUserStateChangedUserUserStateChangedUserUserEmailAddress, CloudPCStatusTransitionUserUserStateChangedUserUserStateChanged
#Careful this script has been translated by AI
# Activate once to install the module
# Install-Module -Name SharePointPnPPowerShellOnline -Force -Scope CurrentUser

# Parameters
$siteUrl = "[siteURL]"
$listname = "Documents"
$username = "login"
$password = "password"
$extension = "[ransomware extension]"

# Create a secure password object from the password
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force

# Create SharePoint credentials
$credentials = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $username, $securePassword

# Connect to SharePoint using the credentials
try {
    Connect-PnPOnline -Url $siteUrl -Credentials $credentials
} catch {
    Write-Host "Error connecting to SharePoint: $_"
    exit
}

# Retrieve list items
try {
    $items = Get-PnpListItem -List $listname
} catch {
    Write-Host "Error retrieving list items: $_"
    exit
}

$global:Counter = 1

ForEach($Item in $items) {
    try {
        # Retrieve files and versions from the list
        Get-PnPProperty -ClientObject $Item -Property File | Out-Null
        Get-PnPProperty -ClientObject $Item.File -Property Versions | Out-Null

        # Process only encrypted files
        if ($item["FileLeafRef"] -match "$extension") {
            Write-Host $item["FileLeafRef"] "is encrypted, attempting recovery"

            if ($Item.File.Versions.Count -gt 0) {
                # Retrieve the previous version
                $VersionLabel = $Item.File.Versions[$Item.File.Versions.Count - 1].VersionLabel

                Write-Host "$(Get-Date) - ($($Counter)/$($items.Count)) - Restoring version $VersionLabel of $($Item.File.Name)"
                $item.File.Versions.RestoreByLabel($VersionLabel)
                Invoke-PnPQuery
                Rename-PnPFile -ServerRelativeUrl $item["FileRef"] -TargetFileName $item["FileLeafRef"].Replace("$extension", '') -Force
            } else {
                Write-Host "$(Get-Date) - ($($Counter)/$($items.Count)) - The file $($Item.File.Name) has no recoverable previous version!"
            }
            $Counter++
        } else {
            Write-Host $item["FileLeafRef"] "is not encrypted"
        }
    } catch {
        Write-Host "Error processing item: $_"
    }
}

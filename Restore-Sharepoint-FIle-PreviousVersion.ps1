# Activer une fois pour installer le module
# Install-Module -Name SharePointPnPPowerShellOnline -Force -Scope CurrentUser

#param

$siteUrl = "[siteURL]"
$listname = "Documents"
$username = "login"
$password = "password"
$extension = "[ransomware extension]"


# Crée un objet de mot de passe sécurisé à partir du mot de passe
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force

# Crée les informations d'identification SharePoint
$credentials = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $username, $securePassword

# Connecte-vous à SharePoint en utilisant les informations d'identification
Connect-PnPOnline -Url $siteUrl -Credentials $credentials

# Remplacez '/sites/votre-site/documents/bibliotheque/' par le chemin de la bibliothèque SharePoint

$items = Get-PnpListItem $listname

 $global:Counter = 1

        ForEach($Item in $items)
        {
            #Récupérer les fichiers et versions de la liste
            Get-PnPProperty -ClientObject $Item -Property File | Out-Null
            Get-PnPProperty -ClientObject $Item.File -Property Versions | Out-Null

            #Traiter uniquement les fichiers chiffrés , remplacer le match par l'extension du ransomware
            if($item["FileLeafRef"] -match "$extension")
            {
             Write-Host $item["FileLeafRef"] "est chiffré, tentative de récupération"
 
                    If($Item.File.Versions.Count -gt 0)
                    {
                        #Récupérer la version précdente
                        $VersionLabel = $Item.File.Versions[$Item.File.Versions.Count-1].VersionLabel
 
                        Write-Host "$(Get-Date) - ($($Counter)/$($AllItems.Count)) - Restauration de la version version $VersionLabel de $($Item.File.Name)"
                        $item.File.Versions.RestoreByLabel($VersionLabel)
                        Invoke-PnPQuery
                        Rename-PnPFile -ServerRelativeUrl $item["FileRef"] -TargetFileName $item["FileLeafRef"].Replace("$extension",'') -Force

                    }
                    else
                    {
                        Write-Host "$(Get-Date) - ($($Counter)/$($AllItems.Count)) - Le fichier $($Item.File.Name)n'a pas de version précédente récupérable!"
                    }
                    $Counter++
            }
            else {Write-Host $item["FileLeafRef"] "N'est pas chiffré"}
        }




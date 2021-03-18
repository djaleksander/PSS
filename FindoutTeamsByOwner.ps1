#einzugebende variable
param(
[parameter(Position=0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$username = '', #anfabe Username
[ValidateSet(“Short”,”Full”)][string]$output #wie viel soll ausgegeben werden
)

Switch ($output) {
    Short {
        $output_quantity = 'displayname' #nur Anzeigename
        break
    }
    Full {
        $output_quantity = 'displayname, GroupID, Visibility, Archived' #erweiterte attribute
        break
    }
    default {
        $output_quantity = 'displayname'
    }
}

if (Get-Module -ListAvailable -Name MicrosoftTeams) {     #pruefung ob Modul Microsfot Teams installiert ist

#Module fuer Teams einbinden:
Import-Module MicrosoftTeams
Connect-MicrosoftTeams

#user angeben - per variable angeben
$user=get-aduser -Properties * -Identity $username

#ou der teams-gruppen
$ou="OU=Teams,OU=Security Groups,OU=_ALL,OU=IAG_Global,DC=peter-wolters,DC=com" #ggf. anpassen

#zu filterndes objekt
$filter=$user.distinguishedname

#ausgabe
$ausgabe=Get-ADGroup -Filter {msExchCoManagedByLink -like $filter} -Properties * #|select displayname
$ausgabe=$ausgabe.displayname
($ausgabe).ToString() # <-Konvertierung array_to_string

#Schleife fuer Abfrage:
foreach($teamname in $ausgabe)
{
Get-Team -DisplayName $teamname | select $output_quantity #select displayname, GroupID, Visibility, Archived #ganzen wert ausgeben <- muss geprueft werden
}
} 
else {
    Write-Host "PowerShell Module 'MicrosoftTeams' is not installed." `n"Install it as Admin using 'Install-Module MicrosoftTeams'."
}

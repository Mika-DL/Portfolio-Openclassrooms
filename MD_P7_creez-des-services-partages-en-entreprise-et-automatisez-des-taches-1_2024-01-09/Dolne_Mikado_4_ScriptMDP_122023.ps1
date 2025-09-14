#Demande de réinitialisation de mot de passe d'un utilisateur de l'AD (DOLNE Mikado v1.0)


# Définir le chemin du fichier de log
$LogFile = "C:\scripts\Réinitialisation mot de passe\log\ResetPasswordLog.txt"

# Fonction pour ajouter une entrée dans le fichier de log
function Add-LogEntry {
    param (
        [string]$Message
    )
    $LogEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    $LogEntry | Out-File -Append -FilePath $LogFile
}

# Demander le nom d'utilisateur à réinitialiser
$Utilisateur = Read-Host "Entrez le nom d'utilisateur à réinitialiser"

# Vérifier si l'utilisateur existe
if (Get-ADUser -Filter {SamAccountName -eq $Utilisateur -or Name -eq $Utilisateur}) {
    # Demander le motif de réinitialisation du mot de passe
    $Motif = Read-Host "Motif de réinitialisation du mot de passe (ex: incident, oubli, demande de l'utilisateur,etc...)"

    try {
        # Réinitialiser le mot de passe avec changement à la prochaine connexion
        Set-ADAccountPassword -Identity $Utilisateur -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "NewPassword123" -Force)
        Set-ADUser -Identity $Utilisateur -ChangePasswordAtLogon $true

        # Enregistrer l'entrée dans le fichier de log
        Add-LogEntry -Message "Réinitialisation du mot de passe pour l'utilisateur $Utilisateur Motif : $Motif"

        Write-Host "Mot de passe réinitialisé avec succès pour l'utilisateur $Utilisateur. Motif : $Motif"
    } catch {
        Write-Host "Erreur lors de la réinitialisation du mot de passe : $_"
    }
} else {
    Write-Warning "L'utilisateur $Utilisateur n'existe pas dans l'AD."
}

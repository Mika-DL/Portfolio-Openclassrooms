#Création d'utilisateurs dans l'AD (DOLNE Mikado 03/12/2023 ver1.3)

#Importer les données
$CSVFile = "C:\scripts\AD_USERS\Utilisateurs.csv.txt"
$CSVData = Import-Csv -Path $CSVFile -Delimiter ";" -Encoding Default

# Boucle Foreach pour parcourir le fichier CSV
Foreach($Utilisateur in $CSVData){

 $UtilisateurPrenom = $Utilisateur.Prenom       #Récupère le prenom de l'utilisateur dans le fichier CSV
 $UtilisateurNom = $Utilisateur.Nom             #Récupère le nom de l'utilisateur dans le fichier CSV
 $UtilisateurLogin = ($UtilisateurPrenom).Substring(0,1).ToLower() + "." + $UtilisateurNom.ToLower()        #On prend la première lettre du prénom et on recupère le nom de famille le tout en minuscules de l'utilisateur
 $UtilisateurEmail = "$UtilisateurLogin@Axeplane.fr"    #On crée une adresse email
 $UtilisateurMotdePasse = "Test1234"            
 $UtilisateurFonction = $Utilisateur.Fonction   #Récupère la fonction de l'utilisateur dans le fichier CSV
 $UtilisateurService = $Utilisateur.Service     #Récupère le service de l'utilisateur dans le fichier CSV
 $UtilisateurGroupe = $Utilisateur.Groupe -split ','      #Récupère le groupe de l'utilisateur dans le fichier CSV
 $UtilisateurOU = $Utilisateur.OU               #Récupère la localisation de l'OU de l'utilisateur
 $Nom = "$UtilisateurNom $UtilisateurPrenom"
 $DossierCacher = $UtilisateurLogin + "$"



  
   try {
   # Créer l'utilisateur dans L'AD
        New-ADUser  -Name "$UtilisateurNom $UtilisateurPrenom" `
                    -DisplayName "$UtilisateurNom $UtilisateurPrenom" `
                    -GivenName $UtilisateurPrenom `
                    -Surname $UtilisateurNom `
                    -SamAccountName $UtilisateurLogin `
                    -UserPrincipalName "$UtilisateurLogin@Axeplane.loc" `
                    -EmailAddress $UtilisateurEmail `
                    -Title $UtilisateurFonction `
                    -Department $UtilisateurService `
                    -Path $UtilisateurOU `
                    -AccountPassword(ConvertTo-SecureString $UtilisateurMotdePasse -AsPlainText -Force) `
                    -ChangePasswordAtLogon $true `
                    -Enabled $true `
                    -HomeDrive "P:" `
                    -HomeDirectory "\\SRV-AD\Partages personnels utilisateurs\$DossierCacher"

        Write-Output "Création de l'utilisateur : $UtilisateurLogin ($UtilisateurNom $UtilisateurPrenom)"               
    
    # Ajouter l'utilisateur aux groupes spécifiés
     foreach ($Groupe in $UtilisateurGroupe) {
        Add-ADGroupMember -Identity $Groupe -Members $UtilisateurLogin
        Write-Host "L'utilisateur $Nom a été ajouté au groupe $groupe"
    }

    # Créer et partager le dossier personnel      
        New-Item -Path "\\SRV-AD\Partages personnels utilisateurs\$DossierCacher" -ItemType Directory
         # Définir les autorisations sur le dossier   
            $acl = Get-Acl "\\SRV-AD\Partages personnels utilisateurs\$DossierCacher"
            $permission = New-Object System.Security.AccessControl.FileSystemAccessRule("$UtilisateurLogin", "FullControl", "Allow")
            $acl.SetAccessRule($permission)
        Set-Acl "\\SRV-AD\Partages personnels utilisateurs\$DossierCacher" $acl
        Write-Output "Création du dossier personnel de l'utilisateur : $DossierCacher ($UtilisateurNom $UtilisateurPrenom)"
    
    # Mapper le lecteur réseau
        #New-PSDrive -Name "P" -PSProvider FileSystem -Root "\\SRV-AD\Partages personnels utilisateurs\$DossierCacher" -Persist
        #Write-Host "Le Lecteur $DossierCacher a été mappé avec succès"
    
    
    } catch {
        Write-Host "Une erreur est apparue : $_"
    }

    }
    
 
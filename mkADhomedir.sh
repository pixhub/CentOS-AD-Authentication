#! /bin/bash
# Script pour creer des dossiers personnels sous Linux pour chaque utilisateur de Active Directory l'AD appartenants au groupe "Utilisateurs FTP"

#Creation de fichiers temporaires recuperant les infos de l'AD
ADaccounts=/root/mkADhomedir/tmpAccounts.txt

#Parametres du serveur AD
#IP de l'AD
IP="10.2.7.1"

#FQDN de l'OU oùl'on ecupere les comptes
OU="OU=DCI,DC=intra,DC=dci-fr,DC=com"
#USER=CN=ldap-cns,OU=Comptes\ de\ services,OU=DCI,DC=intra,DC=dci-fr,DC=com
PASS="XXXXXXXXXXXXXXXXX"
FILTER1="sAMAccountName=*"
FILTER2="objectClass=user"
FILTER3=memberOf=CN=UtilisateursFTP,OU=Acces\ aux\ applications,OU=Groupes\ du\ domaine,OU=DCI,DC=intra,DC=dci-fr,DC=com

#SCRIPT
LDAPTLS_REQCERT=never ldapsearch -LLL -x -H ldaps://ldap.dci.fr:636 -b $OU -D CN=ldap-cns,OU=Comptes\ de\ services,OU=DCI,DC=intra,DC=dci-fr,DC=com -w $PASS "(&($FILTER1)($FILTER2)($FILTER3))" | grep sAMAccountName | awk '{print $2}' > $ADaccounts

if [ -e $ADaccounts ]
        then
        while read ligne
        do
                USERDIR=$(echo $ligne | cut -d: -f1)
                        if [ -e /home/DCIDOM/$USERDIR ]
                                then
                                        echo "$(date): Le repertoire personnel de "$USERDIR" existe deja, rien n'est fait";
                                else
                                        mkdir /home/DCIDOM/"$USERDIR"
                                        chown $USERDIR:root /home/DCIDOM/$USERDIR
                                        chmod 770 /home/DCIDOM/$USERDIR
                                        echo "$(date): Le repertoire personnel pour "$USERDIR" a ete cree avec succes" >> /root/mkADhomedir/mkADhomedir.log
                        fi
        done < $ADaccounts
        else
                                echo "Le fichier "$ADaccounts" n'existe pas"
                touch $ADaccounts
                                echo "Le fichier "$ADaccounts" vient d'etre cree. Relancez le script."
fi

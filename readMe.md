# Cloud Computing Project

Ce projet propose un site sécurisé permettant à l'aide d'un bouton compteur d'interagir avec une base de donnée SQL via une infrastructure déployée sur Azure.

---

## 📄 **Documentation**

---

### 🔧 **Protocole d'utilisation du projet**

#### **1ère étape : Création d'un dépôt GitHub**
1. Créez un dépôt public dans votre propre compte GitHub.

#### **2ème étape : Cloner le dépôt**
1. Clonez ce dépôt dans votre environnement local avec :
   ```bash
   git clone https://github.com/<votre-username>/<nom-du-repo>.git
   ```
#### **3ème étape : Connection à Azure**
1. Authentifiez-vous auprès d’Azure, depuis le terminal du projet maintenant cloné, rentrez cette commande puis connectez-vous.
   ```bash
   az login

#### **4ème étape : Initialiser Terraform**
1. Placez-vous dans le dossier contenant les fichiers Terraform :
   ```bash
   cd infrastructure
2. Initialisez Terraform :
   ```bash
   terraform init

#### **5ème étape : Vérifier le plan Terraform**
1. Analyser les ressources qui seront créées avant le déploiement :
   ```bash
   terraform plan

#### **6ème étape : Déployer l'infrastructure Terraform**
1. Lancez le déploiement :
   ```bash
   terraform apply

---

### 🏗️ **Architecture du projet**

Grâce à l’étape précédente, un groupe de ressources a maintenant été créé sur votre compte Azure contenant les ressources suivantes :

- **App Service – frontend**  
  Héberge l’interface utilisateur accessible publiquement.

- **App Service – backend**  
  Contient la logique applicative communiquant avec la base SQL.

- **Azure SQL Database**  
  Base de données contenant la valeur du compteur.

- **Azure SQL Server**  
  Ressource gérant l’instance SQL Database.

- **Private Endpoint SQL**  
  Permet d’accéder à la base SQL via un point d’accès privé, sans exposition publique, assurant ainsi la sécurité et l’intégrité des données.

- **Interface réseau (NIC) pour le Private Endpoint**  
  Représente l’interface réseau du Private Endpoint dans le VNet.

- **App Service Plan**  
  Plan d’hébergement permettant aux App Services de fonctionner.

- **Identité Managée (Managed Identity)**  
  Assure l’authentification sécurisée entre App Services et autres services Azure.

- **Réseau virtuel interne (`reseau_interne`)**  
  Utilisé pour isoler les ressources backend et le Private Endpoint.

- **Réseau virtuel DMZ (`reseau_dmz`)**  
   A COMPLETER 

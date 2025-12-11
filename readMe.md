# Cloud Computing Project

Ce projet propose un site sécurisé permettant à l'aide d'un bouton compteur d'interagir avec une base de donnée SQL via une infrastructure déployée sur Azure.

---

## 📄 **Documentation**

---

### 🔧 **Protocole d'utilisation du projet**

#### **1ère étape : Création d'un dépôt GitHub**
 Créez un dépôt public dans votre propre compte GitHub.

#### **2ème étape : Cloner le dépôt**
 Clonez ce dépôt dans votre environnement local avec :
   ```bash
   git clone https://github.com/<votre-username>/<nom-du-repo>.git
   ```
#### **3ème étape : Connection à Azure**
 Authentifiez-vous auprès d’Azure, depuis le terminal du projet maintenant cloné, rentrez cette commande puis connectez-vous.
   ```bash
   az login
   ```

**Important :**  certaines régions Azure peuvent ne pas être disponibles selon votre abonnement (gratuit, étudiant, entreprise).

Si vous obtenez une erreur du type :

* Region not allowed
* Location not available
* The provided location is not available for resource creation

  Vous devez modifier la région utilisée par Terraform.

Ouvrez le fichier :

[📄infrastructure/variables.tf](./infrastructure/variables.tf)


Repérez la variable suivante :

```
variable "location" {
default = "francecentral"
}
```
et modifié là pour y mettre une région dont vous avez accés.

```az account list-locations -o table```

> Cette commande permet d'afficher toutes les régions Azure disponibles pour votre abonnement.



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
1. Lancez le déploiement (peux durer environ 10min):
   ```bash
   terraform apply

---

### **7ème étape : Ajouter la table SQL manuellement dans Azure**

Après le `terraform apply`, toute l’infrastructure est déployée automatiquement.  
La seule intervention manuelle consiste à créer la table **VisitCount** dans la base SQL afin que le backend fonctionne correctement.

📌 **Important :** Cette étape ne doit être faite qu’une seule fois, après le premier déploiement.

---

## 7.1 – Accéder à la base SQL dans Azure Portal

1. Rendez-vous sur ➜ https://portal.azure.com  
2. Dans le menu de gauche, cliquez sur **SQL Databases**  

<div align="center">
  <img src="https://github.com/user-attachments/assets/75f75423-b099-4860-bc9b-90a4cd10dadc" width="220">
</div>

3. Sélectionnez la base créée par Terraform  
   (nommée **counter-xxxxxxxxx/counter**).

---

## 7.2 – Ouvrir l’Éditeur de requêtes (Preview)

1. Dans le menu latéral de la base SQL, cliquez sur **Query Editor (preview)**  
2. Connectez-vous avec :

- **Authentication** : SQL login  
- **Username** : `adminuser`  
- **Password** : `P@ssword123` (défini dans Terraform)

3. Cliquez sur le lien d’autorisation lorsqu’il apparaît, puis validez.

<div align="center">
  <img src="https://github.com/user-attachments/assets/1f85973e-cc21-45b1-900e-9cc1204b5ae0" width="260">
  <img src="https://github.com/user-attachments/assets/59da039f-08c7-4be5-9ea0-0021b09f66bc" width="620">
</div>

---

## 7.3 – Créer la table `VisitCount`

Dans la zone SQL, copiez-collez cette commande :

```sql
IF OBJECT_ID('dbo.VisitCount', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.VisitCount (
        Id INT PRIMARY KEY,
        Count INT NOT NULL
    );

    INSERT INTO dbo.VisitCount (Id, Count) VALUES (1, 0);
END

```
Cliquez sur Exécuter.

<div align="center"> <img src="https://github.com/user-attachments/assets/719e6026-5b48-4810-8720-9c578d66981e" width="700"> </div>

#### **7.4 – Vérifier la table**

Vous pouvez maintenant exécuter :

```sql
SELECT * FROM VisitCount;
```

Vous devriez voir alors :

<div align="center"> <img src="https://github.com/user-attachments/assets/d3169ba1-f62f-4ad1-925e-e617e48e07ae" width="750"> </div>

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

---

### 👁️ **Utilisation du site et suivi de la base de donnée**


Pour ouvrir le site utilisateur, rendez-vous sur :

**App Service → frontend-app-xxxx → Parcourir**  
Cela ouvre directement le site dans votre navigateur.

<div align="center"> <img width="794" height="697" alt="6" src="https://github.com/user-attachments/assets/fb5a55c2-adda-4a0c-adf5-5411cfa18f8b" /></div>

> Sur App Service, vous pouvez accéder également au backend pour tester les divers requêtes


### Tester l’incrémentation du compteur

Une fois sur la page d’accueil du site :

1. Le compteur se charge automatiquement.
2. Cliquez sur le bouton **“Increment”**.
3. Le nombre doit **augmenter de +1** à chaque clic ou/et chaque refresh/nouveau utilisateur sur la page de la page.



### Vérifier la valeur dans la base de données SQL

Si vous souhaitez confirmer côté base de données, retourner dans le counter (étape 7.2) et taper :

```sql
SELECT * FROM VisitCount;
```
La colonne Count doit augmenter à chaque visite ou clic sur le site.

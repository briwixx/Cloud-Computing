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

#### **7ème étape : Ajouter la table SQL manuellement dans Azure**

Après le `terraform apply`, toute l’infrastructure est déployée automatiquement.  
La seule intervention manuelle consiste à créer la table **VisitCount** dans la base SQL afin que le backend fonctionne correctement.

📌 **Important :** Cette étape ne doit être faite qu’une seule fois, après le premier déploiement.

---

#### 7.1 – Accéder à la base SQL dans Azure Portal

1. Rendez-vous sur ➜ https://portal.azure.com  
2. Dans le menu de gauche, cliquez sur **SQL Databases**  

<div align="center">
  <img src="https://github.com/user-attachments/assets/75f75423-b099-4860-bc9b-90a4cd10dadc" width="220">
</div>

3. Sélectionnez la base créée par Terraform  
   (nommée **counter-xxxxxxxxx/counter**).

---

#### 7.2 – Ouvrir l’Éditeur de requêtes (Preview)

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

#### 7.3 – Créer la table `VisitCount`

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

Grâce à l’étape précédente, un groupe de ressources a maintenant été créé sur le compte Azure. Ce groupe de ressource contient deux réseaux 'reseau_dmz' et 'reseau_interne' qui serviront d’architecture de base pour le projet (Image de la topologie des réseaux du groupe de ressources disponible dans ./topology.png).

Le réseau DMZ est constitué de trois sous-réseaux : service1, service2 et service3. Ce sont des services qui seront visibles depuis internet donc qui sont plus vulnérables, on y retrouve : 
-	Website_service1 : VM_dmz1 destinée à se connecter au réseau interne, c’est le seul sous-réseau autorisé par le pare-feu à communiquer avec le réseau interne.
-	Website_service2 : VM_dmz2 servant à faire des tests de connectivité, en effet seul le réseau website_service1 a le droit de communiquer avec le réseau interne (voir détails du pare-feu).
-	Website_service 3 : en attente d’une nouvelle fonctionnalité.

Les requêtes vers ce DMZ passent par un NSG (pare-feu pour les sous-réseaux Azure) qui n’autorise que les requêtes SSH (port 22), les requêtes http (port 80) et les requêtes HTTPS (port 443). 
Un peering est également mis en place pour permettre le transit des requêtes autorisées par le NSG entre le DMZ et le réseau interne.

Le réseau interne contient les informations sensibles de l’entreprise, il est constitué dans notre cas de trois sous-réseaux : database, department1 et department2. On y retrouve : 
-	Database : la base de données utilisée par le site Web de la DMZ.
-	Department1 : contenant une VM (vm_internal1) pour les tests de connectivité.
-	Department2 : en attente d’une nouvelle fonctionnalité.

Ces sous-réseaux contiennent les données confidentielles de l’entreprise, il serait donc dangereux de les exposer directement à internet, elles ne sont donc reliées qu’à un seul sous-réseau de la DMZ (les autres sous-réseaux étant bloqués pour plus de sécurité).
Pour bloquer les connexions non-voulues, un NSG est mis en place pour ce réseau interne, cette fois-ci toutes les requêtes TCP sont bloquées sauf celles venant du sous-réseau website_service1 du réseau DMZ. Les connexions SSH sont donc impossible vers vm_internal1 depuis l’ordinateur hôte ou depuis VM_dmz2 mais sont possible via VM_dmz1 comme le montrent les images : 

<img width="852" height="161" alt="dmz1" src="https://github.com/user-attachments/assets/b05a91d3-6f9d-44ff-b5af-e90eef8cdbf6" />

Connexion ssh depuis vm_dmz1 vers vm_internal1

<img width="493" height="82" alt="dmz2" src="https://github.com/user-attachments/assets/55c5ee3d-6ade-45dd-8ee4-7470e2ca847d" />

Tentative de connexion ssh depuis vm_dmz2 vers vm_internal1

<img width="1257" height="80" alt="internal1" src="https://github.com/user-attachments/assets/1d07dc7a-328e-47b9-acde-bd471666d621" />

Tentative de connexion ssh depuis mon ordinateur vers vm_internal1

Pour ce qui est du site internet, le frontend et le backend sont stockés sur le App Service (service PaaS), ils ne peuvent pas être stockés directement sur le réseau créé. Donc le frontend communique avec le backend, puis le backend accède à la base de données du réseau interne via le réseau Azure et les NSG.
Pour aller plus loin, nous avions prévu de :
-	Créer un private endpoint dans un sous-réseau du DMZ afin que les VMs du DMZ puissent accéder de manière privée au frontend.
-	Faire la même chose pour le backend.

Méthode imaginée :

Un private endpoint attribue une IP privée dans le sous-réseau. Les VMs utilisent cette IP pour accéder aux App Services sans passer par Internet.

Pour que le nom de domaine public du site (ex. frontend-app.azurewebsites.net) soit résolu vers cette IP privée, une zone DNS privée est configurée dans Azure. Cela garantit que le trafic entre les VMs du DMZ et les App Services reste entièrement interne au réseau Azure.


### 👁️ **Utilisation du site et suivi de la base de donnée**


Pour ouvrir le site utilisateur, rendez-vous sur :

**App Service → frontend-app-xxxx → Parcourir**  
Cela ouvre directement le site dans votre navigateur.

<div align="center"><img width="503" height="417" alt="6" src="https://github.com/user-attachments/assets/06a0017c-e4c9-474b-bdef-598c8117945b" /></div>

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

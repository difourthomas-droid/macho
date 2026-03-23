# Macho DUI Menu

Interface de menu DUI screenshot-proof pour FiveM utilisant l'API Macho.

## 📋 Prérequis

- FiveM avec Macho installé
- Accès à l'API Macho DUI
- Repository GitHub avec GitHub Pages activé

## 🚀 Installation et Déploiement

### Étape 1 : Activer GitHub Pages

1. Allez sur votre repository : `https://github.com/difourthomas-droid/macho`
2. Cliquez sur **Settings** (Paramètres)
3. Dans le menu de gauche, cliquez sur **Pages**
4. Sous **Source**, sélectionnez :
   - Branch: `main`
   - Folder: `/ (root)`
5. Cliquez sur **Save**
6. Attendez quelques minutes que GitHub Pages se déploie
7. Votre site sera disponible à : `https://difourthomas-droid.github.io/macho/`

### Étape 2 : Vérifier le déploiement

Une fois GitHub Pages activé, votre menu sera accessible à :
```
https://difourthomas-droid.github.io/macho/windsurf-project-2/menu_dui.html
```

Vous pouvez tester en ouvrant cette URL dans votre navigateur.

### Étape 3 : Utiliser avec un Executor

Le fichier `menu_macho.lua` est configuré pour être exécuté directement depuis un executor (Macho, etc.).

**Méthode 1 : Charger depuis l'URL GitHub**
1. Copiez l'URL du fichier raw : `https://raw.githubusercontent.com/difourthomas-droid/macho/main/windsurf-project-2/menu_macho.lua`
2. Dans votre executor, utilisez la fonction de chargement d'URL
3. Le menu se lancera automatiquement

**Méthode 2 : Copier-coller le code**
1. Ouvrez `menu_macho.lua`
2. Copiez tout le contenu
3. Collez-le dans votre executor
4. Exécutez le script

**Méthode 3 : Injection de fichier**
1. Téléchargez `menu_macho.lua`
2. Utilisez la fonction d'injection de fichier de votre executor
3. Le menu se lancera automatiquement

Le menu se charge automatiquement depuis GitHub Pages, aucune configuration supplémentaire nécessaire !

## 🎮 Utilisation

### Raccourcis clavier

- **F5** - Ouvre/ferme le menu

### Fonctionnement

Le script démarre automatiquement dès son exécution :
- Crée le DUI menu
- Lance le thread de contrôle
- Écoute la touche F5 pour toggle le menu

## 📁 Structure des fichiers

```
windsurf-project-2/
├── menu_dui.html      # Interface HTML/CSS/JS du menu
├── menu_macho.lua     # Script Lua pour gérer le DUI
├── apimacho.txt       # Documentation de l'API Macho
└── README.md          # Ce fichier
```

## 🎨 Fonctionnalités

### Interface
- Design moderne avec dégradés violets
- 4 onglets : Principal, Options, Paramètres, À propos
- Animations fluides
- Screenshot-proof grâce à l'API Macho DUI

### Composants
- **Boutons d'action** - Exécutent des actions personnalisées
- **Checkboxes** - Options activables/désactivables
- **Sliders** - Valeurs ajustables de 0 à 100%
- **Input fields** - Champs de saisie de texte
- **Dropdowns** - Menus déroulants

## 🔧 Personnalisation

### Modifier l'URL du menu

Si vous changez l'emplacement du fichier HTML, modifiez la ligne 5 de `menu_macho.lua` :

```lua
local htmlPath = "https://votre-url-ici/menu_dui.html"
```

### Changer les couleurs

Dans `menu_dui.html`, modifiez les couleurs principales :

```css
/* Couleur d'accent principale */
background: linear-gradient(90deg, #8934eb 0%, #6b2bc4 100%);
```

### Ajouter des actions

Dans `menu_macho.lua`, modifiez la fonction `HandleDuiMessage()` :

```lua
if message.action == "votre_action" then
    -- Votre code ici
end
```

## 📝 Notes importantes

- Le menu utilise l'API Macho DUI qui est screenshot-proof
- Les messages entre le DUI et Lua utilisent JSON
- Le menu se nettoie automatiquement à l'arrêt de la ressource
- GitHub Pages peut prendre quelques minutes pour se mettre à jour après un commit

## 🐛 Dépannage

### Le menu ne s'affiche pas
1. Vérifiez que GitHub Pages est activé
2. Vérifiez que l'URL est correcte dans `menu_macho.lua`
3. Vérifiez la console F8 pour les erreurs

### Le menu ne répond pas
1. Vérifiez que les messages JSON sont correctement formatés
2. Vérifiez la console du navigateur (si accessible)
3. Essayez `/recreatemenu` pour recréer le menu

### Erreur 404 sur GitHub Pages
1. Attendez quelques minutes après l'activation de GitHub Pages
2. Vérifiez que le fichier `menu_dui.html` est bien dans le dossier `windsurf-project-2/`
3. Vérifiez que la branche `main` est sélectionnée dans les paramètres Pages

## 📄 Licence

Ce projet utilise l'API Macho. Assurez-vous d'avoir les droits nécessaires pour l'utiliser.

## 🤝 Contribution

Pour contribuer :
1. Push vos modifications sur GitHub
2. Attendez que GitHub Pages se mette à jour (quelques minutes)
3. Testez l'URL dans votre navigateur avant de tester dans FiveM

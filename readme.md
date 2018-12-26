# Installation du plugin

#### Dans le dossier du projet exécuter cette commande: 

ionic cordova plugin add https://github.com/yoyo770/cordova-carplay-android-auto.git

#### Pour la version ios

Ouvrir le projet xcode "MyApp.xcodeproj", 
Aller dans Build Settings, et activer la version de swift 4.2

# Utilisation du plugin

#### le plugin n'est pas en TS

En dessous des imports d'un fichier TS :
``` javascript
declare var window: any;
```

Dans le component:

``` javascript
window.plugins.toastyPlugin.show('Mon Message', 'long', function () {}, function (err) {});
```



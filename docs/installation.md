# 📖 Guide d'Installation Détaillé - Exegol Enhanced

> **Note**: Cette documentation a été créée avec l'assistance de l'IA pour garantir la clarté et la complétude.

## 📋 Table des Matières

- [Prérequis Système](#prérequis-système)
- [Installation Linux](#installation-linux)
- [Installation Windows](#installation-windows)
- [Validation de l'Installation](#validation-de-linstallation)
- [Premiers Pas](#premiers-pas)
- [Dépannage](#dépannage)
- [Désinstallation](#désinstallation)

## 🖥️ Prérequis Système

### Linux (Ubuntu/Mint)

#### Configuration Minimale
- **OS**: Ubuntu 20.04+ ou Linux Mint 20+
- **RAM**: 4 GB (8 GB recommandés)
- **Stockage**: 15 GB d'espace libre
- **Processeur**: x64 compatible
- **Réseau**: Connexion Internet stable

#### Configuration Recommandée
- **OS**: Ubuntu 22.04 LTS ou Linux Mint 21
- **RAM**: 16 GB ou plus
- **Stockage**: 50 GB d'espace libre (SSD recommandé)
- **Processeur**: Multi-core x64
- **GPU**: Support pour l'accélération graphique (optionnel)

#### Permissions Requises
- Accès `sudo` pour l'utilisateur
- Possibilité d'installer des paquets système
- Accès aux groupes `docker` et `sudo`

### Windows

#### Configuration Minimale
- **OS**: Windows 10 version 2004+ ou Windows 11
- **RAM**: 8 GB (Docker Desktop + WSL2)
- **Stockage**: 25 GB d'espace libre
- **Processeur**: x64 avec support de virtualisation
- **Fonctionnalités**: Hyper-V, WSL2

#### Configuration Recommandée
- **OS**: Windows 11 Pro
- **RAM**: 16 GB ou plus
- **Stockage**: 100 GB d'espace libre (SSD recommandé)
- **Processeur**: Multi-core x64 avec VT-x/AMD-V
- **GPU**: Support DirectX 12

#### Prérequis Techniques
- Droits d'administrateur
- Virtualisation activée dans le BIOS
- Windows Subsystem for Linux (WSL2)
- Docker Desktop compatible

## 🐧 Installation Linux

### Méthode Automatique (Recommandée)

```bash
# Télécharger et exécuter le script d'installation
curl -fsSL https://raw.githubusercontent.com/[votre-repo]/exegol-enhanced/main/scripts/linux/install.sh | bash
```

### Méthode Manuelle

#### 1. Cloner le Repository

```bash
git clone https://github.com/[votre-repo]/exegol-enhanced.git
cd exegol-enhanced
chmod +x scripts/linux/install.sh
```

#### 2. Exécuter l'Installation

```bash
./scripts/linux/install.sh
```

#### 3. Redémarrer la Session

```bash
# Recharger les groupes utilisateur
newgrp docker

# Ou se déconnecter/reconnecter
logout
```

### Étapes Détaillées du Script

Le script d'installation effectue automatiquement :

1. **Vérification du système** - Distribution, espace disque, RAM
2. **Mise à jour des paquets** - `apt update && apt upgrade`
3. **Installation des dépendances** - curl, git, python3, etc.
4. **Installation de Docker** - Repository officiel Docker
5. **Configuration Docker** - Ajout utilisateur au groupe docker
6. **Installation d'Exegol** - Via pip3
7. **Configuration Enhanced** - Aliases, raccourcis, configuration
8. **Validation** - Tests de fonctionnement

### Post-Installation Linux

```bash
# Vérifier l'installation
docker --version
exegol version

# Installer les images Exegol
exegol install

# Démarrer votre premier conteneur
exegol start
```

## 🪟 Installation Windows

### Méthode Automatique (Recommandée)

1. **Ouvrir PowerShell en tant qu'Administrateur**
2. **Exécuter la commande d'installation**:

```powershell
iwr -useb https://raw.githubusercontent.com/[votre-repo]/exegol-enhanced/main/scripts/windows/install.ps1 | iex
```

### Méthode Manuelle

#### 1. Télécharger le Script

```powershell
# Télécharger le repository
git clone https://github.com/[votre-repo]/exegol-enhanced.git
cd exegol-enhanced
```

#### 2. Exécuter l'Installation

```powershell
# Exécuter en tant qu'administrateur
.\scripts\windows\install.ps1
```

### Étapes Détaillées du Script Windows

Le script PowerShell effectue :

1. **Vérification Windows** - Version, build, fonctionnalités
2. **Activation des fonctionnalités** - WSL2, Hyper-V, Virtual Machine Platform
3. **Installation WSL2** - Ubuntu 22.04 LTS
4. **Installation Docker Desktop** - Téléchargement et installation automatique
5. **Configuration WSL** - Installation d'Exegol dans Ubuntu
6. **Création des raccourcis** - Bureau et menu démarrer
7. **Configuration PowerShell** - Aliases et fonctions

### Post-Installation Windows

1. **Démarrer Docker Desktop** manuellement
2. **Ouvrir un nouveau PowerShell** pour charger les nouvelles commandes
3. **Tester l'installation**:

```powershell
# Commandes disponibles
exegol          # Démarrer Exegol
exegol-gui      # Démarrer avec interface graphique
exegol-shell    # Entrer dans le shell WSL
exegol-logs     # Voir les logs d'installation
```

## ✅ Validation de l'Installation

### Tests de Base

```bash
# Vérifier Docker
docker --version
docker ps

# Vérifier Exegol
exegol version
exegol info

# Tester la création d'un conteneur
exegol start test-container
exegol stop test-container
```

### Tests Avancés

```bash
# Test avec interface graphique (Linux)
exegol start -X gui-test

# Test des outils intégrés
exegol exec test-container nmap --version
exegol exec test-container python3 --version

# Test des volumes partagés
echo "test" > ~/test.txt
exegol exec test-container cat /workspace/test.txt
```

### Indicateurs de Succès

- ✅ Docker fonctionne sans `sudo` (Linux)
- ✅ Exegol répond aux commandes de base
- ✅ Les conteneurs se créent et démarrent
- ✅ L'interface graphique fonctionne (si applicable)
- ✅ Les volumes partagés sont accessibles

## 🚀 Premiers Pas

### Démarrage Rapide

```bash
# 1. Installer les images Exegol (première fois)
exegol install

# 2. Créer votre premier environnement
exegol start my-lab

# 3. Avec interface graphique
exegol start my-lab -X

# 4. Avec un volume spécifique
exegol start my-lab -v /path/to/workspace:/workspace
```

### Commandes Essentielles

```bash
# Gestion des conteneurs
exegol list                    # Lister les conteneurs
exegol start <name>           # Démarrer un conteneur
exegol stop <name>            # Arrêter un conteneur
exegol remove <name>          # Supprimer un conteneur

# Gestion des images
exegol install                # Installer/mettre à jour les images
exegol images                 # Lister les images disponibles

# Utilitaires
exegol info                   # Informations système
exegol version               # Version d'Exegol
```

### Configuration Personnalisée

```bash
# Fichier de configuration
~/.exegol-enhanced/config/exegol-enhanced.conf

# Aliases personnalisés
~/.exegol-enhanced/config/aliases.sh

# Workspace par défaut
~/.exegol-enhanced/workspace/
```

## 🔧 Dépannage

### Problèmes Courants Linux

#### Docker: Permission Denied

```bash
# Solution 1: Recharger les groupes
newgrp docker

# Solution 2: Redémarrer la session
logout
# Puis se reconnecter

# Solution 3: Vérifier l'appartenance au groupe
groups $USER | grep docker
```

#### Exegol: Command Not Found

```bash
# Vérifier l'installation
pip3 show exegol

# Ajouter ~/.local/bin au PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

#### Erreur d'Espace Disque

```bash
# Nettoyer Docker
docker system prune -a

# Vérifier l'espace disponible
df -h /

# Nettoyer les logs
sudo journalctl --vacuum-time=7d
```

### Problèmes Courants Windows

#### WSL2 Non Installé

```powershell
# Vérifier WSL
wsl --version

# Installer manuellement
wsl --install

# Redémarrer si nécessaire
```

#### Docker Desktop Ne Démarre Pas

1. **Vérifier Hyper-V** dans les fonctionnalités Windows
2. **Redémarrer** après activation des fonctionnalités
3. **Vérifier la virtualisation** dans le BIOS
4. **Réinstaller Docker Desktop** si nécessaire

#### Erreurs de Permissions

```powershell
# Exécuter PowerShell en tant qu'administrateur
# Vérifier les droits utilisateur
whoami /groups
```

### Logs et Diagnostic

```bash
# Linux
tail -f ~/.exegol-enhanced/install.log

# Windows
Get-Content "$env:USERPROFILE\.exegol-enhanced\install.log" -Tail 50
```

### Support Communautaire

- **GitHub Issues**: [Créer un ticket](https://github.com/[votre-repo]/exegol-enhanced/issues)
- **Documentation Exegol**: [Docs officielles](https://exegol.readthedocs.io/)
- **Discord**: Communauté cybersécurité

## 🗑️ Désinstallation

### Linux

```bash
# Script de désinstallation (à créer)
curl -fsSL https://raw.githubusercontent.com/[votre-repo]/exegol-enhanced/main/scripts/linux/uninstall.sh | bash

# Désinstallation manuelle
pip3 uninstall exegol
sudo apt remove docker-ce docker-ce-cli containerd.io
sudo rm -rf ~/.exegol-enhanced
```

### Windows

```powershell
# Désinstaller Docker Desktop via Panneau de configuration
# Désinstaller WSL si souhaité
wsl --unregister Ubuntu-22.04

# Nettoyer les fichiers
Remove-Item -Recurse -Force "$env:USERPROFILE\.exegol-enhanced"
```

## 📞 Support et Contribution

### Obtenir de l'Aide

1. **Consulter la FAQ** dans ce repository
2. **Rechercher dans les issues** existantes
3. **Créer une nouvelle issue** avec :
   - Version du système d'exploitation
   - Logs d'erreur complets
   - Étapes pour reproduire le problème

### Contribuer au Projet

- **Fork** le repository
- **Créer une branche** pour votre fonctionnalité
- **Tester** vos modifications
- **Soumettre une Pull Request**

---

**🎯 Objectif**: Rendre Exegol Enhanced accessible à tous, du débutant au professionnel !

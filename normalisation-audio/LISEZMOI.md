# Égaliser le volume sonore des vidéos (Windows)

Le script mesure le volume de chaque vidéo, puis en crée une copie dont le son est
ramené à **-14 LUFS** (crête max **-1 dBTP**), le niveau de référence couramment
utilisé pour YouTube. L'image est copiée sans réencodage : aucune perte de qualité vidéo.
Les originaux ne sont jamais modifiés.

## 1. Installer ffmpeg (une seule fois)

Ouvrir **PowerShell** (menu Démarrer → taper « PowerShell ») et lancer :

```
winget install Gyan.FFmpeg
```

Fermer puis rouvrir PowerShell, et vérifier avec `ffmpeg -version`.

Sans `winget` : télécharger une version « essentials » sur https://www.gyan.dev/ffmpeg/builds/,
dézipper, et copier `ffmpeg.exe` et `ffprobe.exe` (dossier `bin`) à côté du script.

## 2. Lancer le traitement

Copier `normaliser-audio.ps1` et `normaliser-audio.bat` dans un même dossier, puis
**glisser-déposer le dossier des vidéos sur `normaliser-audio.bat`**.

Les sous-dossiers sont traités. Les vidéos normalisées sont écrites dans un dossier
voisin, nommé comme le dossier source suivi de `_normalise`, avec la même arborescence.

Si le dossier source est dans Google Drive pour ordinateur, le résultat sera lui aussi
synchronisé (plusieurs Go à envoyer).

Le traitement peut être interrompu et relancé : les vidéos déjà faites sont ignorées.

## 3. Vérifier

Le fichier `rapport-volume.csv` (dans le dossier de sortie, s'ouvre dans Excel) donne,
pour chaque vidéo, le volume avant / après. Toutes les lignes « après » doivent être
proches de -14 LUFS.

## Option : compression

Si, dans une même vidéo, la voix reste trop faible par rapport aux bruits de machine,
relancer en ligne de commande avec la compression légère (sur un dossier de sortie vide) :

```
normaliser-audio.bat "G:\Mon Drive\dossier des vidéos" compression
```

## Réglages avancés

En PowerShell, `.\normaliser-audio.ps1 -Source <dossier>` accepte aussi
`-Destination`, `-Lufs` (défaut -14), `-TruePeak` (défaut -1), `-Lra` (défaut 11)
et `-Compression`.

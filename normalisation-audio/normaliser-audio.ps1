<#
.SYNOPSIS
    Égalise le volume sonore d'un lot de vidéos pour une diffusion YouTube.

.DESCRIPTION
    Pour chaque vidéo (.mp4, .mov, .mkv) trouvée dans le dossier source et ses sous-dossiers :
      1. mesure le volume (passe 1, filtre loudnorm de ffmpeg) ;
      2. réécrit la vidéo avec un son normalisé (passe 2) — l'image est copiée sans réencodage ;
      3. remesure le résultat et l'ajoute au rapport CSV.
    Les originaux ne sont jamais modifiés. Les vidéos déjà traitées sont ignorées,
    on peut donc relancer le script après une interruption.

.PARAMETER Source
    Dossier contenant les vidéos (les sous-dossiers sont inclus).

.PARAMETER Destination
    Dossier de sortie. Par défaut : "<Source>_normalise", à côté du dossier source.
    L'arborescence des sous-dossiers est reproduite.

.PARAMETER Compression
    Ajoute une compression légère avant la normalisation, pour réduire les écarts
    de volume à l'intérieur d'une même vidéo (voix faible / machine forte).

.EXAMPLE
    .\normaliser-audio.ps1 -Source "G:\Mon Drive\CAP Charcutier"
.EXAMPLE
    .\normaliser-audio.ps1 -Source "G:\Mon Drive\CAP Charcutier" -Compression
#>
param(
    [Parameter(Mandatory = $true)][string]$Source,
    [string]$Destination,
    [double]$Lufs = -14,
    [double]$TruePeak = -1,
    [double]$Lra = 11,
    [switch]$Compression
)

$ErrorActionPreference = 'Stop'

function Find-Tool([string]$name) {
    $local = Join-Path $PSScriptRoot "$name.exe"
    if (Test-Path -LiteralPath $local) { return $local }
    $cmd = Get-Command $name -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    throw "$name introuvable. Installez ffmpeg (voir LISEZMOI.md) ou placez $name.exe à côté de ce script."
}

# Lance ffmpeg et renvoie tout ce qu'il écrit (stdout + stderr) sous forme de texte.
function Invoke-Ffmpeg([string[]]$arguments) {
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & $script:ffmpeg @arguments 2>&1 | ForEach-Object { "$_" }
        $code = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previous
    }
    $text = $output -join "`n"
    if ($code -ne 0) { throw "ffmpeg a échoué (code $code) :`n$($output | Select-Object -Last 15 | Out-String)" }
    return $text
}

# Extrait le bloc JSON imprimé par loudnorm (print_format=json) à la fin de la sortie ffmpeg.
function Read-LoudnormJson([string]$text) {
    $start = $text.LastIndexOf('{')
    $end = $text.LastIndexOf('}')
    if ($start -lt 0 -or $end -lt $start) { throw "Mesure loudnorm introuvable dans la sortie de ffmpeg." }
    return $text.Substring($start, $end - $start + 1) | ConvertFrom-Json
}

function Measure-Loudness([string]$file, [string]$preFilter) {
    $filter = "${preFilter}loudnorm=I=${Lufs}:TP=${TruePeak}:LRA=${Lra}:print_format=json"
    $text = Invoke-Ffmpeg @('-hide_banner', '-nostats', '-i', $file, '-map', '0:a:0', '-af', $filter, '-f', 'null', '-')
    return Read-LoudnormJson $text
}

function Format-Number($value) {
    return ([double]$value).ToString('0.0', [Globalization.CultureInfo]::GetCultureInfo('fr-FR'))
}

$script:ffmpeg = Find-Tool 'ffmpeg'
$ffprobe = Find-Tool 'ffprobe'

$Source = (Resolve-Path -LiteralPath $Source).Path.TrimEnd('\', '/')
if (-not $Destination) { $Destination = "${Source}_normalise" }
New-Item -ItemType Directory -Force -Path $Destination | Out-Null
$Destination = (Resolve-Path -LiteralPath $Destination).Path.TrimEnd('\', '/')

$preFilter = ''
if ($Compression) { $preFilter = 'acompressor=threshold=-24dB:ratio=3:attack=20:release=250,' }

$extensions = @('.mp4', '.mov', '.mkv', '.m4v')
$videos = Get-ChildItem -LiteralPath $Source -Recurse -File |
    Where-Object { $extensions -contains $_.Extension.ToLower() -and -not $_.FullName.StartsWith($Destination + [IO.Path]::DirectorySeparatorChar) } |
    Sort-Object FullName

if (-not $videos) { Write-Host "Aucune vidéo trouvée dans $Source"; exit 1 }

$report = Join-Path $Destination 'rapport-volume.csv'
if (-not (Test-Path -LiteralPath $report)) {
    'Fichier;LUFS avant;Crête avant (dBTP);LUFS après;Crête après (dBTP);Statut' | Out-File -LiteralPath $report -Encoding utf8
}

Write-Host "Cible : $Lufs LUFS, crête max $TruePeak dBTP$(if ($Compression) { ', avec compression' })"
Write-Host "$($videos.Count) vidéo(s) à traiter -> $Destination`n"

$index = 0
$failures = 0
foreach ($video in $videos) {
    $index++
    $partial = $null
    $relative = $video.FullName.Substring($Source.Length).TrimStart('\', '/')
    $output = Join-Path $Destination ([IO.Path]::ChangeExtension($relative, '.mp4'))
    Write-Host "[$index/$($videos.Count)] $relative"

    if (Test-Path -LiteralPath $output) { Write-Host "    déjà traitée, ignorée`n"; continue }

    try {
        $hasAudio = & $ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 $video.FullName
        if (-not $hasAudio) {
            Write-Host "    pas de piste audio, ignorée`n"
            "$relative;;;;;sans audio" | Out-File -LiteralPath $report -Append -Encoding utf8
            continue
        }

        Write-Host '    mesure du volume...'
        $before = Measure-Loudness $video.FullName ''
        $measured = if ($Compression) { Measure-Loudness $video.FullName $preFilter } else { $before }
        Write-Host "    avant : $(Format-Number $before.input_i) LUFS, crête $(Format-Number $before.input_tp) dBTP"

        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $output) | Out-Null
        $partial = "$output.part.mp4"
        $filter = "${preFilter}loudnorm=I=${Lufs}:TP=${TruePeak}:LRA=${Lra}" +
            ":measured_I=$($measured.input_i):measured_TP=$($measured.input_tp)" +
            ":measured_LRA=$($measured.input_lra):measured_thresh=$($measured.input_thresh)" +
            ":offset=$($measured.target_offset):linear=true"

        Write-Host '    normalisation...'
        Invoke-Ffmpeg @('-hide_banner', '-nostats', '-y', '-i', $video.FullName,
            '-map', '0:v:0', '-map', '0:a:0', '-c:v', 'copy',
            '-af', $filter, '-c:a', 'aac', '-b:a', '192k', '-ar', '48000',
            '-map_metadata', '0', '-movflags', '+faststart', $partial) | Out-Null
        Move-Item -LiteralPath $partial -Destination $output -Force

        $after = Measure-Loudness $output ''
        Write-Host "    après : $(Format-Number $after.input_i) LUFS, crête $(Format-Number $after.input_tp) dBTP`n"
        "$relative;$(Format-Number $before.input_i);$(Format-Number $before.input_tp);$(Format-Number $after.input_i);$(Format-Number $after.input_tp);ok" |
            Out-File -LiteralPath $report -Append -Encoding utf8
    } catch {
        $failures++
        Write-Host "    ERREUR : $($_.Exception.Message)`n" -ForegroundColor Red
        if ($partial -and (Test-Path -LiteralPath $partial)) { Remove-Item -LiteralPath $partial -Force }
        "$relative;;;;;erreur" | Out-File -LiteralPath $report -Append -Encoding utf8
    }
}

Write-Host "Terminé. $failures erreur(s). Rapport : $report"
if ($failures) { exit 1 }

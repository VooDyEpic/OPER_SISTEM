param([string]$SourceDir)

if (-not $SourceDir) {
    Write-Host "Ошибка: укажите путь к папке"
    Write-Host "Пример: .\backup_script.ps1 C:\Images"
    exit 1
}

if (-not (Test-Path $SourceDir -PathType Container)) {
    Write-Host "Ошибка: папка $SourceDir не существует"
    exit 1
}

$ParentDir = Split-Path $SourceDir -Parent
$FolderName = Split-Path $SourceDir -Leaf
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$BackupPath = Join-Path $ParentDir "${FolderName}_backup_${Timestamp}"

New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null

$extensions = @("*.jpg", "*.jpeg", "*.png", "*.gif", "*.heic")
$counter = 0

foreach ($ext in $extensions) {
    $files = Get-ChildItem -Path $SourceDir -Recurse -Filter $ext -File -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        Copy-Item -Path $file.FullName -Destination $BackupPath -Verbose
        $counter++
    }
}

if ($counter -eq 0) {
    Write-Host "Внимание: изображения не найдены"
    Remove-Item -Path $BackupPath -Force
    exit 1
} else {
    Write-Host "Скопировано файлов: $counter"
    Write-Host "Бэкап создан: $BackupPath"
}
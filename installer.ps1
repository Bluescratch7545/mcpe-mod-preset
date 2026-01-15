$modulePath = "$HOME/Documents/WindowsPowerShell/Modules/mcpe"
New-Item -ItemType Directory -Path $modulePath -Force | Out-Null

Invoke-WebRequest `
    "https://raw.githubusercontent.com/Bluescratch7545/mcpe-mod-preset/main/mcpe.psm1" `
    -OutFile "$modulePath/mcpe.psm1"

Import-Module mcpe

Write-Host "||INFO|| mcpe installed successfully!" -ForegroundColor Green
Write-Host "||INFO|| Try: mcpe info" -ForegroundColor Cyan
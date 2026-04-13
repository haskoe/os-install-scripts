# Definer stien til WezTerm (retstien hvis du har installeret den et specielt sted)
$weztermPath = "$env:ProgramFiles\WezTerm\wezterm-gui.exe"

# Tjek om filen findes før vi ændrer noget
if (Test-Path $weztermPath) {
    # Sæt WezTerm som den foretrukne terminal emulator (De-facto standard for Win11)
    $registryPath = "HKCU:\Console\%%Startup"
    if (-not (Test-Path $registryPath)) { New-Item -Path $registryPath -Force }
    
    # Denne nøgle fortæller Windows at bruge en ekstern terminal
    Set-ItemProperty -Path $registryPath -Name "DelegationTerminal" -Value "{E9979B6A-6644-4824-95F8-132F239C2518}" 
    Set-ItemProperty -Path $registryPath -Name "DelegationConsole" -Value "{00000000-0000-0000-0000-000000000000}"

    Write-Host "WezTerm er nu sat som standard terminal!" -ForegroundColor Green
} else {
    Write-Error "Kunne ikke finde WezTerm på stien: $weztermPath"
}
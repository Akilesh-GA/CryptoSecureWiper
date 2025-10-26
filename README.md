# 🔒 Crypto Secure Wipe

**Secure Wipe** is a powerful Android application built using **Flutter (UI)** and **Kotlin (Native Android)** that performs a **complete and secure data wipe** from the device.  
It allows the admin to wipe **contacts, call logs, SMS, internal & external storage, cache, and media files** — or trigger a **full device wipe** using `DevicePolicyManager`.

---

## 📱 Features

| Category | Description |
|-----------|-------------|
| 🧩 **Full User Data Wipe** | Uses `DevicePolicyManager.wipeData()` to remove all user data including apps, media, and external storage. |
| 🗂 **Storage Cleaning** | Deletes internal app files, cache, and external app data directories. |
| 🖼 **Media Deletion** | Removes all photos, videos, audio, and downloads from the device. |
| ☎️ **Call Logs & Contacts** | Deletes all call logs and contacts from the device using content resolvers. |
| 💬 **SMS Wipe** | Deletes all text messages (on supported Android versions). |
| 🧾 **Dashboard UI** | Displays Internal, SD Card, and Flash memory usage stats before wiping. |
| 🔐 **Device Admin Permission** | Requests Device Admin privileges to allow full data wipe operations. |
| ⚙️ **All Files Access** | Requests MANAGE_EXTERNAL_STORAGE permission to wipe external directories. |
| ⚡ **Secure Confirmation Flow** | Ensures user confirmation before triggering irreversible wipe. |

---

## 🧠 Tech Stack

| Layer | Technology |
|--------|-------------|
| Frontend | Flutter (Dart) |
| Native Android | Kotlin |
| Channel Communication | MethodChannel (Flutter ↔ Kotlin bridge) |
| Permissions | DevicePolicyManager, MANAGE_EXTERNAL_STORAGE |
| Data Wipe | File deletion + Android content resolver + DPM wipeData() |

---

## 🧩 Architecture Overview


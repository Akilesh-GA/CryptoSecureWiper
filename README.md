# 🔒 Crypto Secure Wipe

**Secure Wipe** is a high-security Android utility built with **Flutter** and **Kotlin**. It is designed for scenarios requiring a rapid, "scorched-earth" removal of sensitive data. By bridging Flutter’s UI with Android’s `DevicePolicyManager`, it provides a unified dashboard to monitor storage and execute irreversible data destruction.

---

## ⚠️ CRITICAL WARNING

**DATA RECOVERY IS IMPOSSIBLE.** This application performs low-level data wipes and factory resets. Once the process is initiated, data cannot be recovered by any standard forensic means. Use with extreme caution.

---

## 📱 Features

| Category | Description |
|-----------|-------------|
| 🧩 **Full Factory Reset** | Triggers `DevicePolicyManager.wipeData()` to return the device to out-of-the-box state. |
| 🗂 **Granular Cleaning** | Target specific directories: Internal app files, cache, and external data folders. |
| 🖼 **Media Purge** | Recursive deletion of DCIM, Pictures, Videos, and Download directories. |
| ☎️ **Communication Wipe** | Clears Call Logs and Contacts databases via Android Content Resolvers. |
| 💬 **SMS Destruction** | Deep-cleans text message databases (Requires Default SMS app role). |
| 🧾 **Live Analytics** | Real-time dashboard showing used vs. free space for Internal and SD storage. |
| 🔐 **Admin Integration** | Seamless flow to request and verify Device Administrator privileges. |
| ⚙️ **Modern Scoped Storage** | Handles `MANAGE_EXTERNAL_STORAGE` for Android 11+ compatibility. |

---

## 🧠 Tech Stack

* **Frontend:** Flutter (Dart) for a responsive, material dashboard.
* **Native Backend:** Kotlin for low-level filesystem access and System API calls.
* **Bridge:** `MethodChannel` for asynchronous communication between Dart and Kotlin.
* **API Levels:** Supports Android 6.0 (Marshmallow) through Android 14+.

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK: `^3.0.0`
* Android Studio / Android SDK
* A physical Android device (Device Admin features often fail on Emulators)

### Installation & Setup

1.  **Clone the Repository**
    ```bash
    git clone [https://github.com/your-repo/crypto-secure-wipe.git](https://github.com/your-repo/crypto-secure-wipe.git)
    cd crypto-secure-wipe
    ```

2.  **Get Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Android Manifest Configuration**
    Ensure your `AndroidManifest.xml` includes the Device Admin receiver:
    ```xml
    <receiver
        android:name=".DeviceAdminReceiver"
        android:permission="android.permission.BIND_DEVICE_ADMIN">
        <meta-data
            android:name="android.app.device_admin"
            android:resource="@xml/device_admin_rules" />
        <intent-filter>
            <action android:name="android.app.action.DEVICE_ADMIN_ENABLED" />
        </intent-filter>
    </receiver>
    ```

4.  **Run the App**
    ```bash
    flutter run
    ```

---

### 📷 Prototype

<div align="center" style="display: flex; justify-content: center; align-items: flex-start; gap: 10px; flex-wrap: nowrap;">
  <img src="images/home.png" alt="Home" style="width: 18%; height: auto;">
  <img src="images/login.png" alt="Login" style="width: 18%; height: auto;">
  <img src="images/dashboard.png" alt="Dashboard" style="width: 18%; height: auto;">
  <img src="images/wipe.png" alt="Wipe" style="width: 18%; height: auto;">
</div>

## 📋 Permissions Required

To function effectively, the app requires the following high-level permissions:

BIND_DEVICE_ADMIN: To perform factory resets.

MANAGE_EXTERNAL_STORAGE: To bypass Scoped Storage and delete files.

READ_CONTACTS / WRITE_CONTACTS: For contact list purging.

READ_SMS / SEND_SMS: (If set as default) for SMS wiping.

🛡 Security Best Practices
Safety Interlocks: The app includes a "Slide-to-Confirm" or double-tap mechanism to prevent accidental wipes.

No Cloud Sync: This app operates strictly offline to ensure no data is leaked during the wipe process.

Recursive Shredding: Files are unlinked and the application attempts to overwrite pointers where OS permissions allow.

## 🛠 Project Structure

```text
lib/
├── main.dart           # App entry point & Theme setup
├── screens/
│   ├── dashboard.dart  # Storage stats and UI cards
│   └── wipe_screen.dart # Confirmation logic and animations
├── services/
│   └── native_api.dart # MethodChannel implementation
android/app/src/main/kotlin/
└── .../MainActivity.kt # Native Kotlin logic for DPM and File I/O

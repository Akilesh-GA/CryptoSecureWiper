package com.example.securewipe

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.widget.Toast
import android.content.pm.PackageManager
import android.Manifest
import android.util.Log

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.securewipe/channel"
    private val REQUEST_CODE_PERMISSIONS = 1001

    private val REQUIRED_PERMISSIONS = arrayOf(
        Manifest.permission.READ_CONTACTS,
        Manifest.permission.WRITE_CONTACTS,
        Manifest.permission.READ_CALL_LOG,
        Manifest.permission.WRITE_CALL_LOG,
        Manifest.permission.READ_SMS,
        Manifest.permission.READ_EXTERNAL_STORAGE,
        Manifest.permission.WRITE_EXTERNAL_STORAGE,
        Manifest.permission.MANAGE_EXTERNAL_STORAGE
    )

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    // Enable Device Admin
                    "enableDeviceAdmin" -> enableAdmin(result)

                    // ✅ Updated: One-click user data wipe (images, videos, docs)
                    "oneClickWipe" -> {
                        try {
                            checkAndRequestPermissions(result)
                        } catch (e: Exception) {
                            result.error("WIPE_FAILED", e.message, null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    // ✅ Check and request runtime permissions
    private fun checkAndRequestPermissions(result: MethodChannel.Result) {
        val missing = REQUIRED_PERMISSIONS.filter {
            checkSelfPermission(it) != PackageManager.PERMISSION_GRANTED
        }

        if (missing.isNotEmpty()) {
            requestPermissions(missing.toTypedArray(), REQUEST_CODE_PERMISSIONS)
            Toast.makeText(this, "Grant all permissions to proceed", Toast.LENGTH_SHORT).show()
            result.success("Permission request initiated")
        } else {
            performWipe(result)
        }
    }

    // ✅ Performs user data wipe (images, videos, documents, etc.)
    private fun performWipe(result: MethodChannel.Result) {
        try {
            val wipeResults = UserDataWipeHelper.wipeAllUserData(this)
            val summary = wipeResults.joinToString("\n")
            Toast.makeText(this, "User data wipe completed", Toast.LENGTH_SHORT).show()
            result.success(summary)
        } catch (e: SecurityException) {
            Log.e("SecureWipe", "Permission denied: ${e.message}")
            Toast.makeText(this, "Partial wipe done. Some sections skipped.", Toast.LENGTH_LONG).show()
            result.success("Partial wipe done. Missing permissions for some data.")
        } catch (e: Exception) {
            result.error("WIPE_FAILED", e.message, null)
        }
    }

    // ✅ Handle runtime permission result
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_CODE_PERMISSIONS) {
            if (grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
                val results = UserDataWipeHelper.wipeAllUserData(this)
                Toast.makeText(this, "Wipe completed: ${results.joinToString()}", Toast.LENGTH_LONG).show()
            } else {
                Toast.makeText(this, "All permissions required to wipe data", Toast.LENGTH_LONG).show()
            }
        }
    }

    // ✅ Enable device admin
    private fun enableAdmin(result: MethodChannel.Result) {
        val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val compName = ComponentName(this, MyDeviceAdminReceiver::class.java)

        if (!devicePolicyManager.isAdminActive(compName)) {
            val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN)
            intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, compName)
            intent.putExtra(
                DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                "Secure Wipe needs admin access to securely wipe your device."
            )
            startActivity(intent)
            result.success("Admin request initiated")
        } else {
            Toast.makeText(this, "Admin access already granted", Toast.LENGTH_SHORT).show()
            result.success("Admin already granted")
        }
    }

    // (Keep for future full reset if needed)
    private fun wipeDevice(result: MethodChannel.Result) {
        val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val compName = ComponentName(this, MyDeviceAdminReceiver::class.java)

        if (devicePolicyManager.isAdminActive(compName)) {
            Toast.makeText(this, "Full device wipe initiated", Toast.LENGTH_LONG).show()
            devicePolicyManager.wipeData(DevicePolicyManager.WIPE_EXTERNAL_STORAGE)
            result.success("Full device wipe initiated")
        } else {
            Toast.makeText(this, "Admin access required to wipe device", Toast.LENGTH_LONG).show()
            result.error("ADMIN_REQUIRED", "Device admin access is required", null)
        }
    }
}
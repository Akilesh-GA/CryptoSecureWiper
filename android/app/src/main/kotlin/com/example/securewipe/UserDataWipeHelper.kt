package com.example.securewipe

import android.content.Context
import android.os.Environment
import android.provider.MediaStore
import android.provider.ContactsContract
import android.provider.CallLog
import android.provider.Telephony
import android.widget.Toast
import java.io.File

object UserDataWipeHelper {

    fun wipeAllUserData(context: Context): List<String> {
        val result = mutableListOf<String>()

        fun safeDelete(action: String, block: () -> Int?) {
            try {
                val deleted = block() ?: 0
                result.add("✅ $action: Deleted $deleted items")
            } catch (e: SecurityException) {
                result.add("⚠ $action skipped (no permission)")
            } catch (e: Exception) {
                result.add("⚠ $action failed: ${e.message}")
            }
        }

        // 1️⃣ Contacts
        safeDelete("Contacts") {
            context.contentResolver.delete(ContactsContract.RawContacts.CONTENT_URI, null, null)
        }

        // 2️⃣ SMS
        safeDelete("SMS") {
            context.contentResolver.delete(Telephony.Sms.CONTENT_URI, null, null)
        }

        // 3️⃣ Call Logs
        safeDelete("Call Logs") {
            context.contentResolver.delete(CallLog.Calls.CONTENT_URI, null, null)
        }

        // 4️⃣ Media files (images, videos, audio, downloads)
        try {
            val mediaUris = listOf(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                MediaStore.Downloads.EXTERNAL_CONTENT_URI,
                MediaStore.Files.getContentUri("external")
            )

            var totalDeleted = 0
            for (uri in mediaUris) {
                val count = context.contentResolver.delete(uri, null, null)
                totalDeleted += if (count > 0) count else 0
            }
            result.add("✅ Images, videos, audio, and docs wiped: $totalDeleted items")
        } catch (e: Exception) {
            result.add("⚠ Media wipe failed: ${e.message}")
        }

        // 5️⃣ Internal app files
        try {
            context.filesDir.deleteRecursively()
            result.add("✅ Internal app files deleted")
        } catch (e: Exception) {
            result.add("⚠ Internal app files wipe failed: ${e.message}")
        }

        // 6️⃣ Cache
        try {
            context.cacheDir.deleteRecursively()
            result.add("✅ Cache cleared")
        } catch (e: Exception) {
            result.add("⚠ Cache wipe failed: ${e.message}")
        }

        // 7️⃣ External app files
        try {
            val externalFiles = context.getExternalFilesDir(null)
            externalFiles?.deleteRecursively()
            result.add("✅ External app files deleted")
        } catch (e: Exception) {
            result.add("⚠ External app wipe failed: ${e.message}")
        }

        // 8️⃣ Public directories (images, videos, downloads, music, documents)
        try {
            val dirs = listOf(
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM),
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES),
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES),
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS),
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MUSIC)
            )

            var deletedFiles = 0
            for (dir in dirs) {
                if (dir.exists()) {
                    deletedFiles += deleteFolderRecursively(dir)
                }
            }
            result.add("✅ Public media and document folders wiped: $deletedFiles files deleted")
        } catch (e: Exception) {
            result.add("⚠ Public folder wipe failed: ${e.message}")
        }

        Toast.makeText(context, "Wipe completed (some data may require permission)", Toast.LENGTH_LONG).show()
        return result
    }

    private fun deleteFolderRecursively(file: File): Int {
        var count = 0
        if (file.isDirectory) {
            file.listFiles()?.forEach {
                count += deleteFolderRecursively(it)
            }
        }
        if (file.delete()) count++
        return count
    }
}
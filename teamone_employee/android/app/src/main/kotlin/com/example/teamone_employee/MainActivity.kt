package com.example.teamone_employee

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.widget.Toast

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.signuptoast"
    private val CHANNEL1 = "com.example.signuptoast" // Rename to CHANNEL1 or a more meaningful name if needed

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Method Channel for showing sign up success toast
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "showSignupSuccessToast") {
                showSignupSuccessToast()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        // Method Channel for handling successful login
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL1).setMethodCallHandler { call, result ->
            if (call.method == "successfulLogin") {
                // Handle the successful login action here
                showToast("Login Successful")
                result.success(null) // Optionally, send a result back to Dart
            } else {
                result.notImplemented()
            }
        }
    }

    private fun showSignupSuccessToast() {
        runOnUiThread {
            Toast.makeText(applicationContext, "Sign Up Successful", Toast.LENGTH_SHORT).show()
        }
    }

    private fun showToast(message: String) {
        runOnUiThread {
            Toast.makeText(applicationContext, message, Toast.LENGTH_SHORT).show()
        }
    }
}

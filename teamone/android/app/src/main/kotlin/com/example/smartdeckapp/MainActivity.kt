package com.example.smartdeckapp

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.widget.Toast

class MainActivity : FlutterActivity() {

    private val CHANNEL_SIGNUP_TOAST = "com.example.signuptoast"
    private val CHANNEL_LOGIN_SUCCESS = "com.example.signuptoast"
    private val CHANNEL_SIGNUP_FAILURE_TOAST = "com.example.signuptoast" // Add a new channel for signup failure
    private val CHANNEL_LOGIN_FAILURE_TOAST = "com.example.signuptoast" // Add a new channel for signup failure

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Method Channel for showing sign up success toast
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_SIGNUP_TOAST).setMethodCallHandler { call, result ->
            if (call.method == "showSignupSuccessToast") {
                showSignupSuccessToast()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        // Method Channel for handling successful login
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_LOGIN_SUCCESS).setMethodCallHandler { call, result ->
            if (call.method == "successfulLogin") {
                // Handle the successful login action here
                showToast("Login Successful")
                result.success(null) // Optionally, send a result back to Dart
            } else {
                result.notImplemented()
            }
        }

        // Method Channel for showing sign up failure toast
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_SIGNUP_FAILURE_TOAST).setMethodCallHandler { call, result ->
            if (call.method == "showSignupFailureToast") {
                showSignupFailureToast()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        // method channel for showing login failur toast
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_LOGIN_FAILURE_TOAST).setMethodCallHandler { call, result ->
            if (call.method == "showLoginFailureToast") {
                showLoginFailureToast()
                result.success(null)
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

    private fun showSignupFailureToast() {
        runOnUiThread {
            Toast.makeText(applicationContext, "Sign Up Failed,invalid email,password", Toast.LENGTH_SHORT).show()
        }
    }



     private fun showLoginFailureToast() {
        runOnUiThread {
            Toast.makeText(applicationContext, "Login Failed,invalid email,password", Toast.LENGTH_SHORT).show()
        }
    }

    private fun showToast(message: String) {
        runOnUiThread {
            Toast.makeText(applicationContext, message, Toast.LENGTH_SHORT).show()
        }
    }
}

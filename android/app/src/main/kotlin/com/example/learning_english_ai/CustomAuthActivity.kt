package com.example.learning_english_ai

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class CustomAuthActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Manejar el resultado de Google Sign-In
        handleSignInResult(intent)
    }

    private fun handleSignInResult(intent: Intent?) {
        // Puedes agregar lógica personalizada aquí si es necesario
    }
}
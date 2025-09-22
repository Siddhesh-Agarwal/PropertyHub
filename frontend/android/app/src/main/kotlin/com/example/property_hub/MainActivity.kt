package com.mycompany.propertyhub

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import com.google.firebase.FirebaseApp

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        FirebaseApp.initializeApp(this)
    }
}

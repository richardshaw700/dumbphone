package com.bigme.dumbphone

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity

class SecurityActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_security)
        
        // Make the entire screen tappable to go back
        findViewById<View>(R.id.securityRoot).setOnClickListener {
            finish()
        }
    }
    
    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        finish()
    }
}


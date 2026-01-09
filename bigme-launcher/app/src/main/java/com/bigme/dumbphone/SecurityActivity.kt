package com.bigme.dumbphone

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

class SecurityActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_security)
    }
    
    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        finish()
    }
}


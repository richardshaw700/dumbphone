package com.bigme.dumbphone

import android.os.Bundle
import android.view.MotionEvent
import androidx.appcompat.app.AppCompatActivity

class SecurityActivity : AppCompatActivity() {
    
    private var touchDownTime = 0L
    private var touchDownX = 0f
    private var touchDownY = 0f
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_security)
    }
    
    override fun dispatchTouchEvent(event: MotionEvent): Boolean {
        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                touchDownTime = System.currentTimeMillis()
                touchDownX = event.x
                touchDownY = event.y
            }
            MotionEvent.ACTION_UP -> {
                val elapsed = System.currentTimeMillis() - touchDownTime
                val dx = Math.abs(event.x - touchDownX)
                val dy = Math.abs(event.y - touchDownY)
                
                // If it's a quick tap (not a scroll), go back
                if (elapsed < 300 && dx < 50 && dy < 50) {
                    finish()
                    return true
                }
            }
        }
        return super.dispatchTouchEvent(event)
    }
    
    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        finish()
    }
}


package com.bigme.dumbphone

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import java.text.SimpleDateFormat
import java.util.*

class LockScreenActivity : Activity() {

    private lateinit var clockText: TextView
    private val handler = Handler(Looper.getMainLooper())
    
    private val timeFormat = SimpleDateFormat("HH:mm", Locale.getDefault())  // 24h format

    companion object {
        private val restartHandler = Handler(Looper.getMainLooper())
        private var pendingRestart: Runnable? = null
        
        // Call this when user unlocks (reaches home screen)
        fun cancelPendingRestart() {
            pendingRestart?.let { restartHandler.removeCallbacks(it) }
            pendingRestart = null
        }
    }

    private val updateTimeRunnable = object : Runnable {
        override fun run() {
            updateTime()
            handler.postDelayed(this, 1000)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Cancel any pending restart since we're showing now
        cancelPendingRestart()
        
        // Use newer APIs on Android 8.0+ for faster lock screen overlay
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }
        
        // Fullscreen flags
        window.addFlags(
            WindowManager.LayoutParams.FLAG_FULLSCREEN or
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
        )
        
        // Hide system UI immediately
        window.decorView.systemUiVisibility = (
            View.SYSTEM_UI_FLAG_FULLSCREEN or
            View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
            View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or
            View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
            View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
            View.SYSTEM_UI_FLAG_LAYOUT_STABLE
        )
        
        setContentView(R.layout.activity_lockscreen)
        
        clockText = findViewById(R.id.clockText)
        
        updateTime()
    }

    override fun onResume() {
        super.onResume()
        handler.post(updateTimeRunnable)
    }

    override fun onPause() {
        super.onPause()
        handler.removeCallbacks(updateTimeRunnable)
    }

    private fun updateTime() {
        clockText.text = timeFormat.format(Date())
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        // Tap anywhere to dismiss
        if (event.action == MotionEvent.ACTION_UP) {
            dismissAndScheduleRestart()
            return true
        }
        return super.onTouchEvent(event)
    }
    
    private fun dismissAndScheduleRestart() {
        val context = applicationContext
        
        // Schedule restart after 3 seconds
        // (MainActivity.onResume will cancel this if user unlocks)
        pendingRestart = Runnable {
            try {
                val intent = Intent(context, LockScreenActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(intent)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        restartHandler.postDelayed(pendingRestart!!, 3000)
        
        finish()
    }

    override fun onBackPressed() {
        // Do nothing - require tap to dismiss
    }
}

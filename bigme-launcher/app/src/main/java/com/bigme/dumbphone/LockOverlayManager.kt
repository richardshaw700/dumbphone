package com.bigme.dumbphone

import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.TextView
import java.text.SimpleDateFormat
import java.util.*

class LockOverlayManager(private val context: Context) {
    
    private val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private var overlayView: View? = null
    private var clockText: TextView? = null
    private val handler = Handler(Looper.getMainLooper())
    private val timeFormat = SimpleDateFormat("HH:mm", Locale.getDefault())
    
    private val updateTimeRunnable = object : Runnable {
        override fun run() {
            clockText?.text = timeFormat.format(Date())
            handler.postDelayed(this, 1000)
        }
    }
    
    fun showOverlay() {
        if (overlayView != null) return  // Already showing
        
        // Create the overlay view
        val container = FrameLayout(context).apply {
            setBackgroundColor(Color.WHITE)
            
            // Add clock text
            clockText = TextView(context).apply {
                text = timeFormat.format(Date())
                textSize = 72f  // Large clock
                setTextColor(Color.BLACK)
                typeface = android.graphics.Typeface.create("sans-serif-light", android.graphics.Typeface.BOLD)
            }
            
            val clockParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.CENTER
            }
            addView(clockText, clockParams)
            
            // Tap to dismiss
            setOnTouchListener { _, event ->
                if (event.action == MotionEvent.ACTION_UP) {
                    hideOverlay()
                    true
                } else {
                    false
                }
            }
        }
        
        overlayView = container
        
        // Window params for overlay
        val layoutType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_SYSTEM_ALERT
        }
        
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            layoutType,
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE.inv() or  // Allow touch
                WindowManager.LayoutParams.FLAG_FULLSCREEN,
            PixelFormat.OPAQUE
        ).apply {
            gravity = Gravity.CENTER
        }
        
        try {
            windowManager.addView(overlayView, params)
            handler.post(updateTimeRunnable)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    
    fun hideOverlay() {
        overlayView?.let {
            try {
                windowManager.removeView(it)
            } catch (e: Exception) {
                e.printStackTrace()
            }
            overlayView = null
            clockText = null
            handler.removeCallbacks(updateTimeRunnable)
        }
    }
    
    fun isShowing(): Boolean = overlayView != null
}


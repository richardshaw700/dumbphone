package com.bigme.dumbphone

import android.app.Service
import android.content.Intent
import android.content.IntentFilter
import android.os.IBinder

class LockScreenService : Service() {
    
    private var screenReceiver: ScreenReceiver? = null
    
    override fun onCreate() {
        super.onCreate()
        screenReceiver = ScreenReceiver()
        val filter = IntentFilter(Intent.ACTION_SCREEN_ON)
        registerReceiver(screenReceiver, filter)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        screenReceiver?.let {
            unregisterReceiver(it)
        }
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }
}


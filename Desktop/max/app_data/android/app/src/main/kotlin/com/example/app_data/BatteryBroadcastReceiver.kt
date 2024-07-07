package com.example.app_data

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.BatteryManager
import android.widget.Toast

class BatteryBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val batteryStatus: Int = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
        if (batteryStatus >= 90) {
            Toast.makeText(context, "Battery reached 90%", Toast.LENGTH_LONG).show()
        }
    }
}

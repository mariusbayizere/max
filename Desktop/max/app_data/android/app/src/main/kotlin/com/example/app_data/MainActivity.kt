package com.example.app_data

import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle
import android.content.IntentFilter
import android.content.Context
import android.net.ConnectivityManager
import android.content.Intent

class MainActivity: FlutterActivity() {
    private lateinit var connectivityBroadcastReceiver: ConnectivityBroadcastReceiver
    private lateinit var batteryBroadcastReceiver: BatteryBroadcastReceiver

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Register ConnectivityBroadcastReceiver
        connectivityBroadcastReceiver = ConnectivityBroadcastReceiver()
        val connectivityFilter = IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION)
        registerReceiver(connectivityBroadcastReceiver, connectivityFilter)

        // Register BatteryBroadcastReceiver
        batteryBroadcastReceiver = BatteryBroadcastReceiver()
        val batteryFilter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        registerReceiver(batteryBroadcastReceiver, batteryFilter)
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(connectivityBroadcastReceiver)
        unregisterReceiver(batteryBroadcastReceiver)
    }
}

package com.liyin.freeman.service;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.text.format.DateUtils;
import android.util.Log;
import androidx.core.content.ContextCompat;

public class KeepAliveReceiver extends BroadcastReceiver {
    String SCREEN_ON = "android.intent.action.SCREEN_ON";
    String SCREEN_OFF = "android.intent.action.SCREEN_OFF";
    @Override
    public void onReceive(Context context, Intent intent) {

        String action = intent.getAction();
        Log.e("FreeMan", "KeepAliveReceiver onReceive: "+action);
        if(action.equals(Intent.ACTION_BOOT_COMPLETED)
                ||action.equals(Intent.ACTION_REBOOT)
                ||action.equals(Intent.ACTION_MY_PACKAGE_REPLACED)
                ||action.equals(Intent.ACTION_BATTERY_CHANGED)
        ){
            startForegroundService(context);
        }

        if(SCREEN_ON.equals(action)){
            Log.e("FreeMan", "....SCREEN_ON");
            startKeepAliveService(context);
        }else if(SCREEN_OFF.equals(action)){
            Log.e("FreeMan", "......SCREEN_OFF");
            stopKeepAliveService(context);
        }else if(ConnectivityManager.CONNECTIVITY_ACTION.equals(action)){
            NetworkInfo networkInfo = intent.getParcelableExtra(ConnectivityManager.EXTRA_NETWORK_INFO);
            if(networkInfo != null && networkInfo.isConnected()){
                startKeepAliveService(context);
            }else{
                stopKeepAliveService(context);
            }
        }
    }

    private void startKeepAliveService(Context context){
        //Intent intent = new Intent(context, KeepAliveService.class);
        //context.startService(intent);
        KeepAliveJobService.startJob(context);
    }

    private void stopKeepAliveService(Context context){
        Intent intent = new Intent(context, KeepAliveService.class);
        context.stopService(intent);
    }

    private void startForegroundService(Context context){
        try {
            Intent intent = new Intent(KeepAliveService.ACTION_START);
            intent.setClass(context, KeepAliveService.class);
            intent.putExtra(KeepAliveService.EXTRA_TIMEOUT, 7*DateUtils.SECOND_IN_MILLIS);
            Log.e("FreeMan", "KeepAliveReceiver start KeepAliveService");
            ContextCompat.startForegroundService(context,intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


}

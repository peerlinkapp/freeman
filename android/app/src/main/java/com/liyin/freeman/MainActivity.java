package com.liyin.freeman;
import android.content.Context;
import android.content.IntentFilter;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.embedding.android.FlutterActivity;

import android.os.PowerManager;
import android.provider.Settings;
import android.content.Intent;
import android.util.Log;

import com.liyin.freeman.service.KeepAliveJobService;
import com.liyin.freeman.service.KeepAliveReceiver;
import com.liyin.freeman.service.LocalForegroundService;
import com.liyin.freeman.service.RemoteForegroundService;


public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.liyin.freeman/androidInvoke"; // 使用相同的通道名称
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);



        new MethodChannel(getFlutterEngine().getDartExecutor(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("requestBatteryOptimizationPermission")) {
                                requestBatteryOptimizationPermission();
                                result.success(null); // 返回空值，表示成功
                            }  else if (call.method.equals("minimizeApp")) {
                                Log.e("LFF", "应用在后台继续运行。");
                                moveTaskToBack(true); // 关键代码：把任务移到后台
                                result.success(null);
                            } else {
                                result.notImplemented(); // 处理未知方法
                            }
                        }
                );

        startAndroidKeepAliveService();



/*

        AlarmManager alarmManager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
        Intent intent = new Intent(this, KeepAliveReceiver.class);
        PendingIntent pendingIntent = PendingIntent.getService(this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        // 设置定时任务，每隔一段时间执行
        alarmManager.setRepeating(AlarmManager.RTC_WAKEUP, System.currentTimeMillis(), 1000 * 60, pendingIntent);
*/


    }

    // 打开电池优化设置
    private void requestBatteryOptimizationPermission() {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PowerManager powerManager = (PowerManager) getSystemService(Context.POWER_SERVICE);
           // if (!powerManager.isIgnoringBatteryOptimizations(getPackageName())) {
                //Log.e("MainActivity", "[MainActivity]sss");
                try {
                    Intent intent = new Intent();
                    intent.setAction(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS);
                    intent.setData(Uri.parse("package:" + getPackageName()));
                    startActivity(intent);
                }catch (Exception e){
                    e.printStackTrace();
                }


           /* }else {
               Log.e("LFF", "应用已经被允许忽略电池优化，可以在后台继续运行。");
            }*/

        }


        //Intent intent = new Intent();
        //intent.setAction(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS);
        //startActivity(intent); // 启动电池优化设置界面
    }


    // 启动保活服务
    private void startAndroidKeepAliveService() {
        //Intent startIntent = new Intent(this, KeepAliveService.class);
        //startService(startIntent);
        //regisScreenStatusReceiver();

        // JobScheduler 拉活
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            KeepAliveJobService.startJob(this);
        }
    }

    private KeepAliveReceiver mKeepAliveReceiver;


    private void regisScreenStatusReceiver(){
        mKeepAliveReceiver = new KeepAliveReceiver();
        IntentFilter filter = new IntentFilter();
        filter.addAction(Intent.ACTION_SCREEN_ON);
        filter.addAction(Intent.ACTION_SCREEN_OFF);
        filter.addAction(Intent.ACTION_BOOT_COMPLETED);
        filter.addAction(Intent.ACTION_REBOOT);
        filter.addAction(Intent.ACTION_MY_PACKAGE_REPLACED);
        filter.addAction(Intent.ACTION_BATTERY_CHANGED);
        registerReceiver(mKeepAliveReceiver, filter);
    }
}

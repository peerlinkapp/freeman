package com.liyin.freeman.service;

import android.app.NotificationChannel;  // 用于创建通知通道
import android.app.NotificationManager;  // 用于管理通知
import android.os.Build;  // 用于检查设备的 Android 版本
import androidx.core.app.NotificationCompat;  // 支持通知的构建（兼容性）
import android.app.Notification;
import android.app.Service;
import android.content.Intent;
import android.content.pm.ServiceInfo;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;
import android.os.Handler;
import android.os.Looper;



import com.liyin.freeman.MainActivity;
import com.liyin.freeman.R;  // 确保导入正确的 R 类


public class KeepAliveService extends Service {

    public static final String  ACTION_START = "startService";
    public static final String  ACTION_STOP = "stopService";
    public static final String CHANNEL_ID = "MY_CHANNEL_ID";
    public static int NOTIFICATION_ID = 1004;
    public static final String  EXTRA_TIMEOUT = "timeout";


    private Handler handler = new Handler(Looper.getMainLooper()); // 主线程的 Handler
    private Runnable runnable;
    private int count = 0;


    @Override
    public void onCreate() {
        super.onCreate();
        Log.e("FreeMan", "KeepAliveService onCreate() ");

        // 这里可以启动一个新的进程
        // 在后台执行耗时操作
        /*new Thread(new Runnable() {
            @Override
            public void run() {
                // 模拟耗时操作
                int i=0;
                while (i< 1000000)
                {
                    Log.e("FreeMan", "KeepAliveService loop "+String.valueOf(i++));
                    try {
                        Thread.sleep(5000);
                    } catch (InterruptedException e) {
                        throw new RuntimeException(e);
                    }
                }
                stopSelf(); // 完成后停止Service
            }
        }).start();*/

/*
// 创建通知
        Notification notification = new NotificationCompat.Builder(this, "MY_CHANNEL_ID")
                .setContentTitle("Service is running")
                .setContentText("Performing background tasks...")
                .setSmallIcon(R.mipmap.ic_launcher)  // 必须设置图标
                .setPriority(PRIORITY_MIN)
                .build();
*/


        if(Build.VERSION.SDK_INT < Build.VERSION_CODES.O){ //Android4.3以下版本
            startForeground(NOTIFICATION_ID, new Notification());
        } else if (Build.VERSION.SDK_INT < 25) {//Android4.3 - 7.0之间
            //将Service设置为前台服务，可以取消通知栏消息
            startForeground(NOTIFICATION_ID, new Notification());
            startService(new Intent(this, InnerService.class));

        }else{//Android 8.0以上

            startService(new Intent(this, InnerService.class));
            // 创建通知通道
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,     // 通道ID
                    "My Notification",    // 通道名称
                    NotificationManager.IMPORTANCE_DEFAULT); // 通道重要性
            channel.setDescription("My Notification Channel");

            NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID);
            // 注册通知通道
            NotificationManager notificationManager = getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);

            Notification notification = builder.setOngoing(true)
                    .setSmallIcon(R.mipmap.ic_launcher)
                    .setPriority(Notification.PRIORITY_MAX)
                    .setCategory(Notification.CATEGORY_SERVICE)
                    .build();

            Log.e("FreeMan", "KeepAliveService InnerService onStartCommand ");

            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC);



        }

    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        // 停止循环任务
        handler.removeCallbacks(runnable);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {

        Log.e("FreeMan", "KeepAliveService onStartCommand 1");

        // 返回 START_STICKY 可以使服务在被杀死时重启
        return START_STICKY;
    }

    private void startMainProcess(){
        String packageName = getPackageName();
        String className = MainActivity.class.getName();
        Intent intent = new Intent();
        intent.setClassName(packageName, className);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    public static class InnerService extends Service {

        @Override
        public IBinder onBind(Intent intent) {
            return null;
        }

        @Override
        public int onStartCommand(Intent intent, int flags, int startId) {


            stopForeground(true);//移除通知栏消息
            stopSelf();
            return super.onStartCommand(intent, flags, startId);
        }
    }

}

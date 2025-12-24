
import 'dart:async';
import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:device_preview_screenshot/device_preview_screenshot.dart';
import 'package:flutter/foundation.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';

import 'package:freeman/l10n/l10n.dart'; //引入国际化多语言本地化类
import 'package:freeman/dhtclient.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:freeman/ui/register.dart';
import 'global.dart';

import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:permission_handler/permission_handler.dart';

import 'constants.dart';
import 'ui/home_page.dart';
import 'my_app_settings.dart';


import 'ui/themes.dart';
import './my_main_app.dart';

import 'package:talker_flutter/talker_flutter.dart';

Future<void>  main() async {

  WidgetsFlutterBinding.ensureInitialized();

  final talker = TalkerFlutter.init(
    settings: TalkerSettings(
      colors: {
        YourCustomLog.logKey: AnsiPen()..green(),
      },
      titles: {
        YourCustomLog.logKey: 'Custom',
      },
    ),
  );

  kPackageInfo = await PackageInfo.fromPlatform();
  final settings = await MyAppSettings.create();

  //检查并审核权限
  await  requestPermissions();

  //await Future.delayed(Duration(milliseconds: 19500)); // 模拟加载

  if (kIsMobileOrWeb) {
    Global.init(talker).then((e) => runApp(

        ProviderScope(
          overrides: [mySettingsProvider.overrideWith((ref) => settings)],
          child: MyMainApp(settings),
        )
    )//runApp
    );

    return;
  }



}


Future<void> requestPermissions() async {

  await  requestBatteryOptimizationPermission();

  if (Platform.isAndroid && (await Permission.manageExternalStorage.isGranted == false)) {
    await Permission.manageExternalStorage.request();
  }

  try {
    // 检查并请求存储权限
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      print("Storage permission granted");
    } else if (status.isDenied) {
      print("Storage permission denied");
    } else if (status.isPermanentlyDenied) {
      // 如果权限被永久拒绝，可以引导用户到设置页面
      openAppSettings();
    }

    // 检查并请求相机权限
    PermissionStatus cameraStatus = await Permission.camera.request();
    if (cameraStatus.isGranted) {
      print("Camera permission granted");
    } else {
      print("Camera permission denied");
    }
  } catch (e) {
    // 异常处理代码
    print('捕获到的异常: $e');
  }

}


Future<void> requestBatteryOptimizationPermission() async {
  print("permission requestBatteryOptimizationPermission");
  const platform = MethodChannel('com.liyin.freeman/androidInvoke');
  try {
    print("permission invokeMethod requestBatteryOptimizationPermission");
    await platform.invokeMethod('requestBatteryOptimizationPermission');
  } on PlatformException catch (e) {
    print("Error occurred: ${e.message}");
  }
}

class YourCustomLog extends TalkerLog {
  YourCustomLog(String message) : super(message);

  /// Your own log key (for color customization in settings)
  static const logKey = 'custom_log_key';

  @override
  String? get key => logKey;
}

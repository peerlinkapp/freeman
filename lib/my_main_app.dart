import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:freeman/common/ui.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:freeman/l10n/l10n.dart'; //引入国际化多语言本地化类
import 'constants.dart';
import 'global.dart';
import 'ui/my_app_routes.dart' show kAppRoutingTable;
import './my_app_settings.dart';
import 'ui/themes.dart';
import 'ui/login.dart';
import 'ui/my_route.dart';
import 'ui/home_page.dart';
import '../model/user.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:freeman/l10n/l10n.dart'; //引入国际化多语言本地化类
import 'package:freeman/dhtclient.dart';
import 'package:flutter_app_minimizer_plus/flutter_app_minimizer_plus.dart';
import 'common/route.dart';

class MyMainApp extends StatelessWidget {
  final MyAppSettings settings;
  const MyMainApp(this.settings, {super.key});

  @override

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider<MyAppSettings>.value(
      value: settings,
      child: _MyMaterialApp(settings),
    );
  }
}

class _MyMaterialApp extends StatelessWidget {
  final MyAppSettings settings;

  const _MyMaterialApp(this.settings);


  @override
  Widget build(BuildContext context) {

    var kHomeRoute = MyRoute(
      sourceFilePath: 'lib/login.dart',
      title:  APP_NAME,
      routeName: Navigator.defaultRouteName,
      child:  LoginPage(), //系统默认首页
    );

// This app's root-level routing table.
    final kAppRoutingTable = <String, WidgetBuilder>{
      Navigator.defaultRouteName: (context) => kHomeRoute,

    };


    return WillPopScope(
        onWillPop: () async {

          return false;
        },
        child:GetMaterialApp(    // Use GetMaterialApp instead of MaterialApp
                    navigatorKey: navGK,
                    title: APP_NAME,
                    theme: Provider.of<MyAppSettings>(context).isDarkMode
                        ? kDarkTheme
                        : kLightTheme,
					routes: kAppRoutingTable,
                    debugShowCheckedModeBanner: false,
                    locale: DevicePreview.locale(context),
                    builder: DevicePreview.appBuilder,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: AppLocalizations.supportedLocales,
              )
    );
  }
}

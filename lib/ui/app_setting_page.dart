import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freeman/common.dart';
import 'package:freeman/common/ui.dart';


class AppSettingPage extends ConsumerStatefulWidget {
  const AppSettingPage({super.key});

  @override
  _AppSettingPageState createState() => _AppSettingPageState();
}

class _AppSettingPageState extends ConsumerState<AppSettingPage> {
  final List<Tab> tabs = [
    Tab(text: Global.l10n.app_setting_tab1),
    Tab(text: Global.l10n.app_setting_tab2),
  ];



  @override
  Widget build(BuildContext context) {


    var  menuItemsLoginMode = <String>[
      Global.l10n.login_mode_auto,
      Global.l10n.login_mode_every_time,
      Global.l10n.login_mode_timeout,
    ];
    String _btnLoginModeSelectedVal = menuItemsLoginMode[Global.settings.loginMode];

    final List<DropdownMenuItem<String>> dropDownLoginModeMenuItems = menuItemsLoginMode
        .map(
          (String value) => DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      ),
    )
        .toList();

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(Global.l10n.drawer_menu_settings),
        ),
        body: Column(
          children: [


            // TabBar
            Container(
                color:  Global.settings.isDarkMode ? AppDarkColors.AppBarColor :  AppColors.AppBarColor, // TabBar 的背景色
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        color:  Global.settings.isDarkMode ? AppDarkColors.AppBarColor :  AppColors.AppBarColor, // TabBar 的背景色
                        child: TabBar(
                          isScrollable: true, // 必须设置为 true，标签才会靠左，不会均分占满宽度
                          tabs: tabs,
                          indicatorColor: AppColors.TabIconNormal,
                          labelColor: AppColors.TabIconNormal,
                          unselectedLabelColor: AppColors.TabIconNormal,
                        ),
                      ),
                    ])),

            // TabBarView
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: 通用设置
                  ListView(
                    padding: const EdgeInsets.all(5),
                    children: [
                      ListTile(
                        title: Text(Global.l10n.login_mode),
                        trailing: DropdownButton<String>(
                          // Must be one of items.value.
                          value: _btnLoginModeSelectedVal,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              int mode = 0;
                              if(newValue == Global.l10n.login_mode_auto)
                              {
                                mode = 0;
                              }else if(newValue == Global.l10n.login_mode_every_time)
                              {
                                mode = 1;
                              }else if(newValue == Global.l10n.login_mode_timeout)
                              {
                                mode = 2;
                              }
                              Global.settings.loginMode = mode;
                              setState(() => _btnLoginModeSelectedVal = newValue);
                            }
                          },
                          items: dropDownLoginModeMenuItems,
                        ),
                      ),
                    ],
                  ),

                  // Tab 2: 偏好设置
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [

                    ],
                  ),


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freeman/constants.dart';


import 'package:freeman/ui/tip_verify_Input.dart';
import '../../common.dart';
import '../../global.dart';
import '../../common/common_bar.dart';
import '../../common/common_button.dart';

class ChangeNamePage extends StatefulWidget {


  const ChangeNamePage();

  @override
  _ChangeNamePageState createState() => new _ChangeNamePageState();
}

class _ChangeNamePageState extends State<ChangeNamePage> {
  TextEditingController _tc = new TextEditingController();
  FocusNode _f = new FocusNode();
  String? initContent;

  Widget body() {
    var widget = new TipVerifyInput(
      title: Global.l10n.function_nickname,
      defStr: initContent,
      controller: _tc,
      focusNode: _f,
      color: Global.settings.isDarkMode ? AppDarkColors.BackgroundColor : AppColors.BackgroundColor,
    );

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(top: 20), // 增加上边距 20 像素
        child: Column(
          children: [widget],
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    initContent = Global.user.username;

    return new Scaffold(
      appBar: new CommonBar(
        title: Global.l10n.page_title_change_nickname,
        rightDMActions: [
          new IconButton(
            icon: Icon(
              Icons.save,
              color: Colors.green,
            ),
            onPressed: () {
              Global.setUsername(_tc.text);
              Navigator.pop(context);
            },
          )
        ],
      ),
      backgroundColor: Global.settings.isDarkMode ? AppDarkColors.BackgroundColor : AppColors.BackgroundColor,
      body: new MainInputBody(color: Global.settings.isDarkMode ? AppDarkColors.BackgroundColor : AppColors.BackgroundColor, child: body()),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freeman/constants.dart';

import '../../common.dart';
import 'package:freeman/ui/tip_verify_Input.dart';

import '../../global.dart';
import '../../common/common_bar.dart';
import '../../common/common_button.dart';

class SetAliasPage extends StatefulWidget {
  final int userId;
  final String alias;


  const SetAliasPage({required this.userId, required this.alias});

  @override
  _SetAliasPageState createState() => new _SetAliasPageState();
}

class _SetAliasPageState extends State<SetAliasPage> {
  TextEditingController _tc = new TextEditingController();
  FocusNode _f = new FocusNode();
  String? initContent;

  Widget body() {
    var widget = new TipVerifyInput(
      title: Global.l10n.alias_desc,
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
    initContent = widget.alias;

    return new Scaffold(
      appBar: new CommonBar(
        title: Global.l10n.set_alias,
        rightDMActions: [
          new IconButton(
            icon: Icon(
              Icons.save,
              color: Colors.green,
            ),
            onPressed: () {
              print("[SetAliasPage] userid:${widget.userId}, alias:${_tc.text}");
              Global.dhtClient.setContactAlias(widget.userId,_tc.text);
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

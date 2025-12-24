import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freeman/constants.dart';

import '../../common.dart';
import 'package:freeman/ui/tip_verify_Input.dart';

import '../../global.dart';
import '../../common/common_bar.dart';
import '../../common/common_button.dart';

class GroupSetNamePage extends StatefulWidget {
  final int cid;
  final String name;


  const GroupSetNamePage({required this.cid, required this.name});

  @override
  _GroupSetNamePageState createState() => new _GroupSetNamePageState();
}

class _GroupSetNamePageState extends State<GroupSetNamePage> {
  TextEditingController _tc = new TextEditingController();
  FocusNode _f = new FocusNode();
  String? initContent;

  Widget body() {
    var widget = new TipVerifyInput(
      title: Global.l10n.group_chat_title,
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
    initContent = widget.name;

    return new Scaffold(
      appBar: new CommonBar(
        title: Global.l10n.group_chat_title,
        rightDMActions: [
          new IconButton(
            icon: Icon(
              Icons.save,
              color: Colors.green,
            ),
            onPressed: () {
              print("[GroupSetNamePage] cid:${widget.cid}, name:${_tc.text}");
              Global.dhtClient.setGroupName(widget.cid,_tc.text);
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

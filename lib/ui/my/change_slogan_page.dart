import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freeman/constants.dart';

import 'package:freeman/ui/tip_verify_Input.dart';
import '../../common.dart';
import '../../global.dart';
import '../../common/common_bar.dart';
import '../../common/common_button.dart';

class ChangeSloganPage extends StatefulWidget {

  const ChangeSloganPage();

  @override
  _ChangeSloganPageState createState() => new _ChangeSloganPageState();
}

class _ChangeSloganPageState extends State<ChangeSloganPage> {
  TextEditingController _tc = new TextEditingController(text: Global.user.slogan);
  FocusNode _f = new FocusNode();
  String? initContent;

  Widget body() {

    var widget = TextField(
      controller: _tc,
      focusNode: _f,
      maxLines: 10,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: '',
        alignLabelWithHint: true,
        hintText: 'type something...',
        border: const OutlineInputBorder(),
      ),
      onChanged: (text) => setState(() {}),
    );


    return Padding(
        padding: EdgeInsets.all(16.0),
    child: new SingleChildScrollView(child: new Column(children: [widget])));
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new CommonBar(
        title: Global.l10n.profile_slogan_page_title,
        rightDMActions: [
          new IconButton(
            icon: Icon(
              Icons.save,
              color: Colors.green,
            ),
            onPressed: () {
              Global.user.setSlogan(_tc.text);
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

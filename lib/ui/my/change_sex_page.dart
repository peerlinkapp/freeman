import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freeman/constants.dart';

import 'package:freeman/ui/tip_verify_Input.dart';
import '../../common.dart';
import '../../global.dart';
import '../../common/common_bar.dart';
import '../../common/common_button.dart';

class ChangeSexPage extends StatefulWidget {

  const ChangeSexPage();

  @override
  _ChangeSexPageState createState() => new _ChangeSexPageState();

}

class _ChangeSexPageState extends State<ChangeSexPage> {

  int _selectedGender = Global.user.sex;

  Widget body() {
    var widget = Column(
      children: [
        RadioListTile<int>(
          title: Text(Global.l10n.profile_sex_boy),
          value: 1,
          groupValue: _selectedGender,
          onChanged: (value) {
            setState(() {
              _selectedGender = value!;
            });
          },
        ),
        RadioListTile<int>(
          title: Text(Global.l10n.profile_sex_girl),
          value: 2,
          groupValue: _selectedGender,
          onChanged: (value) {
            setState(() {
              _selectedGender = value!;
            });
          },
        ),
        RadioListTile<int>(
          title: Text(Global.l10n.profile_sex_none),
          value: 0,
          groupValue: _selectedGender,
          onChanged: (value) {
            setState(() {
              _selectedGender = value!;
            });
          },
        ),
      ],
    );

    return new SingleChildScrollView(child: new Column(children: [widget]));
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new CommonBar(
        title: Global.l10n.profile_sex_page_title,
        rightDMActions: [
          new IconButton(
            icon: Icon(
              Icons.save,
              color: Colors.green,
            ),
            onPressed: () {
              Global.user.setSex(_selectedGender);
              Navigator.pop(context);
            },
          )
        ],
      ),
      backgroundColor: appBarColor,
      body: new MainInputBody(color: appBarColor, child: body()),
    );
  }
}

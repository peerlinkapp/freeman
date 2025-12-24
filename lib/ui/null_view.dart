
import 'package:flutter/material.dart';
import '../common.dart';


class HomeNullView extends StatelessWidget {
  late String? str;

  HomeNullView({this.str = ""});

  @override
  Widget build(BuildContext context) {

    return new Center(
      child: new InkWell(
        child: new Text(
          str ??  Global.l10n.chat_list_empty,
          style: TextStyle(color: mainTextColor),
        ),
        onTap: () => {},
      ),
    );
  }

}

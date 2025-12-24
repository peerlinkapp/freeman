
import 'package:flutter/material.dart';
import 'package:freeman/common.dart';
import 'package:freeman/ui/tip_verify_input.dart';


class GroupSetNoticePage extends StatefulWidget {
  final int cid;
  final String notice;

  GroupSetNoticePage({required this.cid, required this.notice});

  @override
  _GroupSetNoticePageState createState() => _GroupSetNoticePageState();
}

class _GroupSetNoticePageState extends State<GroupSetNoticePage> {
  TextEditingController _tc = new TextEditingController();
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
        hintText: Global.l10n.remark_desc,
        border: const OutlineInputBorder(),
      ),
      onChanged: (text) => setState(() {}),
    );


    return Padding(
        padding: EdgeInsets.all(16.0),
        child: new SingleChildScrollView(child: new Column(children: [widget])));
  }

  @override
  void initState() {
    super.initState();
    initContent = widget.notice;
    _tc.text = initContent ?? '';
  }


  @override
  Widget build(BuildContext context) {

    var rWidget = new ComMomButton(
      text: Global.l10n.btn_submit,
      style: AppStyles.TitleStyle,
      width: 50.0,
      margin: EdgeInsets.all(10.0),
      radius: 4.0,
      onTap: () {
        print("[GroupSetNoticePage]c:${widget.cid}, alias:${_tc.text}");
        Global.dhtClient.setGroupNotice(widget.cid,_tc.text);
        Navigator.pop(context);
      },
    );

    return new Scaffold(
      backgroundColor: Global.settings.isDarkMode ? AppDarkColors.BackgroundColor : AppColors.BackgroundColor,
      appBar: new ComMomBar(
        title: Global.l10n.group_chat_notice,
        rightDMActions: <Widget>[rWidget],
      ),

      body: new MainInputBody(child: body(), color: Global.settings.isDarkMode ? AppDarkColors.BackgroundColor : AppColors.BackgroundColor),
    );
  }
}

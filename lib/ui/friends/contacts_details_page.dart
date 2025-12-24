import 'package:freeman/common.dart';
import 'package:freeman/ui/friends/contact_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freeman/ui/friends/set_remark_page.dart';
import 'package:freeman/ui/chatdetail/chat_page.dart';

import 'friend_item_dialog.dart';

class ContactsDetailsPage extends StatefulWidget {

  final String hashid;

  ContactsDetailsPage({required this.hashid});

  @override
  _ContactsDetailsPageState createState() => _ContactsDetailsPageState();


}
class _ContactsDetailsPageState extends State<ContactsDetailsPage> {
  late Contact contact;


  List<Widget> body(bool isSelf) {

    print("[ContactsDetailsPage] avatar:${contact.avatar}, name:${contact.name}, inviteCode:${contact.inviteCode}");
    List<Widget> mainBody =  [
      new ContactCard(
        img: contact.avatar,
        id: contact.inviteCode,
        title: contact.alias,
        nickName: contact.name,
        area: ' ',
        isBorder: true,
        sex:contact.sex
      ),

      new Space(),
      /*new Visibility(
        visible: !isSelf,
        child: new ButtonRow(
          text: '音视频通话',
          onPressed: () => showToast('敬请期待'),
        ),
      ),*/
    ];

    mainBody.addAll(getButtons());
    return mainBody;

  }


  @override
  Widget build(BuildContext context) {
    contact = Contact.fromHashID(widget.hashid);
    //bool isSelf = globalModel.account == widget.id;
    bool isSelf = false;

    var rWidget = [
      new SizedBox(
        width: 50,
        child: new TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.all(0),  // 设置内边距
          ),
          onPressed:() =>
              friendItemDialog(
                  context,
                  userId: contact.identifier, suCc: (v) {
            if (v) Navigator.of(context).maybePop();
          }
          ),
          child: Icon(Icons.more_horiz),
        ),
      )
    ];

    return new Scaffold(
      backgroundColor: Global.settings.isDarkMode ? AppDarkColors.ChatBoxBg : AppColors.ChatBoxBg,
      appBar: new ComMomBar(
          title: '',
          backgroundColor: Global.settings.isDarkMode ? AppDarkColors.AppBarColor : AppColors.AppBarColor,
          mainColor: Global.settings.isDarkMode ? AppDarkColors.ButtonDesText : AppColors.ButtonDesText,
          rightDMActions:  [] ),
      body: new SingleChildScrollView(
        child: new Column(children: body(isSelf)),
      ),
    );
  }

  //根据联系人情况，生成不同的操作按钮
  List<Widget> getButtons() {
    print("[ContactsDetailsPage] ctype: ${contact.ctype}");
    List<Widget> btns = [];
    if(contact.ctype == ContactType.pending)
    {
      //允许加好友
      btns.add(new ButtonRow(
        margin: EdgeInsets.only(top: 10.0),
        text: Global.l10n.btn_add_friend_pass,
        isBorder: true,
        onPressed: () {
          Global.dhtClient.sendAddFriendReply(contact.identifier, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Global.l10n.after_pass_add_friend),
              duration: Duration(milliseconds: 1000),
            ),
          );
          Get.back(result: true);
        }

      ));

      //拒绝加好友
      btns.add(new ButtonRow(
        margin: EdgeInsets.only(top: 10.0),
        text: Global.l10n.btn_add_friend_deny,
        isBorder: true,
          onPressed: () {
            Global.dhtClient.sendAddFriendReply(contact.identifier, false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(Global.l10n.after_deny_add_friend),
                duration: Duration(milliseconds: 1000),
              ),
            );
            Get.back(result: false);
          }
      ));
    }else if(contact.ctype == ContactType.approved)
    {
      btns.add(new ButtonRow(
        margin: EdgeInsets.only(top: 10.0),
        text: Global.l10n.btn_send_msg,
        isBorder: true,
        onPressed: () =>
            routePushReplace(
                new ChatPage(conv_id: 0,
                    remote_id: contact.identifier)),
      ));
    }

    return btns;
  }

}

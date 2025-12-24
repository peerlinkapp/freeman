import 'package:flutter/material.dart';
import 'package:freeman/constants.dart';
import 'package:get/get.dart';

import '../../common.dart';
import '../../global.dart';
import '../../common/common_bar.dart';
import '../../model/v2_tim_group_member_info.dart';
import '../../model/v2_tim_user_full_info.dart';
import '../friends/contacts_select_page.dart';
import 'group_select_member.dart';
import 'group_set_name_page.dart';
import 'group_set_notice_page.dart';


class GroupDetailsPage extends StatefulWidget {
  final int cid;

  const GroupDetailsPage({super.key, required this.cid});

  @override
  _GroupDetailsPageState createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  late Conversation _conversation;


  List<V2TimGroupMemberInfo?> memberList = <V2TimGroupMemberInfo?>[];

  Future<void> _loadConversation() async {
    _conversation = await Global.dhtClient.getConversationProfile(widget.cid);
    setState(() {}); // 更新 UI
  }

  @override
  void initState() {
    super.initState();
    _loadConversation();
    _getGroupMembers();
  }

  @override
  void dispose() {

    super.dispose();
  }

  _getGroupMembers() async {
    memberList.clear();
    final List<V2TimGroupMemberInfo?>? memberDataList =  await Global.dhtClient.getGroupMembers(widget.cid);

    if(_conversation.isEnable && _conversation.role.index > ConversationRole.OWNER.index) {
      memberList.add(V2TimGroupMemberInfo(name: '+', userID: 0, avatar: ''));
      memberList.add(V2TimGroupMemberInfo(name: '-', userID: 0, avatar: ''));
    }

    memberList.insertAll(0, memberDataList!.toSet());
    setState(() {});
  }


  void _selectMembers() async {
    // 跳转到联系人选择页面，等待用户选择后返回
    final List<Contact>? selectedContacts = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactsSelectPage(),
      ),
    );

    // 判断是否有选择联系人返回
    if (selectedContacts != null && selectedContacts.isNotEmpty) {
      setState(() {
        List<int> ids = [];
        for (var contact in selectedContacts) {
          ids.add(contact.id);
        }
        Global.dhtClient.groupAddMembers(widget.cid, ids);
        _getGroupMembers();
      });
    }
  }

  void _selectDropMembers() async {
    // 跳转到联系人选择页面，等待用户选择后返回
    final List<Contact>? selectedContacts = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectGroupMemberPage(groupId: widget.cid),
      ),
    );

    // 判断是否有选择联系人返回
    if (selectedContacts != null && selectedContacts.isNotEmpty) {
      setState(() {
        List<int> ids = [];
        for (var contact in selectedContacts) {
          ids.add(contact.id);
        }
        Global.dhtClient.groupDropMembers(widget.cid, ids);
        _getGroupMembers();
      });
    }
  }

  Widget memberItem(V2TimGroupMemberInfo? gm) {

    if (gm!.name == '+'  ) {
      return InkWell(
        child: SizedBox(
          width: (Get.width - 60) / 5,
          child: Image.asset(
            'assets/images/group/${gm.name}.png',
            height: 48.0,
            width: 48.0,
          ),
        ),
        onTap: () async
        {
          _selectMembers();
        },
      );
    }else if (  gm.name == '-') {
      return InkWell(
        child: SizedBox(
          width: (Get.width - 60) / 5,
          child: Image.asset(
            'assets/images/group/${gm.name}.png',
            height: 48.0,
            width: 48.0,
          ),
        ),
        onTap: () async
        {
          _selectDropMembers();
        },
      );
    }

    return FutureBuilder<V2TimUserFullInfo>(
      future: Global.dhtClient.getContactProfile(gm.userID),
      builder:
          (BuildContext context, AsyncSnapshot<V2TimUserFullInfo> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
              // 数据加载中，显示加载指示器
            } else if (snapshot.hasError) {
              // 数据加载出错，显示错误信息
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              // 数据为空，显示空视图
              return Container();
            } else {
              // 数据加载成功，构建列表
              final V2TimUserFullInfo user = snapshot.data ?? V2TimUserFullInfo();
              print("user name:${user.nickName}, avatar:${user.faceUrl}");
              /*if (user.userID == 0) {
              return Container();
            }*/
              return SizedBox(
                width: (Get.width - 60) / 5,
                child: TextButton(
                  /* onPressed: () => Get.to<void>(() =>
                ContactsSelectPage(Data.user() == item.userID, item.userID!)),*/
                  onPressed: (){
                    print("[GroupDetailsPage] click:${gm.name}");

                  },
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: Column(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                        child: !user.faceUrl.startsWith("assets/") ?
                        Image.file(File(user.faceUrl), width: 48, height: 48, fit: BoxFit.cover)
                            : Image.asset(user.faceUrl, height: 48.0, width: 48.0, fit: BoxFit.cover,
                        ),

                      ),
                      const SizedBox(height: 2),
                      Container(
                        alignment: Alignment.center,
                        height: 20.0,
                        width: 50,
                        child: Text(
                          '${!strNoEmpty(gm.name) ? user.nickName : gm.name!.length > 4 ? '${gm.name!.substring(0, 3)}...' : gm.name!}',
                          style: const TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }


      },
    );
  }

  Widget buildQuitGroupBtn()
  {
    if(!_conversation.isEnable)
    {
      return Center(
        child:Container( child: Text(
          Global.l10n.group_quit_tip,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            color: Global.settings.isDarkMode ? AppDarkColors.MainTextColor : AppColors.MainTextColor,
          ),
        ),)
      );
    }

    return Center(
      child: Container(
        width: 200,
        height: 48,
        margin: const EdgeInsets.only(top: 20),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Global.settings.isDarkMode ? AppDarkColors.BackgroundColor : AppColors.BackgroundColor,
            foregroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: const BorderSide(color: Colors.red),
            ),
          ),
          onPressed: () {
            confirmAlert(context, (bool isOK) {
              if (isOK) {
                Global.dhtClient.delConversation(widget.cid);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                }
                //showToast('解散群聊成功');
              }
            }, tips: Global.l10n.group_quit_confirm);
          },
          child: Text(
            Global.l10n.group_quit,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );

  }


  Widget buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Global.settings.isDarkMode ? AppDarkColors.BackgroundColor : AppColors.BackgroundColor,
            padding: const EdgeInsets.only(top: 10.0, bottom: 10),
            width: Get.width,
            child: Wrap(
              runSpacing: 20.0,
              spacing: 10,
              children: memberList.map(memberItem).toList(),
            ),
          ),

          const SizedBox(height: 10.0),
          functionBtn(
            Global.l10n.group_chat_title,
            detail: _conversation.showName,
          ),
          
          const SizedBox(height: 30.0),
          functionBtn(
            Global.l10n.uuid,
            detail: _conversation.uuid,
          ),

          const SizedBox(height: 30.0),
          functionBtn(
            Global.l10n.group_chat_notice,
            detail: _conversation.announcement,
          ),

          Space(),
          buildQuitGroupBtn(),


        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final bgColor = Global.settings.isDarkMode ? AppDarkColors.BackgroundColor : AppColors.BackgroundColor;

    return Scaffold(
      appBar: CommonBar(
        title: Global.l10n.group_chat_details,
      ),
      backgroundColor: bgColor,
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: buildBody(),
      ),
    );
  }

  Widget functionBtn(
      String title, {
        String? detail,
        Widget? right,
      }) {
    return GroupItem(
      detail: detail,
      title: title,
      right: right,
      conversation: _conversation,
      onPressed: () => handle(title),
    );
  }

  handle(String title) {
    if(!_conversation.isEnable) return;
    if(title == Global.l10n.group_chat_title)
    {
      Get.to(() => GroupSetNamePage(cid: widget.cid, name: _conversation.showName))?.then((result) {
        _loadConversation();
      });

    }else if(title == Global.l10n.group_chat_notice) {
      Get.to(() => GroupSetNoticePage(cid: widget.cid, notice: _conversation.announcement))?.then((result) {
        _loadConversation();
      });
    }
  }

}


class GroupItem extends StatelessWidget {
  final String? detail;
  final String title;
  final VoidCallback onPressed;
  final Widget? right;
  final Conversation conversation;

  const GroupItem({
    Key? key,
    this.detail,
    required this.title,
    required this.onPressed,
    required this.conversation,
    this.right,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (detail == null) {
      return Container();
    }
    double? widthT() {
      if (detail != null) {
        return detail!.length > 35
            ? SizeConfig.blockSizeHorizontal! * 60
            : null;
      } else {
        return null;
      }
    }

    bool isSwitch = title == '消息免打扰' ||
        title == '聊天置顶' ||
        title == '保存到通讯录' ||
        title == '显示群成员昵称';
    final bool noBorder = title == '备注' ||
        title == '查找聊天记录' ||
        title == '保存到通讯录' ||
        title == '显示群成员昵称' ||
        title == '投诉' ||
        title == '清空聊天记录';


    //如果已退群
    if(!conversation.isEnable || conversation.role.index <= ConversationRole.OWNER.index)
    {
      isSwitch = true;
    }
    print("[GroupDetailsPage] isEnable =${conversation.isEnable}, role.index=${conversation.role.index}, isSwitch=${isSwitch}");

    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.only(left: 15, right: 15.0),
        backgroundColor: Global.settings.isDarkMode ? AppDarkColors.BackgroundColor : AppColors.BackgroundColor,
      ),
      onPressed: onPressed,
      child: Container(
        padding: EdgeInsets.only(
          top: isSwitch ? 10 : 15.0,
          bottom: isSwitch ? 10 : 15.0,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(title),
                ),
                Visibility(
                  visible: title != Global.l10n.group_chat_notice,
                  child: SizedBox(
                    width: widthT(),
                    child: Text(
                      detail ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                right ?? Container(),
                const SizedBox(width: 10.0),
                isSwitch
                    ? Container()
                    : new Icon(CupertinoIcons.right_chevron,
                    color: mainTextColor.withOpacity(0.5)),
              ],
            ),
            Visibility(
              visible: title == Global.l10n.group_chat_notice,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  detail ?? '',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

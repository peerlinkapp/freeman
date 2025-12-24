import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../common.dart';
import '../../global.dart';
import '../../common/ui/label_row.dart';
import '../../common/ui/search_main_view.dart';
import '../../common/ui/search_tile_view.dart';
import 'add_friend_page.dart';
import 'contacts_details_page.dart';
import 'new_friend_item_view.dart';

//待我审核通过或拒绝的加好友申请列表

class NewFriendPage extends StatefulWidget {
  const NewFriendPage({super.key});

  @override
  _NewFriendPageState createState() => _NewFriendPageState();
}

class _NewFriendPageState extends State<NewFriendPage> {
  bool isSearch = false;
  bool showBtn = false;
  bool isResult = false;

  FocusNode searchF = FocusNode();
  TextEditingController searchC = TextEditingController();


  Widget buildItem(Map<String, String> item) {

    return NewFriendItemView(
      imageUrl: item['icon']!,
      title:   item['title']!,
      content: item['label'] ?? "",
      hashid: item['hashid']!,
      time: timeView( Utils.StringToInt(item['time'])),
      isBorder: true,
        onPressed: () async {
      //进入联系人详情页，以允许或拒绝好友请求
       // 跳转到页面 B，并等待返回数据
      var result = await Get.to(ContactsDetailsPage(hashid: item['hashid']!));
      // 如果返回的数据不为空，刷新页面
      if (result != null) {
        setState(() {
            print("[ContactsDetailsPage] return result:${result}");
        });
      }
    }

    );
  }


  List<Widget> searchBody() {
    if (isResult) {
      return <Widget>[
        Container(
          color: Colors.white,
          width: Get.width,
          height: 110.0,
          alignment: Alignment.center,
          child: const Text(
            '该用户不存在',
            style: TextStyle(color: mainTextColor),
          ),
        ),
        const SizedBox(height: mainSpace),
        SearchTileView(searchC.text, type: 1),
        Container(
          color: Colors.white,
          width: Get.width,
          height: Get.height - 185 * 1.38,
        )
      ];
    } else {
      return <Widget>[
        SearchTileView(
          searchC.text,
          onPressed: () => search(searchC.text),
        ),
        Container(
          color: strNoEmpty(searchC.text) ? Colors.white : appBarColor,
          width: Get.width,
          height: strNoEmpty(searchC.text)
              ? (Get.height - 65 * 2.1) - winKeyHeight(context)
              : Get.height,
        )
      ];
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void unFocusMethod() {
    searchF.unfocus();
    isSearch = false;
    if (isResult) isResult = !isResult;
    setState(() {});
  }

  /// 搜索好友
  Future search(String userName) async {

      isResult = true;
      setState(() {});

  }

  Future<List<Contact>> getContacts() async {
    final listContact = await ContactsPageData().listFriend(ContactType.pending);
    return listContact;
  }

  Widget getBuildBody(BuildContext context, List<Contact> contacts) {
    List<Map<String, String>> data = [];

    for (var contact in contacts) {
        Map<String, String> item = new Map<String, String>();
        item['icon'] = contact.avatar;
        item['title'] = contact.name;
        item['label'] = contact.inviteCode;
        item['hashid'] = contact.identifier;
        item['time'] = contact.updateTime.toString();
        data.add(item);
    }

    List<Widget> content = <Widget>[

      new Column(children: data.map(buildItem).toList()),
    ];

    return Column(children: content);

  }

  Widget getFutureBuilder()
  {
    return FutureBuilder<dynamic>(
      future: getContacts(), // 假设 fetchChatData() 是一个返回 Future<List<V2TimConversation>> 的异步方法
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 数据加载中，显示加载指示器
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // 数据加载出错，显示错误信息
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // 数据为空，显示空视图
          return Center();
        } else {
          // 数据加载成功，构建列表
          return getBuildBody(context, snapshot.data);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final InkWell leading = InkWell(
      child: Container(
        width: 15,
        height: 28,
        child: const Icon(CupertinoIcons.back, color: Colors.black),
      ),
      onTap: () => unFocusMethod(),
    );

    // ignore: unused_element
    List<Widget> searchView() {
      return <Widget>[
        Expanded(
          child: TextField(
            style: const TextStyle(textBaseline: TextBaseline.alphabetic),
            focusNode: searchF,
            controller: searchC,
            decoration:  InputDecoration(
                hintText: Global.l10n.search_friend_tip, border: InputBorder.none),
            onChanged: (String txt) {
              if (strNoEmpty(searchC.text)) {
                showBtn = true;
              } else {
                showBtn = false;
              }
              if (isResult) isResult = false;

              setState(() {});
            },
            textInputAction: TextInputAction.search,
            onSubmitted: (String txt) => search(txt),
          ),
        ),
        if (strNoEmpty(searchC.text))
          InkWell(
            child: Image.asset('assets/images/ic_delete.webp'),
            onTap: () {
              searchC.text = '';
              setState(() {});
            },
          )
        else
          Container()
      ];
    }

    final SingleChildScrollView bodyView = SingleChildScrollView(
      child: isSearch
          ? GestureDetector(
              child: Column(children: searchBody()),
              onTap: () => unFocusMethod(),
            )
          : getFutureBuilder(),
    );

    final TextButton rWidget = TextButton(
      onPressed: () => Get.to<void>(AddFriendPage()),
      child: const Text('添加朋友'),
    );

    return WillPopScope(
      child: new Scaffold(
        backgroundColor: Global.settings.isDarkMode ? AppDarkColors.BackgroundColor : AppColors.BackgroundColor,
        appBar: ComMomBar(
          leadingW: isSearch ? leading : null,
          title: Global.l10n.new_friends_title,
          titleW: isSearch ? Row(children: searchView()) : null,
          rightDMActions: <Widget>[],
        ),
        body: bodyView,
      ),
      onWillPop: () async {
        if (isSearch) {
          unFocusMethod();
        } else {
          Navigator.pop(context);
        }
        return true;
      },
    );
  }


  Container buildContainer()
  {
    return Container(
      color:  Global.settings.isDarkMode ? AppDarkColors.BackgroundColor : AppColors.BackgroundColor,
      child: ScrollConfiguration(
        behavior: MyBehavior(),
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {


            return InkWell(
              onTap: () {

              },
              onTapDown: (TapDownDetails details) {

              },
              onLongPress: () {

              },
              child: NewFriendItemView(
                imageUrl: "",
                title:   'title',
                content: "content",
                hashid: "",
                time: timeView( 11110),
                isBorder: true,
              ),
            );
          },
          itemCount: 1,
        ),
      ),
    );
  }


  Widget timeView(int time) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time * 1000);

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String timeStr = DateTimeUtils.getHumanReadableDate(time);
    List<String> pads = timeStr.split(" ");

    //如果是今天，则取时分
    if (targetDate.isAtSameMomentAs(today)) {
      timeStr = pads[1];
    }else{//如果不是今天，则取日期
      timeStr = pads[0];
    }

    return Text(
      timeStr,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: mainTextColor, fontSize: 14.0),
    );
  }
}

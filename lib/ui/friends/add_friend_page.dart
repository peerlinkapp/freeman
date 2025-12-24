import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:freeman/common.dart';
import 'package:freeman/common/ui/search_main_view.dart';
import 'package:freeman/common/ui/search_tile_view.dart';
import 'package:freeman/ui/friends/contacts_page.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:freeman/ui/friends/qr_scanner.dart';

class AddFriendPage extends StatefulWidget {
  @override
  _AddFriendPageState createState() => new _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  bool isSearch = false;
  bool showBtn = false;
  bool isResult = false;

  String? currentUser;
  List<String> _searchUserResult = [];

  FocusNode searchF = new FocusNode();
  TextEditingController searchC = new TextEditingController(text: "f1");

  Widget buildItem(Map<String, String> item) {
    return new ListTileView(
      border: item['title'] == '雷达加朋友'
          ? null
          : Border(top: BorderSide(color: lineColor, width: 0.2)),
      title: item['title']!,
      label: item['label'],
      icon: strNoEmpty(item['icon'])
          ? item['icon']!
          : 'assets/images/favorite.webp',
      fit: BoxFit.cover,
      onPressed: ()  {
        if(item['title'] == Global.l10n.btn_scan)
          {
            Get.to<void>(new QRScannerScreen());
          }

      },
    );
  }

  Widget body() {
    //final model = Provider.of<Global>(context);
    String myid = Global.dhtClient.getInviteCode();
    List<Map<String, String>> data = [
      {
        'icon': contactAssets + 'ic_scanqr.webp',
        'title': Global.l10n.btn_scan,
        'label': Global.l10n.btn_scan_desc,
      },
     /* {
        'icon': contactAssets + 'ic_reda.webp',
        'title': '雷达加朋友',
        'label': '添加身边的朋友',
      },
      {
        'icon': contactAssets + 'ic_group.webp',
        'title': '面对面建群',
        'label': '与身边的朋友进入同一个群聊'
      },
      {
        'icon': contactAssets + 'ic_new_friend.webp',
        'title': '手机联系人',
        'label': '添加或邀请通讯录中的朋友',
      }*/
    ];
    var content = [
      new SearchMainView(
        text: Global.l10n.search_friend_tip,
        onTap: () {
          isSearch = true;
          setState(() {});
          searchF.requestFocus();
        },
      ),

      new Column(children: data.map(buildItem).toList()),
      new Padding(
        padding: EdgeInsets.only(top: 15.0, bottom: 30.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            new SizedBox(height: mainSpace * 1.5),
            new InkWell(
              child:
                new Container(
                  color: Global.settings.isDarkMode ? AppDarkColors.CardBgColor :  AppColors.BackgroundColor, // 设置二维码背景色
                  padding:EdgeInsets.all(8.0), // 设置内边距，给二维码周围留一些空间
                  child:
                    QrImageView(
                      data: Global.dhtClient.getInviteCode(), // 二维码内容
                      version: QrVersions.auto, // 版本自动选择
                      size: 220.0, // 二维码大小
                      gapless: false, // 是否去除空白边缘
                      embeddedImage: AssetImage('assets/images/app_icon.png'), // 你的 Logo 图片
                      embeddedImageStyle: QrEmbeddedImageStyle(
                        size: Size(30, 30), // Logo 大小
                      ),
                    ),
                ),

                onTap: ()  {

                },
          ),
            new Text(
              '${Global.l10n.invite_code}：${myid}',
              style: TextStyle(color: mainTextColor, fontSize: 14.0),
              textAlign: TextAlign.center,

            )
          ],
        ),
      ),
    ];

    return new Column(children: content);
  }

  Widget getStreamListView()
  {
    return StreamBuilder<List<String>>(
      stream: Global.dhtClient.findStream,
      initialData: [],
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("暂无数据"));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              String line = snapshot.data![index];
              //print("line:${line}");
              List<String> item = line.replaceAll("[", "").replaceAll("]", "").split(", ");
              print("[add_friend_page] snapshot:${item.toString()}");

              String hashid = item[0];
              String inviteCode = item[1];
              String name = item[2];
              String avatar = item[3];
              int addme_mode = Utils.StringToInt(item[6]);

              late Widget imgW;
              if(avatar.isEmpty)
              {
                imgW = Icon(Icons.person);
              }else if(avatar.startsWith("assets/"))
              {
                imgW = new Image.asset( avatar,
                  fit: BoxFit.fill,
                );
              }else{
                imgW =Image.file(File(avatar),
                  fit: BoxFit.fill,
                );
              }

              return ListTile(
                  leading: imgW,
                  title: Text(name),
                  subtitle: Text("["+inviteCode+"]"),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    //添加好友
                    /*
                      NEED_MY_CHECK = 0, //需要审核
                      AUTO_ALLOW = 1, //自动通过, 并加对方进通讯录
                      AUTO_ALLOW_NOT_IN_CONTACTS = 2, //自动通过, 但不加对方进通讯录，（对方发消息后可显示在消息列表中）
                      DENY_ALL = 3, //拒绝一切加好友请求
                      ALLOW_BY_ANSWER = 4 //通过问答加好友
                   */
                    if(addme_mode == 0 || addme_mode == 1)
                    {
                      Global.dhtClient.sendAddFriendMsg(inviteCode);
                    }else if(addme_mode == 4)
                    {
                      //弹出问题框，获取输入的答案后，发送给对端
                      Global.dhtClient.sendAddFriendMsg(inviteCode);
                    }
                    //添加到通讯录中
                    if(addme_mode == 1 || addme_mode == 2) {
                      Global.dhtClient.addContact(hashid, name);
                    }

                    showToast(Global.l10n.after_apply_add_friend);

                    Navigator.pop(context); // 返回上一页
                  }
              );
            },
          );
        }
      },
    );
  }

  List<Widget> searchBody() {
    if (isResult) {


      return [
        new Container(
          color: Global.settings.isDarkMode ? AppDarkColors.SecondColor :  AppColors.SecondColor,
          width: Get.width,
          height: Get.height/2,
          alignment: Alignment.center,
          child: getStreamListView()
          ,
        ),
        new SizedBox(height: mainSpace),
        new SearchTileView(searchC.text, type: 1),
        new Container(
          color: Global.settings.isDarkMode ? AppDarkColors.SecondColor :  AppColors.SecondColor,
          width: Get.width,
          height: (Get.height - 185 * 1.38),
        )
      ];
    } else {
      return [
        new SearchTileView(
          searchC.text,
          onPressed: () => search(searchC.text),
        ),
        new Container(
          color: strNoEmpty(searchC.text) ? Global.settings.isDarkMode ? AppDarkColors.SecondColor :  AppColors.SecondColor : appBarColor,
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
    getUser();
  }

  getUser() async {
    // if (Platform.isAndroid) {
    //   currentUser = await im.getCurrentLoginUser();
    // } else {
    //   currentUser = null;
    // }
    setState(() {});
  }

  unFocusMethod() {
    searchF.unfocus();
    isSearch = false;
    if (isResult) isResult = !isResult;
    setState(() {});
  }

  // 搜索好友
  Future search(String userName) async {

    print("search:${userName}");
    Global.dhtClient.find_user(userName);

    setState(() {
      /*if (Platform.isIOS) {
        V2TimUserFullInfo model = data[0];
        if (model.allowType != null) {
          Get.to<void>(new AddFriendsDetails('search', model.userID!,
              model.faceUrl!, model.nickName!, model.gender!));
        } else {
          isResult = true;
        }
      }*/
      isResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var leading = new InkWell(
      child: new Container(
        width: 15,
        height: 28,
        child: new Icon(CupertinoIcons.back, color: Colors.black),
      ),
      onTap: () => unFocusMethod(),
    );

    // ignore: unused_element
    List<Widget> searchView() {
      return [
        new Expanded(
          child: new TextField(
            focusNode: searchF,
            controller: searchC,
            style: TextStyle(textBaseline: TextBaseline.alphabetic),
            decoration:
                InputDecoration(hintText: Global.l10n.search_friend_tip, border: InputBorder.none),
            onChanged: (txt) {
              if (strNoEmpty(searchC.text))
                showBtn = true;
              else
                showBtn = false;
              if (isResult) isResult = false;

              setState(() {});
            },
            textInputAction: TextInputAction.search,
            onSubmitted: (txt) => search(txt),
          ),
        ),
        strNoEmpty(searchC.text)
            ? new InkWell(
                child: new Image.asset('assets/images/ic_delete.webp', width: defButtonIconWidth, height: defButtonIconHeight,),
                onTap: () {
                  searchC.text = '';
                  setState(() {});
                },
              )
            : new Container()
      ];
    }

    var bodyView = new SingleChildScrollView(
      child: isSearch
          ? new GestureDetector(
              child: new Column(children: searchBody()),
              onTap: () => unFocusMethod(),
            )
          : body(),
    );

    return WillPopScope(
      child: new Scaffold(
        backgroundColor: Global.settings.isDarkMode ? AppDarkColors.BackgroundColor :  AppColors.BackgroundColor,
        appBar: new ComMomBar(
          leadingW: isSearch ? leading : null,
          title: Global.l10n.add_friend,
          titleW: isSearch ? new Row(children: searchView()) : null,
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
}

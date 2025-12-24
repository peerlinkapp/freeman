import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:freeman/common.dart';
import 'package:freeman/common/ui/search_main_view.dart';
import 'package:freeman/common/ui/search_tile_view.dart';
import 'package:freeman/ui/friends/contacts_page.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:freeman/ui/friends/qr_scanner.dart';

class MyInviteCodePage extends StatefulWidget {
  @override
  _MyInviteCodeState createState() => new _MyInviteCodeState();
}

class _MyInviteCodeState extends State<MyInviteCodePage> {
  bool isSearch = false;
  bool showBtn = false;
  bool isResult = false;

  String? currentUser;


  Widget body() {
    //final model = Provider.of<Global>(context);
    String myid = Global.dhtClient.getInviteCode();
    List<Map<String, String>> data = [
      {
        'icon': contactAssets + 'ic_scanqr.webp',
        'title': Global.l10n.btn_scan,
        'label': Global.l10n.btn_scan_desc,
      },

    ];
    var content = [

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
            new SizedBox(height: mainSpace * 1.5),
            new Text(
              '${Global.l10n.invite_code}：${myid}',
              style: TextStyle(color: mainTextColor, fontSize: 14.0),
              textAlign: TextAlign.center,
            ),
            new SizedBox(height: mainSpace * 1.5),
            TextButton(
              onPressed: () {
                Global.dhtClient.regenInviteCode();
                setState(() {

                });
              },
              style: TextButton.styleFrom(
                foregroundColor: Global.settings.isDarkMode ? AppDarkColors.HighLightColor : AppColors.HighLightColor,           // 字体颜色
                backgroundColor: Global.settings.isDarkMode ? AppDarkColors.ActionIconColor : AppColors.ActionIconColor,  // 背景色
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle: TextStyle(fontSize: 16),
              ),
              child: Text(Global.l10n.re_gen+Global.l10n.invite_code),
            )

          ],
        ),
      ),
    ];

    return new Column(children: content);
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

    isSearch = false;
    if (isResult) isResult = !isResult;
    setState(() {});
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


    var bodyView = new SingleChildScrollView(
      child: body(),
    );

    return WillPopScope(
      child: new Scaffold(
        backgroundColor: Global.settings.isDarkMode ? AppDarkColors.BackgroundColor :  AppColors.BackgroundColor,
        appBar: new ComMomBar(
          leadingW: isSearch ? leading : null,
          title: Global.l10n.invite_code,
          titleW: null,
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

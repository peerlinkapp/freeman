import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freeman/common.dart';
import 'package:freeman/common/ui.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../posts/markdown_editor.dart';
import 'avatar_picker.dart';
import 'change_name_page.dart';
import 'change_sex_page.dart';
import 'change_slogan_page.dart';
import 'my_avatar.dart';
import 'new_message_audio.dart';
import 'package:flutter/services.dart';

import 'dart:convert';
import 'package:parchment/parchment.dart';
import 'my_invite_code.dart';



class MyProfilePage extends ConsumerStatefulWidget {
  const MyProfilePage({super.key});

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends ConsumerState<MyProfilePage>  with SingleTickerProviderStateMixin{

  late TabController _tabController;
  late final ScrollController _scrollController;
  List<Map<String, dynamic>> _posts = [];
  int _offset = 0;
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasMore = true;


  final List<Tab> tabs = [
    Tab(text: Global.l10n.my_tab_1),
    Tab(text: Global.l10n.my_tab_2),
    Tab(text: Global.l10n.my_tab_3),
  ];

  Future<void> _loadMorePosts() async {

    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    try {
      var myid = Global.dhtClient.get_userid();
      print("[MyProfilePage] _loadMorePosts myid=$myid");
      await Global.dhtClient.getPosts(PostType.POST_MINE.index, Global.dhtClient.get_userid(), _offset, _limit);
    } catch (e) {
      print('加载更多失败: $e');
    } finally {
      _isLoading = false;
    }
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return; // 正在动画切换时跳过
    if (_tabController.index == 2) {
      // 当前是第二个 tab，执行数据加载
      _offset = 0;
      _hasMore = true;
      _posts.clear();
      _loadMorePosts();
    }
  }


  void _onAvatarTap() {
     Navigator.push(context, MaterialPageRoute(builder: (_) => AvatarPicker()));
  }



  @override
  void initState() {
    super.initState();
    _posts.clear();
    //避免apk启动后执行此段导致发现中动态内容被替换（stream返回的post)
    /*WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        _loadMorePosts();
      },
    );*/

    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);


    _scrollController = ScrollController();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMorePosts(); // 快到底部了
      }
    });

  }

  @override
  Widget build(BuildContext context) {

    String strSex = Global.l10n.profile_sex_none;
    int sex = Global.settings.currUserSex;
    if(sex == 1)
    {
      strSex = Global.l10n.profile_sex_boy;
    }else if(sex == 2)
    {
      strSex = Global.l10n.profile_sex_girl;
    }

    int audioIdx =  Global.getNewMessageAudioIdx();
    String newMsgAudio = Global.getNewMessageAudio(audioIdx);

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        body: Column(
          children: [
            // 用户信息区
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                width: double.infinity,
                child: Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(58),
                      onTap: _onAvatarTap,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 58,
                            backgroundColor: Colors.blueAccent,
                            child: MyLogo.getCircleAvatar(),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.photo_camera, size: 16, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              children:[
                                Text(Global.user.username,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4)

                              ]
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  Global.user.slogan,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Spacer(),
                              _buildCircleButton(Icons.content_copy, Global.l10n.my_cp_invite),
                              SizedBox(width: 8),
                              _buildCircleButton(Icons.post_add, Global.l10n.popmenu_add_post),

                            ],
                          ),


                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // TabBar
            Container(
              color:  Global.settings.isDarkMode ? AppDarkColors.AppBarColor :  AppColors.AppBarColor, // TabBar 的背景色
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                  Container(
                    color: Global.settings.isDarkMode ? AppDarkColors.AppBarColor :  AppColors.AppBarColor, // TabBar 的背景色
                    child: TabBar(
                      isScrollable: true, // 必须设置为 true，标签才会靠左，不会均分占满宽度
                      controller: _tabController, // 使用你自定义的 controller
                      tabs: tabs,
                      indicatorColor: AppColors.TabIconNormal,
                      labelColor: AppColors.TabIconNormal,
                      unselectedLabelColor: AppColors.TabIconNormal,
                    ),
                  ),
           ])),

            // TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: 基本信息
                  ListView(
                    padding: const EdgeInsets.all(5),
                    children: [
                      LabelRow(
                        label: Global.l10n.nick_name_txt,
                        isLine: false,
                        isRight: true,
                        rValue: Global.user.username,
                        rightW: Container(),
                        onPressed: () => Get.to<void>(ChangeNamePage()),
                        value: '',
                      ),
                      LabelRow(
                        label: Global.l10n.profile_sex,
                        isLine: false,
                        isRight: true,
                        rValue: strSex,
                        rightW: Container(),
                        onPressed: () => Get.to<void>(ChangeSexPage()),
                        value: '',
                      ),
                      LabelRow(
                        label: Global.l10n.profile_slogan,
                        isLine: false,
                        isRight: true,
                        rValue: '',
                        rightW: Container(),
                        onPressed: () => Get.to<void>(ChangeSloganPage()),
                        value: '',
                      ),
                      LabelRow(
                        label: Global.l10n.qr_img,
                        isLine: false,
                        isRight: true,
                        rValue: '',
                        rightW: createQRCode(),
                        onPressed: ()   {
                          Get.to<void>(MyInviteCodePage());
                        },
                        value: '',
                      ),
                    ],
                  ),

                  // Tab 2: 偏好设置
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [

                      SwitchListTile(
                        title: Text(Global.l10n.add_me_need_check),
                        value: Global.settings.needCheckWhenApplyFriend,
                        onChanged: (value) {Global.settings.setCheckWhenApplyFriend(value);},
                      ),

                      CheckboxListTile(
                        title: Text(Global.l10n.send_msg_readed_report),
                        value: Global.settings.needCheckWhenApplyFriend,
                        onChanged: (value) {Global.settings.setCheckWhenApplyFriend(value ?? false);},
                      ),

                      LabelRow(
                        label: Global.l10n.msg_notify_audio,
                        isLine: false,
                        isRight: true,
                        rValue: newMsgAudio,
                        rightW: Container(),
                        onPressed: () => Get.to<void>(MessageIncomeAudioPage()),
                        value: '',
                      ),
                    ],
                  ),

                  buildTab1Content()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildCircleButton(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: ClipOval(
        child: Material(
          color: Colors.grey.shade300,
          child: InkWell(
            onTap: () {
              if(tooltip == Global.l10n.my_cp_invite)
              {
                String invite = Global.dhtClient.getInviteCode();
                Clipboard.setData(ClipboardData(text: invite));
                showToast(Global.l10n.invite_code+" "+invite+" "+Global.l10n.copied_to_clipboard );
              }else if(tooltip == Global.l10n.popmenu_add_post){
                Get.to<void>(MarkdownEditorPage());
              }
            },
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(icon, size: 20),
            ),
          ),
        ),
      ),
    );
  }


  Widget createQRCode()
  {
    return new SizedBox(
      width: 55.0,
      height: 55.0,
      child: new ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        child: Hero(
            tag: 'imageQr',  // 设置唯一标识
            child:QrImageView(
              data: Global.dhtClient.getInviteCode(), // 二维码内容
              version: QrVersions.auto, // 版本自动选择
              size: 55.0, // 二维码大小
              gapless: false, // 是否去除空白边缘
              embeddedImage: AssetImage('assets/images/app_icon.png'), // 你的 Logo 图片
              embeddedImageStyle: QrEmbeddedImageStyle(
                size: Size(10, 10), // Logo 大小
              ),
            )),
      ),
    );
  }

  Widget createQRCodeBig()
  {
    double w = Get.width/2.5;
    print("ww:2:$w");
    return new SizedBox(
      width: w,
      height: w,
      child: new ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        child: QrImageView(
          data: Global.dhtClient.getInviteCode(), // 二维码内容
          version: QrVersions.auto, // 版本自动选择
          size: w - 20.0, // 二维码大小
          gapless: true, // 是否去除空白边缘
          embeddedImage: AssetImage('assets/images/app_icon.png'), // 你的 Logo 图片
          embeddedImageStyle: QrEmbeddedImageStyle(
            color: Global.settings.isDarkMode ? AppDarkColors.QrEmbeddedImgColor :  AppColors.QrEmbeddedImgColor,
            size: Size(30, 30), // Logo 大小
          ),
        ),
      ),
    );
  }


  List<Widget> buildWidgetsFromDocument(ParchmentDocument document) {
    List<Widget> widgets = [];

    for (var op in document.toDelta().toList()) {
      if (op.isInsert) {
        final attrs = op.attributes ?? {};
        TextStyle style = const TextStyle(fontSize: 14);

        if (attrs['bold'] == true) {
          style = style.copyWith(fontWeight: FontWeight.bold);
        }
        if (attrs['italic'] == true) {
          style = style.copyWith(fontStyle: FontStyle.italic);
        }
        if (attrs['underline'] == true) {
          style = style.copyWith(decoration: TextDecoration.underline);
        }
        if (attrs['color'] != null) {
          try {
            style = style.copyWith(color: Color(int.parse(attrs['color'])));
          } catch (_) {}
        }

        if (op.data is String) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(op.data as String, style: style),
            ),
          );
        } else if (op.data is Map<String, dynamic>) {
          final Map<String, dynamic> dataMap = op.data as Map<String, dynamic>;
          if (dataMap.containsKey('_type')) {
            final src = dataMap['source'];
            print("LFF file:$src");
            final isNetwork = src.startsWith('http');
            widgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: isNetwork ? Image.network(
                    dataMap['source'],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Text('[图片加载失败]'),
                  ): Image.file(File(src), fit: BoxFit.cover, key: ValueKey(DateTime.now())),
                ),
              ),
            );
          } else {
            widgets.add(const Text('[暂不支持的内容类型]'));
          }
        }
      }
    }

    return widgets;
  }

  Widget getPostCards(List<Map<String, dynamic>> postData)
  {
    return ListView.builder(
      controller: _scrollController,
      itemCount: postData.length,
      itemBuilder: (context, index) {
        final post = postData[index];
        final deltaJson = post['content'];
        final poster = post['userName']+" "+ post['id'].toString();
        String created_at = DateTimeUtils.getHumanReadableDate(post['created_at']);
        final delta = Delta.fromJson(jsonDecode(deltaJson));
        final document = ParchmentDocument.fromDelta(delta);
        final contentWidgets = buildWidgetsFromDocument(document);
        return Card(
          margin: const EdgeInsets.all(12),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(created_at, style: TextStyle(color: Colors.grey, fontSize: 12)),
                    SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        // 点赞处理
                      },
                      child: Row(
                        children: [
                          Icon(Icons.favorite_border, size: 20, color: Colors.grey),
                          SizedBox(width: 4),
                          Text('20', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        // 点赞处理
                      },
                      child: Row(
                        children: [
                          Icon(Icons.comment, size: 20, color: Colors.grey),
                          SizedBox(width: 4),
                          Text('10', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...contentWidgets,
                const SizedBox(height: 8),

              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildTab1Content()
  {
    return new ScrollConfiguration(
      behavior: MyBehavior(),
      child:
      StreamBuilder<String>(
        stream: Global.dhtClient.postStream,  //实时更新刷新消息
        initialData:  '',
        builder: (context, snapshot) {
          print('[MyProfilePage buildTab1Content] getPosts StreamBuilder: snapshot = ${snapshot.data},state=${snapshot.connectionState}, hasData = ${snapshot.hasData}');
          if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
            return ListView(
              padding: EdgeInsets.all(16),
              children: [
                Text(Global.l10n.post_empty, style: TextStyle(fontSize: 16)),
              ],
            );
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            final List<Map<String, dynamic>> newPosts = List<Map<String, dynamic>>.from(jsonDecode(snapshot.data!));

            print("[MyProfilePage buildTab1Content] newPosts size:${newPosts.length}, _posts size:${_posts.length}");

            _hasMore = newPosts.length == _limit;
            _offset += _limit;
            //一页新数据

            for (final post in newPosts) {
              if (!_posts.any((element) => element['id'] == post['id'])) {
                 if(post['userId'] == Global.dhtClient.get_userid()) {
                   _posts.add(post);
                 }
              }
            }


            return getPostCards(_posts);
          }
        },
      ),
    );

  }

}

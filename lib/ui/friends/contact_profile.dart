import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freeman/common.dart';
import 'package:freeman/common/ui.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'set_alias_page.dart';
import 'friend_item_dialog.dart';
import 'dart:convert';
import 'package:fleather/fleather.dart';
import 'package:parchment/parchment.dart';
import '../chatdetail/chat_page.dart';
import 'set_remark_page.dart';
import 'package:freeman/ui/friends/friend_handle.dart';

class ContactProfilePage extends ConsumerStatefulWidget {
  final String hashid;

  const ContactProfilePage({super.key, required this.hashid});

  @override
  _ContactProfilePageState createState() => _ContactProfilePageState();
}

class _ContactProfilePageState extends ConsumerState<ContactProfilePage> with SingleTickerProviderStateMixin{
  late Contact contact;
  late TabController _tabController;
  late final ScrollController _scrollController;
  List<Map<String, dynamic>> _posts = [];
  int _offset = 0;
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasMore = true;


  final List<Tab> tabs = [
    Tab(text: Global.l10n.contact_post),
    Tab(text: Global.l10n.my_tab_1),
  ];

  void _onAvatarTap() {
     //Navigator.push(context, MaterialPageRoute(builder: (_) => AvatarPicker()));
  }


  Future<void> _loadMorePosts() async {

    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    try {
      await Global.dhtClient.getPosts(PostType.POST_MINE.index, contact.id, _offset, _limit);
    } catch (e) {
      print('加载更多失败: $e');
    } finally {
      _isLoading = false;
    }
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return; // 正在动画切换时跳过
    if (_tabController.index == 0) {
      // 当前是第二个 tab，执行数据加载
      _offset = 0;
      _hasMore = true;
      _posts.clear();
      _loadMorePosts();
    }else{
      _posts.clear();
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            _loadMorePosts();
      },
    );

    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);


    _scrollController = ScrollController();
    contact = Contact.fromHashID(widget.hashid);
    print("[ContactProfilePage] avatar:${contact.avatar}");

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMorePosts(); // 快到底部了
      }
    });

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
              if(tooltip == Global.l10n.btn_send_msg)
              {
                routePushReplace(
                    new ChatPage(conv_id: 0, remote_id: contact.identifier )
                );
              }else if(tooltip == Global.l10n.del)
              {
                confirmAlert(
                  context,
                      (bool) {
                    if (bool) {
                      delFriend(contact.identifier, context);
                    }
                  },
                  tips: Global.l10n.del_sure,
                  okBtn: Global.l10n.del,
                  warmStr: Global.l10n.del_contact,
                  isWarm: true,
                  style: TextStyle(fontWeight: FontWeight.w500),
                );
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
                  userId: widget.hashid, suCc: (v) {
                if (v) Navigator.of(context).maybePop();
              }
              ),
          child: Icon(Icons.more_horiz),
        ),
      )
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: new ComMomBar(
            title: '',
            backgroundColor: Global.settings.isDarkMode ? AppDarkColors.AppBarColor : AppColors.AppBarColor,
            mainColor: Global.settings.isDarkMode ? AppDarkColors.ButtonDesText : AppColors.ButtonDesText,
            rightDMActions:   rWidget),
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
                  crossAxisAlignment: CrossAxisAlignment.end, // 保证按钮贴近底部
                  children: [
                    //头像
                    CircleAvatar(
                      radius: 58,
                      backgroundColor: Colors.blueAccent,
                      child: ClipOval(
                        child: Utils.isEmptyStr(contact.avatar)
                            ? Image.asset(defIcon, fit: BoxFit.cover)
                            : ImageView(img: contact.avatar, width: 200, height: 200, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(contact.name,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(contact.inviteCode,
                              style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 10),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Spacer(),
                              _buildCircleButton(Icons.message, Global.l10n.btn_send_msg),
                              SizedBox(width: 20),
                              _buildCircleButton(Icons.person_off, Global.l10n.del),
                            ],
                          ),

                        ],
                      ),
                    ),

                  ],
                ),
              ),
            )
            ,


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
                  // Tab 1: 动态
                  buildTab1Content(),

                  // Tab 2: 联系人可设置项
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      LabelRow(
                        label: Global.l10n.alias,
                        isLine: false,
                        isRight: true,
                        rValue: contact.alias,
                        rightW: Container(),
                        onPressed: () async
                        {
                          await Get.to(() => SetAliasPage(userId: contact.id, alias: contact.alias,))?.then((result) {
                            contact = Contact.fromHashID(widget.hashid);
                            setState(() { }); //刷新
                          });
                        },
                        value: '',
                      ),

                      LabelRow(
                        label: Global.l10n.contact_remark,
                        isLine: false,
                        isRight: true,
                        rValue: '',
                        rightW: Container(),
                        onPressed: () async
                        {
                          await Get.to(() => SetRemarkPage(contact: contact,))?.then((result) {
                            contact = Contact.fromHashID(widget.hashid);
                            setState(() { }); //刷新
                          });
                        },
                        value: '',
                      ),

                    ],
                  ),
                  

                ],
              ),
            ),
          ],
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
                    InkWell(
                      onTap: () {
                        // 点赞处理
                      },
                      child: Row(
                        children: [
                          Text(created_at, style: TextStyle(color: Colors.grey, fontSize: 12)),
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
          print('getPosts StreamBuilder: snapshot = ${snapshot.data},state=${snapshot.connectionState}, hasData = ${snapshot.hasData}');
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

            print("[ContactProfilePage] newPosts size:${newPosts.length}");

            _hasMore = newPosts.length == _limit;
            _offset += _limit;
            //一页新数据
            if(_posts.isNotEmpty && newPosts.isNotEmpty &&  newPosts[0]['id'] > _posts[0]['id'])
            {
              for (final post in newPosts) {
                if (!_posts.any((element) => element['id'] == post['id'])) {
                  _posts.insert(0, post);
                }
              }
            }else{ //一页较旧数据，按原始顺序追加到后面
              _posts.addAll( newPosts);
            }

            return getPostCards(_posts);
          }
        },
      ),
    );

  }

}

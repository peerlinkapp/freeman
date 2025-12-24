
import 'dart:async';
import 'dart:convert';
import 'package:fleather/fleather.dart';
import 'package:freeman/common.dart';
import 'package:freeman/model/contacts.dart';
import 'package:freeman/ui/friends/contact_item.dart';
import 'package:freeman/ui/friends/contact_view.dart';
import 'package:flutter/material.dart';
import 'package:freeman/ui/null_view.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fleather/fleather.dart';
import 'package:parchment/parchment.dart';
import 'reply_page.dart';

class DiscoverNullView extends StatelessWidget {
  final String str;

  DiscoverNullView({this.str = '无'});

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new InkWell(
        child: new Text(
          str ?? '',
          style: TextStyle(color: mainTextColor),
        ),
        onTap: () => {},
      ),
    );
  }
}


class DiscoverPage extends StatefulWidget {
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  ScrollController _scrollController = ScrollController();

  String? _replyingPostId;
  final TextEditingController _replyController = TextEditingController();


  List<Map<String, dynamic>> _posts = [];
  int _offset = 0;
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasMore = true;

  List<Map<String, dynamic>> _posts2 = [];
  int _offset2 = 0;
  final int _limit2 = 10;
  bool _isLoading2 = false;
  bool _hasMore2 = true;


  final List<Tab> tabs = [
    Tab(text: Global.l10n.tab_friends),
    Tab(text: Global.l10n.tab_worlds),
    //Tab(text: Global.l10n.tab_hot),

  ];

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return; // 正在动画切换时跳过
    if (_tabController.index == 0) {
      // 当前是第二个 tab，执行数据加载
      //Global.dhtClient.getPosts(0, 10);
      _offset = 0;
      _hasMore = true;
      _posts.clear();
      _loadMorePosts();
    }else{
      _posts.clear();
    }

    if (_tabController.index == 1) {
      _offset2 = 0;
      _hasMore2 = true;
      _posts2.clear();
      _loadMorePosts2();
    }else{
      _posts2.clear();
    }

  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMorePosts(); // 快到底部了
      }
    });

  }

  Future<void> _loadMorePosts() async {

    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    try {
       await Global.dhtClient.getPosts(PostType.POST_FOLLOWING.index, 0, _offset, _limit);
    } catch (e) {
      print('[_loadMorePosts] 加载更多失败: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _loadMorePosts2() async {
    if (_isLoading2 || !_hasMore2) return;
    _isLoading2 = true;
    try {
      await Global.dhtClient.getPosts(PostType.POST_MINE.index, 0, _offset2, _limit2);
    } catch (e) {
      print('加载更多失败: $e');
    } finally {
      _isLoading2 = false;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    //页面构建后，加载初始化数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMorePosts();
    });

    return  Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // 不显示返回按钮
          toolbarHeight: 0, // 不显示顶部标题栏
          elevation: 0,
          backgroundColor: Colors.transparent,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: AppColors.CardBgColor, // TabBar 的背景色
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start, // 左对齐
                children: [
                  TabBar(
                    isScrollable: true, // 让 Tab 紧凑排列
                    controller: _tabController, // 使用你自定义的 controller
                    tabs: tabs,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                    FocusScope.of(context).unfocus(); // 取消键盘焦点
                    setState(() {
                    _replyingPostId = null; // 隐藏回复框
                    });
                },
                child:
                  Stack(
                        children: [
                          TabBarView(
                              controller: _tabController,
                              children: [
                                Center(child:
                                buildTab1Content()
                                ),
                                Center(child: buildTab2Content()),
                                //Center(child: buildTab3Content())
                              ],
                          ),
                          //if (_replyingPostId != null) _buildGlobalReplyBox(), // 全局回复框

                      ]
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
    if(postData.isEmpty)
    {
      return new HomeNullView(str: Global.l10n.content_empty);
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: postData.length,
      itemBuilder: (context, index) {
        final post = postData[index];
        final postId = post['id'];
        final voted = post['meVoted'];
        final deltaJson = post['content'];
        final poster = post['userName']+" "+ post['id'].toString();
        String created_at = DateTimeUtils.getHumanReadableDate(post['created_at']);
        List<Widget> contentWidgets = [];
        try {
          final delta = Delta.fromJson(jsonDecode(deltaJson));
          final document = ParchmentDocument.fromDelta(delta);
          contentWidgets = buildWidgetsFromDocument(document);
        } catch (e, stackTrace) {
          debugPrint('解析富文本内容出错: $e');
          debugPrint('堆栈: $stackTrace');
          // 可以选择展示一个出错提示组件
          contentWidgets = [
            Text('内容加载失败', style: TextStyle(color: Colors.red)),
          ];
        }
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
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(poster, style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(created_at, style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 8),
                ...contentWidgets,
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () async {
                        await Post.upvote(postId);
                      },
                      child: Row(
                        children: [
                          Icon(voted ?Icons.thumb_up : Icons.thumb_up_off_alt, size: 20, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(post['likes'].toString(), style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ),
                    SizedBox(width: 24),
                    InkWell(
                      onTap: () {
                       /* setState(() {
                          _replyingPostId = postId.toString(); // 触发底部回复框显示
                        });
                        FocusScope.of(context).requestFocus(FocusNode()); // 可选：自动收起原本聚焦*/
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent, // 让圆角不被遮挡
                          builder: (context) => ReplyBottomSheet(postid: postId),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.comment, size: 20, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(post['comments'].toString(), style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ),
                    SizedBox(width: 24),
                    InkWell(
                      onTap: () {
                        // 删除隐藏此帖
                        Post.delPost(postId);
                        //setState(() { }); //刷新
                      },
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.grey),
                        ],
                      ),
                    ),
                  ],
                ),
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
          //print('getPosts StreamBuilder: snapshot = ${snapshot.data},state=${snapshot.connectionState}, hasData = ${snapshot.hasData}');
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
            //print("snapshot.data:${snapshot.data}");
            final List<Map<String, dynamic>> newPosts = List<Map<String, dynamic>>.from(jsonDecode(snapshot.data!));
            _hasMore = newPosts.length == _limit;
            _offset += _limit;
            //一页新数据
            print("[DiscoverPage buildTab1Content] newPosts length:${newPosts.length} _posts.length:${_posts.length}");
            if( newPosts.isNotEmpty )
            {
              for (final post in newPosts) {
                final isVisible = post['isVisible'] == true;
                final isDeleted = post['isDeleted'] == true;
                final alreadyExists = _posts.any((e) => e['id'] == post['id']);
                //print("[buildTab1Content] postid:${post['id']} isVisible:${isVisible} isDeleted: ${isDeleted}");
                if (isVisible && !isDeleted ) {
                  if(!alreadyExists)
                  {
                    if(_posts.length>0) {
                      post['id'] < _posts[0]['id'] ? _posts.add(post) : _posts
                          .insert(0, post);
                    }else{
                      _posts.add(post);
                    }
                  }else{
                    final index = _posts.indexWhere((e) => e['id'] == post['id']);
                    //print("[index] index:${index}");
                    if (index != -1) {
                      _posts.removeAt(index);
                      _posts.insert(index, post);
                    }

                  }
                }
                if ((!isVisible || isDeleted) && alreadyExists) {
                  _posts.removeWhere((e) => e['id'] == post['id']);
                }
              }

            }

            return getPostCards(_posts);
          }
        },
      ),
    );

  }

  Widget buildTab2Content() {

    return new ScrollConfiguration(
        behavior: MyBehavior(),
        child:
        StreamBuilder<String>(
          stream: Global.dhtClient.postStream,  //实时更新刷新消息
          initialData:  '',
          builder: (context, snapshot) {
            //print('getPosts StreamBuilder: snapshot = ${snapshot.data},state=${snapshot.connectionState}, hasData = ${snapshot.hasData}');
            if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
              return ListView(
                padding: EdgeInsets.all(16),
                children: [
                  Text('${snapshot.data}', style: TextStyle(fontSize: 16)),
                  // TODO: 实际内容用 snapshot.data 构建
                ],
              );
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else {
              final List<Map<String, dynamic>> newPosts = List<Map<String, dynamic>>.from(jsonDecode(snapshot.data!));
              _hasMore = newPosts.length == _limit2;
              _offset2 += _limit2;
              for (final post in newPosts) {
                if (!_posts2.any((existing) => existing['id'] == post['id'])) {
                  _posts2.add(post);
                }
              }
              return getPostCards(_posts2);
            }
          },
        ),
      );
  }

  Widget buildTab3Content()
  {
   return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('张三', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('1小时前', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '今天在公园散步，阳光真好～ 🌞',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    'https://picsum.photos/seed/${index + 1}/300/180',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Icon(Icons.favorite_border, size: 20, color: Colors.grey),
                    SizedBox(width: 8),
                    Icon(Icons.comment, size: 20, color: Colors.grey),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}


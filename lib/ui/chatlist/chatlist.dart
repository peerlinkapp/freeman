import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freeman/common.dart';
import '../../my_app_settings.dart';
import 'package:freeman/model/v2_tim_conversation.dart';
import 'package:get/get.dart';

import '../../common/ui/pop_view.dart';
import '../../model/chat_list_data.dart';
import '../../model/conversation_type.dart';
import '../chatdetail/chat_page.dart';
import 'my_conversation_view.dart';
import '../null_view.dart';

//会话列表页

class ChatListPage extends ConsumerStatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<ChatListPage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {

  List<V2TimConversation?> _chatData = [];

  Offset? tapPos;
  TextSpanBuilder _builder = TextSpanBuilder();


  @override
  void initState() {
    super.initState();
    initPlatformState();
    fetchChatData();
    final settings = ref.read(mySettingsProvider);
    // 注册观察者
    WidgetsBinding.instance.addObserver(this);

  }

  Future<void> refresh() async{
    await fetchChatData();
    print("refresh(), $mounted");
    if (mounted) {
      setState(() {});
    }
  }

  Future<List<V2TimConversation?>> fetchChatData() async {
    final List<V2TimConversation?> listChat =  await ChatListData().chatListData();
    if (!listNoEmpty(listChat)) {
      return listChat;
    }
    _chatData.clear();
    _chatData.addAll(listChat.toList());
    return listChat;
  }

  void _showMenu(BuildContext context, Offset tapPos, int type, String id, bool? isPinned) {
    int cid = Utils.StringToInt(id);
    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject()! as RenderBox;
    final RelativeRect position = RelativeRect.fromLTRB(tapPos.dx, tapPos.dy,
        overlay.size.width - tapPos.dx, overlay.size.height - tapPos.dy);
    showMenu<String>(
        context: context,
        position: position,
        items: <MyPopupMenuItem<String>>[
          MyPopupMenuItem(value: Global.l10n.chat_mark_read, child: Text(Global.l10n.chat_mark_read)),
          isPinned?? false ?  MyPopupMenuItem(value: Global.l10n.chat_cancel_pintop, child: Text(Global.l10n.chat_cancel_pintop)) : MyPopupMenuItem(value: Global.l10n.chat_pintop, child: Text(Global.l10n.chat_pintop)),
          MyPopupMenuItem(value: Global.l10n.chat_clear_history, child: Text(Global.l10n.chat_clear_history)),
          // ignore: missing_return
        ]).then<void>((String? selected) async {
          if(selected == Global.l10n.chat_pintop)
          {
            Global.dhtClient.pinConversation(cid, 1);
          }else if(selected == Global.l10n.chat_cancel_pintop)
          {
            Global.dhtClient.pinConversation(cid, 0);
          }else if(selected == Global.l10n.chat_clear_history)
          {
            await clearConversation(id);
          }else if(selected == Global.l10n.chat_mark_read) //标为已读
          {
            /*final num = await getUnreadMessageNumModel(type, id);
              if (num > 0) {
                setReadMessageModel(type, id);
              }*/
          }
          //刷新
          setState(() {});
       });
  }

  void canCelListener() {

  }

  Future<void> initPlatformState() async {
    if (!mounted) {
      return;
    }

   /* _msgStreamSubs ??= eventBusNewMsg.listen((EventBusNewMsg onData) {
      getChatData();
    });*/
  }

  @override
  bool get wantKeepAlive => true;

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      //print(".... 应用进入后台");
    } else if (state == AppLifecycleState.resumed) {
      //print(".... 应用进入前台");
      //刷新
      fetchChatData();
    }
  }

  @override
  void didChangeDependencies() {
    print("HomePage: didChangeDependencies");
    super.didChangeDependencies();
    // 假设有一些状态依赖系统，在后台恢复时可能需要更新状态
  }

  Container buildContainer()
  {
    final settings = ref.read(mySettingsProvider);
    return Container(
      color:  settings.isDarkMode ? AppDarkColors.BackgroundColor :  AppColors.BackgroundColor,
      child: ScrollConfiguration(
        behavior: MyBehavior(),
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            final V2TimConversation? model = _chatData[index];
            if (model == null) {
              return Container();
            }
            //print("[ChatListPage]conversationID:${model.conversationID}, lastMessage.timestamp: ${model!.lastMessage!.timestamp}");
            return InkWell(
              onTap: () async {
                Get.to(() => ChatPage(
                    conv_id: model.conversationID, //把会话id传递给下级页面
                    remote_id: "",
                    ))?.then((result) {
                      refresh(); //刷新
                    });
              },
              onTapDown: (TapDownDetails details) {
                tapPos = details.globalPosition;
              },
              onLongPress: () {
                _showMenu(
                  context,
                  tapPos!,
                  model.type == ConversationType.V2TIM_GROUP ? 2 : 1,
                  model.conversationID.toString(),
                  model.isPinned
                );
              },
              child: MyConversationView(
                imageUrl: model.faceUrl ,
                title: model.showName ?? '',
                content: model.lastMessage,
                time: timeView(model.lastMessage?.timestamp ?? 0),
                isBorder: model.showName != _chatData[0]?.showName,
                unreadCount: model.unreadCount ?? 0,
              ),
            );
          },
          itemCount: _chatData.length ?? 1,
        ),
      ),
    );
  }

  Widget getFutureBuilder()
  {
    return FutureBuilder<List<V2TimConversation?>>(
      future: fetchChatData(), // 假设 fetchChatData() 是一个返回 Future<List<V2TimConversation>> 的异步方法
      builder: (BuildContext context, AsyncSnapshot<List<V2TimConversation?>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          //return Center(child: CircularProgressIndicator());
          // 数据加载中，显示加载指示器
          return buildContainer();

        } else if (snapshot.hasError) {
          // 数据加载出错，显示错误信息
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // 数据为空，显示空视图
          return HomeNullView(str:Global.l10n.chat_list_empty);
        } else {
          // 数据加载成功，构建列表
          return buildContainer();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    /*
    `FutureBuilder` 和 `StreamBuilder` 是常用的异步操作组件，它们分别用于构建基于 `Future` 和 `Stream` 的 UI。
    我们可以结合使用这两个组件来处理同时需要 `Future` 和 `Stream` 数据的场景。
    假设我们有一个场景，首先等待一个 `Future` 操作完成（比如获取初始数据），然后再基于该数据创建一个 `Stream`（比如实时数据流或事件流）。
     */
    return StreamBuilder<String>(
      stream: Global.dhtClient.msgStream,  // 使用初始数据创建 Stream
      builder: (context, streamSnapshot) {
        if (streamSnapshot.connectionState == ConnectionState.waiting) {
          // 显示 Stream 加载中的进度条
          //return CircularProgressIndicator();
          return getFutureBuilder();

        } else if (streamSnapshot.hasError) {
          // 显示错误信息
          return Text('Stream Error: ${streamSnapshot.error}');
        } else if (!streamSnapshot.hasData) {
          // 如果没有数据
          return Text('No Stream Data');
        } else {
          //return Text('Received: ${streamSnapshot.data}');
          // 显示实时数据
          return getFutureBuilder();
        }
      },
    );

  }


  @override
  void dispose() {
    // 取消观察者
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    canCelListener();
  }
}

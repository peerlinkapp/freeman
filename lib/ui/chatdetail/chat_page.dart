
import 'dart:async';
import 'dart:convert';
import 'package:extended_text/extended_text.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:freeman/ui/chatdetail/voice_play_widget.dart';
import 'package:get/get.dart';
import 'package:freeman/common.dart';

import '../../common/ui/emoji_text.dart';
import '../../common/ui/text_span_builder.dart';
import '../../model/v2_tim_message.dart';
import 'chat_details_body.dart';
import 'chat_more_icon.dart';
import 'chat_more_page.dart';
import 'chat_details_row.dart';
import 'package:freeman/ui/chatdetail/message_handler.dart';
import 'group_detail_page.dart';
import 'voice_record_buttion.dart';

//聊天详情页

enum ButtonType { voice, more }

class ChatPage extends StatefulWidget {

  final int conv_id; //会话id, 可能为空
  final String remote_id; //个人：hashid,群聊：topicid 可能为空

  ChatPage({required this.conv_id, required this.remote_id});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _isVoice = false;
  bool _isMore = false;
  double keyboardHeight = 270.0;
  bool _emojiState = false;
  String? newGroupName;
  late int cid; //会话id
  late String remote_id; //对端id
  late String title = ""; //会话标题
  late int ctype = ConversationType.CONVERSATION_TYPE_INVALID; //会话类型

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _sC = ScrollController();
  PageController pageC = PageController();

  bool _showRecorder = false;

  void _toggleRecorder() {
    setState(() {
      _showRecorder = !_showRecorder;
    });
  }

  Future<void> getConversationTitle() async
  {
    if(cid == 0)
    {
      Contact c = Contact.fromHashID(remote_id);
      title = c.name;
      ctype = ConversationType.V2TIM_C2C;
    }else {
      Conversation c = await Global.dhtClient.getConversationProfile(cid);
      title = c.showName;
      ctype = c.isGroup == 1 ? ConversationType.V2TIM_GROUP : ConversationType
          .V2TIM_C2C;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    cid = widget.conv_id;
    remote_id = widget.remote_id;
    //在联系人列表页进入（没有conv_id)，在聊天列表页进入（没有remote_id)，通过以下方式补全
    if(remote_id.isEmpty)
    {
      remote_id = Global.dhtClient.get_conversation_remote_id(cid);
    }
    if(cid == 0)
    {
      cid = Global.dhtClient.get_conversation_id(remote_id);
      debugPrint("[ChatPage]1 cid=${cid}, remote_id=${remote_id}");
      if(cid == 0)
      {
        cid = Global.dhtClient.createConversationC2C(remote_id);
      }
      debugPrint("[ChatPage]2 cid=${cid}, remote_id=${remote_id}");
    }

    //设置窗口标题
    getConversationTitle();



    Global.dhtClient.setMessagesReaded( cid );

    _sC.addListener(() => FocusScope.of(context).requestFocus(FocusNode()));
    initPlatformState();

    if (ctype == ConversationType.V2TIM_GROUP) {
      Notice.addListener(WeChatActions.groupName(), (v) {
        setState(() => newGroupName = v as String);
      });
    }
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _emojiState = false;
      }
    });
  }



  void insertText(String text) {
    var value = _textController.value;
    var start = value.selection.baseOffset;
    var end = value.selection.extentOffset;
    if (value.selection.isValid) {
      String newText = '';
      if (value.selection.isCollapsed) {
        if (end > 0) {
          newText += value.text.substring(0, end);
        }
        newText += text;
        if (value.text.length > end) {
          newText += value.text.substring(end, value.text.length);
        }
      } else {
        newText = value.text.replaceRange(start, end, text);
        end = start;
      }

      _textController.value = value.copyWith(
          text: newText,
          selection: value.selection.copyWith(
              baseOffset: end + text.length, extentOffset: end + text.length));
    } else {
      _textController.value = TextEditingValue(
          text: text,
          selection:
              TextSelection.fromPosition(TextPosition(offset: text.length)));
    }
  }

  void cancelListener() {
    //Global.dhtClient.msgController.close();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;

  }


// 滚动到列表底部
  void _scrollToBottom() {
    _sC.animateTo(
      _sC.position.minScrollExtent,  // 滚动到底部
      duration: Duration(seconds: 1),              // 动画时长
      curve: Curves.easeOut,                       // 动画曲线
    );
  }

  _handleSubmittedData(String text) async {
    _textController.clear();
    if(strEmpty(text)) return;

    if(cid == 0)
    {
      cid = Global.dhtClient.createConversationC2C(remote_id);
    }
    await sendTextMsg(cid,  text);
  }

  onTapHandle(ButtonType type) {
    print("setState:onTapHandle");
    setState(() {
      print("setState:$type");
      if (type == ButtonType.voice) {
        _toggleRecorder();

        _focusNode.unfocus();
        _isMore = false;
        _isVoice = !_isVoice;
      } else {
        _isVoice = false;
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
          _isMore = true;
        } else {
          _isMore = !_isMore;
        }
      }
      _emojiState = false;
    });
  }

  Widget edit(context, size) {
    // 计算当前的文本需要占用的行数
    TextSpan _text =
        TextSpan(text: _textController.text, style: AppStyles.ChatBoxTextStyle);

    TextPainter _tp = TextPainter(
        text: _text,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left);
    _tp.layout(maxWidth: size.maxWidth);

    return ExtendedTextField(
      specialTextSpanBuilder: TextSpanBuilder(showAtBackground: true),
      onTap: () => setState(() {
        if (_focusNode.hasFocus) _emojiState = false;
      }),
      onChanged: (v) => setState(() {}),
      decoration: InputDecoration(
          border: InputBorder.none, contentPadding: const EdgeInsets.all(5.0)),
      controller: _textController,
      focusNode: _focusNode,
      maxLines: 99,
      cursorColor: AppColors.ChatBoxCursorColor,
      style: AppStyles.ChatBoxTextStyle,
    );
  }

  void showCustomToast(BuildContext context, GlobalKey iconKey, String message) {
    final renderBox = iconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final overlay = Overlay.of(context);
    final offset = renderBox.localToGlobal(Offset.zero);

    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy + 50 ,
        left: offset.dx-100,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(Duration(seconds: 2), () {
      entry.remove();
    });
  }

  InkWell p2pIcon()
  {
    final GlobalKey _iconKey = GlobalKey();
    bool isP2P = Global.dhtClient.isContactP2P(remote_id);

    return isP2P?  InkWell(
      child: Container(
        key: _iconKey, // 加关键 key！
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        width: 30.0,
        child: Icon(Icons.public, color: Colors.green),
      ),
      onTap: () {
        showCustomToast(context, _iconKey, Global.l10n.p2p_ok);
      },
    ):InkWell(
      onTap: () {
        // 空的点击事件，也可以留空以禁止点击
      },
      child: Container(), // 空容器，表示没有内容
    );

  }

  @override
  Widget build(BuildContext context) {
    if (keyboardHeight == 270.0 &&
        MediaQuery.of(context).viewInsets.bottom != 0) {
      keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    }
    var body = [
      new ChatDetailsBody(sC: _sC, cid: cid),
        new ChatDetailsRow( //最底端的工具条
            voiceOnTap: () => onTapHandle(ButtonType.voice),
            onEmojio: () {
              if (_isMore) {
                _emojiState = true;
              } else {
                _emojiState = !_emojiState;
              }
              if (_emojiState) {
                FocusScope.of(context).requestFocus(new FocusNode());
                _isMore = false;
              }
              setState(() {});
            },
            isVoice: _isVoice,
            edit: edit,
            more: new ChatMoreIcon(
              value: _textController.text,
              onTap: () async => _handleSubmittedData(_textController.text),
              moreTap: () => onTapHandle(ButtonType.more),
            ),
            type: ctype,
        ),
      new Visibility(
        visible: _emojiState,
        child: emojiWidget(),
      ),
      //聊天详情页中+按钮展开后的界面
      new Container(
        height: _isMore && !_focusNode.hasFocus ? keyboardHeight/2 : 0.0,
        width: winWidth(context),
        color: Global.settings.isDarkMode ? AppDarkColors.ChatBoxBg : AppColors.ChatBoxBg ,
        child: new IndicatorPageView(
          pageC: pageC,
          pages: List.generate(1, (index) { //将1改为2，即可以2页显示
            return new ChatMorePage(
              index: index,
              id: cid,
              type: ctype,
              keyboardHeight: keyboardHeight,
            );
          }),
        ),
      ),
    ];

    final List<InkWell> rWidget = <InkWell>[
      p2pIcon(),
      InkWell(
        child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              width: 30.0,
              child: Icon(Icons.more_horiz),
              ),
         onTap: () {
           if(ctype == ConversationType.V2TIM_GROUP)
             {
               Get.to(() => GroupDetailsPage(cid: cid))?.then((result) {
                 getConversationTitle();
                 setState(() { }); //刷新
               });
             }
         },
      )
    ];

    return Scaffold(
      appBar: ComMomBar(title: newGroupName ??  title, rightDMActions: rWidget),
      body: Stack(
        children: [
          MainInputBody(
                  onTap: () => setState(
                          () {
                        _isMore = false;
                        _emojiState = false;
                      },
                  ),
                  decoration: BoxDecoration(color: Global.settings.isDarkMode ? AppDarkColors.ChatBoxBg : AppColors.ChatBoxBg), //背景色
                  child: Column(children: body),
          ),

          // 叠加的半透明录音按钮
          if (_showRecorder)
            Positioned(
              left: 38,
              right: 72,
              bottom: 2,
              child: Material(
                  color: Colors.transparent, // 避免遮挡下层
                  child: Opacity(
                                opacity: 1.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: VoiceRecorderButton(
                                              onStop: (path, duration) {
                                                debugPrint('录音完成，路径：$path');
                                                sendVoiceMsg(remote_id, path);
                                                setState(() {
                                                  _showRecorder = false;
                                                });
                                              },
                                        ),
                               ),
                              ),
                  ),
            ),

        ],
      ),
    );
  }

  Widget emojiWidget() {
    return GestureDetector(
      child: SizedBox(
        height: _emojiState ? keyboardHeight : 0,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              child:
                  Image.asset(EmojiUitl.instance.emojiMap['[${index + 1}]']!),
              behavior: HitTestBehavior.translucent,
              onTap: () {
                insertText('[${index + 1}]');
              },
            );
          },
          itemCount: EmojiUitl.instance.emojiMap.length,
          padding: const EdgeInsets.all(5.0),
        ),
      ),
      onTap: () {},
    );
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
    Notice.removeListenerByEvent(WeChatActions.msg());
    Notice.removeListenerByEvent(WeChatActions.groupName());
    _sC.dispose();
  }
}

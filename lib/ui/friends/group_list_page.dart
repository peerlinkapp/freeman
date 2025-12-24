
import 'dart:async';
import 'package:freeman/common.dart';
import 'package:flutter/material.dart';
import 'package:freeman/ui/null_view.dart';
import 'group_view.dart';
import 'package:freeman/ui/friends/contact_item.dart';


class GroupsNullView extends StatelessWidget {
  final String str;

  GroupsNullView({this.str = ''});

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


class GroupListPage extends StatefulWidget {
  _GroupListPageState createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage>
    with AutomaticKeepAliveClientMixin {
  var indexBarBg = Colors.transparent;
  String currentLetter = '';
  var isNull = false;

  ScrollController sC = ScrollController();

  List<Conversation> _contacts = [];

  StreamSubscription<dynamic>? _messageStreamSubscription;

  final Map _letterPosMap = {INDEX_BAR_WORDS[0]: 0.0};

  Future getContacts() async {


    final listGroup = await Global.dhtClient.getGroupList();
    isNull = listGroup.length == 0;
    print("[group_list_page] listGroup:${listGroup.length}");

    _contacts.clear();
    _contacts..addAll(listGroup);
    _contacts
        .sort((Conversation a, Conversation b) => a.nameIndex.compareTo(b.nameIndex));
    sC = new ScrollController();

    /// 计算用于 IndexBar 进行定位的关键通讯录列表项的位置
    var _totalPos = 0.0;
    for (int i = 0; i < _contacts.length; i++) {
      bool _hasGroupTitle = true;
      if (i > 0 &&
          _contacts[i].nameIndex.compareTo(_contacts[i - 1].nameIndex) == 0)
        _hasGroupTitle = false;

      if (_hasGroupTitle) _letterPosMap[_contacts[i].nameIndex] = _totalPos;

      _totalPos += ContactItemState.heightItem(_hasGroupTitle);
    }
    return _contacts;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    sC.dispose();
    canCelListener();
  }

  String _getLetter(BuildContext context, double tileHeight, Offset globalPos) {
    final RenderObject? renderObject = context.findRenderObject();
    if(renderObject is RenderBox)
      {
        RenderBox _box = renderObject;
        var local = _box.globalToLocal(globalPos);
        int index = (local.dy ~/ tileHeight).clamp(0, INDEX_BAR_WORDS.length - 1);
        return INDEX_BAR_WORDS[index];
      }
    return INDEX_BAR_WORDS[0];

  }

  void _jumpToIndex(String? letter) {
    if (_letterPosMap.isNotEmpty) {
      final _pos = _letterPosMap[letter];
      if (_pos != null)
        sC.animateTo(_pos,
            curve: Curves.easeOut, duration: Duration(milliseconds: 200));
    }
  }

  Widget _buildIndexBar(BuildContext context, BoxConstraints constraints) {
    final List<Widget> _letters = INDEX_BAR_WORDS
        .map((String word) =>
    new Expanded(child: new Text(word, style: TextStyle(fontSize: 12))))
        .toList();

    final double _totalHeight = constraints.biggest.height;
    final double _tileHeight = _totalHeight / _letters.length;

    void jumpTo(details) {
      indexBarBg = Colors.black26;
      currentLetter = _getLetter(context, _tileHeight, details.globalPosition);
      _jumpToIndex(currentLetter);
      setState(() {});
    }

    void transparentMethod() {
      indexBarBg = Colors.transparent;

      setState(() {});
    }

    return new GestureDetector(
      onVerticalDragDown: (DragDownDetails details) => jumpTo(details),
      onVerticalDragEnd: (DragEndDetails details) => transparentMethod(),
      onVerticalDragUpdate: (DragUpdateDetails details) => jumpTo(details),
      child: new Column(children: _letters),
    );
  }

  @override
  void initState() {
    super.initState();

  }

  void canCelListener() {
    _messageStreamSubscription?.cancel();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
  }

  Widget getFutureBuilder()
  {
    return FutureBuilder<dynamic>(
      future: getContacts(), // 假设 fetchChatData() 是一个返回 Future<List<V2TimConversation>> 的异步方法
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          //return Center(child: CircularProgressIndicator());
          // 数据加载中，显示加载指示器
          return getBuildWidget(context);
        } else if (snapshot.hasError) {
          // 数据加载出错，显示错误信息
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // 数据为空，显示空视图
          return getBuildWidget(context);
        } else {
          // 数据加载成功，构建列表
          return getBuildWidget(context);
        }
      },
    );
  }


  Widget getBuildWidget(BuildContext context) {

    List<Widget> body = [
      new GroupView(
          sC: sC,  contacts: _contacts),

      //右侧的A-Z
      new Positioned(
        width: Constants.IndexBarWidth,
        right: 0.0,
        top: 120.0,
        bottom: 120.0,
        child: new Container(
          color: indexBarBg,
          child: new LayoutBuilder(builder: _buildIndexBar),
        ),
      ),
    ];

    if (isNull) body.add(new HomeNullView(str: Global.l10n.contact_book_empty));

    if (currentLetter.isNotEmpty) {
      var row = [
        new Container(
            width: Constants.IndexLetterBoxSize,
            height: Constants.IndexLetterBoxSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.IndexLetterBoxBg,
              borderRadius: BorderRadius.all(
                  Radius.circular(Constants.IndexLetterBoxSize / 2)),
            ),
            child: new Text(currentLetter,
                style: AppStyles.IndexLetterBoxTextStyle)),
        new Icon(Icons.arrow_right),
        new Space(width: mainSpace * 5),
      ];
      body.add(
        new Container(
          width: winWidth(context),
          height: winHeight(context),
          child:
          new Row(mainAxisAlignment: MainAxisAlignment.end, children: row),
        ),
      );
    }
    return new Scaffold(
        backgroundColor: Global.settings.isDarkMode ? AppDarkColors.BackgroundColor : AppColors.BackgroundColor,
        appBar: ComMomBar(
          title: Global.l10n.group_chat,
          rightDMActions: <Widget>[],
        ),
        body: new Stack(children: body)
    );
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<String>(
      stream: Global.dhtClient.friendsStream,  // 使用初始数据创建 Stream
      builder: (context, streamSnapshot) {
        if (streamSnapshot.connectionState == ConnectionState.waiting) {
          //print("StreamBuilder: ${streamSnapshot.data}");
          return getFutureBuilder();
        } else if (streamSnapshot.hasError) {
          // 显示错误信息
          return Text('Stream Error: ${streamSnapshot.error}');
        } else if (!streamSnapshot.hasData) {
          // 如果没有数据
          return Text('No Stream Data');
        } else {
          // 显示实时数据
          print("StreamBuilder: ${streamSnapshot.data}");
          return getFutureBuilder();
        }
      },
    );
  }

}

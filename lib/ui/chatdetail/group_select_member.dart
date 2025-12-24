
import 'dart:async';
import 'package:freeman/common.dart';
import '../friends/contact_view.dart';
import 'package:freeman/model/contacts.dart';
import 'package:freeman/ui/friends/contact_item.dart';
import 'package:freeman/ui/friends/contact_view.dart';
import 'package:flutter/material.dart';
import 'package:freeman/ui/null_view.dart';
import '../../common/common_bar.dart';

/*
群成员选择器，主要用于群成员删除
 */

class  SelectGroupMemberPage extends StatefulWidget {
  final int groupId;
  SelectGroupMemberPage({required this.groupId});

  _SelectGroupMemberPageState createState() => _SelectGroupMemberPageState();
}

class _SelectGroupMemberPageState extends State<SelectGroupMemberPage>
    with AutomaticKeepAliveClientMixin {
  var indexBarBg = Colors.transparent;
  String currentLetter = '';
  var isNull = false;

  ScrollController sC = ScrollController();

  List<Contact> _contacts = [];
  List<Contact> _selectedContacts = [];
  List<String> _selectedIds = [];

  StreamSubscription<dynamic>? _messageStreamSubscription;

  List<ContactItem> _functionButtons = [];
  final Map _letterPosMap = {INDEX_BAR_WORDS[0]: 0.0};

  Future getContacts() async {
    final listContact= await Conversation.getMemberUserProfiles(widget.groupId);

    _contacts.clear();
    _contacts..addAll(listContact);
    _contacts
        .sort((Contact a, Contact b) => a.nameIndex.compareTo(b.nameIndex));


    /// 计算用于 IndexBar 进行定位的关键通讯录列表项的位置
    var _totalPos =
        _functionButtons.length * ContactItemState.heightItem(false);
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
      new ContactView(
          sC: sC, functionButtons: _functionButtons,
          type:ClickType.select,
          selectedIds: _selectedIds,
          contacts: _contacts,
          callback: (ids) {
            setState(() {
              _selectedIds = List<String>.from(ids);
              print("_selectedIds:${_selectedIds.length}");
            });
          },
      ),

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
        appBar: new CommonBar(
          title: Global.l10n.group_chat_members
        ),
        body: new Stack(children: body),
        bottomNavigationBar: _contacts.isEmpty
            ? null
            : SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed: () {
                _selectedContacts = _contacts
                    .where((contact) => _selectedIds.contains(contact.identifier))
                    .toList();
                Navigator.pop(context, _selectedContacts);
              },
              child: Text("${Global.l10n.del} (${_selectedIds.length})"),
            ),
          ),
        ),

    );
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return getFutureBuilder();
  }

}

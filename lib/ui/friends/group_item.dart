
import 'package:flutter/material.dart';
import 'contact_view.dart';
import 'package:freeman/common.dart';
import 'contacts_details_page.dart';
import 'new_friend_page.dart';
import 'contact_profile.dart';
import 'group_list_page.dart';
import '../chatdetail/chat_page.dart';


typedef OnAdd = void Function(String v);
typedef OnCancel = void Function(String v);

class GroupItem extends StatefulWidget {
  final String avatar;
  final String title;
  final int identifier; //用于区分联系人的唯一id
  final String? groupTitle;
  final bool isLine;
  final bool isSelected;
  final OnAdd? add;
  final OnCancel? cancel;
  final int unreadCount; //未读消息数量（用于显示右上角数字图标）

  GroupItem({
    required this.avatar,
    required this.title,
    required this.identifier,

    this.isLine = true,
    this.isSelected = false,
    this.groupTitle,
    this.add,
    this.cancel,
    this.unreadCount = 0
  });

  ContactItemState createState() => ContactItemState();
}

class ContactItemState extends State<GroupItem> {
  // ‘添加好友’ 横纵间距
  static const double MARGIN_VERTICAL = 6.0;
  static const double MARGIN_HORIZONTAL = 16.0;

  // ‘ABC...’ 高度
  static const double GROUP_TITLE_HEIGHT = 34.0;

  // items的高度 纵向高度*2+头像高度+分割线高度
  static double heightItem(bool hasGroupTitle) {
    final _buttonHeight = MARGIN_VERTICAL * 2 +
        Constants.ContactAvatarSize +
        Constants.DividerWidth;
    if (hasGroupTitle) return _buttonHeight + GROUP_TITLE_HEIGHT;

    return _buttonHeight;
  }

  bool isSelect = false;

  Map<String, dynamic>? mapData;

  bool isLine() {
    if (widget.isLine) {
      if (widget.title != '公众号') {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    /// 定义左边图标Widget
    Widget _avatarIcon = new ImageView(
      img: widget.avatar,
      width: Constants.ContactAvatarSize,
      height: Constants.ContactAvatarSize,
      fit: BoxFit.cover,
      unreadCount:widget.unreadCount,
    );

    /// 头像圆角
    _avatarIcon = _avatarIcon;

    var content = [
      _avatarIcon,

      ///  头像离名字的距离
      new Space(width: 15.0),
      new Expanded(
        child: new Container(
          padding: const EdgeInsets.only(right: MARGIN_HORIZONTAL),
          height: heightItem(false),

          /// 名字的显示位置
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            border: !isLine()
                ? null
                : Border(
              bottom: BorderSide(

                /// 下划线粗细及颜色
                  width: Constants.DividerWidth,
                  color: lineColor),
            ),
          ),

          /// 姓名
          child: new Text(widget.title.length > 30 ? widget.title.substring(0,10)+"......"+widget.title.substring(20,30):widget.title,
              style: TextStyle(fontWeight: FontWeight.w400), maxLines: 1),
        ),
      ),

    ];

    /// 列表项主体部分
    Widget button = new TextButton(
      style: TextButton.styleFrom(
        backgroundColor:  Global.settings.isDarkMode ? AppDarkColors.ListItemBg : AppColors.ListItemBg, // 按钮背景颜色
        foregroundColor:  Global.settings.isDarkMode ? AppDarkColors.MainTextColor : AppColors.MainTextColor, // 文字颜色
      ),
      onPressed: () {
          routePushReplace(
              new ChatPage(conv_id: widget.identifier, remote_id: '')
          );

      },
      child: new Row(children: content),
    );

    /// 定义分组标签（左边的ABC...）
    Widget itemBody;
    if (widget.groupTitle != null) {
      itemBody = new Column(
        children: <Widget>[
          new Container(
            height: GROUP_TITLE_HEIGHT,
            padding: EdgeInsets.only(left: 16.0, right: 16.0),
            decoration: BoxDecoration(
              color:  Global.settings.isDarkMode ? AppDarkColors.ContactGroupTitleBg :  AppColors.ContactGroupTitleBg,
              border: Border(
                top: BorderSide(color: lineColor, width: 0.2),
                bottom: BorderSide(color: lineColor, width: 0.2),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: new Text(widget.groupTitle ?? "",
                style: AppStyles.GroupTitleItemTextStyle),
          ),
          button,
        ],
      );
    } else {
      itemBody = button;
    }

    return itemBody;
  }
}

import 'package:flutter/material.dart';
import 'package:freeman/model/contacts.dart';
import 'package:freeman/common.dart';

import 'group_item.dart';

enum ClickType { select, open }

typedef Callback(data);

class GroupView extends StatelessWidget {
  final ScrollController? sC;
  final List<GroupItem> functionButtons;
  final List<Conversation> contacts;
  final ClickType? type;
  final Callback? callback;
  final List<String> selectedIds;

  GroupView({
    this.sC,
    this.functionButtons = const [],
    this.contacts = const [],
    this.type,
    this.callback,
    this.selectedIds = const [],
  });

  @override
  Widget build(BuildContext context) {
    return new ScrollConfiguration(
      behavior: MyBehavior(),
      child: new ListView.builder(
        controller: sC,
        itemBuilder: (BuildContext context, int index) {
          if (index < functionButtons.length) return functionButtons[index];

          int _contactIndex = index - functionButtons.length;
          bool _isGroupTitle = true;
          Conversation _contact = contacts[_contactIndex];
          if (_contactIndex >= 1 &&
              _contact.nameIndex == contacts[_contactIndex - 1].nameIndex) {
            _isGroupTitle = false;
          }
          bool _isBorder = _contactIndex < contacts.length - 1 &&
              _contact.nameIndex == contacts[_contactIndex + 1].nameIndex;
          bool isSelected = selectedIds.contains(_contact.id.toString());

          if (_contact.showName != contacts[contacts.length - 1].showName) {
            //print('wwwcontact[$_contactIndex]:${_contact.avatar}');
            return new GroupItem(
              avatar: '',
              title: _contact.showName,
              identifier: _contact.id ,
              groupTitle: _isGroupTitle ? _contact.nameIndex : null,
              isLine: _isBorder,
              isSelected: isSelected,
              cancel: (v) {
                selectedIds.remove(v);
                if (callback != null) callback!(selectedIds);
              },
              add: (v) {
                selectedIds.add(v);
                if (callback != null) callback!(selectedIds);
              },
            );
          } else {
            return new Column(children: <Widget>[
              new GroupItem(
                avatar: _contact.faceUrl ?? '',
                title: _contact.showName,
                identifier: _contact.id ,
                groupTitle: _isGroupTitle ? _contact.nameIndex : null,
                isLine: false,
                isSelected: isSelected,

                cancel: (v) {
                  selectedIds.remove(v);
                  if (callback != null) callback!(selectedIds);
                },
                add: (v) {
                  selectedIds.add(v);
                  if (callback != null) callback!(selectedIds);
                },
              ),
              new HorizontalLine(),
              new Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: new Text(
                  '${contacts.length}${Global.l10n.count_groups}',
                  style: TextStyle(color: mainTextColor, fontSize: 16),
                ),
              )
            ]);
          }
        },
        itemCount: contacts.length + functionButtons.length,
      ),
    );
  }
}

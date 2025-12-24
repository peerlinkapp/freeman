import 'package:flutter/material.dart';
import 'package:freeman/model/contacts.dart';
import 'package:freeman/common.dart';

import 'contact_item.dart';

enum ClickType { select, open }

typedef Callback(data);

class ContactView extends StatelessWidget {
  final ScrollController? sC;
  final List<ContactItem> functionButtons;
  final List<Contact> contacts;
  final ClickType? type;
  final Callback? callback;
  final List<String> selectedIds;

  ContactView({
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
          Contact _contact = contacts[_contactIndex];
          if (_contactIndex >= 1 &&
              _contact.nameIndex == contacts[_contactIndex - 1].nameIndex) {
            _isGroupTitle = false;
          }
          bool _isBorder = _contactIndex < contacts.length - 1 &&
              _contact.nameIndex == contacts[_contactIndex + 1].nameIndex;
          bool isSelected = selectedIds.contains(_contact.identifier);

          if (_contact.name != contacts[contacts.length - 1].name) {
            //print('wwwcontact[$_contactIndex]:${_contact.avatar}');
            return new ContactItem(
              avatar: _contact.avatar,
              title: _contact.name,
              identifier: _contact.identifier,
              groupTitle: _isGroupTitle ? _contact.nameIndex : null,
              isLine: _isBorder,
              isSelected: isSelected,
              type: type,
              sex: _contact.sex,
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
              new ContactItem(
                avatar: _contact.avatar,
                title: _contact.name,
                identifier: _contact.identifier,
                groupTitle: _isGroupTitle ? _contact.nameIndex : null,
                isLine: false,
                isSelected: isSelected,
                type: type,
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
                  '${contacts.length}${Global.l10n.count_connects}',
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

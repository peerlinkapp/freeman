import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freeman/constants.dart';


import 'package:freeman/ui/tip_verify_Input.dart';
import 'package:get/get.dart';
import '../../common.dart';
import '../../global.dart';
import '../../common/common_bar.dart';
import '../../common/common_button.dart';
import '../../model/contacts.dart';
import '../../model/conversations.dart';
import '../friends/contacts_select_page.dart';


class TopicDetailPage extends StatefulWidget {
  final Conversation topic;

  const TopicDetailPage({super.key, required this.topic});

  @override
  _TopicDetailPageState createState() => _TopicDetailPageState();
}

class _TopicDetailPageState extends State<TopicDetailPage> {
  late TextEditingController _nameController;
  late TextEditingController _announcementController;
  FocusNode _focusNode = FocusNode();


  Map<int, String> _members = {};

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.topic.showName);
    _announcementController = TextEditingController(text: widget.topic.announcement);
    // _members = { for (var id in widget.topic.members) id: id };

  }

  @override
  void dispose() {
    _nameController.dispose();
    _announcementController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _selectMembers() async {
    // 跳转到联系人选择页面，等待用户选择后返回
    final List<Contact>? selectedContacts = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactsSelectPage(),
      ),
    );

    // 判断是否有选择联系人返回
    if (selectedContacts != null && selectedContacts.isNotEmpty) {
      setState(() {
        for (var contact in selectedContacts) {
          _members[contact.id] = contact.name; // 保存 ID 和 name
        }
      });
    }
  }


  void _saveTopic() {
    setState(() {
      widget.topic.showName = _nameController.text;
      widget.topic.announcement = _announcementController.text;
      widget.topic.members =  _members.keys.toList();

    });

    Global.dhtClient.saveConversation(widget.topic);

    Navigator.pop(context, widget.topic); // 返回保存后的话题
  }

  Widget buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 话题名称
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: Global.l10n.group_chat_title,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // 话题类型，使用 InputDecorator 包装 Dropdown，统一外观
          InputDecorator(
            decoration: InputDecoration(
              labelText: Global.l10n.group_chat_visible,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: widget.topic.isPublic ,
                items: [
                  DropdownMenuItem(
                    value: 0,
                    child: Text(Global.l10n.topic_private),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text(Global.l10n.topic_public),
                  ),
                ],
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      widget.topic.isPublic = newValue;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 公告内容
          TextField(
            controller: _announcementController,
            focusNode: _focusNode,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: Global.l10n.group_chat_notice,
              hintText: Global.l10n.group_chat_notice_input,
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),

          // 成员列表显示 + 添加按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${Global.l10n.group_chat_members} (${_members.length})',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _selectMembers,
                icon: Icon(Icons.person_add),
                label: Text(Global.l10n.btn_add),
              )
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _members.entries
                .map((entry) => Chip(
              label: Text(entry.value), // 显示 name
              onDeleted: () {
                setState(() {
                  _members.remove(entry.key); // 删除用 ID
                });
              },
            ))
                .toList(),
          ),
          const SizedBox(height: 32),

          // 确定按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveTopic,
              icon: Icon(Icons.check),
              label: Text(Global.l10n.btn_submit),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Global.settings.isDarkMode;
    final bgColor = isDark ? AppDarkColors.BackgroundColor : AppColors.BackgroundColor;

    return Scaffold(
      appBar: CommonBar(
        title: Global.l10n.launch_topic,
      ),
      backgroundColor: bgColor,
      body: MainInputBody(color: bgColor, child: buildBody()),
    );
  }
}

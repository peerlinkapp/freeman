import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freeman/constants.dart';


import 'package:freeman/ui/tip_verify_Input.dart';
import '../../common.dart';
import '../../global.dart';
import '../../common/common_bar.dart';
import '../../common/common_button.dart';

class MessageIncomeAudioPage extends StatefulWidget {

  const MessageIncomeAudioPage();

  @override
  _MessageIncomeAudioState createState() => new _MessageIncomeAudioState();

}

class _MessageIncomeAudioState extends State<MessageIncomeAudioPage> {

  int? selectedIndex;

  Widget body() {
    return ListView.builder(
      itemCount: Global.newMessageAudios.length,
      itemBuilder: (_, index) {
        final isSelected = index == selectedIndex;

        return ListTile(
          title: Text(Global.newMessageAudios[index].name),
          trailing: isSelected
              ? const Icon(Icons.check, color: Colors.blue)
              : null,
          onTap: () {
            Global.playNotificationSound(index);

            setState(() {
              selectedIndex = index;
            });
          },
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedIndex = Global.getNewMessageAudioIdx();
    Global.settings.msgAudio = selectedIndex ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    //
    return new Scaffold(
      appBar: new CommonBar(
        title: Global.l10n.msg_notify_audio,
        rightDMActions: [
          new IconButton(
            icon: Icon(
              Icons.save,
              color: Colors.green,
            ),
            onPressed: () {
              Global.settings.msgAudio = selectedIndex!;
              Global.dhtClient.setCfg("newMsgAudio", selectedIndex.toString());
              debugPrint("[selectedIndex] = ${selectedIndex}");
              Navigator.pop(context);
            },
          )
        ],
      ),
      backgroundColor: Global.settings.isDarkMode ? AppDarkColors.BackgroundColor : AppColors.BackgroundColor,
      body: new MainInputBody(color: Global.settings.isDarkMode ? AppDarkColors.BackgroundColor : AppColors.BackgroundColor, child: body()),
    );
  }
}

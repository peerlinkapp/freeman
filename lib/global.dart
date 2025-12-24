
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freeman/common.dart';
import 'package:freeman/dhtclient.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:freeman/l10n/l10n.dart'; //引入国际化多语言本地化类

import 'package:freeman/model/contacts.dart';
import 'model/conversations.dart';
import 'package:provider/provider.dart';

import 'my_app_settings.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:audioplayers/audioplayers.dart';

class NewMessageyAudio {
  final int index;
  final String name;
  final String file;

  NewMessageyAudio({required this.index, required this.name, required this.file});
}


class Global  extends ChangeNotifier{
  static late AppLocalizations l10n;
  //网络客户端对象
  static late DhtClient dhtClient;
  //用户名，显示用
  static late String username;

  static late MyAppSettings settings;

  static late User _user;

  static get user => _user;

  static late Talker _talker;
  static get talker =>_talker;

  static late BuildContext _context;
  static get context =>_context;
  static late FlutterSecureStorage _secureStorage;
  static final player = AudioPlayer();
  static List<NewMessageyAudio> _newMessageAudios = [
    NewMessageyAudio(index: 0, name: 'Game Notification', file: 'mixkit-retro-game-notification-212.wav'),
    NewMessageyAudio(index: 1, name: 'Game Over', file: 'mixkit-arcade-retro-game-over-213.wav'),
    NewMessageyAudio(index: 2, name: 'Trombone', file: 'mixkit-sad-game-over-trombone-471.wav'),
    NewMessageyAudio(index: 3, name: 'Alarm', file: 'mixkit-classic-alarm-995.wav'),
    NewMessageyAudio(index: 4, name: 'Dog barking', file: 'mixkit-dog-barking-twice-1.wav'),
    NewMessageyAudio(index: 5, name: 'tick-tock', file: 'mixkit-tick-tock-clock-timer-1045.wav'),
    NewMessageyAudio(index: 6, name: 'telephone-ringtone', file: 'mixkit-vintage-telephone-ringtone-1356.wav'),
  ];
  static get newMessageAudios => _newMessageAudios;


  static Future init(Talker k) async {

    _talker = k;
    dhtClient = new DhtClient();
    await dhtClient.init();

    //以下sql会在表创建后执行
    //dhtClient.exeSql("DROP TABLE conversation");
    //dhtClient.exeSql("DROP TABLE conversation_users");
    //dhtClient.exeSql("ALTER TABLE conversation ADD COLUMN uuid CHAR(36)");
    //dhtClient.exeSql("DROP TABLE messages");
    //dhtClient.exeSql("ALTER TABLE friendlist RENAME COLUMN peer_checked TO friendType;");

    setupAudioContext();
    AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );
    _secureStorage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    username = "";
  }

  static setUsername(String name) async
  {
    await _secureStorage.write(key: "loginuser", value: name);
    dhtClient.changeNickName(name);
    settings.notifyChanged();
  }

  static Future<String?> getUsername() async
  {
    String? value = await _secureStorage.read(key: "loginuser");
    return value;
  }

  static setPassword(String pwd) async
  {
    await _secureStorage.write(key: "loginpwd", value: pwd);
  }

  static Future<String?> getPassword() async
  {
    String? value = await _secureStorage.read(key: "loginpwd");
    return value;
  }

  static setSuperPassword(String pwd) async
  {
    await _secureStorage.write(key: "superpwd", value: pwd);
  }

  static Future<String?> getSuperPassword() async
  {
    String? value = await _secureStorage.read(key: "superpwd");
    return value;
  }

  static setContext(BuildContext context)
  {
    _context = context;
    settings = Provider.of<MyAppSettings>(context);
  }

  static void setCurrUser(User user)
  {
    _user = user;
  }

  //key: 联系人姓名中包含的关键字，为空的话，返回所有人
  static Future<List<Contact>> getContacts({ContactType ftype = ContactType.approved, String key = ""}) async
  {
     return dhtClient.getContacts(ftype: ftype, key: key);
  }

  static int  getContactsNews()
  {
    return dhtClient.getContacts(ftype: ContactType.pending).length;
  }

  static Future<List<Conversation>> getConversations() async
  {
    return dhtClient.getConversationList();
  }

  static Future<List<Message>> getMessages(int conversationID, int offset, int count) async
  {
    return dhtClient.getMessageList(conversationID,  offset, count);
  }

  static Future<User> login(String username, String password) async
  {
    User user = User();
    bool ret = await Global.dhtClient.login(username, password);
    if(ret)
      {
        String uuid  = dhtClient.get_id();
        user = dhtClient.getUser(uuid);
        user.setLoggedIn(true);
        user.setUserId(uuid);
        setCurrUser(user);
      }

    return user;

  }

  static Future<void> logout() async
  {
     _user.setLoggedIn(false);

  }

  //获取数据目录
  static Future<String> getDataPath() async
  {
    Directory docDir =  await getApplicationDocumentsDirectory();
    return docDir.path;
  }

  //获取数据目录
  static Future<String> getTmpPath() async
  {
     String dataPath = await getDataPath();
    return path.join(dataPath, "tmp");
  }

  //获取语音文件保存目录
  static Future<String> getVoicePath() async
  {
    final now = DateTime.now();
    final yyyy_mm = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    String targetPath = path.join(Global.dhtClient.getUserDataPath(), "Cache", "Audio", yyyy_mm);
    print("[getVoicePath] targetPath: ${targetPath}");
    final myTempFolder = Directory(targetPath);
    await myTempFolder.create(recursive: true);

    return targetPath;
  }

  static String getNewMessageAudio([int index = 0])
  {
    return _newMessageAudios[index].name;
  }

  static int getNewMessageAudioIdx()
  {
    int audioIdx = 0;
    String newMsgAudioIdx = dhtClient.getCfg("newMsgAudio");
    if(newMsgAudioIdx.length != 0)
    {
      audioIdx = Utils.StringToInt(newMsgAudioIdx);
    }
    return audioIdx;
  }

  static Future<void> playNotificationSound([int index = -1]) async {
    print("[Global] playNotificationSound ${index}");
    int idx = 0;
    if(index == -1)
    {
      idx = getNewMessageAudioIdx();
    }else{
      idx = index;
    }
    await player.play(AssetSource("audio/"+_newMessageAudios[idx].file));
  }

  static void setupAudioContext() {
    player.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.notification,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {AVAudioSessionOptions.mixWithOthers},
      ),
    ));
  }

}


class AppStyles {
  static final TitleStyle = TextStyle(
      fontSize: Constants.TitleTextSize,
      color: Global.settings.isDarkMode
          ? AppDarkColors.ButtonArrowColor
          : AppColors.ButtonArrowColor
  );


  static const DesStyle = TextStyle(
    fontSize: Constants.DesTextSize,
    color: AppColors.DesTextColor,
  );

  static const UnreadMsgCountDotStyle = TextStyle(
    fontSize: 12.0,
    color: AppColors.NotifyDotText,
  );

  static const DeviceInfoItemTextStyle = TextStyle(
    fontSize: Constants.DesTextSize,
    color: AppColors.DeviceInfoItemText,
  );

  static const GroupTitleItemTextStyle = TextStyle(
    fontSize: 14.0,
    color: AppColors.ContactGroupTitleText,
  );

  static const IndexLetterBoxTextStyle =
  TextStyle(fontSize: 32.0, color: Colors.white);

  static const HeaderCardTitleTextStyle = TextStyle(
      fontSize: 20.0,
      color: AppColors.HeaderCardTitleText,
      fontWeight: FontWeight.bold);

  static const HeaderCardDesTextStyle = TextStyle(
      fontSize: 14.0,
      color: AppColors.HeaderCardDesText,
      fontWeight: FontWeight.normal);

  static const ButtonDesTextStyle = TextStyle(
      fontSize: 12.0,
      color: AppColors.ButtonDesText,
      fontWeight: FontWeight.bold);

  static const NewTagTextStyle = TextStyle(
      fontSize: Constants.DesTextSize,
      color: Colors.white,
      fontWeight: FontWeight.bold);

  static const ChatBoxTextStyle = TextStyle(
      textBaseline: TextBaseline.alphabetic,
      fontSize: Constants.ContentTextSize,
      color: AppColors.TitleColor);
}

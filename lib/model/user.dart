
import '../global.dart';

class User{
  late String _username = ""; //昵称
  late String _uuid = ""; //hashid/uuid
  late String _avatar = ""; //头像
  late int _sex = 0; //性别
  late int _age = 0; //年龄
  late int _id = 0; //
  late String _slogan = ""; //签名

  int _addMeMode = -1;
  bool _login = false;

  get username => _username;
  get uuid => _uuid;
  get loggedIn => _login;
  get avatar => _avatar;
  get sex => _sex;
  get slogan => _slogan;
  get addMeMode => _addMeMode;

  void setLoggedIn(bool val)
  {
    _login = val;
  }
  void setUsername(String name)
  {
    _username = name;
  }

  void setUserId(String hashid)
  {
    _uuid = hashid;
  }

  void setAvatar(String avatar)
  {
    _avatar = avatar;
    Global.dhtClient.setAvatar(avatar);
    Global.settings.notifyChanged();
  }

  void setSex(int val)
  {
    _sex = val;
    Global.dhtClient.setSex(val);
    Global.settings.notifyChanged();
  }

  void setSlogan(String txt)
  {
    _slogan = txt;
    Global.dhtClient.setSlogan(txt);
    Global.settings.notifyChanged();
  }
  void setAddMeMode(int val)
  {
    _addMeMode = val;
  }

  String toString()
  {
    return 'User(username: $_username, uuid: $_uuid, avatar: $_avatar, sex: $_sex, age: $_age, id: $_id, _login: $_login)';
  }

}


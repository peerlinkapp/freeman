import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

// ignore_for_file: constant_identifier_names

late final PackageInfo kPackageInfo;
const APP_NAME = 'FreeMan';
final kAppIcon =
    Image.asset('assets/images/app_icon.png', height: 64.0, width: 64.0);
const GITHUB_URL = 'https://github.com/peerlinkapp/peerlink';
const AUTHOR_SITE = 'https://github.com/peerlinkapp';
const APPSTORE_URL =
    'https://apps.apple.com/in/app/peerlinkapp';

final kPlatformType = getCurrentPlatformType();
// Whether the app is running on mobile phones (Android/iOS)
final kIsOnMobile =
    {PlatformType.Android, PlatformType.iOS}.contains(kPlatformType);

final kIsMobileOrWeb = kIsWeb ||
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.android;

final kAnalytics = null;

/// ! Adapted from https://www.flutterclutter.dev/flutter/tutorials/how-to-detect-what-platform-a-flutter-app-is-running-on/2020/127/
enum PlatformType { Web, iOS, Android, MacOS, Fuchsia, Linux, Windows, Unknown }

PlatformType getCurrentPlatformType() {
  // ! `Platform` is not available on web, so we must check web first.
  if (kIsWeb) {
    return PlatformType.Web;
  }

  if (Platform.isMacOS) {
    return PlatformType.MacOS;
  }

  if (Platform.isFuchsia) {
    return PlatformType.Fuchsia;
  }

  if (Platform.isLinux) {
    return PlatformType.Linux;
  }

  if (Platform.isWindows) {
    return PlatformType.Windows;
  }

  if (Platform.isIOS) {
    return PlatformType.iOS;
  }

  if (Platform.isAndroid) {
    return PlatformType.Android;
  }

  return PlatformType.Unknown;
}

const mainLineWidth = 0.3;



const defIcon = 'assets/images/def_avatar.jpeg';
const lostIcon = 'assets/images/xymemo-icon.png';

const defButtonIconWidth = 37.0;
const defButtonIconHeight = 37.0;
const mainSpace = 10.0;

const mainLabelColor = Color.fromRGBO(0, 0, 0, 1.0);
const mainLabelFontSize = 17.0;
const mainTextColor = Color.fromRGBO(115, 115, 115, 1.0);

const lineColor = Colors.grey;

const contactAssets = 'assets/images/contact/';

const INDEX_BAR_WORDS = [
  "↑",
  "☆",
  "A",
  "B",
  "C",
  "D",
  "E",
  "F",
  "G",
  "H",
  "I",
  "J",
  "K",
  "L",
  "M",
  "N",
  "O",
  "P",
  "Q",
  "R",
  "S",
  "T",
  "U",
  "V",
  "W",
  "X",
  "Y",
  "Z",
  "#",
];

const appBarColor = Colors.blueGrey;
const appBarColorDark = Color.fromRGBO(18, 18, 18, 1);
const btTextColor = Color.fromRGBO(112, 113, 135, 1.0);
const itemBgColor = Color.fromRGBO(75, 75, 75, 1.0);


class AppColors {
  static const PrimaryColor = Color(0xFF607D8B);
  static const SecondColor = Color(0xffebebeb);
  static const BackgroundColor = Color(0xffededed);
  static const MainTextColor = Color(0xff777777);
  static const MainTextColor2 = Color(0xffababab);
  static const HighLightColor = Color(0xffffffff);
  static const AppBarColor = Color(0xFF607D8B);
  static const ActionIconColor = Color(0xff000000);
  static const ActionMenuBgColor = Color(0xff4c4c4c);
  static const CardBgColor = Color(0xff606062);
  static const TabIconNormal = Color(0xff999999);
  static const TabIconActive = Color(0xff46c11b);
  static const TabItemBgColor = Color(0xffffffff);
  static const AppBarPopupMenuColor = Color(0xffffffff);
  static const TitleColor = Color(0xff181818);
  static const ConversationItemBg = Color(0xffffffff);
  static const DesTextColor = Color(0xff999999);
  static const NotifyDotBg = Color(0xfff85351);
  static const NotifyDotText = Color(0xffffffff);
  static const ConversationMuteIcon = Color(0xffd8d8d8);
  static const DeviceInfoItemBg = AppBarColor;
  static const DeviceInfoItemText = Color(0xff606062);
  static const DeviceInfoItemIcon = Color(0xff606062);
  static const ContactGroupTitleBg = Color(0xffebebeb);
  static const ContactGroupTitleText = Color(0xff888888);
  static const IndexLetterBoxBg = Colors.black45;
  static const HeaderCardBg = Colors.white;
  static const HeaderCardTitleText = Color(0xff353535);
  static const HeaderCardDesText = Color(0xff7f7f7f);
  static const ButtonDesText = Color(0xff8c8c8c);
  static const ButtonArrowColor = Color(0xffadadad);
  static const NewTagBg = Color(0xfffa5251);
  static const ChatBoxBg = Color(0xfff7f7f7);
  static const ChatBoxCursorColor = Color(0xff07c160);
  static const MsgMeBgColor = Color(0xff98E165);
  static const MsgOthersBgColor = Color(0xfffefefe);
  static const ListItemBg = Color(0xfff5f5f5);
  static const QrEmbeddedImgColor = Color(0x11000000);
  static const TestRed = Color(0xffff0000);
}

class AppDarkColors {
  static const PrimaryColor = Color(0xffebebeb);
  static const SecondColor = Color(0xff343434);
  static const BackgroundColor = Color(0xff242424);
  static const MainTextColor = Color(0xffababab);
  static const MainTextColor2 = Color(0xff9a9a9a);
  static const HighLightColor = Color(0xff9a9a9a);
  static const AppBarColor = Color(0xff343434);
  static const ActionIconColor = Color(0xffababab);
  static const ActionMenuBgColor = Color(0xff222222);
  static const CardBgColor = Color(0xff858585);
  static const TabIconNormal = Color(0xff999999);
  static const TabIconActive = Color(0xff46c11b);
  static const TabItemBgColor = Color(0xffffffff);
  static const AppBarPopupMenuColor = Color(0xffffffff);
  static const TitleColor = Color(0xff181818);
  static const ConversationItemBg = Color(0xffffffff);
  static const DesTextColor = Color(0xff999999);
  static const NotifyDotBg = Color(0xfff85351);
  static const NotifyDotText = Color(0xffffffff);
  static const ConversationMuteIcon = Color(0xffd8d8d8);
  static const DeviceInfoItemBg = AppBarColor;
  static const DeviceInfoItemText = Color(0xff606062);
  static const DeviceInfoItemIcon = Color(0xff606062);
  static const ContactGroupTitleBg = Color(0xff343434);
  static const ContactGroupTitleText = Color(0xff888888);
  static const IndexLetterBoxBg = Colors.black45;
  static const HeaderCardBg = Colors.white;
  static const HeaderCardTitleText = Color(0xff353535);
  static const HeaderCardDesText = Color(0xff7f7f7f);
  static const ButtonDesText = Color(0xff8c8c8c);
  static const ButtonArrowColor = Color(0xffadadad);
  static const NewTagBg = Color(0xfffa5251);
  static const ChatBoxBg = Color(0xff222222);
  static const ChatBoxCursorColor = Color(0xff07c160);
  static const MsgMeBgColor = Color(0xff98E165);
  static const MsgOthersBgColor = Color(0xff343434);
  static const ListItemBg = Color(0xff343434);
  static const QrEmbeddedImgColor = Color(0x119a9a9a);
  static const TestRed = Color(0xffff0000);
}

class Constants {
  static const IconFontFamily = "appIconFont";
  static const ActionIconSize = 20.0;
  static const ActionIconSizeLarge = 32.0;
  static const AvatarRadius = 4.0;
  static const ConversationAvatarSize = 48.0;
  static const DividerWidth = 0.2;
  static const ConversationMuteIconSize = 18.0;
  static const ContactAvatarSize = 42.0;
  static const TitleTextSize = 16.0;
  static const ContentTextSize = 20.0;
  static const DesTextSize = 13.0;
  static const IndexBarWidth = 24.0;
  static const IndexLetterBoxSize = 64.0;
  static const IndexLetterBoxRadius = 4.0;
  static const FullWidthIconButtonIconSize = 25.0;
  static const ChatBoxHeight = 48.0;

  static const String MENU_MARK_AS_UNREAD = 'MENU_MARK_AS_UNREAD';
  static const String MENU_MARK_AS_UNREAD_VALUE = '标为未读';
  static const String MENU_PIN_TO_TOP = 'MENU_PIN_TO_TOP';
  static const String MENU_PIN_TO_TOP_VALUE = '置顶聊天';
  static const String MENU_DELETE_CONVERSATION = 'MENU_DELETE_CONVERSATION';
  static const String MENU_DELETE_CONVERSATION_VALUE = '删除该聊天';
  static const String MENU_PIN_PA_TO_TOP = 'MENU_PIN_PA_TO_TOP';
  static const String MENU_PIN_PA_TO_TOP_VALUE = '置顶公众号';
  static const String MENU_UNSUBSCRIBE = 'MENU_UNSUBSCRIBE';
  static const String MENU_UNSUBSCRIBE_VALUE = '取消关注';
}

class Keys {
  static final String currentLanguageCode = "current_language_code";
  static final String currentLanguage = "current_language";
  static final String appName = "app_name";
  static final String account = "account";
  static final String password = "password";
  static final String hasLogged = "hasLogged";
  static final String area = "area";
  static final String contacts = "contacts";
  static final String brokenNetwork = "brokenNetwork";
  static final String faceUrl = 'faceUrl';
  static final String nickName = 'nickName';
  static final String gender = 'gender';
}


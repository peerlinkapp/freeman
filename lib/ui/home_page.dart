import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freeman/ui/app_setting_page.dart';
import 'package:freeman/ui/chatlist/chatlist.dart';
import 'package:freeman/ui/chatdetail/group_create.dart';
import 'package:freeman/ui/friends/contacts_page.dart';
import 'package:freeman/common.dart';
import 'package:freeman/ui/my/my_avatar.dart';
import 'package:freeman/ui/my/my_index.dart';
import 'package:freeman/ui/my/my_profile.dart';
import 'package:get/get.dart';
import '../global.dart';
import '../constants.dart';
import 'about.dart';
import 'logger_viewer.dart';
import 'login.dart';
import 'my_app_routes.dart';
import '../my_app_settings.dart';
import 'my_route.dart';
import 'posts/markdown_editor.dart';

import 'search_delegate.dart';
import 'package:english_words/english_words.dart' as english_words;

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:freeman/l10n/l10n.dart'; //引入国际化多语言本地化类
import 'package:freeman/ui/friends/add_friend_page.dart';
import 'package:freeman/ui/discover/discover_main.dart';
import 'app_setting_page.dart';


class UserHomePage extends ConsumerStatefulWidget {
  const UserHomePage({super.key});

  @override
  _UserHomePageState createState() => _UserHomePageState();
}


class _UserHomePageState extends ConsumerState<UserHomePage> {
  late AppLocalizations _l10n;

  final List<String> kEnglishWords;
  late MySearchDelegate _delegate;

  _UserHomePageState()
      : kEnglishWords = List.from(Set.from(english_words.all))
    ..sort(
          (w1, w2) => w1.toLowerCase().compareTo(w2.toLowerCase()),
    ),
        super();

  int getContactNews()
  {
    return Global.getContactsNews();
  }

  //底部导航条
  List<BottomNavigationBarItem> get _bottmonNavBarItems {
    final newBasic = nNewRoutes(kMyAppRoutesBasic);
    final newAdvanced = getContactNews();
    final newInaction = nNewRoutes(kMyAppRoutesBasic);
    return <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        backgroundColor: Colors.blue,
        icon: Badge(
            label: Text(newBasic.toString()),
            isLabelVisible: newBasic > 0,
            child: Icon(Icons.chat_outlined)),
        label: _l10n.tab_msg,
      ),
      BottomNavigationBarItem(
        backgroundColor: Colors.blueAccent,
        icon: Badge(
            label: Text(newAdvanced.toString()),
            isLabelVisible: newAdvanced > 0,
            child: Icon(Icons.contacts_outlined)),
        label: _l10n.tab_contacts,
      ),
      BottomNavigationBarItem(
        backgroundColor: Colors.blueAccent,
        icon: Badge(
            label: Text(newInaction.toString()),
            isLabelVisible: newInaction > 0,
            child: Icon(Icons.explore_outlined)),
        label: _l10n.tab_more,
      ),
      BottomNavigationBarItem(
        backgroundColor: Colors.indigo,
        icon: Icon(Icons.account_circle_outlined),
        label: _l10n.tab_profile,
      ),
    ];
  }

  // !Adding scroll controllers to avoid errors like:
  // !"The provided ScrollController is currently attached to more than one ScrollPosition."
  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  final ScrollController _scrollController3 = ScrollController();
  final ScrollController _scrollController4 = ScrollController();

  @override
  void initState() {
    super.initState();
    //! Show intro screen if it's never shown before.
    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        final settings = ref.read(mySettingsProvider);
      },
    );

    _delegate = MySearchDelegate(kEnglishWords);
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();
    _scrollController4.dispose();
    super.dispose();
  }

  void actionsHandle(String v) {
    if (v == Global.l10n.add_friend) {
      Get.to<void>(AddFriendPage());
    } else if (v == Global.l10n.launch_topic) {
      Conversation topic = Conversation(id:0, showName:'', announcement:'', members: []);
      Get.to<void>(TopicDetailPage(topic: topic));
    } else if (v == Global.l10n.popmenu_add_post) {
      Get.to<void>(MarkdownEditorPage());
    } else {
      //Get.to<void>(LanguagePage());
    }
  }

  void _logout()
  {
    Global.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
  //每个tab页中的路由页面
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Global.l10n = l10n;
    _l10n = l10n;

    final chatWidget = new  ChatListPage();
    final contactsWidget = new  ContactsPage();
    final discoverPage = new  DiscoverPage();
    //final myZone = new MyIndexPage();
    final myZone = new MyProfilePage();

    final bookmarkAndAboutDemos = <Widget>[
      for (final MyRoute route in ref.watch(mySettingsProvider).starredRoutes)
        _myRouteToListTile(route, leading: const Icon(Icons.bookmark)),
      //_myRouteToListTile(kAboutRoute, leading: const Icon(Icons.info)),
    ];

    final List<Map<String, String>> actions = [
      {"title": Global.l10n.launch_topic, 'icon': 'assets/images/contacts_add_newmessage.png'},
      {"title": Global.l10n.add_friend, 'icon': 'assets/images/ic_add_friend.webp'},
      {"title": Global.l10n.popmenu_add_post, 'icon':'assets/images/contacts_add_newmessage.png'},
    ];

    var appBar = ComMomBar(
      title: _bottmonNavBarItems[ref.read(mySettingsProvider).currentTabIdx].label ?? "",
      showShadow: false,
       backgroundColor: ref.watch(mySettingsProvider).isDarkMode? appBarColorDark : appBarColor,
      rightDMActions: <Widget>[

        //搜索图标
        InkWell(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            width: 22.0,
            child: Image.asset(ref.watch(mySettingsProvider).isDarkMode? 'assets/images/search_white.png': 'assets/images/search_white.png'),
          ),
          onTap: () async {
              final String? selected = await showSearch<String>(
              context: context,
              delegate: _delegate,
              );
              if (context.mounted && selected != null) {
                String result = selected.substring(1, selected.length - 1);
                print("onPress select:${result}");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('selected who: $result'),
                  ),
                );



              }

          },
        ),

        //添加图标
        WPopupMenu(
          menuWidth: Get.width / 1.4,
          menuHeight: 190,
          alignment: Alignment.center,
          onValueChanged: (String value) {
            if (value.isEmpty) return;
            actionsHandle(value);
          },
          actions: actions,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            child: Image.asset('assets/images/add_addressicon.png',
                color: ref.watch(mySettingsProvider).isDarkMode? Colors.white: Colors.white, width: 22.0, fit: BoxFit.fitWidth),
          ),
        )
      ],
    );

    String  uuid = Global.dhtClient.getInviteCode();
    uuid = uuid.substring(0, 19)+"..."+uuid.substring(26);
    var drawerHeader = UserAccountsDrawerHeader(
      accountName: Text(Global.user.username),
      accountEmail: Text(uuid),
      decoration: BoxDecoration(
        color: Colors.blueGrey, // 你要的背景色
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: MyLogo.getCircleAvatar(),
      ),
      otherAccountsPictures: <Widget>[
      ],
    );

    //抽屉菜单项
    final drawerItems = ListView(
      children: <Widget>[

        //设置
        ListTile(
          leading:  Icon(Icons.display_settings_outlined, size: 16, color: Colors.grey),
          title: Text(Global.l10n.drawer_menu_settings),
          onTap: () {
            Get.to<void>(AppSettingPage());
          },
        ),

        //日志菜单
        ListTile(
          leading:  Icon(Icons.event_note_outlined, size: 16, color: Colors.grey),
          title: Text(Global.l10n.drawer_menu_logviewer),
          onTap: () {
            Get.to<void>(LoggerViewer());
          },
        ),

        //关于菜单
        ListTile(
          leading:  Icon(Icons.info_outline, size: 16, color: Colors.grey),
          title: Text(Global.l10n.drawer_menu_about),
          onTap: () {
            Get.to<void>(MyAboutRoute());
          },
        ),

        //退出菜单
        ListTile(
          leading:  Icon(Icons.logout, size: 16, color: Colors.grey),
          title: Text(Global.l10n.drawer_menu_exit),
          onTap: () {
            _logout();
          },
        ),

      ],
    );

    return WillPopScope(
      onWillPop: () async {
        print("[UserHomePage]................onWillPop");
        await AndroidUtils.minimizeApp(); // 最小化到后台
        return false; // 拦截退出
      },
      child: Scaffold(
          appBar: appBar,
          body: IndexedStack(
            index: ref.watch(mySettingsProvider).currentTabIdx,
            children: <Widget>[
              chatWidget,
              contactsWidget,
              discoverPage,
              myZone
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: _bottmonNavBarItems,
            currentIndex: ref.watch(mySettingsProvider).currentTabIdx,
            type: BottomNavigationBarType.fixed,
            onTap: (int index) {
              ref.read(mySettingsProvider).currentTabIdx = index;
            },
            showSelectedLabels: true, // 选中时显示文字
            showUnselectedLabels: true, // 未选中时也显示文字
            selectedItemColor: Colors.blueGrey, // 选中颜色
            unselectedItemColor: Colors.grey, // 未选中颜色
          ),
          //抽屉组件
          drawer: Drawer(
            child: Column(
              children: [
                drawerHeader,

                // 中间的菜单项，使用 Expanded + ListView 包裹
                Expanded(
                  child: drawerItems,
                ),

                // 固定在底部的菜单项
                ListTile(
                  onTap: () {},
                  leading: ref.watch(mySettingsProvider).isDhtConnected ? Icon(Icons.cloud_done_outlined) : Icon(Icons.cloud_off_outlined),
                  title: Text('${Global.l10n.app_net_status}:  ${ref.watch(mySettingsProvider).isDhtConnected ? Global.l10n.connect_on : Global.l10n.connect_off}'),
                  //trailing: ref.watch(mySettingsProvider).isDhtConnected ? Icon(Icons.cloud_done_outlined) : Icon(Icons.cloud_off_outlined),
                ),
                ListTile(
                  onTap: () {},
                  leading: DayNightSwitcherIcon(
                    isDarkModeEnabled: ref.watch(mySettingsProvider).isDarkMode,
                    onStateChanged: (_) {},
                  ),
                  title: Text('${Global.l10n.drawer_menu_darkmode}:  ${ref.watch(mySettingsProvider).isDarkMode ? Global.l10n.switch_on : Global.l10n.switch_off}'),
                  trailing: DayNightSwitcher(
                    isDarkModeEnabled: ref.watch(mySettingsProvider).isDarkMode,
                    onStateChanged: (bool value) => ref.watch(mySettingsProvider).setDarkMode(value),
                  ),
                )
              ],
            ),
          )

      ),
    );

  }

  Widget _myRouteToListTile(MyRoute myRoute,
      {Widget? leading, IconData trialing = Icons.keyboard_arrow_right}) {
    final mySettings = ref.watch(mySettingsProvider);
    final routeTitleTextStyle = Theme.of(context)
        .textTheme
        .bodyMedium!
        .copyWith(fontWeight: FontWeight.bold);
    final leadingWidget =
        leading ?? mySettings.starStatusOfRoute(myRoute.routeName);
    final isNew = mySettings.isNewRoute(myRoute);
    return ListTile(
      leading: isNew
          ? Badge(
        alignment: AlignmentDirectional.topEnd,
        child: leadingWidget,
      )
          : leadingWidget,
      title: Text(myRoute.title, style: routeTitleTextStyle),
      trailing: Icon(trialing),
      subtitle: myRoute.description.isEmpty ? null : Text(myRoute.description),
      onTap: () {
        if (isNew) {
          mySettings.markRouteKnown(myRoute);
        }
        kAnalytics?.logEvent(
          name: 'evt_openRoute',
          parameters: {'routeName': myRoute.routeName},
        );
        Navigator.of(context).pushNamed(myRoute.routeName);
      },
    );
  }

  Widget _myRouteGroupToExpansionTile(MyRouteGroup myRouteGroup) {
    final nNew = ref.watch(mySettingsProvider).numNewRoutes(myRouteGroup);
    return Card(
      key: ValueKey(myRouteGroup.groupName),
      child: ExpansionTile(
        leading: nNew > 0
            ? Badge(label: Text('$nNew'), child: myRouteGroup.icon)
            : myRouteGroup.icon,
        title: Text(
          myRouteGroup.groupName,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        children: myRouteGroup.routes.map(_myRouteToListTile).toList(),
      ),
    );
  }

  int nNewRoutes(List<MyRouteGroup> routeGroups) {
    int res = 0;
    for (final group in routeGroups) {
      res += ref.watch(mySettingsProvider).numNewRoutes(group);
    }
    return res;
  }
}

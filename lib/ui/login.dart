
import 'dart:async';
import 'dart:convert';

import 'package:device_preview/device_preview.dart';
import 'package:device_preview_screenshot/device_preview_screenshot.dart';
import 'package:flutter/foundation.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:freeman/common/ui.dart';
import 'package:freeman/l10n/l10n.dart'; //引入国际化多语言本地化类
import 'package:freeman/dhtclient.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'package:freeman/ui/register.dart';
import '../global.dart';

import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:freeman/common.dart';

import '../constants.dart';
import '../model/user.dart';
import 'home_page.dart';
import '../my_app_settings.dart';


import 'my_app_routes.dart' show kAppRoutingTable;
import 'themes.dart';
import '../my_main_app.dart';


class LoginPage extends ConsumerStatefulWidget {

  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool showPassword = false;
  String? _password;
  TextEditingController? _usernameController;

  // 保存从 API 获取到的数据
  String data = '';

  Future<bool> autoLogin() async
  {
    if(Global.settings.isAccountExist && Global.settings.loginMode == 0)
    {

      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    // 请求权限
    requestPermissions();
    //fetchData();

    // 在Widget渲染完成后执行
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      if(await autoLogin()) {
        _password = await Global.getPassword();
        _formSubmitted();
      }
      String? u = await Global.getUsername();
      //print("IsExist:${Global.settings.isAccountExist}, u:${u}");
      //判断是否未注册过，则跳转到注册页
      if(!Global.settings.isAccountExist || Utils.isEmptyStr(await Global.getUsername()) )
      {
        Get.to<void>(RegisterPage());
        /*
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegisterPage()),
        );
         */
      }
    });

  }

  Future<void> requestPermissions() async {
    // 请求位置权限
    var locationStatus = await Permission.locationWhenInUse.status;
    if (!locationStatus.isGranted) {
      await Permission.locationWhenInUse.request();
    }

    // 其他权限请求...
  }

  String? _validateName(String? value) {
    if (value?.isEmpty ?? false) {
      return 'Name is required.';
    }
    return null;
  }

  void _login() async
  {

    String? name = await Global.getUsername() ?? "" ;
    String password = _password ?? '';
    Global.login(name, password).then((user){
      if(user.loggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserHomePage()),
        );
      }else{
        showGlobalToast(Global.l10n.login_fail);
         /* ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Global.l10n.login_fail),
              duration: Duration(milliseconds: 5000),
            ),
          );*/
      }

    });

  }

  @override
  Widget build(BuildContext context) {

    Global.setContext(context);
    final l10n = context.l10n;
    Global.l10n = l10n;

    print("localeName:${l10n.localeName}");

    return Scaffold(
      body: Container(
          padding: const EdgeInsets.all(16.0),
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:   <Widget>[
              Image.asset('assets/images/app_icon.png', height: 64.0, width: 64.0),
                  const SizedBox(height: 80.0),
                  // "password" form.
                  TextFormField(
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: l10n.password_txt,
                      prefixIcon: const Icon(Icons.security),
                      suffixIcon: IconButton(
                          icon: Icon(
                            showPassword ? Icons.visibility : Icons.visibility_off,
                            color: showPassword ? Colors.blue : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() => showPassword = !showPassword);
                          }
                      ),
                    ),
                    onSaved: (String? pwd){
                      if(strNoEmpty(pwd))  _password = pwd;
                    },
                  ),
                  const SizedBox(height: 30.0),

                  //登陆按钮
                  SizedBox(
                    width: double.infinity,  // 使按钮宽度自适应屏幕宽度
                    height: 50,
                    child:  ElevatedButton(
                      onPressed:_formSubmitted,
                      child: Text(true? l10n.btn_login : l10n.btn_register),
                    ),

                  ),

                  const SizedBox(height: 30.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,  // 右对齐
                    children: [

                      // 忘记密码链接
                      TextButton(
                        onPressed: () {
                          // 弹出提示框
                          _showForgotPasswordDialog(context);
                        },
                        child: Text(
                          Global.l10n.forgot_password_txt,  // 在这里使用本地化的文本
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),

                ],
              )
          )
      ),
    );
  }

  Widget customTextField({
    TextEditingController? textEditController,
    String? hintText,
    String? defaultValue,
  }) {
    return TextField(
      controller: textEditController,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintStyle: TextStyle(
          fontSize: 16,
          color: Colors.grey.withOpacity(0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(5.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
      style: TextStyle(
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }


  void _formSubmitted()
  {
    var form = _formKey.currentState;
    if (form!.validate() ?? false ){
      form.save();
    }
    _login();
  }

  // 弹出提示框
  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Global.l10n.forgot_password_txt),
          content: Text(Global.l10n.forgot_password_desc),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }
}


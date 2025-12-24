
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:freeman/common.dart';
import 'package:freeman/l10n/l10n.dart'; //引入国际化多语言本地化类
import 'package:freeman/dhtclient.dart';
import 'package:freeman/global.dart';



import '../constants.dart';


class RegisterPage extends StatefulWidget {

  const RegisterPage({super.key});


  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool showPassword = false;
  late String _name;
  late String _password;
  late String _passwordSupper;

  String? _validateName(String? value) {
    if (value?.isEmpty ?? false) {
      return 'Name is required.';
    }
    return null;
  }

  void _formSubmitted()
  {
    var form = _formKey.currentState;
    if (form!.validate() ?? false ){
      form.save();
    }

    Global.dhtClient.regist(_name, _password).then((ok){
      if(ok) {
        Global.setUsername(_name);
        Global.setPassword(_password);
        Global.setSuperPassword(_passwordSupper);
        Global.settings.setAccountExist(true);

        showGlobalToast(Global.l10n.regist_ok);
        Navigator.pop(context);
      }else{
        showGlobalToast(Global.l10n.regist_fail);
      }

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 不显示返回按钮
        elevation: 0,  // 设置为 0 来去除阴影
        backgroundColor: Global.settings.isDarkMode ? AppDarkColors.ButtonArrowColor : AppColors.ButtonArrowColor,

      ),
      body: Container(
          padding: const EdgeInsets.all(16.0),
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:   <Widget>[

                  kAppIcon,
                  const SizedBox(height: 12.0),
                  // "Name" form.
                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      prefixIcon: const Icon(Icons.person),
                      hintText: Global.l10n.nick_name_hint,
                      labelText: Global.l10n.nick_name_txt,
                    ),
                    onSaved: (String? value) {
                      _name = value ?? "";
                    },
                    validator: _validateName,
                  ),
                  const SizedBox(height: 24.0),

                  TextFormField(
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: Global.l10n.password_txt,
                      prefixIcon: const Icon(Icons.security),
                      suffixIcon: IconButton(
                          icon: Icon(
                            Icons.remove_red_eye,
                            color: showPassword ? Colors.blue : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() => showPassword = !showPassword);
                          }
                      ),
                    ),
                    onSaved: (String? pwd){
                      _password = pwd ?? "";
                    },
                  ),
                  const SizedBox(height: 24.0),

                  TextFormField(
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: Global.l10n.password_super_txt,
                      prefixIcon: const Icon(Icons.security),
                      suffixIcon: IconButton(
                          icon: Icon(
                            Icons.remove_red_eye,
                            color: showPassword ? Colors.blue : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() => showPassword = !showPassword);
                          }
                      ),
                    ),
                    onSaved: (String? pwd){
                      _passwordSupper = pwd ?? "";
                    },
                  ),
                  const SizedBox(height: 24.0),

                  SizedBox(
                    width: double.infinity,  // 使按钮宽度自适应屏幕宽度
                    height: 50,
                    child:  ElevatedButton(
                      onPressed:_formSubmitted,
                      child: Text(Global.l10n.btn_register),
                    ),

                  ),

                  const SizedBox(height: 24.0),

                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                      children: <TextSpan>[
                        TextSpan(text: '• ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                          text: Global.l10n.reg_page_tip1,
                        ),
                        TextSpan(text: '• ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                          text: Global.l10n.reg_page_tip2,
                        ),
                        TextSpan(text: '• ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                          text: Global.l10n.reg_page_tip3,
                        ),
                      ],
                    ),
                  ),

                ],
              )
          )


      ),
    );
  }

}
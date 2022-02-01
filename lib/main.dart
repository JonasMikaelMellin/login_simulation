import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:login_simulation/admin/adminDemoMgmtScreen.dart';
import 'package:login_simulation/database/whedcappStandalone.dart';
import 'package:login_simulation/participant/participantScreen.dart';
import 'package:login_simulation/common/welcomeScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin/adminChangePasswordScreen.dart';
import 'admin/adminCrudUserScreen.dart';
import 'admin/adminDatabaseMgmtScreen.dart';
import 'admin/adminScreen.dart';
import 'admin/adminUserMgmtScreen.dart';
import 'common/defaultAppbar.dart';
import 'config/colorConfigurationArg.dart';
import 'config/colorConfigurationScreen.dart';
import 'data.dart';
import 'dataSpecification.dart';
import 'common/diagram.dart';
import 'database/whedcappStandalone.dart';
import 'database/whedcappStandalone.dart';
import 'participant/editDataNotes.dart';
import 'participant/enterValue.dart';
import 'myApp.dart';
import 'common/navDrawer.dart';

void main() async {
  var result = initWhedcappStandaloneDatabase();
  result.then((v) => runApp(MyApp()));
}


Map<Role, int> r2i = {
  Role.none: -1,
  Role.participant: 0,
  Role.administrator: 2,
  Role.projectOwner: 1
};
Map<int, Role> i2r = Map.fromIterable(r2i.entries,
    key: (e) => e.value, value: (e) => e.key); // inverse
Role maxRole(List<Role> lor) {
  int maxPri = -1;
  for (var r in lor) {
    maxPri = max(maxPri, r2i[r]!);
  }
  return i2r[maxPri]!;
}

String role2path(Role role) {
  return "/" + role.toString().split('.').last;
}

class Token {
  Digest digest;
  late DateTime timestamp;

  Token({required this.digest}) {
    this.timestamp = DateTime.now();
  }
}

class NoSuchAliasException implements Exception {}

class Auth {
  static Map<String, User> _u2u = {
    'part': User(alias: 'part', password: 'part', roles: [Role.participant]),
    'part@w.o': User(
        alias: 'part@w.o', password: 'papassword', roles: [Role.participant]),
    'adm@w.o': User(
        alias: 'adm@w.o',
        //password: '991b7e64f7f4a49d9b15e92d255effcde73626b730971cb83c93824dce7bd868efa56cfcc566c8a26c3b28c84eea4868b1506b18057860b4b4c6039c9e8893b6',
        password: 'adpassword',
        roles: [Role.administrator, Role.projectOwner]),
    'proj@w.o': User(
        alias: 'proj@w.o', password: 'prpassword', roles: [Role.projectOwner]),
  };
  static Map<String, Token> _u2t = {};
  static List<Role> getRoles(final String user) {
    return _u2u[user]!.roles;
  }

  static Future<bool> checkPassword(
      final String alias, final String password) async {
    try {
      var potUser = await getUserInfo(alias);
      if (potUser == null) {
        throw NoSuchAliasException();
      }
      if (!potUser.enabled) {
        return false;
      }
      if (MyApp.demoMode.demoMode) {
        if (alias != 'demo') {
          return false;
        }
      }
      if (sha512.convert(utf8.encode(password)).toString() ==
          potUser!.hashedPassword) {
        return true;
      }
      return false;
    } catch (e) {
      throw NoSuchAliasException();
    }
  }

  static Future<Token> getToken(
      final String alias, final String password) async {
    if (await checkPassword(alias, password)) {
      if (!_u2t.containsKey(alias)) {
        final l = (alias + password).codeUnits;
        _u2t[alias] = Token(digest: sha256.convert(l));
      }
      return _u2t[alias]!;
    }
    throw NoSuchAliasException();
  }
}

class AppLanguage extends ChangeNotifier {
  Locale _appLocale = Locale('en');

  Locale get appLocal => _appLocale;
  fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    var lc = prefs.getString('language_code');
    if (lc == null) {
      _appLocale = Locale('en');
      return Null;
    }
    _appLocale = Locale(lc);
    return Null;
  }

  void changeLanguage(Locale type) async {
    var prefs = await SharedPreferences.getInstance();
    if (_appLocale == type) {
      return;
    }
    if (type == Locale('en')) {
      _appLocale = Locale('en');
      await prefs.setString('language_code', 'en');
      await prefs.setString('countryCode', '');
    } else if (type == Locale('en', 'US')) {
      _appLocale = Locale('en', 'US');
      await prefs.setString('language_code', 'en');
      await prefs.setString('countryCode', 'US');
    } else if (type == Locale('se')) {
      _appLocale = Locale('se');
      await prefs.setString('language_code', 'se');
      await prefs.setString('countryCode', '');
    }
    notifyListeners();
  }
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _LoginStateState createState() => _LoginStateState();
}

class LoginState extends StatefulWidget {
  const LoginState({Key? key}) : super(key: key);

  @override
  _LoginStateState createState() => _LoginStateState();
}

class _LoginStateState extends State<LoginState> {
  final _formKey = GlobalKey<FormState>();
  final _loginTextfieldCtrl = TextEditingController();
  final _passwordTextfieldCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
        appBar: defaultAppBar(context,AppLocalizations.of(context)!.loginTitle),
        body: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildLoginTextField(context),
                  _buildPasswordTextField(context),
                  _buildButtons(context)
                ])));
  }

  Widget _buildLoginTextField(BuildContext context) {
    final RegExp _loginNameRegExp = RegExp(r"^[a-zA-Z][a-zA-Z0-9\.]*$");
    return Padding(
        padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: TextFormField(
            cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
            maxLength: 64,
            maxLines: 1,
            controller: _loginTextfieldCtrl,
            validator: (v) {
              if (v == null || !_loginNameRegExp.hasMatch(v)) {
                return AppLocalizations.of(context)!.loginIdentityHelperText;
              }
              return null;
            },
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.loginIdentityPrompt,
                helperText:
                    AppLocalizations.of(context)!.loginIdentityHelperText,
                enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).dividerColor)))));
  }

  Widget _buildPasswordTextField(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: TextFormField(
            cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
            maxLength: 64,
            maxLines: 1,
            obscureText: true,
            controller: _passwordTextfieldCtrl,
            validator: (v) {
              final Map<int, int> cnt = {};
              v!.runes.forEach((int rune) {
                cnt.putIfAbsent(rune, () {
                  return 0;
                });
                cnt[rune] = cnt[rune]! + 1;
              });

              if (v.length < 0) {
                return AppLocalizations.of(context)!
                    .loginPasswordValidatorErrorMsg;
              }
              return null;
            },
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.loginPasswordPrompt,
                helperText:
                    AppLocalizations.of(context)!.loginPasswordHelperText,
                enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).dividerColor)))));
  }

  Widget _buildButtons(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(AppLocalizations.of(context)!
                        .loginProcessingMsg(_loginTextfieldCtrl.text))));
                try {
                  if (await Auth.checkPassword(
                      _loginTextfieldCtrl.text, _passwordTextfieldCtrl.text)) {
                    MyApp.userInfo =
                        await getUserInfo(_loginTextfieldCtrl.text);
                    var result = Navigator.pushNamed(
                        context,
                        MyApp.userInfo!.admin
                            ? AdminScreen.route
                            : ParticipantScreen.route);
                    result.then((v) {
                      _loginTextfieldCtrl.text = '';
                      _passwordTextfieldCtrl.text = '';
                    });
                  }
                } on NoSuchAliasException {
                  await Future.delayed(Duration(milliseconds: 1000));
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(AppLocalizations.of(context)!
                          .loginFailedMsg(_loginTextfieldCtrl.text))));
                }
              }
            },
            child: Text('OK')));
  }
}





class ProjectOwnerScreen extends StatefulWidget {
  const ProjectOwnerScreen({Key? key}) : super(key: key);

  @override
  _ProjectOwnerScreenState createState() => _ProjectOwnerScreenState();
}

class _ProjectOwnerScreenState extends State<ProjectOwnerScreen> {
  @override
  Widget build(BuildContext context) {
    return _buildProjectOwnerScreen(context);
  }

  Widget _buildProjectOwnerScreen(BuildContext context) {
    return Scaffold(
        drawer: NavDrawer(),
        appBar: AppBar(
          title: Text('Project Owner Screen'),
        ));
  }
}


class MyModel extends ChangeNotifier {
  List<Data> data;
  MyModel(this.data);
}

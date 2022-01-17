import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';
import 'dataSpecification.dart';
import 'diagram.dart';
import 'editDataNotes.dart';
import 'enterValue.dart';
import 'navDrawer.dart';

void main() async {
  runApp(MyApp());
}

class Item {
  const Item(this.language, this.country, this.description);
  String icu_code() {
    return this.language + "_" + this.country;
  }

  final String language;
  final String country;
  final String description;
}

enum Role { none, participant, administrator, projectOwner }

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

class User {
  final String alias;
  final String password;
  final List<Role> roles;
  User({required this.alias, required this.password, required this.roles});
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
    'part': User(
      alias: 'part', password: 'part', roles: [Role.participant]
    ),
    'part@w.o': User(
        alias: 'part@w.o', password: 'papassword', roles: [Role.participant]),
    'adm@w.o': User(
        alias: 'adm@w.o',
        password: 'adpassword',
        roles: [Role.administrator, Role.projectOwner]),
    'proj@w.o': User(
        alias: 'proj@w.o', password: 'prpassword', roles: [Role.projectOwner]),
  };
  static Map<String, Token> _u2t = {};
  static List<Role> getRoles(final String user) {
    return _u2u[user]!.roles;
  }

  static bool checkPassword(final String alias, final String password) {
    try {
      return _u2u[alias]!.password == password;
    } catch (e) {
      throw NoSuchAliasException();
    }
  }

  static Token getToken(final String alias, final String password) {
    if (checkPassword(alias, password)) {
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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state!.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('sv');
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whedcapp Login Demo',
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale!.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      initialRoute: '/',
      routes: {
        //'/': (context) => LoginState(title: 'Whedcapp Login Simulation Start'),
        '/config': (context) => ConfigState(),
        '/administrator': (context) => AdminScreen(),
        '/projectOwner': (context) => ProjectOwnerScreen(),
        '/participant': (context) => ParticipantScreen(),
        EditDataNotesScreen.routeName: (context) => EditDataNotesScreen(),
        AddDataNoteScreen.addDataNoteScreenPath: (context) =>
            AddDataNoteScreen(),
        EnterValue.routeName(Series.Loneliness): (context) => EnterValue(),
        EnterValue.routeName(Series.Safety): (context) => EnterValue(),
        EnterValue.routeName(Series.Wellbeing): (context) => EnterValue(),
        EnterValue.routeName(Series.SenseOfHome): (context) => EnterValue(),
        EnterValue.subsequentRouteName: (context) => EnterValue()
      },
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          textTheme: const TextTheme(
              headline1: TextStyle(fontSize: 36, fontWeight: FontWeight.bold))),
      home: LoginState(),
      //home: LoginState(title: 'Banzai'),
    );
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
        appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.loginTitle),
            actions: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/config');
                      },
                      child: Icon(Icons.settings, size: 26.0)))
            ]),
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
    final RegExp _loginNameRegExp =
        RegExp(r"^[a-zA-Z][a-zA-Z0-9\.]*@[a-zA-Z][a-zA-Z0-9\.]*$");
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

              if (v.length < 6) {
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
                  Token t = Auth.getToken(
                      _loginTextfieldCtrl.text, _passwordTextfieldCtrl.text);
                  Navigator.pushNamed(
                      context,
                      role2path(
                          maxRole(Auth.getRoles(_loginTextfieldCtrl.text))));
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

class ConfigState extends StatefulWidget {
  const ConfigState({Key? key}) : super(key: key);

  @override
  _ConfigStateState createState() => _ConfigStateState();
}

class _ConfigStateState extends State<ConfigState> {
  final _formKey = GlobalKey<FormState>();
  _ConfigStateState() {
    this.selectedLanguage = languages.first;
  }
  late Item selectedLanguage;
  List<Item> languages = <Item>[
    const Item('en', '', 'English'),
    const Item('sv', '', 'Svenska'),
    const Item('en', 'US', 'American English')
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.configurationTitle)),
        body: _buildForm(context));
  }

  Widget _buildForm(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildLanguageSelection(context),
              _buildContentLanguageSelection(context)
            ]));
  }

  Future<void> setLocale(Locale locale) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString('languageCode', locale.languageCode);
  }

  Widget _buildLanguageSelection(BuildContext context) {
    return DropdownButton<Item>(
        hint: Text(
            AppLocalizations.of(context)!.configurationSelectLanguagePrompt),
        onChanged: (Item? value) async {
          if (value!.country != '') {
            setLocale(Locale(value.language, value.country));
            MyApp.setLocale(context, Locale(value.language, value.country));
          } else {
            setLocale(Locale(value.language));
            MyApp.setLocale(context, Locale(value.language));
          }
        },
        items: languages.map((Item lang) {
          return DropdownMenuItem<Item>(
              value: lang,
              child: Row(children: <Widget>[Text(lang.description)]));
        }).toList());
  }

  Widget _buildContentLanguageSelection(BuildContext context) {
    return DropdownButton<Item>(
        hint: Text(AppLocalizations.of(context)!
            .configurationSelectContentLanguagePrompt),
        onChanged: (Item? value) async {
          if (value!.country != '') {
            setLocale(Locale(value.language, value.country));
            MyApp.setLocale(context, Locale(value.language, value.country));
          } else {
            setLocale(Locale(value.language));
            MyApp.setLocale(context, Locale(value.language));
          }
        },
        items: languages.map((Item lang) {
          return DropdownMenuItem<Item>(
              value: lang,
              child: Row(children: <Widget>[Text(lang.description)]));
        }).toList());
  }
}


class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return _buildAdminScreen(context);
  }

  Widget _buildAdminScreen(BuildContext context) {
    return Scaffold(
        drawer: NavDrawer(),
        appBar: AppBar(
          title: Text('Admin Screen'),
          //leading: Icon(Icons.menu),
        ));
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

class ParticipantScreen extends StatefulWidget {
  const ParticipantScreen({Key? key}) : super(key: key);

  @override
  _ParticipantScreenState createState() => _ParticipantScreenState();
}

class _ParticipantScreenState extends State<ParticipantScreen> {
  List<Data> _data0 = [];
  var _data1 = DataList([]);
  double zoomStart = 0.0;
  int count = 0;
  getData1() async {
    var lc = getLanguageCode();
    await Future.delayed(Duration(seconds: 2));
    var r = Random(1);
    lc.then((_lc) {
      List<Data> dataObj = List.generate(
          14,
          (index) => new Data(
                  date: DateTime.now().subtract(Duration(days: 15 - index)),
                  series2datum: {
                    Series.Wellbeing: Datum(
                      value: r.nextInt(10) + 1,
                      information: List.generate(r.nextInt(3),
                          (index2) => 'Kommentar ${index2.toString()}'),
                    ),
                    Series.SenseOfHome: Datum(
                      value: r.nextInt(10) + 1,
                      information: List.generate(r.nextInt(3),
                          (index2) => 'Kommentar ${index2.toString()}'),
                    ),
                    Series.Safety: Datum(
                      value: r.nextInt(10) + 1,
                      information: List.generate(r.nextInt(3),
                          (index2) => 'Kommentar ${index2.toString()}'),
                    ),
                    Series.Loneliness: Datum(
                      value: r.nextInt(10) + 1,
                      information: List.generate(r.nextInt(3),
                          (index2) => 'Kommentar ${index2.toString()}'),
                    )
                  }));

      this.setState(() {
        this._data1.addAll(dataObj);
        int l = this._data0.length;
        if (l > 7) {
          this.zoomStart = 100.0 - 7 * 100 / l;
        } else {
          this.zoomStart = 0.0;
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    this.getData1();
  }

  @override
  Widget build(BuildContext context) {
    return _buildParticipantScreen(context);
  }

  Future<String?> getLanguageCode() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    return _prefs.getString('languageCode');
  }

  dynamic encode(dynamic item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }

  Widget _buildParticipantScreen(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.partScreenTitle),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/config');
                  },
                  child: Icon(Icons.settings, size: 26.0)))
        ],
      ),
      body: Center(
          child: ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: 100, minHeight: 100, maxHeight: 1000),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    MultiProvider(
                        providers: [
                          ChangeNotifierProvider.value(value: this._data1)
                        ],
                        child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minWidth: 100, minHeight: 100, maxHeight: 800),
                            child: Diagram())),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                              child: Text(AppLocalizations.of(context)!
                                  .acceptButtonText),
                              onPressed: () {})
                        ])
                  ]))),
      floatingActionButton: FloatingActionButton(
        onPressed: ()  {
          this.setState(() {
            _navigateToEnterValueSceenAndAddData();
          });
        },
        child: const Icon(Icons.add_circle_sharp),
        backgroundColor: Colors.green,
      ),
    );
  }
  void _navigateToEnterValueSceenAndAddData() async {
    var time = DateTime.now().add(Duration(days:this.count));
    final result =  await Navigator.pushNamed(context, EnterValue.routeName(Series.values[0]),
          arguments: EnterValueArg(currentTime: time, dataList: this._data1,currentSeries: Series.values[0])) as Map<Series,int> ;

        this.setState(()
        {
          var tmp = Map<Series, Datum>();
          Series.values.forEach((s) =>
          tmp[s] = Datum(value: result![s]!, information: List.generate(0,(x)  {return '';})));
          _data1.add(Data(date: time, series2datum: tmp));
          this.count++;
        });
    }
    // Add your onPressed code here!

  }
  // void _navigateToEditDataNoteScreen(Series series) async {
  //   final result = await Navigator.pushNamed(context,EditDataNotesScreen.routeName,arguments: SeriesDataSpec(dataSpec: DataSpec(dataIndex: dataIndex, data: dataList),series: series));
  //   if (result != null) {
  //     this.setState(() =>
  //         dataList[dataIndex].series2datum[series]!.information.add(
  //             result as String));
  //     changed = true;
  //   }
  // }




class MyModel extends ChangeNotifier {
  List<Data> data;
  MyModel(this.data);
}

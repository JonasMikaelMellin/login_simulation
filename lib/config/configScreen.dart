import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import 'colorConfigurationArg.dart';
import 'colorConfigurationScreen.dart';
import '../data.dart';
import '../database/whedcappStandalone.dart';
import '../myApp.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({Key? key}) : super(key: key);
  static WColors wcolors = WColors();

  static const route = '/config';

  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _formKey = GlobalKey<FormState>();

  _ConfigScreenState() {
    this.selectedLanguage = languages.first;
  }
  late Item selectedLanguage;
/*
  static Map<Series,Color> series2color = {
    Series.Loneliness: Color(0x80008837),
    Series.Wellbeing: Color(0x807b3294),
    Series.Safety: Color(0x80c2a5cf),
    Series.SenseOfHome: Color(0x80a6dba0)
  };
*/

  @override
  void initState()  {
    super.initState();
    var result =  colors();
    result.then((obj) {
      var ccList = obj as List<ConfigColor>;
      ccList.forEach((cc) {
        //series2color[cc.series] = Color(cc.color);
        ConfigScreen.wcolors.set(cc.series, Color(cc.color));
      });
    });
  }
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
        body: _buildProvider(context));
  }
  Widget _buildProvider(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: ConfigScreen.wcolors),
          ChangeNotifierProvider.value(value: ConfigScreen.wcolors.series2color[Series.Safety]!),
          ChangeNotifierProvider.value(value: ConfigScreen.wcolors.series2color[Series.Wellbeing]!),
          ChangeNotifierProvider.value(value: ConfigScreen.wcolors.series2color[Series.Loneliness]!),
          ChangeNotifierProvider.value(value: ConfigScreen.wcolors.series2color[Series.SenseOfHome]!),
        ],
        child: _buildForm(context)
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildLanguageSelection(context),
              _buildContentLanguageSelection(context),
              _buildConsumerColorSelection(context,Series.Safety),
              _buildConsumerColorSelection(context,Series.Wellbeing),
              _buildConsumerColorSelection(context,Series.Loneliness),
              _buildConsumerColorSelection(context,Series.SenseOfHome),


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

  _buildConsumerColorSelection(BuildContext context, Series series) {
    return Consumer<WColor>(
        builder: (context,foo,child) {
          return _buildColorSelection(context,series);
        }
    );
  }

  _buildColorSelection(BuildContext context, Series series) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),
            foregroundColor: MaterialStateProperty.all(Colors.black)
        ),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.configurationChooseColor(getSeriesName(context,series))),
              Icon(Icons.circle,color: ConfigScreen.wcolors.series2color[series]!.color),
            ]
        ),
        onPressed: () {
          var result = Navigator.pushNamed(context,ColorConfigurationScreen.route,arguments: ColorConfigurationArgReq(series: series, color: ConfigScreen.wcolors.get(series)!.value));
          result.then((colorConfigurationArgRep) {
            if (colorConfigurationArgRep != null) {
              setState(() {
                //series2color[series] = Color((colorConfigurationArgRep as ColorConfigurationArgRep).color);
                ConfigScreen.wcolors.set(series,Color((colorConfigurationArgRep as ColorConfigurationArgRep).color));
                updateColor(ConfigColor(series: colorConfigurationArgRep.series, color: colorConfigurationArgRep.color));
              });
            }
          });
        }
    );
  }
}

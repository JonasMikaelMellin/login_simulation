/*
This file is part of Whedcapp - standalone.

Whedcapp is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any later version.

Whedcapp is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Foobar. If not, see <https://www.gnu.org/licenses/>.
*/

import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:login_simulation/admin/adminCommentsDatabaseMgmtExtractData.dart';
import 'package:login_simulation/admin/adminCommentsDatabaseMgmtScreen.dart';
import 'package:login_simulation/participant/participantScreen.dart';
import 'package:login_simulation/common/welcomeScreen.dart';

import 'admin/adminChangePasswordScreen.dart';
import 'admin/adminCrudUserScreen.dart';
import 'admin/adminDatabaseMgmtExtractData.dart';
import 'admin/adminDatabaseMgmtScreen.dart';
import 'admin/adminDemoMgmtScreen.dart';
import 'admin/adminScreen.dart';
import 'admin/adminUserMgmtScreen.dart';
import 'config/colorConfigurationScreen.dart';
import 'config/configScreen.dart';
import 'data.dart';
import 'database/userInfo.dart';
import 'database/whedcappStandalone.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'participant/editDataNotes.dart';
import 'participant/enterValue.dart';
import 'main.dart';


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  static UserInfo? userInfo;
  static DemoMode demoMode = DemoMode(false);

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
        '/config': (context) => ConfigScreen(),
        AdminScreen.route: (context) => AdminScreen(),
        ParticipantScreen.route: (context) => ParticipantScreen(),
        EditDataNotesScreen.routeName: (context) => EditDataNotesScreen(),
        AddDataNoteScreen.addDataNoteScreenPath: (context) =>
            AddDataNoteScreen(),
        EnterValue.routeName(Series.Loneliness): (context) => EnterValue(),
        EnterValue.routeName(Series.Safety): (context) => EnterValue(),
        EnterValue.routeName(Series.Wellbeing): (context) => EnterValue(),
        EnterValue.routeName(Series.SenseOfHome): (context) => EnterValue(),
        EnterValue.subsequentRouteName: (context) => EnterValue(),
        AdminScreen.route: (context) => AdminScreen(),
        AdminDatabaseMgmtScreen.route: (context) => AdminDatabaseMgmtScreen(),
        AdminDemoMgmtScreen.route: (context) => AdminDemoMgmtScreen(),
        AdminCrudUserScreen.route: (context) => AdminCrudUserScreen(),
        AdminUserMgmtScreen.route: (context) => AdminUserMgmtScreen(),
        AdminChangePasswordScreen.route: (context) =>
            AdminChangePasswordScreen(),
        WelcomeScreen.route: (context) => WelcomeScreen(),
        ColorConfigurationScreen.route: (context) => ColorConfigurationScreen(),
        AdminDatabaseMgmtExtractData.route: (context) => AdminDatabaseMgmtExtractData(),
        AdminCommentsDatabaseMgmtScreen.route: (context) => AdminCommentsDatabaseMgmtScreen(),
        AdminCommentsDatabaseMgmtExtractData.route: (context) => AdminCommentsDatabaseMgmtExtractData()
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

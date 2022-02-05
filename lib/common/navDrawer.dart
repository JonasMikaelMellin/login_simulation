import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:login_simulation/participant/participantScreen.dart';
import 'package:login_simulation/common/welcomeScreen.dart';
import 'package:provider/provider.dart';

import '../admin/adminScreen.dart';
import '../data.dart';
import '../myApp.dart';
import 'package:login_simulation/config/demo.dart';


class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value:MyApp.demoMode)
      ],
      child: Drawer(
          child: ListView(padding: EdgeInsets.zero, children: <Widget>[
            DrawerHeader(
              child: Text(AppLocalizations.of(context)!.sideMenuTitle,
                  style: TextStyle(color: Colors.white, fontSize: 25)),
              decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage('assets/images/cover.jpg'))),
            ),
            ListTile(
                leading: Icon(Icons.input),
                title: Text(AppLocalizations.of(context)!.welcomeTitle),
                onTap: ()  {
                  Navigator.pushNamed(context,WelcomeScreen.route);
            }),
            Consumer<DemoMode>(
              builder: (context, snarf, child) {
                return
                ListTile(
                    leading: Icon(Icons.accessibility),
                    title: !MyApp.demoMode.demoMode
                        ? Text(
                        AppLocalizations.of(context)!.navDrawerTurnOnDemoMode)
                        : Text(
                        AppLocalizations.of(context)!.navDrawerTurnOffDemoMode),
                    onTap: () {
                      MyApp.demoMode.demoMode = !MyApp.demoMode.demoMode;
                      if (MyApp.demoMode.demoMode) {
                        Demo.initializeDemo();
                      } else {
                        Demo.removeDemo();
                      }
                    }
                );

              }
            ),
            MyApp.userInfo != null && MyApp.userInfo!.admin?ListTile(leading: Icon(Icons.verified_user),title: Text(AppLocalizations.of(context)!.changeToAdminPageText),onTap: () {Navigator.pushNamed(context,AdminScreen.route);}):SizedBox.shrink(),
            MyApp.userInfo != null && MyApp.userInfo!.admin?ListTile(leading: Icon(Icons.verified_user),title: Text(AppLocalizations.of(context)!.changeToParticipantPageText),onTap: () {Navigator.pushNamed(context,ParticipantScreen.route);}):SizedBox.shrink(),
            ListTile(
                leading: Icon(Icons.logout),
                title: Text(AppLocalizations.of(context)!.logoutText),
                onTap: ()  {
                  MyApp.userInfo = null;
                  Navigator.popUntil(context,(r) {return r.isFirst;});
                })
          ])),
    );
  }
}

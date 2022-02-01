import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:login_simulation/common/defaultAppbar.dart';
import 'package:login_simulation/database/whedcappStandalone.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:login_simulation/common/navDrawer.dart';



class AdminDatabaseMgmtExtractData extends StatefulWidget {
  const AdminDatabaseMgmtExtractData({Key? key}) : super(key: key);

  static const route = '/administrator/extractData';
  @override
  _AdminDatabaseMgmtExtractDataState createState() =>
      _AdminDatabaseMgmtExtractDataState();
}

class _AdminDatabaseMgmtExtractDataState
    extends State<AdminDatabaseMgmtExtractData> {
  var fileNameEditingCtrl = TextEditingController();
  var changeNotifier = ChangeNotifier();

  initState() {
    fileNameEditingCtrl.text = 'output.csv';

    getApplicationDocumentsDirectory().then((p) {
      fileNameEditingCtrl.text = join(p.path,'output.csv');
      changeNotifier.notifyListeners();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
        appBar: defaultAppBar(context,
            AppLocalizations.of(context)!.adminDatabaseExtractDataScreenTitle),
        body: _buildProvider(context));
  }

  _buildProvider(context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: changeNotifier)
      ],
      child: _buildBody(context)
    );
  }

  _buildBody(context) {
    return Column(children: [
      Consumer<ChangeNotifier>(
        builder: (context, snarf, child) {
          return TextFormField(
              cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
              maxLength: 64,
              maxLines: 1,
              controller: fileNameEditingCtrl,
              validator: (v) {
                if (v == null) {
                  return AppLocalizations.of(context)!.loginIdentityHelperText;
                }
                return null;
              },
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.loginIdentityPrompt,
                  helperText: AppLocalizations.of(context)!.loginIdentityHelperText,
                  enabledBorder: UnderlineInputBorder(
                      borderSide:
                      BorderSide(color: Theme.of(context).dividerColor))));
        }),

      Row(children: [
        ElevatedButton(
            child: Text(AppLocalizations.of(context)!.acceptButtonText),
            onPressed: () {
              var outputFile = fileNameEditingCtrl.text;
              var f = File(outputFile);
              var s = f.openWrite();
              var result = whedcappSamplesAll();
              result.then((obj) {
                var lows = obj as List<WhedcappSample>;
                s.write(
                    'Id,Alias,Uid,Wellbeing,Safety,Loneliness,SenseOfHome');
                lows.forEach((ws) {
                  s.write('${ws.id},${ws.user.alias},${ws.user.id},${ws
                      .wellbeing},${ws.safety},${ws.loneliness},${ws
                      .senseOfHome}\n');
                });
                s.close();
              });
              Navigator.pop(context);
            }),
        ElevatedButton(
            child: Text(AppLocalizations.of(context)!.cancelButtonText),
            onPressed: () {
              Navigator.pop(context);
            })
      ])
    ]);
  }
}

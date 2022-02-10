import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:login_simulation/common/defaultAppbar.dart';
import 'package:login_simulation/database/whedcappComment.dart';
import 'package:login_simulation/database/whedcappStandalone.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:login_simulation/common/navDrawer.dart';



class AdminCommentsDatabaseMgmtExtractData extends StatefulWidget {
  const AdminCommentsDatabaseMgmtExtractData({Key? key}) : super(key: key);

  static const route = '/administrator/extractCommentsData';
  @override
  _AdminCommentsDatabaseMgmtExtractDataState createState() =>
      _AdminCommentsDatabaseMgmtExtractDataState();
}

class _AdminCommentsDatabaseMgmtExtractDataState
    extends State<AdminCommentsDatabaseMgmtExtractData> {
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
              var result = commentsForAll();
              result.then((obj) {
                var loco = obj as List<WhedcappComment>;
                s.write(
                    'Id,Alias,Wid,Date,Comment');
                loco.forEach((co) {
                  s.write('${co.id},${co.whedcappSample.user.alias},${co.whedcappSample.id},${co
                      .dateTime},${co.commentText}\n');
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

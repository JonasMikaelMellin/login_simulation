import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:login_simulation/common/defaultAppbar.dart';
import 'package:login_simulation/common/navDrawer.dart';
import 'package:login_simulation/database/whedcappStandalone.dart';
import 'package:provider/provider.dart';

import 'adminDatabaseMgmtExtactData.dart';

class AdminDatabaseMgmtScreen extends StatefulWidget {
  const AdminDatabaseMgmtScreen({Key? key}) : super(key: key);
  static String route = '/administrator/databaseScreen';
  @override
  _AdminDatabaseMgmtScreenState createState() =>
      _AdminDatabaseMgmtScreenState();
}

class _AdminDatabaseMgmtScreenState extends State<AdminDatabaseMgmtScreen> {
  final double listRowPadding = 2.0;
  ChangeNotifier changeNotifier = ChangeNotifier();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
        appBar: defaultAppBar(context,
            AppLocalizations.of(context)!.adminDatabaseMgmtScreenTitle),
        body: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: changeNotifier)
          ],
          child:_buildBody(context)
        ));
  }

  _buildBody(context) {
    return Column(children: [
      Consumer<ChangeNotifier>(
        builder: (context,snarf,child) {
          return _buildList(context);
        }),
      _buildButtons(context)]);
  }

  Widget _buildList(context) {
    return FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState != ConnectionState.done ||
              snapshot.hasData == null ||
              snapshot.hasError) {
            return Container(
                child: Center(
                    child: Text(AppLocalizations.of(context)!
                        .adminDatabaseMgmtEmptyTableMessage)));
          }
          List<WhedcappSample> lows = snapshot.data;

          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemCount: lows.length + 1,
                itemBuilder: (context, index) {
                  return index == 0
                      ? Row(children: [
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .adminLabelId
                                      .toString()
                                      .length *
                                  0.5,
                              AppLocalizations.of(context)!.adminLabelId),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .adminLabelAlias
                                      .toString()
                                      .length *
                                  0.6,
                              AppLocalizations.of(context)!.adminLabelAlias),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .adminLabelUid
                                      .toString()
                                      .length *
                                  0.6,
                              AppLocalizations.of(context)!.adminLabelUid),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .adminLabelTimestamp
                                      .toString()
                                      .length *
                                  2.0,
                              AppLocalizations.of(context)!
                                  .adminLabelTimestamp),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .seriesWellbeing
                                      .toString()
                                      .length *
                                  0.6,
                              AppLocalizations.of(context)!.seriesWellbeing),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .seriesSafety
                                      .toString()
                                      .length *
                                  0.6,
                              AppLocalizations.of(context)!.seriesSafety),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .seriesLoneliness
                                      .toString()
                                      .length *
                                  0.6,
                              AppLocalizations.of(context)!.seriesLoneliness),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .seriesSenseOfHome
                                      .toString()
                                      .length *
                                  0.6,
                              AppLocalizations.of(context)!.seriesSenseOfHome),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .adminLabelComments
                                      .toString()
                                      .length *
                                  0.6,
                              AppLocalizations.of(context)!.adminLabelComments),
                        ])
                      : Row(children: [
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .adminLabelId
                                      .toString()
                                      .length *
                                  0.5,
                              lows[index-1].id),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .adminLabelAlias
                                      .toString()
                                      .length *
                                  0.6,
                              lows[index-1].user.alias),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .adminLabelUid
                                      .toString()
                                      .length *
                                  0.6,
                              lows[index-1].user.id),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .adminLabelTimestamp
                                      .toString()
                                      .length *
                                  2.0,
                              lows[index-1].dateTime),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .seriesWellbeing
                                      .toString()
                                      .length *
                                  0.6,
                              lows[index-1].wellbeing),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .seriesSafety
                                      .toString()
                                      .length *
                                  0.6,
                              lows[index-1].safety),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .seriesLoneliness
                                      .toString()
                                      .length *
                                  0.6,
                              lows[index-1].loneliness),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .seriesSenseOfHome
                                      .toString()
                                      .length *
                                  0.6,
                              lows[index-1].senseOfHome),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .adminLabelComments
                                      .toString()
                                      .length *
                                  0.6,
                              '?'),
                        ]);
                }),
          );
        },
        future: whedcappSamplesAll());
  }

  _buildListColumn(BuildContext context, double width, dynamic value) {
    return SizedBox(
        width: width,
        child: Padding(
            padding: EdgeInsets.all(listRowPadding), child: Text('$value')));
  }

  _buildBodyContent(context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: ListView())
        ]);
  }

  _buildButtons(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: [
      ElevatedButton(
          child:
              Text(AppLocalizations.of(context)!.adminDatabaseMgmtDumpButton),
          onPressed: () async {
            Navigator.pushNamed(context,AdminDatabaseMgmtExtractData.route);
          }),
      ElevatedButton(
          child:
              Text(AppLocalizations.of(context)!.adminDatabaseMgmtClearButton),
          onPressed: () {
            deleteAllSamples();
            changeNotifier.notifyListeners();
          }),

      ElevatedButton(
        child: Text(AppLocalizations.of(context)!.cancelButtonText),
        onPressed: () {
          Navigator.pop(context);
        }
        )

    ]);
  }
}

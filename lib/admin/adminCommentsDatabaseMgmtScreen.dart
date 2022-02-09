import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:login_simulation/common/defaultAppbar.dart';
import 'package:login_simulation/common/navDrawer.dart';
import 'package:login_simulation/database/whedcappStandalone.dart';
import 'package:provider/provider.dart';

import 'adminDatabaseMgmtExtractData.dart';

class AdminCommentsDatabaseMgmtScreen extends StatefulWidget {
  const AdminCommentsDatabaseMgmtScreen({Key? key}) : super(key: key);
  static String route = '/administrator/commentsDatabaseScreen';
  @override
  _AdminCommentsDatabaseMgmtScreenState createState() =>
      _AdminCommentsDatabaseMgmtScreenState();
}

class _AdminCommentsDatabaseMgmtScreenState extends State<AdminCommentsDatabaseMgmtScreen> {
  final double listRowPadding = 2.0;
  // id, "alias", wid, metric, dateTime, comment
  final columnWidthFactor = [ 0.5, 1.0, 0.6, 1.0, 0.6, 0.6, ];
  ChangeNotifier changeNotifier = ChangeNotifier();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
        appBar: defaultAppBar(context,
            AppLocalizations.of(context)!.adminCommentsDatabaseMgmtScreenTitle),
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
                        .adminCommentsDatabaseMgmtEmptyTableMessage)));
          }
          List<Comment> loco = snapshot.data;

          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemCount: loco.length + 1,
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
                                  columnWidthFactor[0],
                              AppLocalizations.of(context)!.adminLabelId),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .adminLabelAlias
                                      .toString()
                                      .length *
                                  columnWidthFactor[1],
                              AppLocalizations.of(context)!.adminLabelAlias),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .adminLabelWid
                                      .toString()
                                      .length *
                                  columnWidthFactor[2],
                              AppLocalizations.of(context)!.adminLabelWid),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .adminLabelMetric
                                      .toString()
                                      .length *
                                  columnWidthFactor[3],
                              AppLocalizations.of(context)!
                                  .adminLabelMetric),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .adminLabelTimestamp
                                      .toString()
                                      .length *
                                  columnWidthFactor[4],
                              AppLocalizations.of(context)!.adminLabelTimestamp),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .adminLabelComments
                                      .toString()
                                      .length *
                                  columnWidthFactor[5],
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
                                  columnWidthFactor[0],
                              loco[index-1].id),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .adminLabelAlias
                                      .toString()
                                      .length *
                                  columnWidthFactor[1],
                              loco[index-1].whedcappSample.user.alias),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .adminLabelWid
                                      .toString()
                                      .length *
                                  columnWidthFactor[2],
                              loco[index-1].whedcappSample.id),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .adminLabelMetric
                                      .toString()
                                      .length *
                                  columnWidthFactor[3],
                              loco[index-1].metric.toString()),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .adminLabelTimestamp
                                      .toString()
                                      .length *
                                  columnWidthFactor[4],
                              loco[index-1].dateTime),
                          _buildListColumn(
                              context,
                              Theme.of(context).textTheme.bodyText1!.fontSize! *
                                  AppLocalizations.of(context)!
                                      .adminLabelComments
                                      .toString()
                                      .length *
                                  columnWidthFactor[5],
                              loco[index-1].commentText),
                        ]);
                }),
          );
        },
        future: commentsForAll());
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

/*
This file is part of Whedcapp - standalone.

Whedcapp is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any later version.

Whedcapp is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Foobar. If not, see <https://www.gnu.org/licenses/>.
*/

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:login_simulation/database/whedcappComment.dart';
import 'package:login_simulation/database/whedcappSample.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import '../common/defaultAppbar.dart';
import '../common/diagram.dart';
import '../data.dart';
import '../database/whedcappStandalone.dart';
import 'enterValue.dart';
import '../myApp.dart';
import '../common/navDrawer.dart';

class ParticipantScreen extends StatefulWidget {
  const ParticipantScreen({Key? key}) : super(key: key);

  static const route = '/participant';

  @override
  _ParticipantScreenState createState() => _ParticipantScreenState();
}

class _ParticipantScreenState extends State<ParticipantScreen> {
  List<Data> _data0 = [];
  var _data1 = DataList([]);
  double zoomStart = 0.0;
  int count = 0;
  int _maxId = 1;

  getWhedcappSamplesWithCommentsFromDatabase() async {
    var lc = getLanguageCode();
    lc.then((_lc) async {
      var result = whedcappSamples(MyApp.userInfo!);
      var result2 = commentsForUser(MyApp.userInfo!);
      this._maxId = await getWhedcappSamplesMaxId()+1;
      result.then((wsObj) {
        result2.then((coObj) {
          var lows = wsObj as List<WhedcappSample>;
          var loco = coObj as List<WhedcappComment>;
          List<Data> dataObj = lows.map((ws) {
            return Data(
              date: ws.dateTime,
              series2datum: {
                Series.Wellbeing: Datum(
                    value: ws.wellbeing,
                    information: loco.where((co) =>
                    co.whedcappSample.id == ws.id &&
                        co.metric.index == Series.Wellbeing.index).map((co) =>
                    co.commentText).toList()
                ),
                Series.Safety: Datum(
                    value: ws.safety,
                    information: loco.where((co) =>
                    co.whedcappSample.id == ws.id &&
                        co.metric.index == Series.Safety.index).map((co) =>
                    co.commentText).toList()
                ),
                Series.Loneliness: Datum(
                    value: ws.loneliness,
                    information: loco.where((co) =>
                    co.whedcappSample.id == ws.id &&
                        co.metric.index == Series.Loneliness.index).map((co) =>
                    co.commentText).toList()
                ),
                Series.SenseOfHome: Datum(
                    value: ws.senseOfHome,
                    information: loco.where((co) =>
                    co.whedcappSample.id == ws.id &&
                        co.metric.index == Series.SenseOfHome.index).map((co) =>
                    co.commentText).toList()
                ),
              }

            );
          }).toList();
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
      });
    });
  }

  @override
  void initState() {
    super.initState();
    this.getWhedcappSamplesWithCommentsFromDatabase();
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
      appBar:
      defaultAppBar(context, AppLocalizations.of(context)!.partScreenTitle),
      body: Center(
          child: ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: 100, minHeight: 100, maxHeight: 1000),
              child: Flex(
                direction: Axis.vertical,
                children: [ Expanded(
                  flex: 1,
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
                                    minWidth: 100, minHeight: 100, maxHeight: MediaQuery.of(context).size.height*0.7),
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
                      ]),
                ),
            ]
              ))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
    var time = DateTime.now().add(MyApp.demoMode.demoMode?Duration(days: this.count):Duration(days:0));
    final result = await Navigator.pushNamed(
        context, EnterValue.routeName(Series.values[0]),
        arguments: EnterValueArg(
            currentTime: time,
            dataList: this._data1,
            currentSeries: Series.values[0])) as Map<Series, int>;

    this.setState(() {
      var tmp = Map<Series, Datum>();
      Series.values.forEach((s) => tmp[s] = Datum(
          value: result[s]!,
          information: List.generate(0, (x) {
            return '';
          })));
      _data1.add(Data(date: time, series2datum: tmp));
      insertWhedcappSample(WhedcappSample(
        id: this._maxId++,
        dateTime: time,
        wellbeing: tmp[Series.Wellbeing]!.value,
        loneliness: tmp[Series.Loneliness]!.value,
        safety: tmp[Series.Safety]!.value,
        senseOfHome: tmp[Series.SenseOfHome]!.value,
        user: MyApp.userInfo!

      ));
      this.count++;
    });
  }

}


import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  getWhedcappSamplesWithCommentsFromDatabase() async {
    var lc = getLanguageCode();
    lc.then((_lc) async {
      var result = whedcappSamples(MyApp.userInfo!);
      var result2 = commentsForUser(MyApp.userInfo!);
      this._maxId = await getNumberOfWhedcappSamples();
      result.then((wsObj) {
        result2.then((coObj) {
          var lows = wsObj as List<WhedcappSample>;
          var loco = coObj as List<Comment>;
          List<Data> dataObj = lows.map((ws) {
            return Data(
              date: ws.dateTime,
              series2datum: {
                Series.Wellbeing: Datum(
                    value: ws.wellbeing,
                    information: loco.where((co) =>
                    co.whedcappSample.id == ws.id &&
                        co.metric == Series.Wellbeing.index).map((co) =>
                    co.comment).toList()
                ),
                Series.Safety: Datum(
                    value: ws.safety,
                    information: loco.where((co) =>
                    co.whedcappSample.id == ws.id &&
                        co.metric == Series.Safety.index).map((co) =>
                    co.comment).toList()
                ),
                Series.Loneliness: Datum(
                    value: ws.loneliness,
                    information: loco.where((co) =>
                    co.whedcappSample.id == ws.id &&
                        co.metric == Series.Loneliness.index).map((co) =>
                    co.comment).toList()
                ),
                Series.SenseOfHome: Datum(
                    value: ws.senseOfHome,
                    information: loco.where((co) =>
                    co.whedcappSample.id == ws.id &&
                        co.metric == Series.SenseOfHome.index).map((co) =>
                    co.comment).toList()
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
    var time = DateTime.now().add(Duration(days: this.count));
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
// Add your onPressed code here!

}


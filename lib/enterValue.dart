import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:login_simulation/common/catharinasRadionButton.dart';
import 'package:provider/provider.dart';

import 'data.dart';
import 'common/diagram.dart';
import 'navDrawer.dart';

class EnterValue extends StatefulWidget {
  EnterValue({Key? key}) : super(key: key);

  static String routeName(Series series) {
    return '/enterValue-'+series.toString();
  }
  static const subsequentRouteName = '/enterValueSubsequent';

  @override
  _EnterValueState createState() => _EnterValueState();
}

class _EnterValueState extends State<EnterValue> {
  DateTime _dateTime = DateTime.now();
  DataList _dataList = DataList([]);
  Series _currentSeries = Series.values[0];
  var chosen = Chosen({});
  late Map<Series,int?> _answer;
  //var chosen = Chosen();
  //var chosen = HashMap<Series, Chosen>();

  @override
  Widget build(BuildContext context) {
    return _buildEnterValueScreen(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as EnterValueArg;
    this._dateTime = args.currentTime;
    this._dataList = args.dataList;
    this._currentSeries = args.currentSeries;
    if (args.answer == null) {
      this._answer = Map<Series,int?>();
      Series.values.forEach((s) => this._answer[s] = -1);
    } else {
      this._answer = args.answer!;
      this.chosen.setMap(this._answer);
    }
  }

  Widget _buildEnterValueScreen(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!
            .addValueScreenTitle(DateFormat.yMMMd().format(_dateTime))),
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
                          ChangeNotifierProvider.value(value: this._dataList),
                          ChangeNotifierProvider.value(value: this.chosen)
                        ],
                        child: Column(children: [
                          ConstrainedBox(
                              constraints: BoxConstraints(
                                  minWidth: 100,
                                  minHeight: 100,
                                  maxHeight: 699),
                              child: Diagram()),
                          Consumer<Chosen>(
                            builder: (context, foo, child) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (this._currentSeries.index != 0)
                                    ElevatedButton(
                                        child: Icon(Icons.arrow_left),
                                        onPressed: () {
                                          _navigateToEnterValueSceenPopData(EnterValue.routeName(Series.values[this._currentSeries.index-1]),
                                              EnterValueArg(
                                                  currentTime: this._dateTime,
                                                  dataList: this._dataList,
                                                  currentSeries: Series.values[
                                                  this
                                                      ._currentSeries
                                                      .index -
                                                      1],
                                                  answer: chosen.getMap()));
                                        })

                                  else
                                    SizedBox.shrink(),
                                  CatharinasRadioButton(
                                      question: getQuestion(
                                          context, this._currentSeries),
                                      start: 0,
                                      end: 10,
                                      chosen: this.chosen,
                                      series: this._currentSeries),
                                  if (this._currentSeries.index !=
                                      Series.values.length - 1)
                                    ElevatedButton(
                                        child: Icon(Icons.arrow_right),
                                        onPressed: () {
                                          _navigateToEnterValueSceenPopData(EnterValue.routeName(Series.values[this._currentSeries.index+1]),
                                              EnterValueArg(
                                                  currentTime: this._dateTime,
                                                  dataList: this._dataList,
                                                  currentSeries: Series.values[
                                                  this
                                                      ._currentSeries
                                                      .index +
                                                      1],
                                                  answer: chosen.getMap()));
                                        })
                                  else
                                    SizedBox.shrink(),
                                ]),
                          ),
                          Consumer<Chosen>(
                            builder: (context, foo, child) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                ElevatedButton(child: Text(AppLocalizations.of(context)!.cancelButtonText),
                                onPressed: () { Navigator.pop(context); }
                                ),
                                ElevatedButton(child: Text(AppLocalizations.of(context)!.acceptButtonText),
                                onPressed: chosen.getMap().values.every((v) => v > -1) ? () { Navigator.pop(context,this.chosen.getMap()); } : null
                                )
                              ]
                            ),
                          )
                        ])
                    ),
                  ]))),
    );
  }
  void _navigateToEnterValueSceenPopData(String route, EnterValueArg enterValueArg) async {
    final result =  await Navigator.pushNamed(context, route,
        arguments: enterValueArg) as Map<Series,int> ;
    Navigator.pop(context,result);
  }

}

getQuestion(BuildContext context, Series currentSeries) {
  return AppLocalizations.of(context)!.enterValueQuestion(getSeriesName(context,currentSeries));
}

import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'config/configScreen.dart';
import 'database/whedcappStandalone.dart';
import 'main.dart';

class Item {
  const Item(this.language, this.country, this.description);
  String icu_code() {
    return this.language + "_" + this.country;
  }

  final String language;
  final String country;
  final String description;
}

class WColor extends ChangeNotifier {
  Color _color;
  WColor(this._color);
  void set color(Color color) {
    this._color = color;
    notifyListeners();
  }
  Color get color {
    return this._color;
  }
}

class WColors extends ChangeNotifier {
  Map<Series,WColor> series2color = {
    Series.Loneliness: WColor(Color(0xff008837)),
    Series.Wellbeing: WColor(Color(0xff7b3294)),
    Series.Safety: WColor(Color(0xffc2a5cf)),
    Series.SenseOfHome: WColor(Color(0xffa6dba0))
  };
  WColors() {
    var result = colors();
    result.then((obj) {
      var ccList = obj as List<ConfigColor>;
      ccList.forEach((cc) {
        series2color[cc.series]!.color = Color(cc.color);
      });
    });
  }
  void set(Series series, Color color) {
    series2color[series]!.color = color;
    notifyListeners();
  }
  Color get(Series series) {
    return series2color![series]!.color;
  }
}

enum Role { none, participant, administrator, projectOwner }

class User {
  final String alias;
  final String password;
  final List<Role> roles;
  User({required this.alias, required this.password, required this.roles});
}

enum Series { Wellbeing, SenseOfHome, Safety, Loneliness }
const Map<Series,int> seriesColor = {Series.Wellbeing: 0xff7b3294, Series.SenseOfHome: 0xffa6dba0, Series.Safety: 0xffc2a5cf, Series.Loneliness: 0xff008837 };
int getSeriesColor(Series series) {
  return ConfigScreen.wcolors.get(series).value;
  return seriesColor[series]!;
}
String getJavascriptSeriesColor(Series series) {
  // Must move alpha to end for JavaScript, sigh
  var color = getSeriesColor(series);
  //return '#'+((color << 8 | color >> 24)&0xffffffff).toRadixString(16).padLeft(6,'0');
  return '#'+((color << 0 | color >>0)&0xffffff).toRadixString(16).padLeft(6,'0');
}

String getSeriesName(BuildContext context,Series series) {
  switch (series) {

    case Series.Wellbeing:
      return AppLocalizations.of(context)!.seriesWellbeing;
    case Series.SenseOfHome:
      return AppLocalizations.of(context)!.seriesSenseOfHome;
    case Series.Safety:
      return AppLocalizations.of(context)!.seriesSafety;
    case Series.Loneliness:
      return AppLocalizations.of(context)!.seriesLoneliness;
  }
}


class Datum {
  final int value;
  final List<String> information;
  const Datum({
    required this.value,
    required this.information
  });
}
class Data {
  final DateTime date;
  final Map<Series,Datum> series2datum;
  const Data({
    required this.date,
    required this.series2datum
  });
  Map<String,Object> toEchart(BuildContext context) {
    Map<String,Object> result = {};
    result['Datum'] = date.toIso8601String();
    for (var series in Series.values) {
      result[getSeriesName(context,series)] = series2datum[series]!.value;
    }
    result['information'] = Series.values.map((el) {
      return series2datum[el]!.information.toList();
    }).toList();
    return result;
  }
}

class DataList extends ChangeNotifier {
  List<Data> _dataList = [];
  UnmodifiableListView<Data> get data => UnmodifiableListView(_dataList);
  DataList(this._dataList);
  void add(Data data) {
    _dataList.add(data);
    notifyListeners();
  }
  void addAll(List<Data> dataList) {
    _dataList.addAll(dataList);
    notifyListeners();
  }
  void addComment(Series series, int idx, String comment) {
    _dataList[idx].series2datum[series]!.information.add(comment);
    notifyListeners();
  }
  void removeComment(Series series, int idx, int commentIdx) {
    _dataList[idx].series2datum[series]!.information.removeAt(commentIdx);
    notifyListeners();
  }

}

class Chosen extends ChangeNotifier {
  Map<Series, int> chosen = {
    Series.Loneliness: -1,
    Series.Safety: -1,
    Series.SenseOfHome: -1,
    Series.Wellbeing: -1
  };
  Chosen(Map<Series,int> map) {
    Series.values.forEach((s) => this.chosen[s] = map[s] == null ? -1 : map[s]!);
  }
  void setMap(Map<Series,int?> map) {
    Series.values.forEach((s) => this.chosen[s] = map![s]!);
  }
  Map<Series,int> getMap() {
    return this.chosen;
  }
  void set(Series series, int value) {
    this.chosen[series] = value;
    notifyListeners();
  }
  int? get(Series series) {
    return this.chosen[series];
  }
}

class EnterValueArg {
  DataList dataList;
  DateTime currentTime;
  Series currentSeries;

  EnterValueArg({required this.dataList, required this.currentTime,required this.currentSeries,this.answer});
  Map<Series,int?>? answer;
}

class AddedComments {
  Map<Series,List<int>> _series2commentIdxs = {};
  AddedComments(this._series2commentIdxs);
  getCommentIdxs(series) => _series2commentIdxs[series];
}

class DatabaseInfo extends ChangeNotifier {
  DatabaseInfo() {
    getNumberOfUsers().then((v) => numbOfUsers = v);
    getNumberOfWhedcappSamples().then((v) => numbOfRecords = v);
  }
  int numbOfUsers = 0;
  int numbOfRecords = 0;
  void set numberOfUsers(int numberOfUsers) {
    this.numbOfUsers = numberOfUsers;
    notifyListeners();
  }
  void set numberOfRecords(int numberOfRecords) {
    this.numbOfRecords = numberOfRecords;
    notifyListeners();
  }
  int get numberOfUsers {
    return numbOfUsers;
  }
  int get numberOfRecords {
    return numbOfRecords;
  }

}

class DemoMode extends ChangeNotifier {
  bool _demoMode;
  DemoMode(this._demoMode);
  void set demoMode(bool flag) {
    _demoMode = flag;
    notifyListeners();
  }
  bool get demoMode {
    return _demoMode;
  }
}
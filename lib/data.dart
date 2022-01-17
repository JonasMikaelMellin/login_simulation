import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';


enum Series { Wellbeing, SenseOfHome, Safety, Loneliness }
const Map<Series,int> seriesColor = {Series.Wellbeing: 0x7b3294, Series.SenseOfHome: 0xa6dba0, Series.Safety: 0xc2a5cf, Series.Loneliness: 0x008837 };
int getSeriesColor(Series series) {
  return seriesColor[series]!;
}
String getJavascriptSeriesColor(Series series) {
  return '#'+seriesColor[series]!.toRadixString(16).padLeft(6,'0');
}
Map<Series,String> seriesName = {
  Series.Wellbeing: 'Välmående',
  Series.SenseOfHome: 'Hemkänsla',
  Series.Safety: 'Trygghet',
  Series.Loneliness: 'Ensamhet'
};

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
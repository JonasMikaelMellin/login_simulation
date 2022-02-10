
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:login_simulation/database/whedcappComment.dart';
import 'package:login_simulation/database/whedcappStandalone.dart';
import 'package:provider/provider.dart';

import '../data.dart';
import '../dataSpecification.dart';
import '../common/defaultAppBar.dart';

abstract class DataNoteListItem {
  final Series series;

  DataNoteListItem({required this.series});

  Widget buildTitle(context);

  Widget buildSubTitle(context);

  Widget buildButton(context, bool show, Function f);

  Widget buildEditButton(context, bool show, Function f);

  Color getColor();
}

class SeriesListItem extends DataNoteListItem {
  final String seriesName;

  SeriesListItem({required this.seriesName, required series})
      : super(series: series);

  @override
  Widget buildButton(context, show, f) {
    return Padding(
        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: ElevatedButton(
          onPressed: () {
            f();
          },
          child:
              Icon(!show ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up),
        ));
  }

  @override
  Widget buildSubTitle(context) {
    return SizedBox.shrink();
  }

  @override
  Widget buildTitle(context) {
    return Text(seriesName,
        style: Theme.of(context)
            .copyWith(
                textTheme: const TextTheme(
                    headline1: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)))
            .textTheme
            .headline1);
  }

  @override
  Color getColor() {
    return Color(0xff000000 | getSeriesColor(series));
  }

  @override
  Widget buildEditButton(context, bool show, Function f) {
    return Padding(
        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: ElevatedButton(
          onPressed: () {
            f();
          },
          child: Icon(Icons.add_comment),
        ));
  }
}

class NoteItem extends DataNoteListItem {
  final String note;

  NoteItem({required this.note, required series}) : super(series: series);

  @override
  Widget buildButton(context, show, f) {
    return SizedBox.shrink();
  }

  @override
  Widget buildSubTitle(context) {
    return SizedBox.shrink();
  }

  @override
  Widget buildTitle(context) {
    return Text(note, style: Theme.of(context).textTheme.bodyText1);
  }

  @override
  Color getColor() {
    return Color(0xb0000000 | getSeriesColor(series));
  }

  @override
  Widget buildEditButton(context, bool show, Function f) {
    return SizedBox.shrink();
  }
}

class EditDataNotesScreen extends StatefulWidget {
  const EditDataNotesScreen({Key? key}) : super(key: key);

  static const routeName = '/editDataNotes';

  @override
  _EditDataNotesScreenState createState() => _EditDataNotesScreenState();
}

class ShowSeriesModel extends ChangeNotifier {
  Map<Series, bool> _showSeries = {};

  ShowSeriesModel() {
    Series.values.forEach((s) => _showSeries[s] = true);
  }

  getShowSeries(series) => _showSeries[series];

  setShowSeries(series, flag) {
    _showSeries[series] = flag;
    notifyListeners();
  }
}

class _EditDataNotesScreenState extends State<EditDataNotesScreen> {
  //Map<Series, bool> _showSeries = {};
  Map<Series, List<int>> newCommentsIdx = {};
  var dataList = DataList([]);
  int dataIndex = -1;
  bool changed = false;

  @override
  initState() {
    super.initState();
//    Series.values.forEach((s) => _showSeries[s] = false);
    Series.values.forEach((s) => newCommentsIdx[s] = []);
    changed = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as DataSpec;
    dataList = args.data;
    dataIndex = args.dataIndex;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ShowSeriesModel>(
        create: (_) => ShowSeriesModel(),
        child: _buildEditDataNoteScreen(context));
  }

  Widget _buildEditDataNoteScreen(BuildContext context) {
    return Scaffold(
      //TODO: Use defaultAppBar
        appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.editDataNoteScreenTitle),
            actions: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/config');
                      },
                      child: Icon(Icons.settings, size: 26.0)))
            ]),
        body: _buildEditDataNoteBody(context));
  }

  Widget _buildEditDataNoteBody(BuildContext context) {
    return Consumer<ShowSeriesModel>(
        builder: (context, value, child) => Container(
            child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildEditDataNoteListView(context),
                      _buildEditDataNoteButton(context)
                    ]))));
  }

  Widget _buildEditDataNoteListView(context) {
    final Data data = dataList.data[dataIndex];
    List<DataNoteListItem> lst = [];
    for (var series in Series.values) {
      lst.add(SeriesListItem(
          seriesName: getSeriesName(context, series), series: series));
      for (var note in data.series2datum[series]!.information.reversed) {
        lst.add(NoteItem(note: note, series: series));
      }
    }
    return SizedBox(
      height: MediaQuery.of(context).size.height*0.8,
      child: Flexible(
          child: ListView.builder(
              itemCount: lst.length,
              itemBuilder: (context, index) {
                if (lst[index] is SeriesListItem ||
                    context
                        .read<ShowSeriesModel>()
                        .getShowSeries(lst[index].series)) {
                  return ListTile(
                    title: lst[index].buildTitle(context),
                    trailing: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          data.series2datum[lst[index].series]!.information
                                          .length >
                                      0 &&
                                  lst[index] is SeriesListItem
                              ? Icon(Icons.more_horiz)
                              : SizedBox.shrink(),
                          lst[index].buildEditButton(context, true, () {
                            this.setState(() {
                              _navigateToAddDataNoteAndAddData(lst[index].series);
                            });
                          }),
                          lst[index].buildButton(
                              context,
                              context
                                  .read<ShowSeriesModel>()
                                  .getShowSeries(lst[index].series), () {
                            var ssm = context.read<ShowSeriesModel>();
                            ssm.setShowSeries(lst[index].series,
                                !ssm.getShowSeries(lst[index].series));
                          }),
                        ]),
                    tileColor: lst[index].getColor(),
                  );
                } else {
                  return SizedBox.shrink();
                }
              })),
    );
  }

  void _navigateToAddDataNoteAndAddData(Series series) async {
    final result = await Navigator.pushNamed(
        context, AddDataNoteScreen.addDataNoteScreenPath,
        arguments: SeriesDataSpec(
            dataSpec: DataSpec(dataIndex: dataIndex, data: dataList),
            series: series));
    if (result != null) {
      this.setState(() {
        dataList.addComment(series, dataIndex, result as String);
        changed = true;
        this.newCommentsIdx[series]!.add(
            dataList.data[dataIndex].series2datum[series]!.information.length -
                1);
      });
    }
  }

  _buildEditDataNoteButton(BuildContext context) {
    return Flexible(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
          ElevatedButton(
              child: Text(AppLocalizations.of(context)!.acceptButtonText),
              onPressed: ()  {
                var maxCidF =  getMaxIdOfComments();
                maxCidF.then((maxCidBase) {
                  var maxCid = maxCidBase+1;
                  var wsF = getWhedcappSampleForTimestamp(
                      dataList.data[dataIndex].date);
                  wsF.then((ws) {
                    newCommentsIdx.forEach((k, v) {
                      v.forEach((cidx) {
                        final c = WhedcappComment(
                            id: maxCid++,
                            whedcappSample: ws,
                            metric: Metric.values[k.index],
                            dateTime: DateTime.now(),
                            commentText: dataList.data[dataIndex]
                                .series2datum[k]!
                                .information[cidx]);
                        insertComment(c);
                      });
                    });
                  });
                });
                Navigator.pop(context, AddedComments(newCommentsIdx));
              }),
          ElevatedButton(
              child: Text(AppLocalizations.of(context)!.cancelButtonText),
              onPressed: () {
                Series.values.forEach((s) {
                  newCommentsIdx[s]!.reversed.forEach((i) {
                    dataList.removeComment(s, dataIndex, i);
                  });
                });
                Series.values.forEach((s) => newCommentsIdx[s] = []);
                Navigator.pop(context);
              })
        ]));
  }
}

class AddDataNoteScreen extends StatefulWidget {
  const AddDataNoteScreen({Key? key}) : super(key: key);

  static const String addDataNoteScreenPath = '/addDataNoteScreen';

  @override
  _AddDataNoteScreenState createState() => _AddDataNoteScreenState();
}

class _AddDataNoteScreenState extends State<AddDataNoteScreen> {
  late List<Data> dataList = [];
  late int dataIndex = -1;
  final _formKey = GlobalKey<FormState>();
  final _addDataNoteTextFieldCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as SeriesDataSpec;
    dataList = args.dataSpec.data.data;
    dataIndex = args.dataSpec.dataIndex;
  }

  @override
  Widget build(BuildContext context) {
    return _buildAddDataNoteScreen(context);
  }

  Widget _buildAddDataNoteScreen(BuildContext context) {
    return Scaffold(
        appBar: defaultAppBar(
            context,
            AppLocalizations.of(context)!.addDataNoteScreenTitle),
        body: _buildAddDataNoteScreenBody(context));
  }

  _buildAddDataNoteScreenBody(BuildContext context) {
    return Column(children: [
      TextFormField(
          maxLength: 4096,
          maxLines: 30,
          controller: _addDataNoteTextFieldCtrl,
          decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.addDataNotePrompt,
              helperText: AppLocalizations.of(context)!.addDataNoteHelpText(
                  AppLocalizations.of(context)!.acceptButtonText))),
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            ElevatedButton(
                child: Text(AppLocalizations.of(context)!.acceptButtonText),
                onPressed: () {
                  Navigator.pop(context, _addDataNoteTextFieldCtrl.text);
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

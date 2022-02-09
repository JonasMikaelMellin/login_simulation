import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import '../data.dart';
import '../common/defaultAppBar.dart';

class AddValueArgs {
  final List<Data> dataList;
  final Map<Series,int> currentResponses;
  const AddValueArgs({required this.dataList,required this.currentResponses});
}

class AddValueResult {
  final Map<Series,int> series2value;
  const AddValueResult({required this.series2value});
}

class AddValueScreen extends StatefulWidget {
  const AddValueScreen({Key? key}) : super(key: key);

  static const String addValueScreen = '/addValueScreen';

  @override
  _AddValueScreenState createState() => _AddValueScreenState();
}

class _AddValueScreenState extends State<AddValueScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context, AppLocalizations.of(context)!.addValueScreenTitle(DateFormat.yMMMd(DateTime.now()))),
      body: _buildAddValueBody(context)
    );
  }

  Widget _buildAddValueBody(BuildContext context) {
    return Column(
      children: [

      ]
    );
  }
}

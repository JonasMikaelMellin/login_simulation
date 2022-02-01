import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:login_simulation/common/defaultAppbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import '../data.dart';
import '../common/navDrawer.dart';
import 'colorConfigurationArg.dart';

class ColorConfigurationScreen extends StatefulWidget {
  const ColorConfigurationScreen({Key? key}) : super(key: key);

  static const route = '/config/colorConfiguration';

  @override
  _ColorConfigurationScreenState createState() => _ColorConfigurationScreenState();
}

class _ColorConfigurationScreenState extends State<ColorConfigurationScreen> {
  late Series series;
  late Color color;

  @override
  void didChangeDependencies() {
    var colorConfArg = ModalRoute.of(context)!.settings.arguments as ColorConfigurationArgReq;
    setState(() {
      this.series = colorConfArg.series;
      this.color = Color(colorConfArg.color);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: defaultAppBar(context,AppLocalizations.of(context)!.configurationChooseColor(series)),
      body: _buildColorPicker(context)

    );
  }

  _buildColorPicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        ColorPicker(
          pickerColor: color,
          onColorChanged: ((color) {
            setState(() {
              this.color = color;
            });
          })
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.acceptButtonText),
              onPressed: () {
                Navigator.pop(context,ColorConfigurationArgRep(series: series, color: color.value));
              }
            ),
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.cancelButtonText),
              onPressed: () {
                Navigator.pop(context);
              }
            )
          ]
        )
      ]
    );
  }
}

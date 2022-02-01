import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import 'defaultAppbar.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  static const route = '/welcome';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context,AppLocalizations.of(context)!.welcomeScreenTitle),
      body: Text(AppLocalizations.of(context)!.welcomeText)
    );
  }
}

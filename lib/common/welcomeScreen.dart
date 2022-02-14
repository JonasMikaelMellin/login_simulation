/*
This file is part of Whedcapp - standalone.

Whedcapp is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any later version.

Whedcapp is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Foobar. If not, see <https://www.gnu.org/licenses/>.
*/

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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [

          SizedBox(width: MediaQuery.of(context).size.width*0.6,child: Center(child: Text(AppLocalizations.of(context)!.welcomeText))),
          SizedBox(height:32),
          Center(child: Text('Copyright 2021-2022 Catharina Gillsjö, Jonas Mellin')),
          SizedBox(height: 32),
          SizedBox(width: MediaQuery.of(context).size.width*0.6,
            child: Center(child: Text('This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>. ')
            ),
          )
        ]
        ),
      )
    );
  }
}

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

AppBar defaultAppBar(BuildContext context, String title) {
  return AppBar(
    title: Text(title),
    actions: <Widget>[
      Image(
        width: 200,
        image: AssetImage('assets/image001.png'),
      ),
      Image(
        width: 100,
        image: AssetImage('assets/image002.png'),
      ),
      Padding(
        padding: EdgeInsets.only(right:20.0),
        child: GestureDetector(
          onTap: () {

              Navigator.pushNamed(context,'/config');

          },
          child: Icon(Icons.settings, size: 26.0)
        )
      )
    ]
  );
}
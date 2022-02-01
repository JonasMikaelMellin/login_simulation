

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AppBar defaultAppBar(BuildContext context, String title) {
  return AppBar(
    title: Text(title),
    actions: <Widget>[
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
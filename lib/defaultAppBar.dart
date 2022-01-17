
import 'package:flutter/material.dart';

class DefaultAppBar extends AppBar {
  final BuildContext context;
  DefaultAppBar({required this.context,required title}): super(
    title: title,
    actions: <Widget>[
      Padding(
        padding: EdgeInsets.only(right:20.0),
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context,'/config');
          },
          child: Icon(Icons.settings)
        )
      )
    ]
  );
}
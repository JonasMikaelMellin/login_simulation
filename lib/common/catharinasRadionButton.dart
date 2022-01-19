import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data.dart';

class CatharinasRadioButton extends StatefulWidget {
  CatharinasRadioButton(
      {required this.question,
      required this.start,
      required this.end,
      required this.chosen,
      required this.series,
      Key? key})
      : super(key: key);
  final String question;
  final int start;
  final int end;
  final Chosen chosen;
  final Series series;

  @override
  _CatharinasRadioButtonState createState() => _CatharinasRadioButtonState();
}

class _CatharinasRadioButtonState extends State<CatharinasRadioButton> {
  TextEditingController _controller = TextEditingController(text: "");

  @override
  initState() {
    _controller = TextEditingController(text: widget.question);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var length = widget.end - widget.start + 1;
    return SizedBox(
      height: 100,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [

            SizedBox(
              width: MediaQuery.of(context).size.width*0.75,
              child:
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0,0.0,10.0,0.0),
                child: Expanded(flex: 2, child:
                Text(widget.question,
                  style: TextStyle(backgroundColor: Colors.blue, color: Colors.white, fontSize: 18.0),
                )),
              ),
            ),
               Row(
                  children: List.generate(length, (i) => i + 1).map((i) {
                return _buildButtonRow(context, length, i - 1+widget.start);
              }).toList()),

          ]),
    );
  }

  Widget _buildButtonRow(BuildContext context, int length, int i) {
    if (i >= widget.start) {
      return Row(children: [
        Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: _buildButton(context, i))
      ]);
    } else {
      return _buildButton(context, i);
    }
  }

  Widget _buildButton(BuildContext context, int i) {
    return ( ElevatedButton(
          onPressed: () {
            widget.chosen.set(widget.series, i);
          },
          child: Text(i.toString()),
          style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(Size(10.0,10.0)),
              maximumSize: i<10? MaterialStateProperty.all(Size(40.0,20.0)): MaterialStateProperty.all(Size(50.0,20.0)),

              backgroundColor: widget.chosen.get(widget.series) == i
                  ? MaterialStateProperty.all<Color>(Colors.green)
                  : MaterialStateProperty.all<Color>(Colors.blue)))
    );
  }
}

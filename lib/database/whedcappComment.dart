/*
This file is part of Whedcapp - standalone.

Whedcapp is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any later version.

Whedcapp is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Foobar. If not, see <https://www.gnu.org/licenses/>.
*/

//TODO: Merge Metric and Series. Stupid mistake!
import 'package:login_simulation/database/whedcappSample.dart';

enum Metric { wellbeing, senseOfHome, safety, loneliness }

class WhedcappComment {
  final int id;
  final WhedcappSample whedcappSample;
  final Metric metric;
  final DateTime dateTime;
  final String commentText;
  WhedcappComment(
      {required this.id,
        required this.whedcappSample,
        required this.metric,
        required this.dateTime,
        required this.commentText});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wid': whedcappSample.id,
      'metric': metric.index,
      'dateTime': dateTime.toIso8601String(),
      'comment_text': commentText
    };
  }

  @override
  String toString() {
    return 'Comment(Id: $id, whedcappSample: $whedcappSample, metric: $metric, dateTime: $dateTime, comment: $commentText)';
  }
}
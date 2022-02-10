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
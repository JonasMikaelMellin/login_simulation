import 'package:login_simulation/database/userInfo.dart';

class WhedcappSample {
  final int id;
  final UserInfo user;
  final DateTime dateTime;
  final int wellbeing;
  final int senseOfHome;
  final int safety;
  final int loneliness;

  WhedcappSample(
      {required this.id,
        required this.user,
        required this.dateTime,
        required this.wellbeing,
        required this.senseOfHome,
        required this.safety,
        required this.loneliness});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': user.id,
      'dateTime': dateTime.toIso8601String(),
      'wellbeing': wellbeing,
      'sense_of_home': senseOfHome,
      'safety': safety,
      'loneliness': loneliness
    };
  }

  @override
  String toString() {
    return 'WhedcappSample(Id: $id, User: $user, dateTime: $dateTime, wellbeing: $wellbeing, senseOfHome: $senseOfHome, safety: $safety, loneliness: $loneliness)';
  }
}
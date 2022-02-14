/*
This file is part of Whedcapp - standalone.

Whedcapp is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any later version.

Whedcapp is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Foobar. If not, see <https://www.gnu.org/licenses/>.
*/

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
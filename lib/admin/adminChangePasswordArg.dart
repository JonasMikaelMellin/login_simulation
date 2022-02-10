
import 'package:login_simulation/database/userInfo.dart';
import 'package:login_simulation/database/whedcappStandalone.dart';

class AdminChangePasswordArgReq {
  final UserInfo user;
  AdminChangePasswordArgReq({required this.user});
}

class AdminChangePasswordArgRep {
  final String hashedPassword;
  AdminChangePasswordArgRep({required this.hashedPassword});
}
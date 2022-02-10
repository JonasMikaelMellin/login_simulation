
import 'package:login_simulation/common/crudOperations.dart';
import 'package:login_simulation/database/userInfo.dart';
import 'package:login_simulation/database/whedcappStandalone.dart';

class CrudUserArgReq {
  final UserInfo user;
  final CrudOp crudOp;
  CrudUserArgReq({required this.user, required this.crudOp});

}

class CrudUserArgRep {
  final UserInfo? userInfo;
  final bool accept;
  CrudUserArgRep({required this.userInfo, required this.accept});
}
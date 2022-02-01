import 'package:flutter/cupertino.dart';
import 'package:login_simulation/common/crudOperations.dart';
import 'package:login_simulation/common/typeInfo.dart';
import 'package:login_simulation/database/whedcappStandalone.dart';
import 'package:login_simulation/database/whedcappStandalone.dart';

Map<String,TextEditingController> genUserAdminTextEditingControllers() {
  return { for (var item in UserInfo.field.entries.where((e)=>e.value.type != TypeInfo.BOOL).map((e)=>e.key).toList()) '$item' : TextEditingController()};
}
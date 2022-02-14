/*
This file is part of Whedcapp - standalone.

Whedcapp is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any later version.

Whedcapp is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Foobar. If not, see <https://www.gnu.org/licenses/>.
*/


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
import 'package:login_simulation/common/typeInfo.dart';

class UserInfo {
  static Map<int, FormEntryInfo> field = {
    0: FormEntryInfo(
        order: 0,
        name: 'id',
        type: TypeInfo.INT,
        hidden: false,
        label: 'Id',
        helpText: 'Enter id'),
    1: FormEntryInfo(
        order: 1,
        name: 'alias',
        type: TypeInfo.STRING,
        hidden: false,
        label: 'Alias',
        helpText: 'Enter alias'),
    2: FormEntryInfo(
        order: 2,
        name: 'hashedPassword',
        type: TypeInfo.STRING,
        hidden: true,
        label: 'Password',
        helpText: 'Enter password'),
    3: FormEntryInfo(
        order: 3,
        name: 'admin',
        type: TypeInfo.BOOL,
        hidden: false,
        label: 'Administrator?',
        helpText: 'Toggle administrator'),
    4: FormEntryInfo(
        order: 4,
        name: 'enabled',
        type: TypeInfo.BOOL,
        hidden: false,
        label: 'Enabled?',
        helpText: 'Toggle enabled flag'),
  };
  final int id;
  final String alias;
  late final String hashedPassword;
  late final bool admin;
  late final bool enabled;

  UserInfo(
      {required this.id,
        required this.alias,
        required this.hashedPassword,
        required this.admin,
        required this.enabled});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'alias': alias,
      'hashed_password': hashedPassword,
      'admin': admin ? 1 : 0,
      'enabled': enabled ? 1 : 0
    };
  }

  @override
  String toString() {
    return 'User(id: $id, alias: $alias, admin: $admin, enabled: $enabled)';
  }

  dynamic get(String name) {
    if (name == 'id')
      return id;
    else if (name == 'alias')
      return alias;
    else if (name == 'hashedPassword')
      return hashedPassword;
    else if (name == 'admin')
      return admin;
    else if (name == 'enabled')
      return enabled;
    else
      throw Exception('Unknown field name');
  }
}
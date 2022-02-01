import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:login_simulation/common/typeInfo.dart';
import 'package:path/path.dart';
import 'package:reflectable/mirrors.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tuple/tuple.dart';

import '../data.dart';

class UserInfo {
  static Map<int,FormEntryInfo> field = {
    0: FormEntryInfo(order: 0, name: 'id',type: TypeInfo.INT, hidden: false, label: 'Id', helpText:'Enter id'),
    1: FormEntryInfo(order: 1, name: 'alias',type: TypeInfo.STRING, hidden: false, label: 'Alias', helpText:'Enter alias'),
    2: FormEntryInfo(order: 2, name: 'hashedPassword',type: TypeInfo.STRING, hidden: true, label: 'Password', helpText:'Enter password'),
    3: FormEntryInfo(order: 3, name: 'admin',type: TypeInfo.BOOL, hidden: false, label: 'Administrator?', helpText:'Toggle administrator'),
    4: FormEntryInfo(order: 4, name: 'enabled',type: TypeInfo.BOOL, hidden: false, label: 'Enabled?', helpText:'Toggle enabled flag'),
  };
  final int id;
  final String alias;
  late final String hashedPassword;
  late final bool admin;
  late final bool enabled;

  UserInfo({required this.id, required this.alias, required this.hashedPassword, required this.admin,  required this.enabled});

  Map<String,dynamic> toMap() {
    return {
      'id': id,
      'alias': alias,
      'hashed_password': hashedPassword,
      'admin': admin?1:0,
      'enabled': enabled?1:0
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
  }}

class WhedcappSample {
  final int id;
  final UserInfo user;
  final DateTime dateTime;
  final int wellbeing;
  final int senseOfHome;
  final int safety;
  final int loneliness;

  WhedcappSample({required this.id,required this.user, required this.dateTime, required this.wellbeing, required this.senseOfHome, required this.safety, required this.loneliness});

  Map<String,dynamic> toMap() {
    return {
      'id': id,
      'uid': user.id,
      'dateTime': dateTime.toIso8601String()  ,
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

enum Metric {wellbeing,senseOfHome,safety,loneliness}
class Comment {
  final int id;
  final WhedcappSample whedcappSample;
  final Metric metric;
  final DateTime dateTime;
  final String comment;
  Comment({required this.id, required this.whedcappSample, required this.metric, required this.dateTime, required this.comment});

  Map<String,dynamic> toMap() {
    return {
      'id': id,
      'wid': whedcappSample.id,
      'metric': metric.index,
      'dateTime': dateTime.toIso8601String(),
      'comment': comment
    };
  }
  @override
  String toString() {
    return 'Comment(Id: $id, whedcappSample: $whedcappSample, metric: $metric, dateTime: $dateTime, comment: $comment)';
  }
}
late Future<Database> database;

Future<bool> initWhedcappStandaloneDatabase() async {
  bool removeDatabase = false;
  WidgetsFlutterBinding.ensureInitialized();
  if (removeDatabase) {
    try {
      final filePath = join(await getDatabasesPath(), 'whedcappStandalone.db');
      final file = File(filePath);
      file.delete();
    } catch (e) {
      throw e;
    }
  }
  database = openDatabase(
      join(await getDatabasesPath(),'whedcappStandalone.db'),
      onCreate: (db, version)  async {
        await db.transaction((txn) {
          txn.execute('CREATE TABLE color_config(id INTEGER PRIMARY KEY, color INTEGER NOT NULL)');
          txn.execute('INSERT INTO color_config(id,color) VALUES(0,2155557524),(1,2158418848),(2,2160240079),(3,2147518519)');
          txn.execute('CREATE TABLE user(id INTEGER PRIMARY KEY, alias TEXT, hashed_password TEXT, admin INTEGER, enabled INTEGER)');
          txn.execute('CREATE UNIQUE INDEX user_index ON user(alias)');
          txn.execute('CREATE TABLE whedcapp_sample(id INTEGER PRIMARY KEY, uid INTEGER NOT NULL, dateTime TEXT, wellbeing INTEGER, sense_of_home INTEGER, safety INTEGER, loneliness INTEGER, FOREIGN KEY (uid) REFERENCES user(id) ON UPDATE NO ACTION ON DELETE CASCADE)');
          txn.execute('CREATE UNIQUE INDEX whedcapp_sample_index ON whedcapp_sample(uid,dateTime)');
          txn.execute('CREATE TABLE comment(id INTEGER PRIMARY KEY, wid INTEGER NOT NULL, metric INTEGER, dateTime TEXT, comment TEXT,FOREIGN KEY (wid) REFERENCES whedcapp_sample(id) ON UPDATE NO ACTION ON DELETE CASCADE)');
          return txn.execute('''
            INSERT INTO user(id, alias, hashed_password, admin, enabled) 
            VALUES
              (1,\'admin\',\'2bb1b4fc0283fd00ac5b8eceb344635354bbb75f9918f34f406d583bce360a343de07441acf12ab350330c8fbe90df5f158ede8abfca07c4280e50f5b670c281\',true,true),
              (2,\'demo\',\'26c669cd0814ac40e5328752b21c4aa6450d16295e4eec30356a06a911c23983aaebe12d5da38eeebfc1b213be650498df8419194d5a26c7e0a50af156853c79\',false,false)
          ''');
        });
      },
      version: 3
  );
  return true;
}
Future<void> insertUser(UserInfo user) async {
  final db = await database;
  await db.transaction((txn) {
    return txn.insert(
        'user',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort
    );
  });
}
Future<List<UserInfo>> users() async {
  final db = await database;
  final List<Map<String,dynamic>> maps = await db.transaction((txn) { return txn.query('user');});
  if (maps.length == 0) {
    return List.empty();
  }
  return List.generate(maps.length,(i) {
    return UserInfo(
        id: maps[i]['id'],
        alias: maps[i]['alias'],
        hashedPassword: maps[i]['hashed_password'],
        admin: maps[i]['admin']==1,
      enabled: maps[i]['enabled']==1
    );
  });
}
Future<UserInfo?> getUserInfo(String alias) async {
  final db = await database;
  final List<Map<String,dynamic>> los2d = await db.transaction((txn) {return txn.query('user',where: 'alias = ?', whereArgs: [alias]);});
  if (los2d.length < 1) {
    return null;
  }
  return UserInfo(
      id: los2d[0]['id'],
      alias: los2d[0]['alias'],
      hashedPassword: los2d[0]['hashed_password'],
      admin: los2d[0]['admin']==1,
      enabled: los2d[0]['enabled']==1
  );
}
Future<void> updateUser(UserInfo user) async {
  final db = await database;
  await db.transaction((txn) {
    return txn.update(
        'user',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id]
    );
  });
}



Future<void> deleteUser(UserInfo user) async {
  final db = await database;
  await db.transaction((txn) {
    return txn.delete(
        'user',
        where: 'id = ?',
        whereArgs: [user.id]

    );
  });
}

Future<int> getNumberOfUsers() async {
  final db = await database;
  final List<Map<String,dynamic>> maps = await db.transaction((txn) { return txn.query('user');});
  return maps.length;
}

Future<int?> getMaxUid() async {
  final db = await database;
  final result = await db.transaction((txn) {
    return txn.rawQuery('SELECT max(id) FROM user');
  });
  return result[0]['max(id)'] as int?;
  //return result;
}

Future<void> insertWhedcappSample(WhedcappSample whedcappSample) async {
  final db = await database;
  await db.transaction((txn) {
    return txn.insert(
        'whedcapp_sample',
        whedcappSample.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort
    );
  });
}
Future<List<WhedcappSample>> whedcappSamples(UserInfo user) async {
  final db = await database;
  final List<UserInfo> userList = await users();
  final List<Map<String,dynamic>> maps = await db.transaction((txn) { return txn.query('whedcapp_sample',where: 'uid = ?',whereArgs: [user.id]);});
  if (maps.length == 0) {
    return List.empty();
  }
  return List.generate(maps.length,(i) {
    return WhedcappSample(
        id: maps[i]['id'],
        user: user,
        dateTime: DateTime.parse(maps[i]['dateTime']),
        wellbeing: maps[i]['wellbeing'],
        senseOfHome: maps[i]['sense_of_home'],
        safety: maps[i]['safety'],
        loneliness: maps[i]['loneliness'],
    );
  });
}
Future<List<WhedcappSample>> whedcappSamplesAll() async {
  final db = await database;
  final List<UserInfo> userList = await users();
  final List<Map<String,dynamic>> maps = await db.transaction((txn) { return txn.query('whedcapp_sample');});
  if (maps.length == 0) {
    return List.empty();
  }
  return List.generate(maps.length,(i) {
    return WhedcappSample(
      id: maps[i]['id'],
      user: userList.firstWhere((e) => e.id == maps[i]['uid']),
      dateTime: DateTime.parse(maps[i]['dateTime']),
      wellbeing: maps[i]['wellbeing'],
      senseOfHome: maps[i]['sense_of_home'],
      safety: maps[i]['safety'],
      loneliness: maps[i]['loneliness'],
    );
  });
}
Future<void> updateWhedcappSample(WhedcappSample whedcappSample) async {
  final db = await database;
  await db.transaction((txn) {
    return txn.update(
        'whedcapp_sample',
        whedcappSample.toMap(),
        where: 'id = ?',
        whereArgs: [whedcappSample.id]
    );
  });
}

Future<void> deleteWhedcappSample(WhedcappSample whedcappSample) async {
  final db = await database;
  await db.transaction((txn) {
    return txn.delete(
        'whedcapp_sample',
        where: 'id = ?',
        whereArgs: [whedcappSample.id]

    );
  });
}

Future<int> getNumberOfWhedcappSamples() async {
  final db = await database;
  //TODO: Improved count query, current sucks
  final List<Map<String,dynamic>> maps = await db.transaction((txn) { return txn.rawQuery('SELECT IFNULL(max(id),0) FROM whedcapp_sample');});
  return maps[0]['IFNULL(max(id),0)']!=null?maps[0]['IFNULL(max(id),0)']:Future<int>(()=>0);
}

Future<void> deleteAllSamples() async {
  final db = await database;
  await db.transaction((txn) {
    return txn.delete('whedcapp_sample');
  });
  return;
}

// Comment
Future<void> insertComment(Comment comment) async {
  final db = await database;
  await db.transaction((txn) {
    return txn.insert(
        'comment',
        comment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort
    );
  });
}
Future<List<Comment>> comments(WhedcappSample whedcappSample) async {
  final db = await database;
  final List<Map<String,dynamic>> maps = await db.transaction((txn) { return txn.query('comment',where: 'wid = ?',whereArgs: [whedcappSample.id]);});
  if (maps.length == 0) {
    return List.empty();
  }
  return List.generate(maps.length,(i) {
    return Comment(
        id: maps[i]['id'],
        whedcappSample: whedcappSample,
        metric: Metric.values[maps[i]['metric']],
        dateTime: DateTime.parse(maps[i]['dateTime']),
        comment: maps[i]['comment']
    );
  });
}
Future<List<Comment>> commentsForUser(UserInfo userInfo) async {
  final db = await database;
  final List<Map<String,dynamic>> maps = await db.transaction((txn)
  {
    return txn.rawQuery('SELECT comment.id as id, comment.wid as wid, comment.metric as series, comment.dateTime as dateTime, comment.comment as comment FROM comment JOIN whedcapp_sample ON comment.wid = whedcapp_sample.id WHERE whedcapp_sample.uid = ?',[userInfo.id]);
  });
  var ws = await whedcappSamples(userInfo);
  if (maps.length == 0) {
    return List.empty();
  }
  return List.generate(maps.length,(i) {
    var result = ws.where((element) => element.id == maps[i]['wid']).toList();
    return Comment(
        id: maps[i]['id'],
        whedcappSample: result[0],
        metric: Metric.values[maps[i]['metric']],
        dateTime: DateTime.parse(maps[i]['dateTime']),
        comment: maps[i]['comment']
    );
  });
}
Future<List<Comment>> commentsForAll() async {
  final db = await database;
  final List<Map<String,dynamic>> maps = await db.transaction((txn)
  {
    return txn.rawQuery('SELECT comment.id as id, comment.wid as wid, comment.metric as series, comment.dateTime as dateTime, comment.comment as comment FROM comment JOIN whedcapp_sample ON comment.wid = whedcapp_sample.id');
  });
  var ws = await whedcappSamplesAll();
  if (maps.length == 0) {
    return List.empty();
  }
  return List.generate(maps.length,(i) {
    var result = ws.where((element) => element.id == maps[i]['wid']).toList();
    return Comment(
        id: maps[i]['id'],
        whedcappSample: result[0],
        metric: Metric.values[maps[i]['metric']],
        dateTime: DateTime.parse(maps[i]['dateTime']),
        comment: maps[i]['comment']
    );
  });
}
Future<void> updateComment(Comment comment) async {
  final db = await database;
  await db.transaction((txn) {
    return txn.update(
        'comment',
        comment.toMap(),
        where: 'id = ?',
        whereArgs: [comment.id]
    );
  });
}
Future<void> deleteComment(Comment comment) async {
  final db = await database;
  await db.transaction((txn) {
    return txn.delete(
        'comment',
        where: 'id = ?',
        whereArgs: [comment.id]

    );
  });
}
Future<int> getNumberOfComments(WhedcappSample whedcappSample) async {
  var db = await database;
  var result = await db.transaction((txn) {
    return txn.rawQuery('SELECT count(id) FROM comment WHERE wid = ?',[whedcappSample.id]);
  });
  return result[0]['count(id)']! as int;
}
Future<int> getMaxIdOfComments() async {
  final db = await database;
  final List<Map<String,dynamic>> maps = await db.transaction((txn) { return txn.rawQuery('SELECT IFNULL(max(id),0) FROM comment');});
  return maps[0]['IFNULL(max(id),0)'];
}
class ConfigColor {
  Series series;
  int color;
  ConfigColor({required this.series,required this.color});
  Map<String,dynamic> toMap() {
    return {
      'id': series.index,
      'color': color
    };
  }

}
Future<List<ConfigColor>> colors() async {
  final db = await database;
  final List<Map<String,dynamic>> maps = await db.transaction((txn) { return txn.query('color_config');});
  if (maps.length == 0) {
    return List.empty();
  }
  return List.generate(maps.length,(i) {
    return ConfigColor(series: Series.values[maps[i]['id']],color: maps[i]['color']);
  });
}
Future<void> updateColor(ConfigColor color) async {
  final db = await database;
  await db.transaction((txn) {
    return txn.update(
        'color_config',
        color.toMap(),
        where: 'id = ?',
        whereArgs: [color.series.index]
    );
  });
}



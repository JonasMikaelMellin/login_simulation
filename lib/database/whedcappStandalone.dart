import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class User {
  final int id;
  final String alias;
  final bool admin;
  final bool supporter;
  final bool enabled;

  User({required this.id, required this.alias, required this.admin, required this.supporter, required this.enabled});

  Map<String,dynamic> toMap() {
    return {
      'alias': alias,
      'admin': admin,
      'enabled': enabled
    };
  }

  @override
  String toString() {
    return 'User(alias: $alias, admin: $admin, enabled: $enabled)';
  }
}

class WhedcappSample {
  final int id;
  final User user;
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
      'senseOfHome': senseOfHome,
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
  WidgetsFlutterBinding.ensureInitialized();
  database = openDatabase(
      join(await getDatabasesPath(),'whedcappStandalone.db'),
      onCreate: (db, version)  async {
        await db.transaction((txn) {
          txn.execute('CREATE TABLE user(id INTEGER PRIMARY KEY, alias TEXT, admin INTEGER, enabled INTEGER)');
          txn.execute('CREATE TABLE whedcapp_sample(id INTEGER PRIMARY KEY, uid INTEGER, dateTime TEXT, wellbeing INTEGER, sense_of_home INTEGER, safety INTEGER, loneliness INTEGER)');
          return txn.execute('CREATE TABLE comment(id INTEGER PRIMARY KEY, wid INTEGER, metric INTEGER, dateTime TEXT, comment TEXT');
        });
      },
      version: 1
  );
  return true;
}
Future<void> insertUser(User user) async {
  final db = await database;
  await db.transaction((txn) {
    return txn.insert(
        'user',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort
    );
  });
}
Future<List<User>> users() async {
  final db = await database;
  final List<Map<String,dynamic>> maps = await db.transaction((txn) { return txn.query('user');});
  if (maps.length == 0) {
    return List.empty();
  }
  return List.generate(maps.length,(i) {
    return User(
        id: maps[i]['id'],
        alias: maps[i]['alias'],
        admin: maps[i]['admin']==1,
      supporter: maps[i]['supporter']==1,
      enabled: maps[i]['enabled']==1
    );
  });
}
Future<void> updateUser(User user) async {
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

Future<void> deleteUser(User user) async {
  final db = await database;
  await db.transaction((txn) {
    return txn.delete(
        'user',
        where: 'id = ?',
        whereArgs: [user.id]

    );
  });
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
Future<List<WhedcappSample>> whedcappSamples(User user) async {
  final db = await database;
  final List<User> userList = await users();
  final List<Map<String,dynamic>> maps = await db.transaction((txn) { return txn.query('whedcapp_sample',where: 'id = ?',whereArgs: [user.id]);});
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


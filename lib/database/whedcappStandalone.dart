/*
This file is part of Whedcapp - standalone.

Whedcapp is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any later version.

Whedcapp is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Foobar. If not, see <https://www.gnu.org/licenses/>.
*/

import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:login_simulation/common/typeInfo.dart';
import 'package:login_simulation/database/whedcappComment.dart';
import 'package:login_simulation/database/userInfo.dart';
import 'package:login_simulation/database/whedcappSample.dart';
import 'package:path/path.dart';
import 'package:reflectable/mirrors.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tuple/tuple.dart';

import '../data.dart';






late Future<Database> database;

Future<bool> initWhedcappStandaloneDatabase() async {
  bool removeDatabase = false; // if you have no file manager in the emulated surf board, set this to true to remove the database file 8-)
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
  database =
      openDatabase(join(await getDatabasesPath(), 'whedcappStandalone.db'),
          onCreate: (db, version) async {
        //TODO: Use AUTO INCREMENT instead, require changing the app in several places
    await db.transaction((txn) {
      txn.execute(
          'CREATE TABLE color_config(id INTEGER PRIMARY KEY, color INTEGER NOT NULL)');
      txn.execute(
          'INSERT INTO color_config(id,color) VALUES(0,2155557524),(1,2158418848),(2,2160240079),(3,2147518519)');
      txn.execute('''
            CREATE TABLE user(
              id INTEGER PRIMARY KEY, 
              alias TEXT NOT NULL, 
              hashed_password TEXT NOT NULL, 
              admin INTEGER NOT NULL, 
              enabled INTEGER NOT NULL)
              ''');
      txn.execute('CREATE UNIQUE INDEX user_index ON user(alias)');
      txn.execute('''
            CREATE TABLE whedcapp_sample(
              id INTEGER PRIMARY KEY, 
              uid INTEGER NOT NULL, 
              dateTime TEXT NOT NULL, 
              wellbeing INTEGER NOT NULL, 
              sense_of_home INTEGER NOT NULL, 
              safety INTEGER NOT NULL, 
              loneliness INTEGER NOT NULL, 
              FOREIGN KEY (uid) REFERENCES user(id) ON UPDATE NO ACTION ON DELETE CASCADE)
              ''');
      txn.execute(
          'CREATE UNIQUE INDEX whedcapp_sample_index ON whedcapp_sample(uid,dateTime)');
      txn.execute('''
            CREATE TABLE comment(
              id INTEGER PRIMARY KEY, 
              wid INTEGER NOT NULL, 
              metric INTEGER NOT NULL, 
              dateTime TEXT NOT NULL, 
              comment_text TEXT NOT NULL,
              FOREIGN KEY (wid) REFERENCES whedcapp_sample(id) ON UPDATE NO ACTION ON DELETE CASCADE)
              ''');
      return txn.execute('''
            INSERT INTO user(id, alias, hashed_password, admin, enabled) 
            VALUES
              (1,\'admin\',\'2bb1b4fc0283fd00ac5b8eceb344635354bbb75f9918f34f406d583bce360a343de07441acf12ab350330c8fbe90df5f158ede8abfca07c4280e50f5b670c281\',true,true),
              (2,\'demo\',\'26c669cd0814ac40e5328752b21c4aa6450d16295e4eec30356a06a911c23983aaebe12d5da38eeebfc1b213be650498df8419194d5a26c7e0a50af156853c79\',false,false)
          ''');
    });
  }, version: 3);

  return true;
}

Future<void> insertUser(UserInfo user) async {
  final db = await database;
  await db.transaction((txn) {
    return txn.insert('user', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort);
  });
}

Future<List<UserInfo>> users() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.transaction((txn) {
    return txn.query('user');
  });
  if (maps.length == 0) {
    return List.empty();
  }
  return List.generate(maps.length, (i) {
    return UserInfo(
        id: maps[i]['id'],
        alias: maps[i]['alias'],
        hashedPassword: maps[i]['hashed_password'],
        admin: maps[i]['admin'] == 1,
        enabled: maps[i]['enabled'] == 1);
  });
}

Future<UserInfo?> getUserInfo(String alias) async {
  final db = await database;
  final List<Map<String, dynamic>> los2d = await db.transaction((txn) {
    return txn.query('user', where: 'alias = ?', whereArgs: [alias]);
  });
  if (los2d.length < 1) {
    return null;
  }
  return UserInfo(
      id: los2d[0]['id'],
      alias: los2d[0]['alias'],
      hashedPassword: los2d[0]['hashed_password'],
      admin: los2d[0]['admin'] == 1,
      enabled: los2d[0]['enabled'] == 1);
}

Future<void> updateUser(UserInfo user) async {
  final db = await database;
  await db.transaction((txn) {
    return txn
        .update('user', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  });
}

Future<void> deleteUser(UserInfo user) async {
  final db = await database;
  await db.transaction((txn) {
    return txn.delete('user', where: 'id = ?', whereArgs: [user.id]);
  });
}

Future<int> getNumberOfUsers() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.transaction((txn) {
    return txn.query('user');
  });
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
    return txn.insert('whedcapp_sample', whedcappSample.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort);
  });
}

Future<List<WhedcappSample>> whedcappSamples(UserInfo user) async {
  final db = await database;
  final List<UserInfo> userList = await users();
  final List<Map<String, dynamic>> maps = await db.transaction((txn) {
    return txn.query('whedcapp_sample', where: 'uid = ?', whereArgs: [user.id]);
  });
  if (maps.length == 0) {
    return List.empty();
  }
  return List.generate(maps.length, (i) {
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
  final List<Map<String, dynamic>> maps = await db.transaction((txn) {
    return txn.query('whedcapp_sample');
  });
  if (maps.length == 0) {
    return List.empty();
  }
  return List.generate(maps.length, (i) {
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
    return txn.update('whedcapp_sample', whedcappSample.toMap(),
        where: 'id = ?', whereArgs: [whedcappSample.id]);
  });
}

Future<void> deleteWhedcappSample(WhedcappSample whedcappSample) async {
  final db = await database;
  await db.transaction((txn) {
    return txn.delete('whedcapp_sample',
        where: 'id = ?', whereArgs: [whedcappSample.id]);
  });
}

Future<int> getNumberOfWhedcappSamples() async {
  final db = await database;

  final List<Map<String, dynamic>> maps = await db.transaction((txn) {
    return txn.rawQuery('SELECT IFNULL(COUNT(id),0) FROM whedcapp_sample');
  });
  return maps[0]['IFNULL(COUNT(id),0)'] != null
      ? maps[0]['IFNULL(COUNT(id),0)']
      : Future<int>(() => 0);
}
Future<int> getWhedcappSamplesMaxId() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.transaction((txn) {
    return txn.rawQuery('SELECT IFNULL(max(id),0) FROM whedcapp_sample');
  });
  return maps[0]['IFNULL(max(id),0)'] != null
      ? maps[0]['IFNULL(max(id),0)']
      : Future<int>(() => 0);
}


Future<void> deleteAllSamples() async {
  final db = await database;
  await db.transaction((txn) {
    return txn.delete('whedcapp_sample');
  });
  return;
}

Future<WhedcappSample> getWhedcappSampleForTimestamp(DateTime timestamp) async {
  final db = await database;
  final List<UserInfo> userList = await users();
  return await db.transaction((txn) async {
    final List<Map<String, dynamic>> maps = await txn.query('whedcapp_sample',
        where: 'dateTime = ?', whereArgs: [timestamp.toIso8601String()]);
    return WhedcappSample(
      id: maps[0]['id'] as int,
      user: userList.firstWhere((e) => e.id == maps[0]['uid']),
      dateTime: DateTime.parse(maps[0]['dateTime']),
      wellbeing: maps[0]['wellbeing'],
      senseOfHome: maps[0]['sense_of_home'],
      safety: maps[0]['safety'],
      loneliness: maps[0]['loneliness'],
    );
  });
}

// Comment
Future<void> insertComment(WhedcappComment comment) async {
  final db = await database;
  await db.transaction((txn) {
    return txn.insert('comment', comment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort);
  });
}

Future<List<WhedcappComment>> comments(WhedcappSample whedcappSample) async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.transaction((txn) {
    return txn
        .query('comment', where: 'wid = ?', whereArgs: [whedcappSample.id]);
  });
  if (maps.length == 0) {
    return List.empty();
  }
  return List.generate(maps.length, (i) {
    return WhedcappComment(
        id: maps[i]['id'],
        whedcappSample: whedcappSample,
        metric: Metric.values[maps[i]['metric']],
        dateTime: DateTime.parse(maps[i]['dateTime']),
        commentText: maps[i]['comment']);
  });
}

Future<List<WhedcappComment>> commentsForUser(UserInfo userInfo) async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.transaction((txn) {
    return txn.rawQuery(
        'SELECT comment.id as id, comment.wid as wid, comment.metric as series, comment.dateTime as dateTime, comment.comment_text as comment FROM comment JOIN whedcapp_sample ON comment.wid = whedcapp_sample.id WHERE whedcapp_sample.uid = ?',
        [userInfo.id]);
  });
  var ws = await whedcappSamples(userInfo);
  if (maps.length == 0) {
    return List.empty();
  }
  return List.generate(maps.length, (i) {
    var result = ws.where((element) => element.id == maps[i]['wid']).toList();
    return WhedcappComment(
        id: maps[i]['id'],
        whedcappSample: result[0],
        metric: Metric.values[maps[i]['series']],
        dateTime: DateTime.parse(maps[i]['dateTime']),
        commentText: maps[i]['comment']);
  });
}

Future<List<WhedcappComment>> commentsForAll() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.transaction((txn) {
    return txn.rawQuery(
        'SELECT comment.id as id, comment.wid as wid, comment.metric as series, comment.dateTime as dateTime, comment.comment_text as scomment FROM comment JOIN whedcapp_sample ON comment.wid = whedcapp_sample.id');
  });
  var ws = await whedcappSamplesAll();
  final x = await db.query('comment');
  if (maps.length == 0) {
    return List.empty();
  }
  return List.generate(maps.length, (i) {
    var result = ws.where((element) => element.id == maps[i]['wid']).toList();
    final c = WhedcappComment(
        id: maps[i]['id'],
        whedcappSample: result[0],
        metric: Metric.values[maps[i]['series']],
        dateTime: DateTime.parse(maps[i]['dateTime']),
        commentText: maps[i]['scomment']);
    return c;
  });
}

Future<void> updateComment(WhedcappComment comment) async {
  final db = await database;
  await db.transaction((txn) {
    return txn.update('comment', comment.toMap(),
        where: 'id = ?', whereArgs: [comment.id]);
  });
}

Future<void> deleteComment(WhedcappComment comment) async {
  final db = await database;
  await db.transaction((txn) {
    return txn.delete('comment', where: 'id = ?', whereArgs: [comment.id]);
  });
}

Future<int> getNumberOfComments(WhedcappSample whedcappSample) async {
  var db = await database;
  var result = await db.transaction((txn) {
    return txn.rawQuery(
        'SELECT count(id) FROM comment WHERE wid = ?', [whedcappSample.id]);
  });
  return result[0]['count(id)']! as int;
}

Future<int> getMaxIdOfComments() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.transaction((txn) {
    return txn.rawQuery('SELECT IFNULL(max(id),0) FROM comment');
  });
  return maps[0]['IFNULL(max(id),0)'];
}
Future<void> deleteAllComments() async {
  final db = await database;
  await db.transaction((txn) {
    return txn.delete('comment');
  });
  return;
}
class ConfigColor {
  Series series;
  int color;
  ConfigColor({required this.series, required this.color});
  Map<String, dynamic> toMap() {
    return {'id': series.index, 'color': color};
  }
}

Future<List<ConfigColor>> colors() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.transaction((txn) {
    return txn.query('color_config');
  });
  if (maps.length == 0) {
    return List.empty();
  }
  return List.generate(maps.length, (i) {
    return ConfigColor(
        series: Series.values[maps[i]['id']], color: maps[i]['color']);
  });
}

Future<void> updateColor(ConfigColor color) async {
  final db = await database;
  await db.transaction((txn) {
    return txn.update('color_config', color.toMap(),
        where: 'id = ?', whereArgs: [color.series.index]);
  });
}

/*
This file is part of Whedcapp - standalone.

Whedcapp is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any later version.

Whedcapp is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Foobar. If not, see <https://www.gnu.org/licenses/>.
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:login_simulation/common/defaultAppbar.dart';
import 'package:login_simulation/database/whedcappStandalone.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import '../data.dart';
import '../common/navDrawer.dart';
import 'adminCommentsDatabaseMgmtScreen.dart';
import 'adminDatabaseMgmtScreen.dart';
import 'adminDemoMgmtScreen.dart';
import 'adminUserMgmtScreen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  static String route = '/administrator/adminScreen';
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late DatabaseInfo databaseInfo;
  @override
  Widget build(BuildContext context) {
    return _buildAdminScreen(context);
  }

  @override
  void initState() {
    databaseInfo = DatabaseInfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getNumberOfUsers().then ((nou) {
      setState(() {
        this.databaseInfo.numberOfUsers = nou;
      });
    });
    getNumberOfWhedcappSamples().then((now) {
      setState(() {
        this.databaseInfo.numberOfRecords = now;
      });
    });
  }

  Widget _buildAdminScreen(BuildContext context) {
    return Scaffold(
        drawer: NavDrawer(),
        appBar: defaultAppBar(context,AppLocalizations.of(context)!.adminScreenTitle),
      body: _buildAdminBody(context)
    );
  }
  Widget _buildAdminBody(context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: this.databaseInfo)
      ],
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(AppLocalizations.of(context)!.adminScreenNumberOfUsers),
                      Consumer<DatabaseInfo>(
                        builder: (context,snarf,child) {
                          return Text('${this.databaseInfo.numberOfUsers}');
                        }
                      )
                    ]
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(AppLocalizations.of(context)!.adminScreenNumberOfRecords),
                      Consumer<DatabaseInfo>(
                        builder: (context,snarf,child) {
                          return Text('${this.databaseInfo.numberOfRecords}');
                        }
                      )
                    ]
                  ),
                )
              ]
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                _buildDatabaseMgmtButton(context),
                _buildCommentDatabaseMgmtButton(context),
                _buildUserMgmtButton(context),
            ]
            )
          ]
        )
      ),
    );
  }

  _buildDatabaseMgmtButton(context) {
    return ElevatedButton(
        onPressed: () {
          _navigateToAdminDatabaseScreen(context);
          getNumberOfUsers().then((numberOfUsers) => setState(() {databaseInfo.numberOfUsers = numberOfUsers;}));
          getNumberOfWhedcappSamples().then((numberOfRecords) => setState(() {databaseInfo.numberOfRecords = numberOfRecords;}));
        },
        child: Text(AppLocalizations.of(context)!.adminScreenDatabaseManagementButtonText));
  }

  _buildCommentDatabaseMgmtButton(context) {
    return ElevatedButton(
        onPressed: () {
          _navigateToAdminCommentsDatabaseScreen(context);
          getNumberOfUsers().then((numberOfUsers) => setState(() {databaseInfo.numberOfUsers = numberOfUsers;}));
          getNumberOfWhedcappSamples().then((numberOfRecords) => setState(() {databaseInfo.numberOfRecords = numberOfRecords;}));
        },
        child: Text(AppLocalizations.of(context)!.adminScreenCommentsDatabaseManagementButtonText));
  }


  void _navigateToAdminDatabaseScreen(context) {
    Navigator.pushNamed(context,AdminDatabaseMgmtScreen.route);
  }

  void _navigateToAdminCommentsDatabaseScreen(context) {
    Navigator.pushNamed(context,AdminCommentsDatabaseMgmtScreen.route);
  }


  void _navigateToAdminDemoMgmtScreen(context) {
    Navigator.pushNamed(context,AdminDemoMgmtScreen.route);
  }

  _buildUserMgmtButton(context) {
    return ElevatedButton(
      onPressed: () {
        _navigateToAdminUserMgmtScreen(context);
        getNumberOfUsers().then((numberOfUsers) => setState(() {databaseInfo.numberOfUsers = numberOfUsers;}));
        getNumberOfWhedcappSamples().then((numberOfRecords) => setState(() {databaseInfo.numberOfRecords = numberOfRecords;}));
        },
        child: Text(AppLocalizations.of(context)!.adminScreenUserManagementButtonText)

    );
  }

  void _navigateToAdminUserMgmtScreen(context) {
    Navigator.pushNamed(context,AdminUserMgmtScreen.route);
  }
}
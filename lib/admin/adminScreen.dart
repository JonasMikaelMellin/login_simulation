import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../navDrawer.dart';
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
  @override
  Widget build(BuildContext context) {
    return _buildAdminScreen(context);
  }

  Widget _buildAdminScreen(BuildContext context) {
    return Scaffold(
        drawer: NavDrawer(),
        appBar: AppBar(
          title: Text('Admin Screen'),
          //leading: Icon(Icons.menu),
        ),
      body: _buildAdminBody(context)
    );
  }
  Widget _buildAdminBody(context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDatabaseMgmtButton(context),
          _buildDemoMgmtButton(context),
          _buildUserMgmtButton(context),
        ]
      )
    );
  }

  _buildDatabaseMgmtButton(context) {
    return ElevatedButton(
        onPressed: () {
          _navigateToAdminDatabaseScreen(context);
        },
        child: Text('Database management'));
  }

  void _navigateToAdminDatabaseScreen(context) {
    Navigator.pushNamed(context,AdminDatabaseMgmtScreen.route);
  }

  _buildDemoMgmtButton(context) {
    return ElevatedButton(
      onPressed: () {
        _navigateToAdminDemoMgmtScreen(context);
      },
      child: Text('Handle demonstration')

    );
  }

  void _navigateToAdminDemoMgmtScreen(context) {
    Navigator.pushNamed(context,AdminDemoMgmtScreen.route);
  }

  _buildUserMgmtButton(context) {
    return ElevatedButton(
      onPressed: () {
        _navigateToAdminUserMgmtScreen(context);
        },
        child: Text('User management')

    );
  }

  void _navigateToAdminUserMgmtScreen(context) {
    Navigator.pushNamed(context,AdminUserMgmtScreen.route);
  }
}
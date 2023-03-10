/*
This file is part of Whedcapp - standalone.

Whedcapp is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any later version.

Whedcapp is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Foobar. If not, see <https://www.gnu.org/licenses/>.
*/

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:login_simulation/common/defaultAppbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:login_simulation/database/userInfo.dart';
import 'package:login_simulation/database/whedcappStandalone.dart';

import '../common/navDrawer.dart';
import 'adminChangePasswordArg.dart';


class AdminChangePasswordScreen extends StatefulWidget {
  const AdminChangePasswordScreen({Key? key}) : super(key: key);

  static String route = '/administrator/changePassword';

  @override
  _AdminChangePasswordScreenState createState() => _AdminChangePasswordScreenState();
}

class _AdminChangePasswordScreenState extends State<AdminChangePasswordScreen> {
  late UserInfo user;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      var req = ModalRoute.of(context)!.settings.arguments as AdminChangePasswordArgReq;
      this.user = req.user;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavDrawer(),
        appBar: defaultAppBar(context,AppLocalizations.of(context)!.adminChangePasswordTitle),
      body: _buildBody(context)
    );
  }



  _buildBody(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _editingPasswordController = TextEditingController();
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              Text(AppLocalizations.of(context)!.adminLabelAlias + ': '),
              Text(user.alias)
            ]
          ),
          TextFormField(
              cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
              maxLength: 64,
              maxLines: 1,
              obscureText: true,
              enabled: true,
              controller: _editingPasswordController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.adminLabelPassword,
                  helperText: AppLocalizations.of(context)!.adminHelpTextPassword,
                  enabledBorder: UnderlineInputBorder(
                      borderSide:
                      BorderSide(color: Theme.of(context).dividerColor)))
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children:[
              ElevatedButton(
                child: Text(AppLocalizations.of(context)!.acceptButtonText),
                onPressed: () {
                  Navigator.pop(context,AdminChangePasswordArgRep(hashedPassword: sha512.convert(utf8.encode(_editingPasswordController.text)).toString()));
                }
              ),
              ElevatedButton(
                child: Text(AppLocalizations.of(context)!.cancelButtonText),
                onPressed: () {
                  Navigator.pop(context);
                }
              )
            ]
          )
        ]
      ),
    );
  }
}

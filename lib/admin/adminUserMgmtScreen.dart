import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:login_simulation/common/crudOperations.dart';
import 'package:login_simulation/common/defaultAppbar.dart';
import 'package:login_simulation/database/whedcappStandalone.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import '../data.dart';
import '../common/navDrawer.dart';
import 'adminChangePasswordArg.dart';
import 'adminChangePasswordScreen.dart';
import 'adminCrudUserArgs.dart';
import 'adminCrudUserScreen.dart';

class AdminUserMgmtScreen extends StatefulWidget {
  const AdminUserMgmtScreen({Key? key}) : super(key: key);

  static String route = '/administrator/userMgmt';

  @override
  _AdminUserMgmtScreenState createState() => _AdminUserMgmtScreenState();
}

class _AdminUserMgmtScreenState extends State<AdminUserMgmtScreen> {
  final double listRowPadding = 2.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: defaultAppBar(context,AppLocalizations.of(context)!.adminUserMgmtScreenTitle),
      body: Column(
        children: [SizedBox(
          height: MediaQuery.of(context).size.height*0.8,
          child: FutureBuilder(
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState != ConnectionState.done ||
                  snapshot.hasData == null || snapshot.hasError) {
                return Container(
                    child: Center(child: Text('No users in the database yet')));
              }
              List<UserInfo> users = snapshot.data;
              return ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemCount: users.length+1,
                itemBuilder: (context,index) {
                  return index == 0?
                  Row(children:
                  [
                    _buildListColumn(context,
                        Theme.of(context).textTheme.bodyText1!.fontSize!*AppLocalizations.of(context)!.adminLabelId.toString().length*0.5,
                        AppLocalizations.of(context)!.adminLabelId),
                    _buildListColumn(context,Theme.of(context).textTheme.bodyText1!.fontSize!*10,AppLocalizations.of(context)!.adminLabelAlias),
                    _buildListColumn(context,Theme.of(context).textTheme.bodyText1!.fontSize!*5,AppLocalizations.of(context)!.adminLabelAdmin),
                    _buildListColumn(context,Theme.of(context).textTheme.bodyText1!.fontSize!*5,AppLocalizations.of(context)!.adminLabelEnabled),

                  ]):Row(
                      children: [
                        _buildListColumn(context,
                            Theme.of(context).textTheme.bodyText1!.fontSize!*AppLocalizations.of(context)!.adminLabelId.toString().length*0.5
                            ,users[index-1].id),
                        _buildListColumn(context,Theme.of(context).textTheme.bodyText1!.fontSize!*10,users[index-1].alias),
                        _buildListColumn(context,Theme.of(context).textTheme.bodyText1!.fontSize!*5,users[index-1].admin),
                        _buildListColumn(context,Theme.of(context).textTheme.bodyText1!.fontSize!*5,users[index-1].enabled),
                        index > 2 ? GestureDetector(
                          onTap: () {
                            _navigateToConfirmDeleteUser(context,users[index-1]);
                            setState(() {});
                          },

                          child: Icon(Icons.delete),
                        ) : SizedBox(width:25.0,child: Text(' ')),
                        GestureDetector(
                          onTap: () {
                            _navigateToUpdateUser(context,users[index-1]);
                            setState((){});
                          },
                          child: Icon(Icons.edit)
                        ),
                        GestureDetector(
                          onTap: () {
                            _navigateToViewUser(context,users[index-1]);
                            setState((){});
                          },
                          child: Icon(Icons.visibility)
                        ),
                        GestureDetector(
                          onTap: () {
                            var result = Navigator.pushNamed(context, AdminChangePasswordScreen.route,arguments: AdminChangePasswordArgReq(user: users[index-1]));
                            result.then((v){
                              if (v != null) {
                                final u = users[index-1];
                                var nu = UserInfo(
                                  id: u.id,
                                  alias: u.alias,
                                  hashedPassword: (v as AdminChangePasswordArgRep).hashedPassword,
                                  admin: u.admin,
                                  enabled: u.enabled
                                );
                                setState(() {
                                  updateUser(nu);
                                });
                              }
                            });
                          },
                          child: Icon(Icons.change_circle)
                        )
                      ]
                  );
                }
              );
            },
            future: users()

          ),
        ),
          ElevatedButton(
            child: Text(AppLocalizations.of(context)!.acceptButtonText),
            onPressed: () {
              Navigator.pop(context);
            }
          )
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()  {
          this.setState(() {
            _navigateToCrudUserScreenAndAddData();
          });
        },
        child: const Icon(Icons.add_circle_sharp),
        backgroundColor: Colors.green,
      ),
    );
  }
  _buildListColumn(BuildContext context, double width, dynamic value) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: EdgeInsets.all(listRowPadding),
        child: Text('$value')
      )
    );
  }

  void _navigateToConfirmDeleteUser(BuildContext context, UserInfo user) {
    var result = Navigator.pushNamed(context,AdminCrudUserScreen.route,arguments: CrudUserArgReq(
        crudOp: CrudOp.DELETE,
        user: user));
    result.then((v) {
      if (v!= null) {
        setState(() {
          deleteUser(v as UserInfo);
        });
      }
    });
  }

  void _navigateToCrudUserScreenAndAddData() async {
    int? maxUid = await getMaxUid();
    if (maxUid == null) {
      maxUid = 2;
    }
    var result = Navigator.pushNamed(context,AdminCrudUserScreen.route,
        arguments: CrudUserArgReq(
            crudOp: CrudOp.CREATE,
            user: UserInfo(
                id: maxUid+1,
                alias: '',
                hashedPassword: '',
                admin: false,
                enabled: true)) );
    result.then((v) {
      if (v != null) {
        final u = v as UserInfo;
        var inputBytes = utf8.encode(v.hashedPassword);
        var result = sha512.convert(inputBytes);

        final realUserData = UserInfo(id: u.id, alias: u.alias, hashedPassword: result.toString(), admin: u.admin, enabled: u.enabled);
        setState(() {
          insertUser(realUserData);
        });
      }
    });
  }

  void _navigateToUpdateUser(BuildContext context, UserInfo user) {
    var result = Navigator.pushNamed(context,AdminCrudUserScreen.route,
        arguments: CrudUserArgReq(
            crudOp: CrudOp.UPDATE,
            user: user ));
    result.then((v) {
      if (v != null) {
        setState(() {
          updateUser(v as UserInfo);
        });
      }
    });

  }

  void _navigateToViewUser(BuildContext context, UserInfo user) {
    var result = Navigator.pushNamed(context,AdminCrudUserScreen.route,
        arguments: CrudUserArgReq(
            crudOp: CrudOp.READ,
            user: user ));

  }
}

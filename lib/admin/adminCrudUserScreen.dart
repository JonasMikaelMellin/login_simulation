import 'package:flutter/material.dart';
import 'package:login_simulation/admin/adminChangePasswordArg.dart';
import 'package:login_simulation/admin/genUserAdminTextEditingControllers.dart';
import 'package:login_simulation/common/crudOperations.dart';
import 'package:login_simulation/common/defaultAppbar.dart';
import 'package:login_simulation/common/typeInfo.dart';
import 'package:login_simulation/database/whedcappStandalone.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../common/navDrawer.dart';
import 'adminChangePasswordScreen.dart';
import 'adminCrudUserArgs.dart';

class AdminCrudUserScreen extends StatefulWidget {
  const AdminCrudUserScreen({Key? key}) : super(key: key);

  static String route = '/administrator/confirmDeleteUser';

  @override
  _AdminCrudUserScreenState createState() => _AdminCrudUserScreenState();
}

class _AdminCrudUserScreenState extends State<AdminCrudUserScreen> {
  _AdminCrudUserScreenState() {}
  final _formKey = GlobalKey<FormState>();
  var idEditCtrl = TextEditingController();
  var aliasEditCtrl = TextEditingController();
  var passwordEditCtrl = TextEditingController();
  //var editingCtrl = genUserAdminTextEditingControllers();
  bool adminFlag = false;
  bool enabledFlag = false;
  late UserInfo user;
  late CrudOp crudOp;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final crudUserReq =
        ModalRoute.of(context)!.settings.arguments as CrudUserArgReq;
    if (crudUserReq != null) {
      setState(() {
        UserInfo.field.entries
            .where((e) => e.value.type != TypeInfo.BOOL)
            .forEach((e) {
          if (e.key == 0) {
            idEditCtrl.text = genString(crudUserReq, e.value);
          } else if (e.key == 1) {
            aliasEditCtrl.text = genString(crudUserReq, e.value);
          } else if (e.key == 2) {
            passwordEditCtrl.text = genString(crudUserReq, e.value);
          }
          user = crudUserReq.user;
          crudOp = crudUserReq.crudOp;
        });
        adminFlag = user.admin;
        enabledFlag = user.enabled;
      });
    } else {
      throw Exception('Developmental error, no argument passed');
    }
  }

  String genString(CrudUserArgReq crudUserReq, FormEntryInfo formEntryInfo) {
    String tmp;
    var value = crudUserReq.user.get(formEntryInfo.name);
    switch (formEntryInfo.type) {
      case TypeInfo.DOUBLE:
        tmp = (value as double).toString();
        break;
      case TypeInfo.INT:
        tmp = (value as int).toString();
        break;
      case TypeInfo.STRING:
        tmp = value;
        break;
      default:
        throw Exception('Unbelievable exception');
    }
    return tmp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavDrawer(),
        appBar: defaultAppBar(context, genCrudUserScreenTitle(crudOp)),
        body: _buildBody(context));
  }

  _buildBody(BuildContext context) {
    List<FormEntryInfo> editableColumns = UserInfo.field.entries
        .where((e) => e.value.type != TypeInfo.BOOL)
        .map((e) => e.value)
        .toList();
    List<FormEntryInfo> switchableColumns = UserInfo.field.entries
        .where((e) => e.value.type == TypeInfo.BOOL)
        .map((e) => e.value)
        .toList();
    return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              children:
                  _buildFields(context, editableColumns, switchableColumns) +
                      [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(
                                        context,
                                        UserInfo(
                                            id: int.parse(idEditCtrl.text),
                                            alias: aliasEditCtrl.text,
                                            hashedPassword:
                                                passwordEditCtrl.text,
                                            admin: adminFlag,
                                            enabled: enabledFlag));
                                  },
                                  child: Text(AppLocalizations.of(context)!
                                      .acceptButtonText)),
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(AppLocalizations.of(context)!
                                      .cancelButtonText)),
                              ElevatedButton(
                                onPressed: () {
                                  var result = Navigator.pushNamed(context,AdminChangePasswordScreen.route,arguments: AdminChangePasswordArgReq(user: user));
                                  result.then((v) {
                                    if (v != null) {
                                      final adminChangePasswordArgRep = v as AdminChangePasswordArgRep;
                                      setState(() {
                                        updateUser(UserInfo(
                                          id: user.id,
                                          alias: user.alias,
                                          hashedPassword: adminChangePasswordArgRep.hashedPassword,
                                          admin: user.admin,
                                          enabled: user.enabled
                                        ));
                                        user.hashedPassword = adminChangePasswordArgRep.hashedPassword;
                                        passwordEditCtrl.text = adminChangePasswordArgRep.hashedPassword;
                                      });
                                    }
                                  });
                                },
                                child: Text(AppLocalizations.of(context)!.adminChangePasswordButton)
                              )

                            ]),

                      ]),
        ));
  }

  _buildFields(context, List<FormEntryInfo> editableColumns,
      List<FormEntryInfo> switchableColumns) {
    // It should be possible to use List.generate here instead. However, that failed
    // and now I add this "working" solution.
    List<Widget> l = [];
    l += [
      TextFormField(
          cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
          maxLength: 64,
          maxLines: 1,
          obscureText: false,
          enabled: false,
          controller: idEditCtrl,
          decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.adminLabelId,
              helperText: AppLocalizations.of(context)!.adminHelpTextId,
              enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).dividerColor))))
    ];
    l += [
      TextFormField(
          cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
          maxLength: 64,
          maxLines: 1,
          obscureText: false,
          enabled: crudOp != CrudOp.DELETE && crudOp != CrudOp.READ,
          controller: aliasEditCtrl,
          decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.adminLabelAlias,
              helperText: AppLocalizations.of(context)!.adminHelpTextAlias,
              enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).dividerColor))))
    ];
    l += [
      TextFormField(
          cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
          maxLength: 64,
          maxLines: 1,
          obscureText: true,
          enabled: crudOp != CrudOp.DELETE && crudOp != CrudOp.READ,
          controller: passwordEditCtrl,
          decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.adminLabelPassword,
              helperText: AppLocalizations.of(context)!.adminHelpTextPassword,
              enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).dividerColor))))
    ];

    l += [
      Row(children: [
        Text(AppLocalizations.of(context)!.adminLabelAdmin),
        Switch(
          onChanged: (value) {
            if (crudOp != CrudOp.DELETE && crudOp != CrudOp.READ) {
              setState(() {
                adminFlag = value;
              });
            }
          },
          value: adminFlag,
        ),
      ])
    ];

    l += [
      Row(children: [
        Text(AppLocalizations.of(context)!.adminLabelEnabled),
        Switch(
            onChanged: (value) {
              if (crudOp != CrudOp.DELETE && crudOp != CrudOp.READ) {
                setState(() {
                  enabledFlag = value;
                });
              }
            },
            value: enabledFlag),
      ])
    ];

    return l;
  }

  String genCrudUserScreenTitle(CrudOp crudOp) {
    switch (crudOp) {
      case CrudOp.CREATE:
        return AppLocalizations.of(context)!.adminCrudUserScreenCreateTitle;
      case CrudOp.UPDATE:
        return AppLocalizations.of(context)!.adminCrudUserScreenUpdateTitle;
      case CrudOp.DELETE:
        return AppLocalizations.of(context)!.adminCrudUserScreenDeleteTitle;
      case CrudOp.READ:
        return AppLocalizations.of(context)!.adminCrudUserScreenReadTitle;
    }
  }
}

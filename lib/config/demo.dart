
import 'dart:math';

import 'package:login_simulation/database/userInfo.dart';
import 'package:login_simulation/database/whedcappComment.dart';
import 'package:login_simulation/database/whedcappSample.dart';
import 'package:login_simulation/database/whedcappStandalone.dart';

import '../data.dart';

class Demo {
  static void initializeDemo() async {
    final numberOfSamples = 100;
    var r = Random(1);

    List<Data> dataObj = List.generate(
        numberOfSamples,
            (index) =>
        new Data(
            date: DateTime.now().subtract(Duration(days: numberOfSamples - index)),
            series2datum: {
              Series.Wellbeing: Datum(
                value: r.nextInt(10) + 1,
                information: List.generate(r.nextInt(3),
                        (index2) => 'Kommentar ${index2.toString()}'),
              ),
              Series.SenseOfHome: Datum(
                value: r.nextInt(10) + 1,
                information: List.generate(r.nextInt(3),
                        (index2) => 'Kommentar ${index2.toString()}'),
              ),
              Series.Safety: Datum(
                value: r.nextInt(10) + 1,
                information: List.generate(r.nextInt(3),
                        (index2) => 'Kommentar ${index2.toString()}'),
              ),
              Series.Loneliness: Datum(
                value: r.nextInt(10) + 1,
                information: List.generate(r.nextInt(3),
                        (index2) => 'Kommentar ${index2.toString()}'),
              )
            }));
    int maxid = await getWhedcappSamplesMaxId()+1;
    int maxcid = await getMaxIdOfComments()+1;
    var user = await getUserInfo('demo');
    int ccount = 0;
    dataObj.forEach((o) {
      var tmp = WhedcappSample(
        id: maxid++,
        user: user!,
        dateTime: o.date,
        wellbeing: o.series2datum[Series.Wellbeing]!.value,
        safety: o.series2datum[Series.Safety]!.value,
        loneliness: o.series2datum[Series.Loneliness]!.value,
        senseOfHome: o.series2datum[Series.SenseOfHome]!.value,
      );
      insertWhedcappSample(tmp);
      Series.values.forEach((s) {
        o.series2datum[s]!.information.forEach((c) {
          final c = WhedcappComment(
              id: maxcid++,
              commentText: 'Kommentar ${ccount++}',
              dateTime: o.date,
              metric: Metric.values[s.index],
              whedcappSample: tmp
          );
          insertComment(c);
        });
      });
    });
    var demoUser = getUserInfo('demo');
    demoUser.then((d) {
      updateUser(UserInfo(
          id: d!.id,
          alias: d.alias,
          admin: d.admin,
          hashedPassword: d.hashedPassword,
          enabled: true
      ));
    });
  }

  static void removeDemo() {
    var demoUser = getUserInfo('demo');
    demoUser.then((d) {
      updateUser(UserInfo(
          id: d!.id,
          alias: d.alias,
          admin: d.admin,
          hashedPassword: d.hashedPassword,
          enabled: false
      ));
      var result = whedcappSamples(d);
      result.then((lowso) {
        final lows = lowso as List<WhedcappSample>;
        lows.forEach((ws) => deleteWhedcappSample(ws as WhedcappSample));
      });
    });
  }
}
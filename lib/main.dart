import 'dart:math';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rehabnow_app/components/skeleton.dart';
import 'package:rehabnow_app/models/exercise.model.dart';
import 'package:rehabnow_app/pages/cases/view_cases.dart';
import 'package:rehabnow_app/pages/connection/connection.dart';
import 'package:rehabnow_app/pages/exercises/exercises.dart';
import 'package:rehabnow_app/pages/home/login.dart';
import 'package:rehabnow_app/pages/profile/view_profile.dart';
import 'package:rehabnow_app/pages/reminder/view_reminder.dart';
import 'package:rehabnow_app/services/exercise.http.service.dart';
import 'package:rehabnow_app/services/login.http.service.dart';
import 'package:rehabnow_app/utils/flutter_secure_storage.dart';
import 'package:rehabnow_app/utils/loading.dart';
import 'package:rehabnow_app/utils/shared_preferences.dart';
import 'package:rehabnow_app/utils/time.constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/src/text_element.dart';
import 'package:charts_flutter/src/text_style.dart' as style;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  // RehabnowSharedPreferences preferences;
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  print(await FlutterNativeTimezone.getLocalTimezone());
  tz.setLocalLocation(
      tz.getLocation(await FlutterNativeTimezone.getLocalTimezone()));
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);

  final MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings();

  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: selectNotification,
  );
  SharedPreferences.getInstance()
      .then((value) => RehabnowSharedPreferences.sharedPreferences = value);

  runApp(MyApp());
}

Future selectNotification(String? payload) async {
  if (payload != null) {
    debugPrint('notification payload: $payload');
  }
}

Future onDidReceiveLocalNotification(
    int i, String? s1, String? s2, String? s3) async {}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.cyan,
          primaryColor: Color.fromRGBO(152, 51, 174, 1),
          primaryIconTheme: IconThemeData(color: Colors.white),
          primaryTextTheme:
              TextTheme(headline6: TextStyle(color: Colors.white)),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.white),
              backgroundColor: MaterialStateProperty.all(
                Color.fromRGBO(152, 51, 174, 1),
              ),
            ),
          ),
          snackBarTheme: SnackBarThemeData(
              backgroundColor: Color.fromRGBO(152, 51, 174, 1)),
          appBarTheme: AppBarTheme(
            brightness: Brightness.dark,
            centerTitle: true,
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            backgroundColor: Colors.grey[200], body: SafeArea(child: Login())));
  }
}

enum GameState {
  PRECHECK_BLUETOOTH_STATUS,
  PRECHECK_DEVICE_CONNECTION,
  PRE_DEVICE_NOT_DETECTED,
  READY,
  BLUETOOTH_DISCONNECTED,
  DEVICE_CONNECTING,
  DEVICE_DISCONNECTED,
}

/// Sample linear data type.
class LinearSales {
  final int year;
  final int sales;

  LinearSales(this.year, this.sales);
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _time = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> drawers = [
      'Case',
      'Connect Wearable Devices',
      'Exercise',
      'Reminder',
      'Profile',
      'Logout'
    ];
    List<IconData> drawerIcons = [
      Icons.local_hospital,
      Icons.bluetooth,
      Icons.airline_seat_recline_extra,
      Icons.alarm,
      Icons.person_outline,
      Icons.exit_to_app,
    ];
    List<Function()?> drawerFunctions = [
      () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ViewCases()));
      },
      () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Connection()));
      },
      () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Exercises()));
      },
      () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ViewReminder()));
      },
      () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Profile()));
      },
      () {
        logout();
        Navigator.pop(context);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MyApp()));
      }
    ];

    return Scaffold(
        appBar: AppBar(
          title: Text("Home"),
        ),
        drawer: Drawer(
          child: SafeArea(
              child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(padding: EdgeInsets.all(10)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/logo1.png",
                      width: 80,
                    ),
                    Text(
                      "RehabNow",
                      style: TextStyle(fontSize: 25),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                ),
                Flexible(
                  child: ListView.separated(
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('${drawers[index]}'),
                          leading: Icon(drawerIcons[index]),
                          onTap: drawerFunctions[index],
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                        );
                      },
                      separatorBuilder: (context, index) => Divider(height: 0),
                      itemCount: drawers.length),
                )
              ],
            ),
          )),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          child: FutureBuilder<List<ExerciseRecords>>(
              future: getExercisesRecords(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<charts.Series<ExerciseData, DateTime>> datas = snapshot
                          .data
                          ?.map((exerciseRecords) {
                        int color = Random().nextInt(Colors.primaries.length);
                        return charts.Series<ExerciseData, DateTime>(
                          data: exerciseRecords.exercises,
                          colorFn: (datum, index) =>
                              charts.ColorUtil.fromDartColor(
                                  Colors.primaries[color]),
                          domainFn: (datum, index) =>
                              DateTime.fromMillisecondsSinceEpoch(
                                  datum.dateTime // % 10 + Random().nextInt(10)
                                  ),
                          id: exerciseRecords.partName,
                          measureFn: (datum, index) => datum.oscillation,
                          // displayName: exerciseRecords.partName,
                          // labelAccessorFn: (datum, index) => "hi",
                          // keyFn: (datum, index) => "key",
                          radiusPxFn: (datum, index) => 3,
                          strokeWidthPxFn: (datum, index) => 3,
                          // measureFormatterFn: (datum, index) =>
                          //     (num) => "measure",
                          // dashPatternFn: (datum, index) => [0, 1, 1, 1],
                          // domainFormatterFn: (datum, index) =>
                          //     (aa) => "sth",
                          // measureLowerBoundFn: (datum, index) => 10,
                          // measureOffsetFn: (datum, index) => 20,
                          // measureUpperBoundFn: (datum, index) => 10,
                          // seriesCategory: "cat",
                        );
                      }).toList() ??
                      [];

                  List<MeterRecordDisplay?> _meterDisplays = snapshot.data
                          ?.map((exerciseRecords) {
                        return MeterRecordDisplay(
                            name: exerciseRecords.partName,
                            lastOsc: exerciseRecords.exercises.last.oscillation,
                            targetOsc:
                                exerciseRecords.targets.first.oscillationNum ??
                                    0);
                      }).toList() ??
                      [];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0;
                              i < _meterDisplays.length || i < 2;
                              i++)
                            _partTarget(
                              meterRecordDisplay: _meterDisplays[i]!,
                            ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 2; i < _meterDisplays.length; i++)
                            _partTarget(
                              meterRecordDisplay: _meterDisplays[i]!,
                            ),
                        ],
                      ),
                      Container(
                        height: 350 + (datas.length / 2) * 35.0,
                        margin: EdgeInsets.only(top: 30),
                        // width: 300,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: charts.TimeSeriesChart(
                            datas,
                            defaultRenderer: charts.LineRendererConfig(
                              includePoints: true,
                            ),
                            // domainAxis: charts.DateTimeAxisSpec(),
                            selectionModels: [
                              charts.SelectionModelConfig(
                                // type: charts.SelectionModelType.info,
                                changedListener: (model) {
                                  print(model);
                                  if (model.hasDatumSelection) {
                                    print(model.selectedSeries[0].measureFn(
                                        model.selectedDatum[0].index));
                                    _time =
                                        "${DATETIME_FORMAT.format(DateTime.fromMillisecondsSinceEpoch(model.selectedDatum[0].datum.dateTime as int))}: ${model.selectedSeries[0].measureFn(model.selectedDatum[0].index)}";

                                    // model.selectedSeries[0]
                                    //     .measureFn(model.selectedDatum[0].index)
                                    //     .toString();
                                  }
                                  // setState(() {});
                                },
                              )
                            ],
                            behaviors: [
                              charts.LinePointHighlighter(
                                  symbolRenderer: RehabnowCustomSymbolRenderer1(
                                      () => _time,
                                      MediaQuery.of(context).size.width)),
                              charts.ChartTitle(
                                "Number of oscillations per parts",
                                behaviorPosition: charts.BehaviorPosition.top,
                                innerPadding: 50,
                              ),
                              charts.ChartTitle(
                                "Date Time",
                                behaviorPosition:
                                    charts.BehaviorPosition.bottom,
                                titleStyleSpec:
                                    charts.TextStyleSpec(fontSize: 12),
                              ),
                              charts.ChartTitle(
                                "Oscillation",
                                behaviorPosition: charts.BehaviorPosition.start,
                                titleStyleSpec:
                                    charts.TextStyleSpec(fontSize: 12),
                              ),
                              charts.SeriesLegend(
                                desiredMaxColumns: 2,
                                position: charts.BehaviorPosition.bottom,
                              ),
                              charts.PanAndZoomBehavior()
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                } else {
                  return Skeleton(
                    child: Text(""),
                    isLoading: true,
                  );
                }
              }),
        )));
  }
}

class RehabnowCustomSymbolRenderer1 extends charts.CircleSymbolRenderer {
  String Function() text;
  double mediaWidth;
  static const List<int> _list = [];
  static const _color = charts.Color();
  late double max;

  RehabnowCustomSymbolRenderer1(this.text, this.mediaWidth) {
    max = mediaWidth - 100 - 20;
  } // ColorUtil.fromDartColor(Colors.black);

  @override
  void paint(charts.ChartCanvas canvas, Rectangle<num> bounds,
      {List<int> dashPattern = _list,
      charts.Color fillColor = _color,
      charts.FillPatternType fillPattern = charts.FillPatternType.solid,
      charts.Color strokeColor = _color,
      double strokeWidthPx = 1}) {
    // super.paint(canvas, bounds);
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidthPx: strokeWidthPx);
    // canvas.drawRect(bounds, fill: charts.Color.black);

    canvas.drawRect(
        Rectangle(
            bounds.left > max ? max - bounds.width : bounds.left - 10,
            bounds.top < 50 ? 23 : bounds.top - 30,
            bounds.width + 100,
            bounds.height + 10),
        fill: charts.Color.white);
    canvas.drawText(
        TextElement(text(),
            style: style.TextStyle()
              ..color = charts.Color.black
              ..fontSize = 10),
        (bounds.left > max ? max - bounds.width : bounds.left).round(),
        (bounds.top < 50 ? 28 : bounds.top - 25).round());
    // var textStyle = TextStyle();
    // textStyle.color = Color.black;
    // textStyle.fontSize = 15;
    // canvas.drawText(
    //   charts.TextElement("1", style: textStyle),
    //     (bounds.left).round(),
    //     (bounds.top - 28).round()
    // );
  }

  @override
  bool shouldRepaint(charts.CircleSymbolRenderer oldRenderer) {
    return true;
  }
}

class _partTarget extends StatelessWidget {
  final MeterRecordDisplay meterRecordDisplay;

  const _partTarget({
    Key? key,
    required this.meterRecordDisplay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              "Last oscillation\nvs target\n${meterRecordDisplay.lastOsc}\n${meterRecordDisplay.targetOsc}",
              textAlign: TextAlign.center,
            ),
            Positioned(
              bottom: 10,
              child: Text(
                meterRecordDisplay.name,
                textAlign: TextAlign.center,
              ),
            ),
            Positioned.fill(
              child: MeterGauge(
                color: Colors.blue,
                percent:
                    meterRecordDisplay.lastOsc / meterRecordDisplay.targetOsc,
              ),
            ),
          ],
        ),
        width: 150,
        height: 150,
        decoration: BoxDecoration(
            // color: Colors.yellow,
            // shape: BoxShape.circle,
            ),
      ),
    );
  }
}

class MeterGauge extends StatelessWidget {
  final double percent;

  final Color? backgroundColor;

  final Color? color;
  const MeterGauge({
    Key? key,
    this.percent = 0,
    this.backgroundColor = Colors.black12,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CircularProgressIndicatorClipper(),
      child: Transform.rotate(
        angle: -pi * 3 / 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: CircularProgressIndicator(
            strokeWidth: 10,
            valueColor: AlwaysStoppedAnimation<Color>(color!),
            backgroundColor: backgroundColor,
            value: percent * 6 / 8,
            // : Text("100")
          ),
        ),
      ),
    );
  }
}

class CircularProgressIndicatorClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path()
      ..moveTo(size.width / 2, size.height / 2)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    Path circle = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ));
    return Path.combine(PathOperation.difference, circle, path);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class MeterRecordDisplay {
  String name;
  int lastOsc;
  int targetOsc;
  MeterRecordDisplay(
      {required this.name, required this.lastOsc, required this.targetOsc});
}

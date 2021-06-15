import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rehabnow_app/components/skeleton.dart';
import 'package:rehabnow_app/constants/routes.constant.dart';
import 'package:rehabnow_app/models/exercise.model.dart';
import 'package:rehabnow_app/pages/cases/view_cases.dart';
import 'package:rehabnow_app/services/exercise.http.service.dart';
import 'package:rehabnow_app/services/login.http.service.dart';
import 'package:rehabnow_app/utils/time.constant.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/src/text_element.dart';
import 'package:charts_flutter/src/text_style.dart' as style;

class DrawerRow {
  final String title;
  final IconData icon;
  final void Function()? callback;
  DrawerRow({required this.title, required this.icon, required this.callback});
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _time = "";

  List<DrawerRow> _drawerRow = [];

  @override
  void initState() {
    super.initState();
    _drawerRow = [
      DrawerRow(
          title: "Case",
          icon: Icons.local_hospital,
          callback: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed(RoutesConstant.CASES);
          }),
      DrawerRow(
          title: "Connect Wearable Devices",
          icon: Icons.bluetooth,
          callback: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed(RoutesConstant.CONNECTION);
          }),
      DrawerRow(
          title: "Exercise",
          icon: Icons.airline_seat_recline_extra,
          callback: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed(RoutesConstant.EXERCISES);
          }),
      DrawerRow(
          title: "Reminder",
          icon: Icons.alarm,
          callback: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed(RoutesConstant.VIEW_REMINDER);
          }),
      DrawerRow(
          title: "Profile",
          icon: Icons.person_outline,
          callback: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed(RoutesConstant.PROFILE);
          }),
      DrawerRow(
          title: "Logout",
          icon: Icons.exit_to_app,
          callback: () {
            logout().then((value) {
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed(RoutesConstant.HOME);
            });
          })
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Home"),
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.elliptical(20, 10))),
        ),
        drawer: Drawer(
          child: SafeArea(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DrawerHeader(
                child: Row(
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
              ),
              Flexible(
                child: ListView.separated(
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('${_drawerRow[index].title}'),
                        leading: Icon(_drawerRow[index].icon),
                        onTap: _drawerRow[index].callback,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(height: 0),
                    itemCount: _drawerRow.length),
              )
            ],
          )),
        ),
        body: SafeArea(
            child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: SingleChildScrollView(
            physics:
                BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            child: FutureBuilder<List<ExerciseRecords>>(
                future: getExercisesRecords(),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data!.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: NotFoundCenter(
                          text: "Hooray! No case under treatment found.",
                          happy: true,
                        ),
                      );
                    }
                    List<charts.Series<ExerciseData, DateTime>> datas =
                        snapshot.data?.map((exerciseRecords) {
                              int color =
                                  Random().nextInt(Colors.primaries.length);
                              return charts.Series<ExerciseData, DateTime>(
                                data: exerciseRecords.exercises,
                                colorFn: (datum, index) =>
                                    charts.ColorUtil.fromDartColor(
                                        Colors.primaries[color]),
                                domainFn: (datum, index) =>
                                    DateTime.fromMillisecondsSinceEpoch(
                                        datum.dateTime),
                                id: "${exerciseRecords.partName} - ${exerciseRecords.caseName}",
                                measureFn: (datum, index) => datum.oscillation,
                                radiusPxFn: (datum, index) => 3,
                                strokeWidthPxFn: (datum, index) => 3,
                              );
                            }).toList() ??
                            [];

                    List<MeterRecordDisplay?> _meterDisplays = snapshot.data
                            ?.map((exerciseRecords) =>
                                MeterRecordDisplay(exerciseRecords))
                            .toList() ??
                        [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: Duration(seconds: 10),
                          curve: Curves.bounceIn,
                          child: Card(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                  children: buildMeterDisplays(_meterDisplays)

                                  // [
                                  //   Row(
                                  //     mainAxisAlignment: MainAxisAlignment.center,
                                  //     children: [
                                  //       for (var i = 0;i < _meterDisplays.length && i < 2;i++)
                                  //         PartTarget(meterRecordDisplay: _meterDisplays[i]!,),
                                  //     ],
                                  //   ),
                                  //   Row(
                                  //     mainAxisAlignment: MainAxisAlignment.center,
                                  //     children: [
                                  //       for (var i = 2;
                                  //           i < _meterDisplays.length;
                                  //           i++)
                                  //         PartTarget(
                                  //           meterRecordDisplay: _meterDisplays[i]!,
                                  //         ),
                                  //     ],
                                  //   ),
                                  // ],
                                  ),
                            ),
                          ),
                        ),
                        Card(
                          child: Container(
                            height: 350 + (datas.length / 2) * 35.0,
                            // margin: EdgeInsets.only(top: 30),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: charts.TimeSeriesChart(
                                datas,
                                defaultRenderer: charts.LineRendererConfig(
                                  includePoints: true,
                                ),
                                selectionModels: [
                                  charts.SelectionModelConfig(
                                    changedListener: (model) {
                                      print(model);
                                      if (model.hasDatumSelection) {
                                        print(model.selectedSeries[0].measureFn(
                                            model.selectedDatum[0].index));
                                        _time =
                                            "${DATETIME_FORMAT.format(DateTime.fromMillisecondsSinceEpoch(model.selectedDatum[0].datum.dateTime as int))}: ${model.selectedSeries[0].measureFn(model.selectedDatum[0].index)}";
                                      }
                                    },
                                  )
                                ],
                                behaviors: [
                                  charts.LinePointHighlighter(
                                      symbolRenderer:
                                          RehabnowCustomSymbolRenderer(
                                              () => _time,
                                              MediaQuery.of(context)
                                                  .size
                                                  .width)),
                                  charts.ChartTitle(
                                    "Number of oscillations per parts",
                                    behaviorPosition:
                                        charts.BehaviorPosition.top,
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
                                    behaviorPosition:
                                        charts.BehaviorPosition.start,
                                    titleStyleSpec:
                                        charts.TextStyleSpec(fontSize: 12),
                                  ),
                                  charts.SeriesLegend(
                                    desiredMaxColumns: 1,
                                    position: charts.BehaviorPosition.bottom,
                                  ),
                                  charts.PanAndZoomBehavior()
                                ],
                              ),
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
          ),
        )));
  }

  List<Widget> buildMeterDisplays(List<MeterRecordDisplay?> _meterDisplays) {
    List<Row> list = [];
    for (int i = 0; i < _meterDisplays.length; i++) {
      if (i % 2 == 0) {
        // left side
        list.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [],
        ));
      }
      //right side
      list[(i / 2).floor()].children.add(PartTarget(
            meterRecordDisplay: _meterDisplays[i]!,
          ));
    }
    return list;
  }
}

class RehabnowCustomSymbolRenderer extends charts.CircleSymbolRenderer {
  String Function() text;
  double mediaWidth;
  static const List<int> _list = [];
  static const _color = charts.Color();
  late double max;

  RehabnowCustomSymbolRenderer(this.text, this.mediaWidth) {
    max = mediaWidth - 100 - 20;
  }

  @override
  void paint(charts.ChartCanvas canvas, Rectangle<num> bounds,
      {List<int> dashPattern = _list,
      charts.Color fillColor = _color,
      charts.FillPatternType fillPattern = charts.FillPatternType.solid,
      charts.Color strokeColor = _color,
      double strokeWidthPx = 1}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidthPx: strokeWidthPx);

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
  }

  @override
  bool shouldRepaint(charts.CircleSymbolRenderer oldRenderer) {
    return true;
  }
}

class PartTarget extends StatelessWidget {
  final MeterRecordDisplay meterRecordDisplay;

  const PartTarget({
    Key? key,
    required this.meterRecordDisplay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  "Last oscillation\nvs target\n${meterRecordDisplay.lastOsc}\n${meterRecordDisplay.targetOsc}",
                  textAlign: TextAlign.center,
                ),
                Positioned.fill(
                  child: MeterGauge(
                    color: Colors.blue,
                    percent: meterRecordDisplay.lastOsc /
                        meterRecordDisplay.targetOsc,
                  ),
                ),
              ],
            ),
            width: 150,
            height: 150,
            decoration: BoxDecoration(),
          ),
          Text(
            meterRecordDisplay.name,
            textAlign: TextAlign.center,
          ),
        ],
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
  late String name;
  late int lastOsc;
  late int targetOsc;
  MeterRecordDisplay(ExerciseRecords exerciseRecords) {
    lastOsc = exerciseRecords.exercises.isNotEmpty
        ? exerciseRecords.exercises.last.oscillation
        : 0;
    name = "${exerciseRecords.partName} -\n${exerciseRecords.caseName}";
    targetOsc = exerciseRecords.targets.first.oscillationNum ?? 0;
  }
}

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rehabnow_app/components/meter_gauge.dart';
import 'package:rehabnow_app/components/not_found_center.dart';
import 'package:rehabnow_app/components/skeleton.dart';
import 'package:rehabnow_app/constants/routes.constant.dart';
import 'package:rehabnow_app/models/exercise.model.dart';
import 'package:rehabnow_app/services/exercise.http.service.dart';
import 'package:rehabnow_app/services/login.http.service.dart';
import 'package:rehabnow_app/constants/time.constant.dart';
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
              Navigator.of(context).pushReplacementNamed(RoutesConstant.LOGIN);
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              color: Color.fromRGBO(100, 5, 190, 1),
              height: 150,
              child: DrawerHeader(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/logo1.png",
                      width: 80,
                      color: Colors.white,
                    ),
                    Text(
                      "RehabNow",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 10),
                itemBuilder: _buildDrawerList,
                separatorBuilder: (context, index) => Divider(height: 0),
                itemCount: _drawerRow.length,
              ),
            )
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onrefresh,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: FutureBuilder<List<ExerciseRecords>>(
                future: getExercisesRecords(), builder: _buildMeterAndChart),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerList(context, index) {
    return ListTile(
      title: Text('${_drawerRow[index].title}'),
      leading: Icon(_drawerRow[index].icon),
      onTap: _drawerRow[index].callback,
      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
    );
  }

  Widget _buildMeterAndChart(
      BuildContext context, AsyncSnapshot<List<ExerciseRecords>> snapshot) {
    if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
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
                int color = Random().nextInt(Colors.primaries.length);
                return charts.Series<ExerciseData, DateTime>(
                  data: exerciseRecords.exercises,
                  colorFn: (datum, index) =>
                      charts.ColorUtil.fromDartColor(Colors.primaries[color]),
                  domainFn: (datum, index) =>
                      DateTime.fromMillisecondsSinceEpoch(datum.dateTime),
                  id: "${exerciseRecords.partName} - ${exerciseRecords.caseName}",
                  measureFn: (datum, index) => datum.oscillation,
                  radiusPxFn: (datum, index) => 3,
                  strokeWidthPxFn: (datum, index) => 3,
                );
              }).toList() ??
              [];

      List<MeterRecordDisplay?> _meterDisplays = snapshot.data
              ?.map((exerciseRecords) => MeterRecordDisplay(exerciseRecords))
              .toList() ??
          [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            child: Container(
              padding: EdgeInsets.only(top: 10),
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "Latest Performance vs Target",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  ...buildMeterDisplays(_meterDisplays),
                ],
              ),
            ),
          ),
          Card(
            child: Container(
              height: 350 + (datas.length / 2) * 35.0,
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
                        if (model.hasDatumSelection) {
                          _time =
                              "${DATETIME_FORMAT.format(DateTime.fromMillisecondsSinceEpoch(model.selectedDatum[0].datum.dateTime as int))}: ${model.selectedSeries[0].measureFn(model.selectedDatum[0].index)}";
                        }
                      },
                    )
                  ],
                  behaviors: [
                    charts.LinePointHighlighter(
                        symbolRenderer: RehabnowCustomSymbolRenderer(
                            () => _time, MediaQuery.of(context).size.width)),
                    charts.ChartTitle(
                      "Number of Oscillations per Parts",
                      behaviorPosition: charts.BehaviorPosition.top,
                      innerPadding: 50,
                    ),
                    charts.ChartTitle(
                      "Date Time",
                      behaviorPosition: charts.BehaviorPosition.bottom,
                      titleStyleSpec: charts.TextStyleSpec(fontSize: 12),
                    ),
                    charts.ChartTitle(
                      "Oscillation",
                      behaviorPosition: charts.BehaviorPosition.start,
                      titleStyleSpec: charts.TextStyleSpec(fontSize: 12),
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
  }

  Future<void> _onrefresh() async {
    setState(() {});
  }

  List<Widget> buildMeterDisplays(List<MeterRecordDisplay?> _meterDisplays) {
    List<Row> list = [];
    for (int i = 0; i < _meterDisplays.length; i++) {
      if (i % 2 == 0) {
        list.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [],
          ),
        );
      }
      //right side
      list[(i / 2).floor()].children.add(
            PartTarget(
              meterRecordDisplay: _meterDisplays[i]!,
            ),
          );
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

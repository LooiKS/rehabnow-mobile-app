import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rehabnow_app/components/not_found_center.dart';
import 'package:rehabnow_app/components/skeleton.dart';
import 'package:rehabnow_app/constants/routes.constant.dart';
import 'package:rehabnow_app/models/case.model.dart';
import 'package:rehabnow_app/models/part.model.dart';
import 'package:rehabnow_app/services/case.http.service.dart';
import 'package:rehabnow_app/utils/dialog.dart';
import 'package:rehabnow_app/utils/shared_preferences.dart';

class CaseDisplay extends Case {
  bool isSelected = false;
  CaseDisplay(Case c)
      : super(c.name, c.description, c.status, c.patientId, c.createdBy,
            c.createdDt, c.id);
}

class PartDisplay extends Part {
  String? deviceUuid;
  PartDisplay(Part p, this.deviceUuid)
      : super(p.description, p.name, p.recoveryDt, p.status, p.createdDt,
            p.createdBy, p.caseId, p.id, p.targets, p.predictedRecoveries);
}

class Exercises extends StatefulWidget {
  @override
  _ExercisesState createState() => _ExercisesState();
}

class _ExercisesState extends State<Exercises> {
  ValueNotifier<List<CaseDisplay>?> _cases = ValueNotifier(null);

  ValueNotifier<List<PartDisplay>?> _parts = ValueNotifier(null);

  int _caseSelected = 0;
  int _partSelected = 0;
  int _gameSelected = 0;

  @override
  void initState() {
    super.initState();
    getAllCases(status: "Under Treatment").then((cases) {
      _cases.value = cases.map((e) => CaseDisplay(e)).toList();
      if (cases.isNotEmpty) {
        updateParts(cases.first.id);
      } else {
        _parts.value = [];
      }
    });
  }

  void updateParts(int caseId) {
    _parts.value = null;
    getAllParts(caseId).then((value) {
      _parts.value = value
          .map((part) => PartDisplay(part, _getDevice(part.name)))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exercises"),
        centerTitle: true,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(bottom: Radius.elliptical(20, 10))),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Skeleton(
          isLoading: false,
          child: Container(
            child: Column(
              children: [
                _buildCases(),
                _buildPartsChoice(),
                _DividerText(text: "Games"),
                _ChoiceChipWithIcon(
                  label: "Catch The Bug",
                  selected: _gameSelected,
                  index: 0,
                  onSelected: (i) => setState(() => _gameSelected = 0),
                ),
                _ChoiceChipWithIcon(
                  label: "Flying Bird",
                  selected: _gameSelected,
                  index: 1,
                  onSelected: (i) => setState(() => _gameSelected = 1),
                ),
                ElevatedButton(
                  child: Text("Start"),
                  onPressed: _startPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ValueListenableBuilder<List<CaseDisplay>?> _buildCases() {
    return ValueListenableBuilder(
      valueListenable: _cases,
      builder: (context, List<CaseDisplay>? value, child) {
        return Column(
          children: [
            _DividerText(text: "Cases"),
            value == null
                ? Skeleton(
                    child: Text("Loading..."),
                    isLoading: true,
                    lines: 3,
                  )
                : value.isEmpty
                    ? NotFoundCenter(text: "No case found.")
                    : Column(
                        children: [
                          ...value
                              .asMap()
                              .entries
                              .map((e) => _ChoiceChipWithIcon(
                                    label: e.value.name ?? "",
                                    selected: _caseSelected,
                                    index: e.key,
                                    onSelected: (i) => setState(() {
                                      _caseSelected = e.key;
                                      updateParts(
                                          _cases.value![_caseSelected].id);
                                    }),
                                  ))
                              .toList()
                        ],
                      )
          ],
        );
      },
    );
  }

  Widget _buildPartsChoice() {
    return ValueListenableBuilder(
        valueListenable: _parts,
        builder: (context, List<PartDisplay>? value, child) => value == null ||
                value.isNotEmpty
            ? Column(
                children: [
                  _DividerText(text: "Parts"),
                  value == null
                      ? Skeleton(
                          child: Text("Loading"),
                          isLoading: true,
                          lines: 3,
                        )
                      : Column(
                          children: [
                            ...value
                                .asMap()
                                .entries
                                .map((e) => _ChoiceChipWithIcon(
                                      label: e.value.name ?? "",
                                      selected: _partSelected,
                                      index: e.key,
                                      onSelected: (i) =>
                                          setState(() => _partSelected = e.key),
                                    ))
                                .toList(),
                          ],
                        )
                ],
              )
            : Container());
  }

  void _startPressed() {
    if (_parts.value == null || _parts.value!.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No available.")));
    } else if (_parts.value?[_partSelected].deviceUuid == null) {
      showAlertDialog(
          context: context,
          title: "Confirmation",
          content:
              "The device for ${_parts.value?[_partSelected].name} is not set. Please proceed to the configuration.",
          confirmCallback: () {
            Navigator.of(context).pushNamed(RoutesConstant.CONNECTION).then(
                (value) => _parts.value?[_partSelected].deviceUuid =
                    _getDevice(_parts.value?[_partSelected].name));
          });
    } else {
      Navigator.of(context).pushNamed(RoutesConstant.GAME, arguments: {
        "gameNum": _gameSelected,
        "part": _parts.value![_partSelected]
      });
    }
  }

  String? _getDevice(String? name) {
    switch (name) {
      case "Upper Left Limb":
        return RehabnowSharedPreferences().leftArmDevice;
      case "Upper Right Limb":
        return RehabnowSharedPreferences().rightArmDevice;
      case "Lower Left Limb":
        return RehabnowSharedPreferences().leftLegDevice;
      case "Lower Right Limb":
        return RehabnowSharedPreferences().rightLegDevice;
    }
  }
}

class _DividerText extends StatelessWidget {
  final String text;

  const _DividerText({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Divider(
          color: Colors.black,
          endIndent: 15,
          height: 30,
        )),
        Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
            child: Divider(
          color: Colors.black,
          indent: 15,
        )),
      ],
    );
  }
}

class _ChoiceChipWithIcon extends StatelessWidget {
  final String label;

  const _ChoiceChipWithIcon({
    Key? key,
    required this.selected,
    required this.index,
    required this.onSelected,
    required this.label,
  }) : super(key: key);

  final int selected;
  final int index;
  final Function(bool) onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          selected == index ? Icon(Icons.check_rounded) : Container(),
        ],
      ),
      selected: selected == index,
      onSelected: (i) => onSelected(i),
    );
  }
}

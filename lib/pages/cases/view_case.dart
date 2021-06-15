import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rehabnow_app/components/skeleton.dart';
import 'package:rehabnow_app/constants/routes.constant.dart';
import 'package:rehabnow_app/models/case.model.dart';
import 'package:rehabnow_app/models/part.model.dart';
import 'package:rehabnow_app/pages/cases/view_exercises.dart';
import 'package:rehabnow_app/services/case.http.service.dart';
import 'package:rehabnow_app/utils/time.constant.dart';

class ViewCase extends StatefulWidget {
  final Case caseObj;

  const ViewCase({Key? key, required this.caseObj}) : super(key: key);
  @override
  _ViewCaseState createState() => _ViewCaseState();
}

class _ViewCaseState extends State<ViewCase> {
  List<Part> _parts = [], _filteredParts = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getAllParts(widget.caseObj.id).then((parts) => setState(() {
          _parts = _filteredParts = parts;
          isLoading = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.caseObj.name ?? ""),
        centerTitle: true,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(bottom: Radius.elliptical(20, 10))),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5),
        child: Skeleton(
          isLoading: isLoading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 200,
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.filter_alt_outlined),
                  ),
                  items: ["All", "Recovered", "Under Treatment"]
                      .map((e) => DropdownMenuItem(
                            child: Text(e),
                            value: e,
                          ))
                      .toList(),
                  value: "All",
                  onChanged: (e) => {
                    setState(() => _filteredParts = _parts
                        .where((element) => e == "All" || element.status == e)
                        .toList())
                  },
                ),
              ),
              if (_filteredParts.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        "No part found.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              else
                ..._filteredParts
                    .map((part) => _BodyPartCard(
                          part: part,
                        ))
                    .toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BodyPartCard extends StatelessWidget {
  final Part part;
  const _BodyPartCard({
    Key? key,
    required this.part,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          part.name ?? "",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          part.status ?? "",
                          style: TextStyle(
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CaseInfo(
                      title: "Description", value: part.description ?? ""),
                  _CaseInfo(
                      title: "Created On",
                      value: part.createdDt == null
                          ? "-"
                          : DATETIME_FORMAT.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  part.createdDt!))),
                  _CaseInfo(
                      title: "Recovered On",
                      value: part.recoveryDt == null
                          ? part.predictedRecoveries.isEmpty
                              ? "-"
                              : "${DATETIME_FORMAT.format(DateTime.fromMillisecondsSinceEpoch(part.predictedRecoveries.first!.recoveryDt))} (Predicted)"
                          : DATETIME_FORMAT.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  part.recoveryDt!))),
                  _CaseInfo(
                      title: "Frequency",
                      value: TARGET_FREQUENCIES[part.targets.first.frequency]!),
                  _CaseInfo(
                      title: "Oscillation",
                      value: part.targets.first.oscillationNum.toString()),
                  _CaseInfo(
                      title: "Time Allocated (s)",
                      value: part.targets.first.timeTaken.toString()),
                ],
              ),
            ),
            IconButton(
              tooltip: "View Exercise Records",
              icon: Icon(
                Icons.keyboard_arrow_right,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(RoutesConstant.VIEW_EXERCISES,
                    arguments: {"id": part.id});
              },
            )
          ],
        ),
      ),
    );
  }
}

class _CaseInfo extends StatelessWidget {
  final String title;
  final String value;
  const _CaseInfo({Key? key, required this.title, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }
}

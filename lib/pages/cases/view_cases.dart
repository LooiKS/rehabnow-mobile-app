import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rehabnow_app/components/skeleton.dart';
import 'package:rehabnow_app/constants/routes.constant.dart';
import 'package:rehabnow_app/models/case.model.dart';
import 'package:rehabnow_app/pages/cases/view_case.dart';
import 'package:rehabnow_app/services/case.http.service.dart';
import 'package:intl/intl.dart' show DateFormat;

class ViewCases extends StatefulWidget {
  @override
  _ViewCasesState createState() => _ViewCasesState();
}

class _ViewCasesState extends State<ViewCases> {
  List<Case> _cases = [], _filteredCases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getAllCases().then((cases) => setState(() {
          _cases = _filteredCases = cases;
          _isLoading = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cases"),
        centerTitle: true,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(bottom: Radius.elliptical(20, 10))),
      ),
      body: SingleChildScrollView(
          child: Skeleton(
        isLoading: _isLoading,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
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
                  onChanged: (e) {
                    setState(() {
                      _filteredCases = _cases
                          .where((element) => e == "All" || element.status == e)
                          .toList();
                    });
                  },
                ),
              ),
              Container(),
              if (_filteredCases.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: NotFoundCenter(
                      text: "No case found.",
                    ),
                  ),
                )
              else
                ..._filteredCases
                    .map((e) => _CaseCard(
                          caseObj: e,
                        ))
                    .toList(),
            ],
          ),
        ),
      )),
    );
  }
}

class NotFoundCenter extends StatelessWidget {
  final String text;

  final bool happy;

  const NotFoundCenter({
    Key? key,
    required this.text,
    this.happy = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            happy ? "assets/images/party.png" : "assets/images/not-found.png",
            width: 200,
            color: Colors.blue,
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _CaseCard extends StatelessWidget {
  final Case caseObj;
  const _CaseCard({
    Key? key,
    required this.caseObj,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      caseObj.name ?? "-",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  _CaseInfo(
                      title: "Description", value: caseObj.description ?? "-"),
                  _CaseInfo(
                      title: "Created By", value: caseObj.createdBy ?? "-"),
                  _CaseInfo(
                      title: "Created On",
                      value: DateFormat("dd-MM-yyyy").format(
                          DateTime.fromMillisecondsSinceEpoch(
                              caseObj.createdDt))),
                  _CaseInfo(title: "Status", value: caseObj.status ?? "-"),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.keyboard_arrow_right),
              onPressed: () {
                Navigator.of(context).pushNamed(RoutesConstant.CASE,
                    arguments: {"caseObj": caseObj});
              },
            )
          ],
        ),
      ),
      elevation: 2,
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

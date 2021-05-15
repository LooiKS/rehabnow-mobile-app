import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rehabnow_app/pages/cases/view_case.dart';

class ViewCases extends StatefulWidget {
  @override
  _ViewCasesState createState() => _ViewCasesState();
}

class _ViewCasesState extends State<ViewCases> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Cases"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
                    items: ["Recovered", "Under treatment"]
                        .map((e) => DropdownMenuItem(
                              child: Text(e),
                              value: e,
                            ))
                        .toList(),
                    value: "Recovered",
                    onChanged: (e) => {},
                  ),
                ),
                Container(),
                _CaseCard(),
                _CaseCard(),
                _CaseCard(),
              ],
            ),
          ),
        ));
  }
}

class _CaseCard extends StatelessWidget {
  const _CaseCard({
    Key key,
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
                      "Fell Down",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  _CaseInfo(title: "Description", value: "desc"),
                  _CaseInfo(title: "Created By", value: "desc"),
                  _CaseInfo(title: "Created On", value: "desc"),
                  _CaseInfo(title: "Status", value: "desc"),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.keyboard_arrow_right),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => ViewCase()));
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
  const _CaseInfo({Key key, this.title, this.value}) : super(key: key);

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

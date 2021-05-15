import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rehabnow_app/pages/cases/view_exercises.dart';

class ViewCase extends StatefulWidget {
  @override
  _ViewCaseState createState() => _ViewCaseState();
}

class _ViewCaseState extends State<ViewCase> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Case"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5),
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
                items: ["Recovered", "Under Treatment"]
                    .map((e) => DropdownMenuItem(
                          child: Text(e),
                          value: e,
                        ))
                    .toList(),
                value: "Recovered",
                onChanged: (e) => {},
              ),
            ),
            _BodyPartCard(),
            _BodyPartCard(),
            _BodyPartCard(),
          ],
        ),
      ),
    );
  }
}

class _BodyPartCard extends StatelessWidget {
  const _BodyPartCard({
    Key key,
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
                          "Left Upper Limb",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          "[Status]",
                          style: TextStyle(
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CaseInfo(title: "Description", value: "desc"),
                  _CaseInfo(title: "Created On", value: "desc"),
                  _CaseInfo(title: "Recovered On", value: "desc"),
                  _CaseInfo(title: "Frequency", value: "desc"),
                  _CaseInfo(title: "Oscillation", value: "desc"),
                  _CaseInfo(title: "Time Allocated", value: "desc"),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.keyboard_arrow_right,
              ),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ViewExercises()));
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

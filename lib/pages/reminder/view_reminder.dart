import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rehabnow_app/shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewReminder extends StatefulWidget {
  @override
  _ViewReminderState createState() => _ViewReminderState();
}

class _ViewReminderState extends State<ViewReminder> {
  List<String> _quotes = [
    "The secret of your success is found in your daily routine.",
    "Start thinking wellness, not illness",
    "Don’t tell people your plans. Show them your results.",
    "You’re a warrior, warriors don’t give up and they don’t back down. Pick up your sword and fight.",
    "Your body can stand almost anything. It’s your mind that you have to convince.",
    "It does not matter how slow you go as long as you do not stop.",
  ];
  int index = 0;
  get quote => _quotes[index];
  RehabnowSharedPreferences rsp = RehabnowSharedPreferences();
  bool _reminder;
  String _reminderTime;
  @override
  void initState() {
    super.initState();
    _reminder = rsp.reminder;
    _reminderTime = rsp.reminderTime;
    Random _random = Random();
    index = _random.nextInt(_quotes.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reminder"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                height: (MediaQuery.of(context).size.height - 150) / 2,
                width: (MediaQuery.of(context).size.width),
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  quote,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(100))),
                    color: Colors.lightBlueAccent)),
            Container(
              child: ListTile(
                leading: Icon(Icons.alarm),
                title: Text("Enable Reminder"),
                trailing: Switch(
                  value: _reminder,
                  onChanged: (value) {
                    setState(() => _reminder = value);
                    rsp.reminder = value;
                  },
                ),
              ),
            ),
            Divider(
              color: Colors.black54,
              indent: 10,
              endIndent: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                child: TextField(
                  enabled: false,
                  controller: new TextEditingController(text: _reminderTime),
                  decoration: InputDecoration(
                    labelText: "Reminder Time",
                    suffixIcon: Icon(Icons.access_time),
                    border: OutlineInputBorder(),
                  ),
                ),
                onTap: () async {
                  if (_reminder) {
                    TimeOfDay time = await showTimePicker(
                        context: context, initialTime: TimeOfDay.now());
                    if (time != null) {
                      rsp.reminderTime = time.format(context);
                      setState(() {
                        _reminderTime = time.format(context);
                      });
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Please enable reminder"),
                    ));
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

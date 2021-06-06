import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rehabnow_app/utils/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

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
  late bool? _reminder;
  late TimeOfDay _reminderTime;
  @override
  void initState() {
    super.initState();
    _reminder = rsp.reminder == null ? false : rsp.reminder;
    String? reminderTime = rsp.reminderTime;
    List<String>? reminderTimes =
        (reminderTime == null ? null : reminderTime.split(":"));
    _reminderTime = reminderTimes != null
        ? TimeOfDay(
            hour: int.parse(reminderTimes[0]),
            minute: int.parse(reminderTimes[1]))
        : TimeOfDay(hour: 12, minute: 0);
    Random _random = Random();
    index = _random.nextInt(_quotes.length);
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.alarm),
                    title: Text("Enable Reminder"),
                    trailing: Switch(
                      value: _reminder!,
                      onChanged: (value) {
                        setState(() => _reminder = value);
                        rsp.reminder = value;
                        if (!value) {
                          flutterLocalNotificationsPlugin.cancel(0);
                        } else {
                          scheduleNotification(_reminderTime);
                        }
                      },
                    ),
                  ),
                ],
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
                  controller: new TextEditingController(
                      text: _reminderTime.format(context)),
                  decoration: InputDecoration(
                    labelText: "Reminder Time",
                    suffixIcon: Icon(Icons.access_time),
                    border: OutlineInputBorder(),
                  ),
                ),
                onTap: () async {
                  if (_reminder!) {
                    TimeOfDay time = (await showTimePicker(
                        context: context, initialTime: _reminderTime))!;
                    if (time != null) {
                      rsp.reminderTime = "${time.hour}:${time.minute}";
                      print(rsp.reminderTime);
                      scheduleNotification(time);
                      setState(() {
                        _reminderTime = time;
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

  scheduleNotification(TimeOfDay time) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('rehabenow_id', 'rehabnow', 'rehabnow',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    DateTime now = DateTime.now();
    int day = now.compareTo(DateTime(
                now.year, now.month, now.day, time.hour, time.minute)) <
            0
        ? now.day
        : now.day + 1;

    flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        "Rehabilitation Reminder",
        "Check out your rehabilitation exercises now!",
        tz.TZDateTime(
            tz.local, now.year, now.month, day, time.hour, time.minute),
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
        matchDateTimeComponents: DateTimeComponents.time);
  }
}

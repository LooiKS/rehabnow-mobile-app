import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class Connection extends StatefulWidget {
  @override
  _ConnectionState createState() => _ConnectionState();
}

class _ConnectionState extends State<Connection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connect Devices"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: (MediaQuery.of(context).size.height - 150) / 2,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Row(
              children: [
                Icon(
                  Icons.settings_bluetooth,
                  size: 50,
                  color: Colors.white,
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Configure your devices to match with limbs",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(100))),
                color: Colors.lightBlueAccent),
          ),
          Card(
            margin: EdgeInsets.all(10),
            child: Column(
              children: [
                ListTile(
                  leading: Text(
                    "Arm",
                    style: TextStyle(fontSize: 18),
                  ),
                  title: Text(
                    "device-001",
                    textAlign: TextAlign.right,
                  ),
                  trailing: Icon(Icons.watch_outlined),
                  onTap: () {
                    FlutterBlue fb = FlutterBlue.instance;
                    fb.startScan();
                    fb.scanResults.listen((event) {
                      print(event);
                    });
                  },
                ),
                ListTile(
                  leading: Text(
                    "Arm",
                    style: TextStyle(fontSize: 18),
                  ),
                  title: Text(
                    "device-001",
                    textAlign: TextAlign.right,
                  ),
                  trailing: Icon(Icons.watch_outlined),
                ),
                ListTile(
                  leading: Text(
                    "Arm",
                    style: TextStyle(fontSize: 18),
                  ),
                  title: Text(
                    "device-001",
                    textAlign: TextAlign.right,
                  ),
                  trailing: Icon(Icons.watch_outlined),
                ),
                ListTile(
                  leading: Text(
                    "Arm",
                    style: TextStyle(fontSize: 18),
                  ),
                  title: Text(
                    "device-001",
                    textAlign: TextAlign.right,
                  ),
                  trailing: Icon(Icons.watch_outlined),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

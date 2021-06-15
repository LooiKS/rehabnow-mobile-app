import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';

import 'package:rehabnow_app/utils/shared_preferences.dart';

class RehabnowBluetoothDevice extends BluetoothDevice {
  bool isBonding = false;
  bool hasBonded = false;
  RehabnowBluetoothDevice(BluetoothDevice bd)
      : super(
            address: bd.address,
            bondState: bd.bondState,
            isConnected: bd.isConnected,
            name: bd.name,
            type: bd.type);
}

class Connection extends StatefulWidget {
  @override
  _ConnectionState createState() => _ConnectionState();
}

class _ConnectionState extends State<Connection> {
  List<Map<String, dynamic>> _isExpanded = [
    {
      "deviceType": DeviceType.LEFT_ARM,
      "isExpanded": false,
      "partName": "Upper Left Limb"
    },
    {
      "deviceType": DeviceType.LEFT_LEG,
      "isExpanded": false,
      "partName": "Lower Left Limb"
    },
    {
      "deviceType": DeviceType.RIGHT_ARM,
      "isExpanded": false,
      "partName": "Upper Right Limb"
    },
    {
      "deviceType": DeviceType.RIGHT_LEG,
      "isExpanded": false,
      "partName": "Lower Right Limb"
    },
  ];
  List<RehabnowBluetoothDevice> _devices = [];
  bool _isLoading = false;
  @override
  void didUpdateWidget(Connection oldWidget) {
    // if(message != widget.message) {
    //     setState((){
    //         message = widget.message;
    //     });
    // }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connect Devices"),
        centerTitle: true,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(bottom: Radius.elliptical(20, 10))),
      ),
      // extendBodyBehindAppBar: true,
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            margin: const EdgeInsets.all(15.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    // height: (MediaQuery.of(context).size.height - 150) / 2 + kToolbarHeight * 2,
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(left: 20, right: 20),
                    // margin: EdgeInsets.only(top: 5),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bluetooth,
                          size: 50,
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Configure your devices to match with limbs",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      // color: Colors.lightBlueAccent,
                    ),
                  ),
                  StreamBuilder<BluetoothState>(
                      stream: FlutterBluetoothSerial.instance.onStateChanged(),
                      builder:
                          (context, AsyncSnapshot<BluetoothState> snapshot) {
                        return Card(
                          margin: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              ExpansionPanelList(
                                expansionCallback: (panelIndex, isExpanded) {
                                  print(isExpanded);
                                  setState(() {
                                    for (int i = 0; i < _isExpanded.length; i++)
                                      _isExpanded[i]["isExpanded"] = false ||
                                          (panelIndex == i && !isExpanded);

                                    if (!isExpanded) {
                                      _isLoading = true;
                                      _devices = [];
                                      // var s = Future.delayed(
                                      //     Duration(seconds: 1),
                                      //     () => setState(() {
                                      //           _devices.add(RehabnowBluetoothDevice(
                                      //               BluetoothDevice(
                                      //                   name:
                                      //                       "my name ${_devices.length}")));
                                      //         }));
                                      FlutterBluetoothSerial
                                          .instance.isDiscovering
                                          .then((isDiscovering) {
                                        if (isDiscovering) {
                                          FlutterBluetoothSerial.instance
                                              .cancelDiscovery()
                                              .then((value) => scan());
                                        } else {
                                          scan();
                                        }
                                      });
                                    } else {
                                      FlutterBluetoothSerial.instance
                                          .cancelDiscovery();
                                    }
                                  });
                                },
                                expandedHeaderPadding: EdgeInsets.zero,
                                children: _isExpanded
                                    .map((e) => ExpansionPanel(
                                          // backgroundColor: Colors.amberAccent,
                                          headerBuilder:
                                              (context, isExpanded) => ListTile(
                                            contentPadding:
                                                EdgeInsets.only(left: 16.0),
                                            leading: Text(
                                              e["partName"],
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            title: Text(
                                              getDevice(e["deviceType"]) ??
                                                  "not set",
                                              textAlign: TextAlign.right,
                                            ),
                                            // trailing: Icon(Icons.watch_outlined),
                                          ),
                                          body:
                                              /*
                                          (!snapshot.hasData ||
                                                  snapshot.requireData !=
                                                      BluetoothState.STATE_ON)
                                              ? ListTile(
                                                  title: Text(
                                                      "Bluetooth is not activated."),
                                                  leading:
                                                      Icon(Icons.bluetooth_disabled),
                                                )
                                              :
                                           */

                                              Column(children: [
                                            _isLoading
                                                ? ListTile(
                                                    title: Text(
                                                      "Scanning ...",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    trailing:
                                                        CircularProgressIndicator(),
                                                    tileColor: Colors.grey[300],
                                                  )
                                                : Container(),
                                            ..._devices
                                                .map(
                                                  (device) => ListTile(
                                                      leading: Icon(Icons
                                                          .devices_outlined),
                                                      title: Text(device.name ??
                                                          "(Unknown)"),
                                                      subtitle: Text(
                                                          '${device.address ?? "(Unknown)"} - ${device.isBonded || device.hasBonded ? "Paired" : "Not Paired"}'),
                                                      onTap: () =>
                                                          _connectDevice(device,
                                                              e["deviceType"]),
                                                      trailing: device.isBonding
                                                          ? Text("Pairing")
                                                          : null),
                                                )
                                                .toList(),
                                          ]),
                                          isExpanded: e["isExpanded"],
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        );
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _connectDevice(RehabnowBluetoothDevice device, DeviceType deviceType) {
    setState(() {
      device.isBonding = true;
    });

    FlutterBluetoothSerial.instance.bondDeviceAtAddress(device.address).then(
        (result) {
      setState(() {
        device.isBonding = false;
        device.hasBonded = result;
      });
      if (result) {
        saveDevice(deviceType, device.address);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Paired successfully"),
        ));
      }
    }, onError: (error) {
      FlutterBluetoothSerial.instance.cancelDiscovery().then((value) {
        FlutterBluetoothSerial.instance.getBondedDevices().then((value) {
          value.forEach((element) {
            print(element.address);
          });
        });
      });
      saveDevice(deviceType, device.address);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Paired successfully"),
      ));
    });

    // emulator
    // Future.delayed(Duration(seconds: 10), () {
    //   setState(() {
    //     // device.isBonding = false;
    //   });
    // });
  }

  saveDevice(DeviceType deviceType, String address) {
    switch (deviceType) {
      case DeviceType.LEFT_ARM:
        RehabnowSharedPreferences().leftArmDevice = address;
        break;
      case DeviceType.RIGHT_ARM:
        RehabnowSharedPreferences().rightArmDevice = address;
        break;
      case DeviceType.LEFT_LEG:
        RehabnowSharedPreferences().leftLegDevice = address;
        break;
      case DeviceType.RIGHT_LEG:
        RehabnowSharedPreferences().rightLegDevice = address;
        break;
    }
  }

  String? getDevice(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.LEFT_ARM:
        return RehabnowSharedPreferences().leftArmDevice;
      case DeviceType.RIGHT_ARM:
        return RehabnowSharedPreferences().rightArmDevice;
      case DeviceType.LEFT_LEG:
        return RehabnowSharedPreferences().leftLegDevice;
      case DeviceType.RIGHT_LEG:
        return RehabnowSharedPreferences().rightLegDevice;
    }
  }

  scan() {
    FlutterBluetoothSerial.instance.requestEnable().then((value) {
      if (value) {
        var s =
            FlutterBluetoothSerial.instance.startDiscovery().listen((event) {
          setState(() {
            _devices.add(RehabnowBluetoothDevice(event.device));
          });
          print(event);
        });
        s.onError((e) => {print("error")});

        s.onDone(() {
          print("done");
          s.cancel();
          setState(() {
            _isLoading = false;
          });
        });

        Future.delayed(Duration(seconds: 1), () {
          FlutterBluetoothSerial.instance.isDiscovering
              .asStream()
              .listen((event) {
            if (_isLoading && !event) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Please try again later."),
              ));
            }
            print(event);
          });
        });
      }
    });
  }
}

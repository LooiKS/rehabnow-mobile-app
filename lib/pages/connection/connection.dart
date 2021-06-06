import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';

import 'package:rehabnow_app/utils/shared_preferences.dart';

class BluetoothDeviceListEntry extends ListTile {
  BluetoothDeviceListEntry(
      {required BluetoothDevice device,
      int? rssi,
      GestureTapCallback? onTap,
      GestureLongPressCallback? onLongPress,
      bool enabled = true})
      : super(
          onTap: onTap,
          onLongPress: onLongPress,
          enabled: enabled,
          leading:
              Icon(Icons.devices), // @TODO . !BluetoothClass! class aware icon
          title: Text(device.name ?? "Unknown device"),
          subtitle: Text(device.address.toString()),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            rssi != null
                ? Container(
                    margin: new EdgeInsets.all(8.0),
                    child: DefaultTextStyle(
                        style: () {
                          /**/ if (rssi >= -35)
                            return TextStyle(color: Colors.greenAccent[700]);
                          else if (rssi >= -45)
                            return TextStyle(
                                color: Color.lerp(Colors.greenAccent[700],
                                    Colors.lightGreen, -(rssi + 35) / 10));
                          else if (rssi >= -55)
                            return TextStyle(
                                color: Color.lerp(Colors.lightGreen,
                                    Colors.lime[600], -(rssi + 45) / 10));
                          else if (rssi >= -65)
                            return TextStyle(
                                color: Color.lerp(Colors.lime[600],
                                    Colors.amber, -(rssi + 55) / 10));
                          else if (rssi >= -75)
                            return TextStyle(
                                color: Color.lerp(
                                    Colors.amber,
                                    Colors.deepOrangeAccent,
                                    -(rssi + 65) / 10));
                          else if (rssi >= -85)
                            return TextStyle(
                                color: Color.lerp(Colors.deepOrangeAccent,
                                    Colors.redAccent, -(rssi + 75) / 10));
                          else
                            /*code symetry*/
                            return TextStyle(color: Colors.redAccent);
                        }(),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(rssi.toString()),
                              Text('dBm'),
                            ])),
                  )
                : Container(width: 0, height: 0),
            device.isConnected
                ? Icon(Icons.import_export)
                : Container(width: 0, height: 0),
            device.isBonded ? Icon(Icons.link) : Container(width: 0, height: 0),
          ]),
        );
}

class DiscoveryPage extends StatefulWidget {
  /// If true, discovery starts on page start, otherwise user must press action button.
  final bool start;

  const DiscoveryPage({this.start = true});

  @override
  _DiscoveryPage createState() => new _DiscoveryPage();
}

class _DiscoveryPage extends State<DiscoveryPage> {
  late StreamSubscription<BluetoothDiscoveryResult> _streamSubscription;
  List<BluetoothDiscoveryResult> results =
      []; // List<BluetoothDiscoveryResult>();
  late bool isDiscovering;

  _DiscoveryPage();

  @override
  void initState() {
    super.initState();

    isDiscovering = widget.start;
    if (isDiscovering) {
      _startDiscovery();
    }
  }

  void _restartDiscovery() {
    setState(() {
      results.clear();
      isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        results.add(r);
      });
    });

    _streamSubscription.onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });
  }

  // @TODO . One day there should be `_pairDevice` on long tap on something... ;)

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _streamSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: isDiscovering
              ? Text('Discovering devices')
              : Text('Discovered devices'),
          actions: <Widget>[
            (isDiscovering
                ? FittedBox(
                    child: Container(
                        margin: new EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white))))
                : IconButton(
                    icon: Icon(Icons.replay), onPressed: _restartDiscovery))
          ],
        ),
        body: ListView.builder(
          itemCount: results.length,
          itemBuilder: (BuildContext context, index) {
            BluetoothDiscoveryResult result = results[index];
            return BluetoothDeviceListEntry(
                device: result.device,
                rssi: result.rssi,
                onTap: () {
                  Navigator.of(context).pop(result.device);
                },
                onLongPress: () async {
                  try {
                    bool bonded = false;
                    if (result.device.isBonded) {
                      print('Unbonding from ${result.device.address}...');
                      await FlutterBluetoothSerial.instance
                          .removeDeviceBondWithAddress(result.device.address);
                      print(
                          'Unbonding from ${result.device.address} has succed');
                    } else {
                      print('Bonding with ${result.device.address}...');
                      bonded = await FlutterBluetoothSerial.instance
                          .bondDeviceAtAddress(result.device.address);
                      print(
                          'Bonding with ${result.device.address} has ${bonded ? 'succed' : 'failed'}.');
                    }
                    setState(() {
                      results[results.indexOf(result)] =
                          BluetoothDiscoveryResult(
                              device: BluetoothDevice(
                                name: result.device.name ?? '',
                                address: result.device.address,
                                type: result.device.type,
                                bondState: bonded
                                    ? BluetoothBondState.bonded
                                    : BluetoothBondState.none,
                              ),
                              rssi: result.rssi);
                    });
                  } catch (ex) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error occured while bonding'),
                          content: Text("${ex.toString()}"),
                          actions: <Widget>[
                            new FlatButton(
                              child: new Text("Close"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                });
          },
        ));
  }
}

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
      ),
      body: SingleChildScrollView(
        child: Column(
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
            StreamBuilder<BluetoothState>(
                stream: FlutterBluetoothSerial.instance.onStateChanged(),
                builder: (context, AsyncSnapshot<BluetoothState> snapshot) {
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        ExpansionPanelList(
                          expansionCallback: (panelIndex, isExpanded) {
                            print(isExpanded);
                            setState(() {
                              for (int i = 0; i < _isExpanded.length; i++)
                                _isExpanded[i]["isExpanded"] =
                                    false || (panelIndex == i && !isExpanded);

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
                                FlutterBluetoothSerial.instance.isDiscovering
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
                                    headerBuilder: (context, isExpanded) =>
                                        ListTile(
                                      contentPadding:
                                          EdgeInsets.only(left: 16.0),
                                      leading: Text(
                                        e["partName"],
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      title: Text(
                                        getDevice(e["deviceType"]) ?? "not set",
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
                                                leading: Icon(
                                                    Icons.devices_outlined),
                                                title: Text(
                                                    device.name ?? "(Unknown)"),
                                                subtitle: Text(
                                                    '${device.address ?? "(Unknown)"} - ${device.isBonded || device.hasBonded ? "Paired" : "Not Paired"}'),
                                                onTap: () => _connectDevice(
                                                    device, e["deviceType"]),
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

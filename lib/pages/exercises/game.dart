import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:rehabnow_app/components/dot_loading_indicator.dart';
import 'package:rehabnow_app/main.dart';
import 'package:rehabnow_app/pages/exercises/catch_the_bug_game.dart';
import 'package:rehabnow_app/pages/exercises/exercises.dart';
import 'package:rehabnow_app/pages/exercises/skip_the_hurdles.dart';
import 'package:rehabnow_app/services/exercise.http.service.dart';
import 'package:rehabnow_app/utils/loading.dart';

enum GameState {
  PRECHECK_BLUETOOTH_STATUS,
  PRECHECK_DEVICE_CONNECTION,
  PRE_DEVICE_NOT_DETECTED,
  SAVING,
  READY,
  PAUSE,
  RESUME,
  BLUETOOTH_DISCONNECTED,
  DEVICE_CONNECTING,
  DEVICE_DISCONNECTED,
}

class Game extends StatefulWidget {
  final int gameNum;
  final PartDisplay part;

  const Game({
    Key? key,
    required this.gameNum,
    required this.part,
  }) : super(key: key);

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  // GameState _gameState.value = GameState.PRECHECK_BLUETOOTH_STATUS;

  Stream<double>? _orientationStream;

  ValueNotifier<GameState> _gameState =
      ValueNotifier(GameState.PRECHECK_BLUETOOTH_STATUS);

  StreamSubscription<BluetoothState>? bluetoothStateSubscription;

  BluetoothConnection? bluetoothConnection;

  bool isPaused = false;

  late Stopwatch stopwatch;

  int oscillation = 0;

  bool reachTop = false;

  late String address;

  StreamSubscription<Uint8List>? _streamSubscription;

  /*
   * 1. check Bluetooth isEnabled
   *    1.1 if enabled, go 2.
   *    1.2 if not enabled, go 3.
   * 
   * 2. check device connection,
   *    2.1 if cannot connect, go to previous screen, show message
   *    2.2 if can connect, start game
   * 
   * 3. request enabled
   *    3.1 if allow, go 2.
   *    3.2 if not allow, go back, show message
   */

  Future<bool?> requestEnabled() {
    return FlutterBluetoothSerial.instance.requestEnable().then((enabled) {
      if (enabled) {
        return true;
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Bluetooth must be turned on.")));
      }
    });
  }

  Stream<GameState> _stateStream() async* {
    _gameState.addListener(() async* {
      yield _gameState.value;
    });
    yield _gameState.value;
  }

  void _prepareGame() {
    _gameState.value = GameState.PRECHECK_BLUETOOTH_STATUS;
    _mainStateProcessing();

    // yield GameState.PRECHECK_BLUETOOTH_STATUS;
    // bool isEnabled = await FlutterBluetoothSerial
    //     .instance.isEnabled; //.then((value) async* {
    // print(isEnabled);
    // if (!isEnabled)
    //   FlutterBluetoothSerial.instance.requestEnable().then((enabled) {
    //     if (!enabled) {
    //       Navigator.of(context).pop();
    //       ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(content: Text("Bluetooth must be turned on.")));
    //     }
    //   });
    // else {
    //   _gameState.value = GameState.PRECHECK_DEVICE_CONNECTION;
    //   yield _gameState;
    //   _gameState.value = await _connectAndListen(widget.address, (error) {
    //     Navigator.of(context).pop();
    //     ScaffoldMessenger.of(context)
    //         .showSnackBar(SnackBar(content: Text("Device must be turned on.")));
    //   });
    //   yield _gameState;
    // }
    bluetoothStateSubscription =
        FlutterBluetoothSerial.instance.onStateChanged().listen((value) {
      // await for (var value in bts) {
      // if (_gameState.index > GameState.READY.index) {
      //   // already in game
      //   if (value == BluetoothState.STATE_OFF) {
      //     // pause game
      //     // request to turn on bluetooth
      //     // if allow turn on, then proceed with connecting and resume
      //     // if not allow then ask whether to quit game
      //   }
      // } else {
      //   // have not been in game yet
      //   if (value == BluetoothState.STATE_ON) {}
      // }
      print(value);
      if (value == BluetoothState.STATE_ON) {
        // _gameState.value = _gameState.value.index < GameState.READY.index
        //     ? GameState.PRECHECK_DEVICE_CONNECTION
        //     : GameState.DEVICE_CONNECTING;
        // _mainStateProcessing();
      } else if (value == BluetoothState.STATE_OFF) {
        _gameState.value = _gameState.value.index < GameState.READY.index
            ? GameState.PRECHECK_BLUETOOTH_STATUS
            : GameState.BLUETOOTH_DISCONNECTED;
        _mainStateProcessing();
      }
      //   yield GameState.PRECHECK_DEVICE_CONNECTION;
      //   _gameState.value = await _connectAndListen(widget.address, (error) {
      //     showDialog(
      //       context: context,
      //       builder: (context) {
      //         return AlertDialog(
      //           title: Text("Disconnected"),
      //           content: Text("Please make sure the device is turned on."),
      //           actions: [
      //             TextButton(
      //               child: Text("Reconnect"),
      //               onPressed: () {
      //                 _connectAndListen(widget.address, () {});
      //               },
      //             )
      //           ],
      //         );
      //       },
      //     );
      //     ScaffoldMessenger.of(context).showSnackBar(
      //         SnackBar(content: Text("Device must be turned on.")));
      //   });
      //   yield _gameState;
      // } else if (value == BluetoothState.STATE_OFF)
      //   FlutterBluetoothSerial.instance.requestEnable();
      // print(value == BluetoothState.STATE_ON);
      // print(value);
    });
    // }
    // });
  }

  Future<GameState> _connectAndListen(String address, Function onError) {
    return BluetoothConnection.toAddress(address).then((value) {
      _listenPosition(value);
      return GameState.READY;
    }, onError: onError);
  }

  FutureOr<dynamic> _listenPosition(BluetoothConnection value) {
    _orientationStream = _getOrientationStream(value.input.asBroadcastStream());
  }

  double initialValue = 0.0;
  int iteration = 2;

  Stream<double> _getOrientationStream(Stream<Uint8List> source) async* {
    List<int> _uint8List = [];
    _streamSubscription = source.listen((event) {
      // print(event);
    });
    _streamSubscription!.onDone(() {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Device disconnected")));
      print("disconnected");
      _gameState.value = GameState.DEVICE_DISCONNECTED;
      _mainStateProcessing();
    });
    await for (var val in source) {
      for (int i = 0; i < val.length; i++) {
        if (val[i] == 10) {
          _uint8List = [];
        } else if (val[i] == 13) {
          // latest position
          // print(String.fromCharCodes(_uint8List));
          double value =
              double.tryParse(String.fromCharCodes(_uint8List)) ?? 0.0;
          value = initialValue + (1 / iteration) * (value - initialValue);
          initialValue = value;
          // iteration++;

          if (value > 60 && reachTop) {
            reachTop = false;
            setState(() {
              oscillation++;
            });
          }
          if (value < -60) {
            reachTop = true;
          }

          yield value;
          continue;
        } else {
          _uint8List.add(val[i]);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    address = widget.part.deviceUuid!;
    _prepareGame();
    stopwatch = Stopwatch();
  }

  @override
  void dispose() {
    bluetoothStateSubscription?.cancel();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    bluetoothConnection?.close();
    bluetoothConnection?.finish();
    bluetoothConnection?.dispose();
    _streamSubscription?.onDone(() {});
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return ValueListenableBuilder(
        valueListenable: _gameState, // builder: builder)
        // StreamBuilder<GameState>(
        // stream: _stateStream(),
        builder: (context, GameState snapshot, child) {
          if (snapshot != null && snapshot.index >= GameState.READY.index)
            return widget.gameNum == 1
                ? SkipTheHurdlesGame(
                    oscillation: oscillation,
                    target: widget.part.targets.first.oscillationNum!,
                    pause: isPaused,
                    stream: _orientationStream,
                    onPaused: () {
                      _gameState.value = GameState.PAUSE;
                      _mainStateProcessing();
                    },
                    onResume: () {
                      _gameState.value = GameState.RESUME;
                      _mainStateProcessing();
                    },
                    onSaved: () {
                      _gameState.value = GameState.SAVING;
                      _mainStateProcessing();
                    },
                  )
                : CatchTheBug(
                    oscillation: oscillation,
                    target: widget.part.targets.first.oscillationNum!,
                    pause: isPaused,
                    stream: _orientationStream,
                    onPaused: () {
                      _gameState.value = GameState.PAUSE;
                      _mainStateProcessing();
                    },
                    onResume: () {
                      _gameState.value = GameState.RESUME;
                      _mainStateProcessing();
                    },
                    onSaved: () {
                      _gameState.value = GameState.SAVING;
                      _mainStateProcessing();
                    },
                  );
          else
            return Scaffold(
              backgroundColor: Colors.blue,
              body: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      snapshot == GameState.PRECHECK_BLUETOOTH_STATUS
                          ? "Checking Bluetooth   "
                          : snapshot == GameState.PRECHECK_DEVICE_CONNECTION
                              ? "Connecting   "
                              : snapshot == GameState.PRE_DEVICE_NOT_DETECTED
                                  ? "Please ensure device is on   "
                                  : snapshot == GameState.SAVING
                                      ? "Saving   "
                                      : "Loading   ",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    DotLoadingIndicator(
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            );
        });
  }

  Future<void> _mainStateProcessing() async {
    // switch (_gameState) {
    //   case GameState.PRECHECK_BLUETOOTH_STATUS:
    //     _gameState.value = GameState.PRECHECK_DEVICE_CONNECTION;
    //     break;
    //   case GameState.PRECHECK_DEVICE_CONNECTION:
    //     break;
    //   case GameState.PRE_DEVICE_NOT_DETECTED:
    //     break;
    //   default:
    // }
    _gameState.notifyListeners();
    switch (_gameState.value) {
      case GameState.PRECHECK_BLUETOOTH_STATUS:
        bool enabled = await FlutterBluetoothSerial.instance.requestEnable();
        if (enabled) {
          _gameState.value = GameState.PRECHECK_DEVICE_CONNECTION;
          return _mainStateProcessing();
        } else {
          Navigator.of(context).pop();
        }
        break;
      case GameState.PRECHECK_DEVICE_CONNECTION:
        // FlutterBluetoothSerial.instance
        //     .(widget.address)
        //     .then((value) => print(value));
        BluetoothConnection.toAddress(address).then((value) {
          bluetoothConnection = value;
          _orientationStream =
              _getOrientationStream(value.input.asBroadcastStream());
          _gameState.value = GameState.READY;
          return _mainStateProcessing();
        }, onError: (e) {
          /* device not on */
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Device must be turned on.")));
        });
        break;
      case GameState.PRE_DEVICE_NOT_DETECTED:
        break;
      case GameState.READY:
      case GameState.RESUME:
        /* start game */
        stopwatch.start();
        setState(() {
          isPaused = false;
        });
        break;
      case GameState.PAUSE:
        stopwatch.stop();
        setState(() {
          isPaused = true;
        });
        print("paused");
        break;
      case GameState.BLUETOOTH_DISCONNECTED:
        stopwatch.stop();
        setState(() {
          isPaused = true;
        });
        FlutterBluetoothSerial.instance.requestEnable().then((enabled) {
          if (enabled) {
            // connect device
            _gameState.value = GameState.DEVICE_CONNECTING;
            return _mainStateProcessing();
          } else {
            // dialog to ask whether to continue?
            showAlertDialog(
              context: context,
              title: "Confirmation",
              content:
                  "Bluetooth is required to continue, do you want to turn it on?",
              confirmCallback: () {
                /* request again */
                return _mainStateProcessing();
              },
              cancelCallback: () {
                /* go back without save */
                Navigator.of(context).pop();
              },
              extraButtonText: "Save and back",
              extraButtonCallback: () {
                /* save and back */
                Future.delayed(Duration(seconds: 2), () {
                  // TODO: change to http
                  Navigator.of(context).pop();
                });
              },
            );
          }
        });
        break;
      case GameState.DEVICE_CONNECTING:
      case GameState.DEVICE_DISCONNECTED:
        stopwatch.stop();
        setState(() {
          isPaused = true;
        });
        showLoadingDialog(context);
        BluetoothConnection.toAddress(address).then((value) {
          _orientationStream =
              _getOrientationStream(value.input.asBroadcastStream());
          _gameState.value = GameState.READY;
          return _mainStateProcessing();
        }, onError: (e) {
          /* device not on */
          // still cannot find, ask whether to proceed?
          showAlertDialog(
            context: context,
            title: "Confirmation",
            content:
                "The device cannot be detected, do you still want to continue?",
            confirmCallback: () {
              /* search again */
              return _mainStateProcessing();
            },
            cancelCallback: () {
              /* go back without save */
              Navigator.of(context).pop();
            },
            extraButtonCallback: () {
              /* save and go back */
              Future.delayed(Duration(seconds: 2), () {
                // TODO: change to http
                Navigator.of(context).pop();
              });
            },
            extraButtonText: "Save and back",
          );
        });
        break;
      case GameState.SAVING:
        stopwatch.stop();
        print(stopwatch.elapsedMilliseconds);
        uploadExercise(widget.part.id!, stopwatch.elapsedMilliseconds / 1000.0,
                oscillation)
            .then((value) {
          Navigator.of(context).pop();
          // Navigator.of(context).pop();
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Exercise record saved.")));
        });
        break;
    }
  }
}

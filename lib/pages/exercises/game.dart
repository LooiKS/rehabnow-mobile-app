import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:rehabnow_app/components/dot_loading_indicator.dart';
import 'package:rehabnow_app/pages/exercises/catch_the_bug_game.dart';
import 'package:rehabnow_app/pages/exercises/exercises.dart';
import 'package:rehabnow_app/pages/exercises/skip_the_hurdles.dart';
import 'package:rehabnow_app/services/exercise.http.service.dart';
import 'package:rehabnow_app/utils/dialog.dart';

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

  int maxAngle = 180;
  int diffAngle = 90;

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

  void _prepareGame() {
    _gameState.value = GameState.PRECHECK_BLUETOOTH_STATUS;
    _mainStateProcessing();

    bluetoothStateSubscription =
        FlutterBluetoothSerial.instance.onStateChanged().listen((value) {
      if (value == BluetoothState.STATE_ON) {
      } else if (value == BluetoothState.STATE_OFF) {
        _gameState.value = _gameState.value.index < GameState.READY.index
            ? GameState.PRECHECK_BLUETOOTH_STATUS
            : GameState.BLUETOOTH_DISCONNECTED;
        _mainStateProcessing();
      }
    });
  }

  double initialValue = 0.0;
  int iteration = 2;

  Stream<double> _getOrientationStream(Stream<Uint8List> source) async* {
    List<int> _uint8List = [];
    _streamSubscription = source.listen((event) {});
    _streamSubscription!.onDone(() {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Device disconnected")));
      _gameState.value = GameState.DEVICE_DISCONNECTED;
      _mainStateProcessing();
    });
    await for (var val in source) {
      for (int i = 0; i < val.length; i++) {
        if (val[i] == 10) {
          _uint8List = [];
        } else if (val[i] == 13) {
          double value =
              double.tryParse(String.fromCharCodes(_uint8List)) ?? 0.0;
          value = initialValue + (1 / iteration) * (value - initialValue);
          initialValue = value;

          double normalisedPosition = (value + diffAngle) / maxAngle;

          if (normalisedPosition > 0.85 && reachTop) {
            reachTop = false;
            setState(() {
              oscillation++;
            });
          }
          if (normalisedPosition < 0.15) {
            reachTop = true;
          }

          yield normalisedPosition;
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
    maxAngle = widget.part.name!.toUpperCase().indexOf("UPPER") > -1 ? 180 : 90;
    diffAngle = widget.part.name!.toUpperCase().indexOf("UPPER") > -1 ? 90 : 0;
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
        valueListenable: _gameState,
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
        break;
      case GameState.BLUETOOTH_DISCONNECTED:
        stopwatch.stop();
        setState(() {
          isPaused = true;
        });
        FlutterBluetoothSerial.instance.requestEnable().then((enabled) {
          if (enabled) {
            _gameState.value = GameState.DEVICE_CONNECTING;
            return _mainStateProcessing();
          } else {
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
                Navigator.of(context).pop();
              });
            },
            extraButtonText: "Save and back",
          );
        });
        break;
      case GameState.SAVING:
        stopwatch.stop();
        uploadExercise(widget.part.id!, stopwatch.elapsedMilliseconds / 1000.0,
                oscillation)
            .then((value) {
          Navigator.of(context).pop();

          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Exercise record saved.")));
        });
        break;
    }
  }
}

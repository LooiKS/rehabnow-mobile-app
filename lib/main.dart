import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rehabnow_app/components/rehabnow_scaffold.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:rehabnow_app/pages/cases/view_cases.dart';
import 'package:rehabnow_app/pages/connection/connection.dart';
import 'package:rehabnow_app/pages/exercises/exercises.dart';
import 'package:rehabnow_app/pages/profile/view_profile.dart';
import 'package:rehabnow_app/pages/reminder/view_reminder.dart';
import 'package:rehabnow_app/shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  // RehabnowSharedPreferences preferences;
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  print(await FlutterNativeTimezone.getLocalTimezone());
  tz.setLocalLocation(
      tz.getLocation(await FlutterNativeTimezone.getLocalTimezone()));
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);

  final MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings();

  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: selectNotification,
  );
  SharedPreferences.getInstance()
      .then((value) => RehabnowSharedPreferences.sharedPreferences = value);

  runApp(MyApp());
}

Future selectNotification(String payload) async {
  if (payload != null) {
    debugPrint('notification payload: $payload');
  }
}

Future onDidReceiveLocalNotification(
    int i, String s1, String s2, String s3) async {}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.cyan,
            primaryColor: Color.fromRGBO(152, 51, 174, 1),
            primaryIconTheme: IconThemeData(color: Colors.white),
            primaryTextTheme:
                TextTheme(headline6: TextStyle(color: Colors.white)),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor: MaterialStateProperty.all(
                        Color.fromRGBO(152, 51, 174, 1)))),
            snackBarTheme: SnackBarThemeData(
                backgroundColor: Color.fromRGBO(152, 51, 174, 1))),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            backgroundColor: Colors.grey[200],
            body: SafeArea(
                child: Login())) //MyHomePage(title: 'Flutter Demo Home Page'),
        );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Card(
            elevation: 2,
            // color: Colors.amber,
            margin: EdgeInsets.all(20),
            child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Welcome To RehabNow",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                    ),
                    Flexible(
                        child: TextFormField(
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.mail_outline),
                          labelText: "Email Address",
                          border: OutlineInputBorder()),
                    )),
                    Padding(padding: EdgeInsets.all(10)),
                    Flexible(
                      child: TextFormField(
                        decoration: InputDecoration(
                            labelText: "Password",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: Icon(Icons.visibility_off)),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(10)),
                    RaisedButton(
                      color: Colors.blue,
                      onPressed: () => {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => MainPage()))
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      padding: EdgeInsets.all(10),
                    ),
                    Divider(
                      color: Colors.black54,
                    ),
                    Text(
                      "Forgot Password?",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      child: Text(
                        "Reset here",
                        style: TextStyle(color: Colors.blue[500]),
                      ),
                      onTap: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ResetPassword()))
                      },
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Container(
          child: Center(
            child: Card(
                margin: EdgeInsets.all(20),
                child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "Reset Password",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                        ),
                        Text(
                          "No worries, it is normal to be forgetful. We got you covered!",
                          textAlign: TextAlign.center,
                          // style: TextStyle(),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.mail_outline),
                              border: OutlineInputBorder(),
                              labelText: "Email Address"),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                        ),
                        RaisedButton(
                          onPressed: () => {},
                          color: Colors.blue,
                          child: Text(
                            "Submit",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ))),
          ),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> drawers = [
      'Case',
      'Connect Wearable Devices',
      'Exercise',
      'Reminder',
      'Profile',
      'Logout'
    ];
    List<IconData> drawerIcons = [
      Icons.local_hospital,
      Icons.bluetooth,
      Icons.airline_seat_recline_extra,
      Icons.alarm,
      Icons.person_outline,
      Icons.exit_to_app,
    ];
    List<Function> drawerFunctions = [
      () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ViewCases()));
      },
      () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Connection()));
      },
      () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Exercises()));
      },
      () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ViewReminder()));
      },
      () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Profile()));
      },
      () {
        Navigator.pop(context);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MyApp()));
      }
    ];
    return Scaffold(
        appBar: AppBar(
          title: Text("Home"),
        ),
        drawer: Drawer(
          child: SafeArea(
              child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(padding: EdgeInsets.all(10)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/logo.png"),
                    Text(
                      "RehabNow",
                      style: TextStyle(fontSize: 25),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                ),
                Flexible(
                  child: ListView.separated(
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('${drawers[index]}'),
                          leading: Icon(drawerIcons[index]),
                          onTap: drawerFunctions[index],
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                        );
                      },
                      separatorBuilder: (context, index) => Divider(height: 0),
                      itemCount: drawers.length),
                )
              ],
            ),
          )),
        ),
        body: SafeArea(
            child: Container(
          child: Text("Main Page Coming Soon."),
        )));
  }
}

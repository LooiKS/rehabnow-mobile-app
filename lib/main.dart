import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rehabnow_app/constants/routes.constant.dart';
import 'package:rehabnow_app/models/case.model.dart';
import 'package:rehabnow_app/models/user.model.dart';
import 'package:rehabnow_app/pages/cases/view_case.dart';
import 'package:rehabnow_app/pages/cases/view_cases.dart';
import 'package:rehabnow_app/pages/cases/view_exercises.dart';
import 'package:rehabnow_app/pages/connection/connection.dart';
import 'package:rehabnow_app/pages/exercises/exercises.dart';
import 'package:rehabnow_app/pages/exercises/game.dart';
import 'package:rehabnow_app/pages/home/reset_password.dart';
import 'package:rehabnow_app/pages/prelogin/login.dart';
import 'package:rehabnow_app/pages/prelogin/main_page.dart';
import 'package:rehabnow_app/pages/profile/edit_profile.dart';
import 'package:rehabnow_app/pages/profile/view_profile.dart';
import 'package:rehabnow_app/pages/reminder/view_reminder.dart';
import 'package:rehabnow_app/utils/flutter_secure_storage.dart';
import 'package:rehabnow_app/utils/shared_preferences.dart';
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

Future selectNotification(String? payload) async {
  if (payload != null) {
    debugPrint('notification payload: $payload');
  }
}

Future onDidReceiveLocalNotification(
    int i, String? s1, String? s2, String? s3) async {}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RehabNow',
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
        primaryColor: Color.fromRGBO(100, 5, 190, 1),
        primaryIconTheme: IconThemeData(color: Colors.white),
        primaryTextTheme: TextTheme(headline6: TextStyle(color: Colors.white)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.white),
            backgroundColor: MaterialStateProperty.all(
              Color.fromRGBO(100, 5, 190, 1),
            ),
          ),
        ),
        snackBarTheme:
            SnackBarThemeData(backgroundColor: Color.fromRGBO(100, 5, 190, 1)),
        appBarTheme: AppBarTheme(
          brightness: Brightness.dark,
          centerTitle: true,
          backgroundColor: Color.fromRGBO(100, 5, 190, 1),
          // foregroundColor: Color.fromRGBO(152, 51, 174, 1),
          // textTheme: TextTheme(headline6: TextStyle(color: Colors.black)),
          // elevation: 0,
          // systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        scaffoldBackgroundColor: Color.fromRGBO(255 - 9, 255 - 9, 255 - 9, 1),
      ),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        late Widget page;

        var args = settings.arguments as Map<String, Object>;

        switch (settings.name) {
          case RoutesConstant.VIEW_EXERCISES:
            page = ViewExercises(
              partId: args["id"] as int,
            );
            break;
          case RoutesConstant.EXERCISES:
            page = Exercises();
            break;
          case RoutesConstant.CASE:
            page = ViewCase(
              caseObj: args["caseObj"] as Case,
            );
            break;
          case RoutesConstant.GAME:
            page = Game(
              gameNum: args["gameNum"] as int,
              part: args["part"] as PartDisplay,
            );
            break;
          case RoutesConstant.CONNECTION:
            page = Connection();
            break;
          case RoutesConstant.MAIN_PAGE:
            page = MainPage();
            break;
          case RoutesConstant.RESET_PASSWORD:
            page = ResetPassword();
            break;
          case RoutesConstant.CASES:
            page = ViewCases();
            break;
          case RoutesConstant.VIEW_REMINDER:
            page = ViewReminder();
            break;
          case RoutesConstant.PROFILE:
            page = Profile();
            break;
          case RoutesConstant.HOME:
            page = MyApp();
            break;
          case RoutesConstant.EDIT_PROFILE:
            page = ProfileEdit(user: args["user"] as User);
            break;
        }
        return MaterialPageRoute(builder: (context) => page);
      },
      home: Scaffold(
        backgroundColor: Colors.grey[200],
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: FutureBuilder<String?>(
              future: RehabnowFlutterSecureStorage.storage.read(key: "token"),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return CircularProgressIndicator();
                } else {
                  if (snapshot.hasData) {
                    //todo: check token
                    return MainPage();
                  } else {
                    return Login();
                  }
                }
              }),
        ),
      ),
    );
  }
}

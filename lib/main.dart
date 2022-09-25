// checked = 0 => No Url found
// checked = 1 => Url found
// notification = 0 => No Notification yet
// notification = 1 => User was notified
// import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'list_page.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'db_helper.dart';
import 'package:http/http.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/theme_data.dart';

DBHelper _dbHelper = DBHelper();
void initState() {
  _dbHelper.initializeDatabase().then((value) {
    print('------database intialized');
  });
}

setfirststarttrue() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('notfirststart', true);
}

getnotfirststart() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return bool
  bool boolValue = prefs.getBool('notfirststart') ?? false;
  return boolValue;
}

void showHelp(context) {
  showModalBottomSheet<void>(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Container(
          color: Colors.black,
          child: Column(children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(height: 40),
                        RichText(
                          text: TextSpan(
                            text: 'How to use\nBaeWatch\n\n',
                            style: TextStyle(fontSize: 32),
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Add new Entry',
                                  style: TextStyle(fontSize: 24)),
                            ],
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            'assets/new_entry.jpg',
                            height: 64.4,
                            width: 200.0,
                            fit: BoxFit.fill,
                          ),
                        ),
                        Container(
                          width: 200,
                          child: Text(
                              'Click the button to create a new entry in the database\n\nNow you have to fill out the form shown below. You must specify at least one URL for the app to work properly\n',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            'assets/save.jpg',
                            height: 281.11,
                            width: 200.0,
                            fit: BoxFit.fill,
                          ),
                        ),
                        Container(
                          width: 200,
                          child: Text(
                              '\nAfter saving you will see your entry on the main screen. If at least one URL is available the box will be colored blue (Example1) otherwise it will be shown as red (Example2)\n',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                        ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/examples.jpg',
                              height: 171.11,
                              width: 200.0,
                              fit: BoxFit.fill,
                            )),
                        SizedBox(height: 40),
                        Container(
                          width: 200,
                          child: Text(
                            'Manipulate/Show Entries\n',
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                        ),
                        Container(
                          width: 200,
                          child: Text(
                            'If you want to view or manipulate one entry just click on the box and the following page will appear\n',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/change.jpg',
                              height: 314.44,
                              width: 200.0,
                              fit: BoxFit.fill,
                            )),
                        Container(
                          width: 200,
                          child: Text(
                            '\nBy clicking the symbol next to the URL the link will be opened in your browser\nIf you want to manipulate your entry just do so and click the save button after you´re finished\n',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 30),
                        Container(
                          width: 200,
                          child: Text(
                            'If you need help and want to read this text again, click on the help symbol on the top right of the main screen\n',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(20),
              width: 250,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: GradientTemplate.gradientTemplate[1].colors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              child: FlatButton(
                child: const Text('Close Hints',
                    style: TextStyle(fontSize: 24, color: Colors.white)),
                onPressed: () => Navigator.pop(context),
              ),
            )
          ]),
        ),
      );
    },
  );
}

Future checkurl() async {
  var elements = await _dbHelper.getElements();

  for (int i = 0; i < elements.length; i++) {
    var checked = 0;
    if (elements[i].url1.isNotEmpty) {
      var url = elements[i].url1;
      checked = await urlsubfunction(checked, url);
    }
    if (elements[i].url2.isNotEmpty) {
      var url = elements[i].url2;
      checked = await urlsubfunction(checked, url);
    }
    if (elements[i].url3.isNotEmpty) {
      var url = elements[i].url3;
      checked = await urlsubfunction(checked, url);
    }
    if (elements[i].checked != checked) {
      //Turn on notification if the status changed
      elements[i].notification = 0;
    }
    elements[i].checked = checked;
    print(elements[i].checked);
    print(elements[i].notification);
    if ((checked == 0) && (elements[i].notification == 0)) {
      elements[i].notification = 1;
      print('Benachrichtigung');
      notification(elements[i].title);
    } else if ((checked == 1) && elements[i].notification == 1) {
      elements[i].notification = 0;
    }
    await _dbHelper.update(elements[i]);
  }
}

Future urlsubfunction(checked, url) async {
  try {
    final Response response = await get(url);
    // print(response.statusCode);
    // print(response.headers);
    if (response.statusCode == 200) {
      checked = 1;
    }
  } catch (e) {
    // print(e);
  }
  return checked;
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void printHello() async {
  // final DateTime now = DateTime.now();
  // final int isolateId = Isolate.current.hashCode;
  // print("[$now] Hello, world! isolate=$isolateId function='$printHello'");
  initState();
  if (await DataConnectionChecker().hasConnection) {
    checkurl();
  }
}

void main() async {
  final int helloAlarmID = 0;
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();

  var initializationSettingsAndroid =
      AndroidInitializationSettings('baewatch_logo');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {});
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  });
  runApp(MyApp());

  await AndroidAlarmManager.periodic(
      const Duration(minutes: 1), helloAlarmID, printHello);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BaeWatch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AlarmPage(),
    );
  }
}

void notification(String title) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'alarm_notif',
    'alarm_notif',
    'Channel for Alarm notification',
    icon: 'baewatch_logo',
    largeIcon: DrawableResourceAndroidBitmap('baewatch_logo'),
  );

  var iOSPlatformChannelSpecifics = IOSNotificationDetails(
      presentAlert: true, presentBadge: true, presentSound: true);
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      0,
      'New Development',
      'Open the app and check your entry with the title $title',
      platformChannelSpecifics);
}

import 'dart:convert';

import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('A bg message just showed up :  ${message.data}');
  if (message.data['user'].toString() == "1") {
    debugPrint("user is string");
  } else {
    debugPrint('not string');
  }
  flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.data['title'],
      message.data['body'],
      NotificationDetails(
          android: AndroidNotificationDetails(channel.id, channel.name,
              importance: Importance.high,
              color: Colors.blue,
              playSound: true,
              icon: '@mipmap/ic_launcher')));
}

Future<String?> getToken() async {
  return await FirebaseMessaging.instance.getToken();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseInstallations installations = FirebaseInstallations.instance;
  installations.getToken().then((value) => debugPrint('token install: $value'));
  String id = await installations.getId();
  debugPrint('getID: $id');
  installations.onIdChange.listen((token) {
    debugPrint('FID token: $token');
  });
  FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    debugPrint('onTokenRefresh $fcmToken');
  }).onError((err) {
    debugPrint(err.toString());
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage('Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage(this.title);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      debugPrint('A new onMessageOpenedApp event was published!');
      var data = message.data;
      debugPrint(data.toString());
      // if (notification != null  ) {

      flutterLocalNotificationsPlugin.show(
          0,
          message.data['title'],
          message.data['body'],
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              color: Colors.blue,
              playSound: true,
              icon: '@mipmap/ic_launcher',
            ),
          ));
      // }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      // if (notification != null ) {
      flutterLocalNotificationsPlugin.show(
          0,
          message.data['title'],
          message.data['body'],
          NotificationDetails(
              android: AndroidNotificationDetails(channel.id, channel.name,
                  importance: Importance.high,
                  color: Colors.blue,
                  playSound: true,
                  icon: '@mipmap/ic_launcher')));
      // }
    });
  }

  void toast(String mes) {
    Fluttertoast.showToast(
        msg: mes,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void showNotification() {
    setState(() {
      _counter++;
    });
    flutterLocalNotificationsPlugin.show(
        0,
        "Testing $_counter",
        "How you doin ?",
        NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                importance: Importance.high,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher')));
  }

  // String host = 'http://172.16.6.32:8811';
  String host = 'https://apiuat.kss.com.vn/uat/v1/device';
  // String host = 'http://172.16.6.32:8811';
  String hostLocal = 'http://172.16.6.32:8809/push_notification';

  // String host = 'http://10.199.18.5:8811';

  void sendToUser(String userName) async {
    try {
      var url = Uri.parse('$hostLocal/i/push');
      final body = {
        "body": 'body cua $userName',
        "data": {
          "body": 'body cua $userName',
          "title": "title cua  $userName",
          "additionalProp3": "string"
        },
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        // "listUser": [userName],
        "lstFileAttach": "string",
        "messageType": "ACCOUNT",
        "providerType": "FIRE_BASE",
        "sendType": "SINGLE",
        "template": "string",
        "title": "string",
        "topic": "topic_1",
        "url": "string",
        "user": userName
      };

      var response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body));

      // response.then((value) => debugPrint(value.body));
      if (response.statusCode == 200) {
        toast("Send request success!!!");
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void sendToTopic(String topic) async {
    try {
      var url = Uri.parse('$hostLocal/i/push');
      final body = {
        "body": ' body cua topic: $topic',
        "data": {
          "body": ' body cua topic: $topic',
          "title": "title cua topic: $topic",
          "additionalProp3": "string"
        },
        "id": DateTime.now().millisecondsSinceEpoch,
        "lstFileAttach": "string",
        "messageType": "ACCOUNT",
        "providerType": "FIRE_BASE",
        "sendType": "TOPIC",
        "template": "string",
        "title": "string",
        "topic": topic,
        "url": "string",
      };

      var response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body));

      // response.then((value) => debugPrint(value.body));
      if (response.statusCode == 200) {
        toast("Send request success!!!");
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void registerDevice(String userName, String token) async {
    try {
      var split = token.split(":");
      var url = Uri.parse('$host/p/device/register/$userName');
      final body = {
        "device_name": "3123131312",
        "install_id": split[0],
        "os": "os",
        "token": token
      };

      var response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body));

      // response.then((value) => debugPrint(value.body));
      if (response.statusCode == 200) {
        toast("register device success!!!");
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void unregisterDevice(String userName, String token) async {
    try {
      var split = token.split(":");
      var url = Uri.parse('$host/p/device/unregister/$userName');
      final body = {
        "device_name": "3123131312",
        "install_id": split[0],
        "os": "os",
        "token": token
      };

      var response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body));

      // response.then((value) => debugPrint(value.body));
      if (response.statusCode == 200) {
        toast("unregister device success!!!");
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void subscribeTopic(String userName) async {
    try {
      String topic = 'topic_1';
      var url = Uri.parse('$host/p/topic/subscribe/$userName');
      final body = {"topic_name": topic};

      var response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body));

      // response.then((value) => debugPrint(value.body));
      if (response.statusCode == 200) {
        toast("subscribe topic success!!!");
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void unsubscribeTopic(String userName) async {
    try {
      String topic = 'topic_1';
      var url = Uri.parse('$host/p/topic/unsubscribe/$userName');
      final body = {"topic_name": topic};

      var response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body));

      // response.then((value) => debugPrint(value.body));
      if (response.statusCode == 200) {
        toast("unsubscribe topic success!!!");
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var myController = TextEditingController();
    var myControllerForTest = TextEditingController();
    String? token = '';
    getToken().then((value) => token = value);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            TextField(
              controller: myController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a search term',
              ),
            ),
            Row(
              children: [
                FlatButton(
                  child: const Text(
                    '?????ng k?? device',
                    style: TextStyle(fontSize: 5.0),
                  ),
                  onPressed: () {
                    registerDevice(myController.text, token!);
                  },
                ),
                FlatButton(
                  child: const Text(
                    'delete device',
                    style: TextStyle(fontSize: 5.0),
                  ),
                  onPressed: () {
                    unregisterDevice(myController.text, token!);
                  },
                ),
                FlatButton(
                  child: const Text(
                    'subscribe topic: topic_1',
                    style: TextStyle(fontSize: 5.0),
                  ),
                  onPressed: () {
                    subscribeTopic(myController.text);
                  },
                ),
                FlatButton(
                  child: const Text(
                    'unsubscribe topic: topic_1',
                    style: TextStyle(fontSize: 5.0),
                  ),
                  onPressed: () {
                    unsubscribeTopic(myController.text);
                  },
                ),
              ],
            ),
            TextField(
              controller: myControllerForTest,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Test',
              ),
            ),
            Row(children: [
              FlatButton(
                child: const Text(
                  'Send to User',
                  style: TextStyle(fontSize: 5.0),
                ),
                onPressed: () {
                  sendToUser(myControllerForTest.text);
                },
              ),
              FlatButton(
                child: const Text(
                  'Send to topic',
                  style: TextStyle(fontSize: 5.0),
                ),
                onPressed: () {
                  sendToTopic(myControllerForTest.text);
                },
              ),
            ])
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showNotification,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

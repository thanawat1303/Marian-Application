import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marian/VideoStart.dart';
import 'package:marian/notifyPage.dart';
import 'package:marian/profilePage.dart';
import 'package:marian/reviewPage.dart';
import 'package:marian/searchPage.dart';
import 'package:marian/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marian/UserData.dart';
import 'package:provider/provider.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.max,
);

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class allBodyMarian extends StatefulWidget {
  const allBodyMarian({key});

  @override
  State<allBodyMarian> createState() => _allBodyMarianState();
}

class _allBodyMarianState extends State<allBodyMarian>
    with TickerProviderStateMixin {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final messageLi = FirebaseMessaging.instance;
  //int _selectPage = 0;

  AnimationController? animationControllerSearch;
  AnimationController? animationControllerReport;
  AnimationController? animationControllerProfile;
  AnimationController? animationControllerNotify;

  Animation<double>? animationShPosition;
  Animation? animationShColor;
  Animation<double>? animationShSize;

  Animation<double>? animationReportPosition;
  Animation? animationReportColor;
  Animation<double>? animationReportSize;

  Animation<double>? animationProfilePosition;
  Animation? animationProfileColor;
  Animation<double>? animationProfileSize;

  Animation<double>? animationNotifyPosition;
  Animation? animationNotifyColor;
  Animation<double>? animationNotifySize;

  int currentState = 0;
  bool stateNotify = true;

  String? message;
  String channelId = "1000";
  String channelName = "FLUTTER_NOTIFICATION_CHANNEL";
  String channelDescription = "FLUTTER_NOTIFICATION_CHANNEL_DETAIL";

  @override
  void initState() {
    // _getUser();
    super.initState();
    animationControllerSearch =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    animationControllerProfile =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    animationControllerReport =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    animationControllerNotify =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    dynamic initPosiosion(AnimationController animation) {
      return Tween<double>(begin: 10, end: 20).animate(animation)
        ..addListener(() {
          setState(() {});
        });
    }

    dynamic initColor(AnimationController animation) {
      return ColorTween(
              begin: Color.fromARGB(255, 175, 90, 127), end: ColorThemeSoft)
          .animate(animation)
        ..addListener(() {
          setState(() {});
        });
    }

    dynamic initSize(AnimationController animation) {
      return Tween<double>(begin: 45, end: 55).animate(animation)
        ..addListener(() {
          setState(() {});
        });
    }

    animationShPosition = initPosiosion(animationControllerSearch!);
    animationShColor = initColor(animationControllerSearch!);
    animationShSize = initSize(animationControllerSearch!);

    animationReportPosition = initPosiosion(animationControllerReport!);
    animationReportColor = initColor(animationControllerReport!);
    animationReportSize = initSize(animationControllerReport!);

    animationProfilePosition = initPosiosion(animationControllerProfile!);
    animationProfileColor = initColor(animationControllerProfile!);
    animationProfileSize = initSize(animationControllerProfile!);

    animationNotifyPosition = initPosiosion(animationControllerNotify!);
    animationNotifyColor = initColor(animationControllerNotify!);
    animationNotifySize = initSize(animationControllerNotify!);

    message = "No message.";
    var initializationSettingsAndroid =
        AndroidInitializationSettings('notiicon');

    var initializationSettingsIOS = DarwinInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) async {
      print("onDidReceiveLocalNotification called.");
    });

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) async {
      print("onSelectNotification called.");
      setState(() {
        message = payload.payload;
      });
    });

    initFirebaseMessaging();
  }

  void initFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification!;
      AndroidNotification? android = message.notification?.android;

      if (android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: android.smallIcon,
              ),
            ));
        // var a = notification.title.toString();
        // var b = notification.body.toString();
        // sendNotification(a, b);
      }
    });

    messageLi.getToken().then((String? token) {
      assert(token != null);
      print("Token : $token");
    });
  }

  sendNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      '10000',
      'FLUTTER_NOTIFICATION_CHANNEL',
      channelDescription: 'FLUTTER_NOTIFICATION_CHANNEL_DETAIL',
      importance: Importance.max,
      priority: Priority.high,
    );

    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin
        .show(111, title, body, platformChannelSpecifics, payload: '');
  }

  @override
  void dispose() {
    super.dispose();
  }

  PageController pageView = PageController();
  PageController pageViewMain = PageController();
  double pageNow = 0;

  // List<Map<String, dynamic>> userProfile = [];

  // void _getUser() async {
  //   if (auth.currentUser != null) {
  //     await getData('member', 'uid', auth.currentUser!.uid).then((value) {
  //       setState(() {
  //         userProfile = value;
  //       });
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    try {
      final userData = store
          .collection('member')
          .where('uid', isEqualTo: auth.currentUser!.uid)
          .snapshots()
          .listen(
        (event) async {
          final dataDB = event.docs.map((e) => e.data()).toList(growable: true);
          final userKey = await store
              .collection('member')
              .where('uid', isEqualTo: auth.currentUser!.uid)
              .get()
              .then((value) => value.docs.first.id);
          UserDB dataUser = UserDB(
              id: userKey,
              uid: dataDB[0]['uid'],
              fullname: dataDB[0]['fullname'],
              email: dataDB[0]['email'],
              typeUser: dataDB[0]['type'],
              image: dataDB[0]['image'],
              phone: dataDB[0]['phone']);
          var nuser = Provider.of<UserProvider>(context, listen: false);
          nuser.addNewUser(dataUser);
          if (stateNotify) {
            await messageLi.subscribeToTopic(nuser.users.last.id.toString());
            stateNotify = false;
            print("stateNotify ${stateNotify}");
          }
        },
      );
    } catch (e) {
      auth.signOut();
    }
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.0), // here the desired height
          child: Container(
            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
            color: Color.fromARGB(255, 175, 90, 127),
            child: GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  currentFocus.unfocus();
                  pageViewMain.animateToPage(0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.linear);
                },
                child: Image(
                  height: 70,
                  image: AssetImage('assets/img/Logo.png'),
                )),
          )),
      body: PageView(
          scrollDirection: Axis.vertical,
          onPageChanged: (value) {
            print("Page : $value");
            if (value < 1) {
              pageView = PageController(initialPage: pageNow.toInt());
              AnimationPage(4);
            } else {
              List<AnimationController> animetion = [
                animationControllerSearch!,
                animationControllerReport!,
                animationControllerProfile!,
                animationControllerNotify!
              ];
              animetion[pageNow.toInt()].forward();
            }
          },
          controller: pageViewMain,
          children: [
            const VideoSchool(),
            PageView(
              onPageChanged: (value) {
                // _getUser();
                pageNow = value.toDouble();
                AnimationPage(value);
              },
              controller: pageView,
              children: const [
                search(),
                review(),
                profile(),
                notifyPage(),
              ],
            )
          ]),
      bottomNavigationBar: BarBottom(),
    );
  }

  Container text() {
    return Container(
      child: Text("145"),
    );
  }

  // void _selectIndex(int index) {
  //   setState(() {
  //     _selectPage = index;
  //   });
  // }

  NavigationBar BarBottom() {
    return NavigationBar(
      height: 85,
      backgroundColor: Colors.white,
      onDestinationSelected: (value) {
        print("Naga : $value");
      },
      destinations: [
        Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
                bottom: animationShPosition!.value,
                child: IconButton(
                  color: animationShColor!.value,
                  highlightColor: Colors.pink.shade100,
                  splashColor: Colors.indigo.shade100,
                  iconSize: animationShSize!.value,
                  splashRadius: 30,
                  icon: Icon(
                    Icons.search,
                  ),
                  onPressed: () {
                    ChangePull(0);
                  },
                ))
          ],
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
                bottom: animationReportPosition!.value,
                child: IconButton(
                  color: animationReportColor!.value,
                  highlightColor: Colors.pink.shade100,
                  splashColor: Colors.indigo.shade100,
                  iconSize: animationReportSize!.value,
                  splashRadius: 30,
                  icon: Icon(
                    Icons.note_alt_rounded,
                  ),
                  onPressed: () {
                    ChangePull(1);
                  },
                ))
          ],
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
                bottom: animationProfilePosition!.value,
                child: IconButton(
                  color: animationProfileColor!.value,
                  highlightColor: Colors.pink.shade100,
                  splashColor: Colors.indigo.shade100,
                  iconSize: animationProfileSize!.value,
                  splashRadius: 30,
                  icon: Icon(
                    Icons.person,
                  ),
                  onPressed: () {
                    ChangePull(2);
                  },
                ))
          ],
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
                bottom: animationNotifyPosition!.value,
                child: IconButton(
                  color: animationNotifyColor!.value,
                  highlightColor: Colors.pink.shade100,
                  splashColor: Colors.indigo.shade100,
                  iconSize: animationNotifySize!.value,
                  splashRadius: 30,
                  icon: Icon(
                    Icons.notifications_outlined,
                  ),
                  onPressed: () {
                    ChangePull(3);
                  },
                ))
          ],
        )
      ],
    );
  }

  void ChangePull(int Page) {
    print("Page Now : $pageNow");

    List<AnimationController> animetion = [
      animationControllerSearch!,
      animationControllerReport!,
      animationControllerProfile!,
      animationControllerNotify!
    ];
    pageNow = Page.toDouble();
    if (pageViewMain.page!.toDouble() < 1.0) {
      animetion[Page].forward();
      if (pageViewMain.page != 0) {
        pageView.animateToPage(Page,
            duration: Duration(milliseconds: 200), curve: Curves.linear);
      } else {
        pageView = PageController(initialPage: Page);
      }
      pageViewMain.animateToPage(1,
          duration: Duration(milliseconds: 400), curve: Curves.linear);
    } else {
      pageView.animateToPage(Page,
          duration: Duration(milliseconds: 200), curve: Curves.linear);
    }
  }

  int PageOld = 0;

  void AnimationPage(int value) {
    List<AnimationController> animetion = [
      animationControllerSearch!,
      animationControllerReport!,
      animationControllerProfile!,
      animationControllerNotify!
    ];
    if (value <= 3) {
      animetion[value].forward();
      for (int x = 0; x <= 3; x++) {
        if (x != value) animetion[x].reverse();
      }
    } else {
      for (int x = 0; x <= 3; x++) {
        animetion[x].reverse();
      }
    }
  }
}


  // dynamic ItemBar() {
  //   List<BottomNavigationBarItem> Item = <BottomNavigationBarItem>[
  //     BottomNavigationBarItem(
  //         icon: Icon(
  //           Icons.search_rounded,
  //         ),
  //         label: ''),
  //     BottomNavigationBarItem(
  //         icon: Icon(
  //           Icons.note_alt_rounded,
  //         ),
  //         label: ''),
  //     BottomNavigationBarItem(
  //         icon: Icon(
  //           Icons.person,
  //         ),
  //         label: ''),
  //     BottomNavigationBarItem(
  //         icon: Icon(
  //           Icons.notifications_outlined,
  //         ),
  //         label: '')
  //   ];
  //   return Item;
  // }

// ElevatedButton(
//             onPressed: () {
//               auth.signOut();
//               Navigator.pushNamed(context, '/');
//             },
//             child: Text("Logout"))


//BottomNavigationBar(
      //   unselectedItemColor: Color.fromARGB(255, 175, 90, 127),
      //   selectedItemColor:
      //       stateAppStart ? Color.fromARGB(255, 175, 90, 127) : Colors.indigo.shade100,
      //   showUnselectedLabels: false,
      //   showSelectedLabels: true,
      //   selectedLabelStyle: TextStyle(fontSize: 0),
      //   unselectedLabelStyle: TextStyle(fontSize: 0),
      //   type: BottomNavigationBarType.fixed,
      //   items: ItemBar(),
      //   currentIndex: _selectPage,
      //   onTap: _selectIndex,
      //   selectedIconTheme: IconThemeData(
      //       size: 70,
      //       color: stateAppStart
      //           ? Color.fromARGB(255, 175, 90, 127)
      //           : Colors.indigo.shade100),
      //   unselectedIconTheme: IconThemeData(
      //     size: 55,
      //     color: Color.fromARGB(255, 175, 90, 127),
      //   ),
      // ),
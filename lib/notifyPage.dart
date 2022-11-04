import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marian/UserData.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';
import 'package:marian/functions.dart';

class notifyPage extends StatefulWidget {
  const notifyPage({super.key});

  @override
  State<notifyPage> createState() => _notifyPageState();
}

class _notifyPageState extends State<notifyPage> {
  final store = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> _getMessage(String id) {
    return store.collection('notifyMessage').doc(id).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    var nuser = Provider.of<UserProvider>(context, listen: false);
    var userM = nuser.users.last;
    return Scaffold(
      body: StreamBuilder(
        stream: _getMessage(userM.id.toString()),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? buildListMessage(snapshot.data!)
              : Center(
                  child: CircularProgressIndicator(
                    color: ColorThemeSoft,
                  ),
                );
        },
      ),
    );
  }

  dynamic buildListMessage(dynamic data) {
    Map dataQuery = data.data();
    if (dataQuery.length == 0) {
      return Center(
        child: Text(
          "ไม่มีการแจ้งเตือน",
          style: TextStyle(fontFamily: fontFamilyForm, fontSize: 20),
        ),
      );
    }
    List dataNotify = [];
    dataQuery.forEach((key, value) {
      dataNotify.add(value);
    });
    return ListView.builder(
        itemCount: dataNotify.length,
        itemBuilder: ((context, index) {
          Timestamp Time = dataNotify[index]['dateNotify'];
          return Container(
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
            width: MediaQuery.of(context).size.width,
            child: Row(children: [
              dataNotify[index]['image'] != ""
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 30,
                        child: Image.network(
                          (dataNotify[index]['image']),
                        ),
                      ))
                  : CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 238, 221, 221),
                      radius: 30,
                      child: Icon(
                        Icons.person,
                        color: ColorThemeSoft,
                        size: 60,
                      ),
                    ),
              SizedBox(
                width: 10,
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.76,
                  child: Stack(
                    children: [
                      Text(
                        "${dataNotify[index]['title']}",
                        style: TextStyle(
                            fontFamily: fontFamilyForm,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${dataNotify[index]['title']} ${dataNotify[index]['body']}",
                        style: TextStyle(
                          fontFamily: fontFamilyForm,
                        ),
                      )
                    ],
                  ),
                ),
                Text(
                  searchTime(DateTime.now().difference(Time.toDate())),
                  style: TextStyle(color: Color.fromARGB(255, 183, 183, 183)),
                )
              ])
            ]),
          );
        }));
  }

  String searchTime(Duration date) {
    if (date.inDays != 0) {
      return "${date.inDays.toString()} วันที่แล้ว";
    } else if (date.inHours != 0) {
      return "${date.inHours.toString()} ชั่วโมงที่แล้ว";
    } else {
      return "${date.inMinutes.toString()} นาทีที่แล้ว";
    }
  }
}

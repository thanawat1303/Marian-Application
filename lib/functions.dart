import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String fontFamilyForm = 'NatoSansThai';

Color ColorThemeSoft = Color.fromARGB(162, 238, 129, 176);

Color ColorError = Color.fromARGB(255, 197, 13, 0);

bool validateEmail(String value) {
  RegExp regex = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  return (!regex.hasMatch(value)) ? false : true;
}

bool validateName(String value) {
  RegExp regex = RegExp(
      r"^([a-zA-Z]{2,}\s[a-zA-z]{1,}'?-?[a-zA-Z]{2,}\s?([a-zA-Z]{1,})?)");
  return (!regex.hasMatch(value)) ? false : true;
}

bool isPWCorrect(String string) {
  final numericRegex = RegExp(r'^(([a-zA-Z]+[0-9])|([0-9]+[a-zA-Z]))');
  return numericRegex.hasMatch(string);
}

DateTime formatDate(String FormatUTC) {
  String date = DateTime.now().toString() + FormatUTC;
  return DateTime.parse(date);
}

Future getEmailToId(String field, String value) async {
  final store = FirebaseFirestore.instance;
  final query = await store
      .collection("member")
      .where(field, isEqualTo: value)
      .get()
      .then(
        (res) => res.docs[0].reference.id,
        onError: (e) => print("Error completing: $e"),
      );
  return query;
}

Future getData(String collection, String field, String value) async {
  final store = FirebaseFirestore.instance;
  final query = await store
      .collection(collection)
      .where(field, isEqualTo: value)
      .get()
      .then(
        (res) => res.docs.map((e) => e.data()).toList(growable: true),
        onError: (e) => print("Error completing: $e"),
      );
  return query;
}

Future<void> addFieldUser(String KeyId, dynamic data) async {
  final store = FirebaseFirestore.instance;
  await store.collection('member').doc(KeyId).update(data).catchError((e) {
    print(e);
  });
}

void addDocument() async {
  final store = FirebaseFirestore.instance;
  Map<String, dynamic> data = {
    'name': 'หอในและหออินเตอร์',
    'name_eng': '',
    'initial': '',
    'img': '',
    'map': '''https://goo.gl/maps/o3NrS2KpSHBo245Y9''',
    'like': 0,
  };
  DocumentReference userRef = await store.collection('place').add(data);
}

Future updateDatabase(String collectionPath, String documentPath,
    Map<String, dynamic> data) async {
  final store = FirebaseFirestore.instance;
  return await store.collection(collectionPath).doc(documentPath).update(data);
}

Future<void> sendMessageTopic(
    String topicSend, String body, String title) async {
  try {
    await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAE_dhMMw:APA91bEbNa0z3v49ruknlJkXF83ZHMKlJYAm9bLsIhdhJWS0wGzgyClO0i6miv2vb9uFTRl2TUR7kaza87vWxE7Az-Q77g9GWMD4yrSJp4dIi150Q-tlldC9CCQg6c0ic3kJbgr1baoZ',
        },
        body: jsonEncode({
          "to": "/topics/$topicSend",
          "notification": {'title': title, 'body': body},
        }));

    print('FCM request for device sent! $topicSend $body $title');
  } catch (e) {
    print("Error notify $e");
  }
}

Future<void> createTopic(String idMember) async {
  try {
    await http.post(
      Uri.parse('https://iid.googleapis.com/iid/v1:batchAdd'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
            'key=AAAAE_dhMMw:APA91bEbNa0z3v49ruknlJkXF83ZHMKlJYAm9bLsIhdhJWS0wGzgyClO0i6miv2vb9uFTRl2TUR7kaza87vWxE7Az-Q77g9GWMD4yrSJp4dIi150Q-tlldC9CCQg6c0ic3kJbgr1baoZ',
      },
      body: jsonEncode({"to": "/topics/$idMember"}),
    );
    print('Create Topic! $idMember');
  } catch (e) {
    print("Error notify $e");
  }
}

Future<void> deleteTopic(String idMember) async {
  try {
    await http.post(
      Uri.parse('https://iid.googleapis.com/iid/v1:batchRemove'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
            'key=AAAAE_dhMMw:APA91bEbNa0z3v49ruknlJkXF83ZHMKlJYAm9bLsIhdhJWS0wGzgyClO0i6miv2vb9uFTRl2TUR7kaza87vWxE7Az-Q77g9GWMD4yrSJp4dIi150Q-tlldC9CCQg6c0ic3kJbgr1baoZ',
      },
      body: jsonEncode({"to": "/topics/$idMember", "registration_tokens": []}),
    );
    print('Create Topic!');
  } catch (e) {
    print("Error notify $e");
  }
}

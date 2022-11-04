// ignore: depend_on_referenced_packages

import 'dart:math';

import 'package:marian/functions.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';

// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';

class search extends StatefulWidget {
  const search({key});

  @override
  State<search> createState() => _searchState();
}

class _searchState extends State<search> {
  TextEditingController search = TextEditingController();

  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  List Place = [];

  late FocusNode focusNodeTextForm;

  List vowelsThai = ['ิ', 'ี', 'ึ', 'ื', 'ุ', 'ู', '์'];

  Position? userLocation;

  Future<Position> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    userLocation = await Geolocator.getCurrentPosition();
    return userLocation!;
  }

  Future<void> _openOnGoogleMapApp(double latitude, double longitude,
      double latitudeUser, double longitudeUser) async {
    final Uri _url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=$latitude,$longitude&destination=$latitudeUser,$longitudeUser');

//'https://www.google.com/maps/dir/?api=1&origin=13.7929841,100.636345&destination=13.9880741,100.8068477');

    final bool nativeAppLaunchSucceeded = await launchUrl(
      _url,
      mode: LaunchMode.externalNonBrowserApplication,
    );

    if (!nativeAppLaunchSucceeded) {
      await launchUrl(
        _url,
        mode: LaunchMode.externalNonBrowserApplication,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    focusNodeTextForm = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    dataPlace = {};
    focusNodeTextForm.unfocus();
    focusNodeTextForm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Header(),
            SizedBox(height: 10),
            TextSearch(),
            Stack(
              children: [detailPlace(), ListSelect()],
            )
          ],
        )
      ],
    );
  }

  Center Header() {
    return Center(
      child: Text(
        "ค้นหาสถานที่",
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: 'NatoSansThai',
            fontSize: 20,
            fontWeight: FontWeight.w900),
      ),
    );
  }

  int random = 0;

  Container TextSearch() {
    return Container(
      height: 45,
      padding: EdgeInsets.only(left: 25, right: 25),
      child: Form(
        child: TextFormField(
          onFieldSubmitted: (value) {
            setState(() {
              Place.clear();
            });
          },
          focusNode: focusNodeTextForm,
          onChanged: (valueM) async {
            Place.clear();
            print(valueM);
            List data = await store.collection('place').get().then((value) {
              return value.docs.map((e) => e.get('name')).toList();
            }).then((value) {
              value.forEach((element) {
                int numPass = 0;
                if (valueM.length != 0) {
                  int check = valueM.indexOf("ตึก");
                  if (check == 0 && valueM.length >= 4) {
                    valueM = valueM.replaceRange(0, 3, "");
                  }
                  print(valueM);
                  List<dynamic> all = [element, valueM];
                  for (int a = 0; a < 2; a++) {
                    List box = [];
                    for (int z = 0; z < all[a].length; z++) {
                      if (vowelsThai.contains(all[a][z])) {
                        box[z - 1] = "";
                        box.add(all[a][z - 1] + all[a][z]);
                      } else {
                        box.add(all[a][z]);
                      }
                    }
                    box.removeWhere((element) => element == "");
                    all.removeAt(a);
                    all.insert(a, box);
                  }
                  print(all);

                  for (int x = 0; x < all[1].length; x++) {
                    for (int y = 0; y < all[0].length; y++) {
                      if (all[1][x] == all[0][y]) {
                        print(all[0][y]);
                        numPass++;
                        break;
                      }
                    }
                  }
                  if (numPass / all[1].length * 100 >= 80) {
                    String PlaceSelect = element;
                    Future.delayed(Duration(milliseconds: 100), () {
                      setState(() {
                        Place.add(PlaceSelect);
                      });
                    });
                  } else {
                    Future.delayed(Duration(milliseconds: 70), () {
                      setState(() {
                        Place.clear();
                      });
                    });
                  }
                  print("$element : ${numPass / all[1].length * 100}");
                } else {
                  Future.delayed(Duration(milliseconds: 70), () {
                    setState(() {
                      Place.clear();
                    });
                  });
                }
              });
              return value;
            });
          },
          controller: search,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          cursorColor: Colors.white,
          cursorRadius: Radius.circular(50),
          cursorWidth: 3.0,
          style: TextStyle(
            fontStyle: FontStyle.normal,
            fontSize: 24,
          ),
          decoration: InputDecoration(
            fillColor: Color.fromARGB(95, 175, 90, 127),
            filled: true,
            contentPadding: EdgeInsets.zero,
            prefixIcon: Icon(
              Icons.search,
              size: 35,
              color: Colors.white,
            ),
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(25.0)),
          ),
        ),
      ),
    );
  }

  String map = "";

  Container detailPlace() {
    return Container(
      padding: const EdgeInsets.only(left: 50, right: 50, top: 50, bottom: 50),
      child: dataPlace.isNotEmpty
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                Align(
                  child: Column(children: [
                    dataPlace['img'][0] != ""
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              dataPlace['img'][random].toString(),
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress != null) {
                                  return Container(
                                    padding: EdgeInsets.all(100),
                                    child: CircularProgressIndicator(
                                      color: ColorThemeSoft,
                                    ),
                                  );
                                } else {
                                  return Image.network(
                                      dataPlace['img'][random].toString());
                                }
                              },
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.all(20),
                            child: ImageIcon(
                              AssetImage('assets/img/LogoApp.png'),
                              size: 150,
                              color: ColorThemeSoft,
                            ),
                          ),
                    SizedBox(height: 10),
                    Text(
                      dataPlace['name'],
                      style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'NatoSansThai',
                          fontWeight: FontWeight.w900),
                    )
                  ]),
                ),
                Positioned(
                  right: -15,
                  top: -15,
                  child: GestureDetector(
                    //AIzaSyD4-jDAFqTWILlQ0Vzq4KEmvJ8lI2Fwj7c
                    onTap: () async {
                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return Dialog(
                              insetAnimationCurve: Curves.linear,
                              insetAnimationDuration:
                                  Duration(milliseconds: 500),
                              child: Container(
                                  color: Color.fromARGB(95, 175, 90, 127),
                                  padding: EdgeInsets.all(10.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Loading Map',
                                        style: TextStyle(
                                            fontFamily: fontFamilyForm),
                                      )
                                    ],
                                  )),
                            );
                          });

                      await _getLocation().then((value) {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                          print(Navigator.of(context));
                          _openOnGoogleMapApp(
                              dataPlace['map']['latitude'],
                              dataPlace['map']['logitude'],
                              userLocation!.latitude,
                              userLocation!.longitude);
                        }
                      });
                    },
                    child: Image.asset('assets/img/google_map.png', scale: 10),
                  ),
                )
              ],
            )
          : Container(),
    );
  }

  Map<String, dynamic> dataPlace = {};

  Container ListSelect() {
    return Container(
        margin: EdgeInsets.only(left: 45, right: 45),
        constraints: BoxConstraints(maxHeight: 160),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(
                  color: Color.fromARGB(115, 158, 158, 158), width: 1),
              right: BorderSide(
                  color: Color.fromARGB(115, 158, 158, 158), width: 1),
              bottom: BorderSide(
                  color: Color.fromARGB(115, 158, 158, 158), width: 1),
            )),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: Place.length,
          itemBuilder: (context, index) {
            int n = Place.length - 1;
            return GestureDetector(
              onTap: () async {
                dataPlace = await store
                    .collection('place')
                    .where('name', isEqualTo: Place[index])
                    .get()
                    .then((value) => value.docs[0].data());
                print(dataPlace);

                setState(() {
                  if (dataPlace['img'] != null) {
                    var ran = Random();
                    random = ran.nextInt(dataPlace['img'].length);
                  }
                  search.text = Place[index];
                  focusNodeTextForm.unfocus();
                  Place.clear();
                });
              },
              child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 10),
                height: 40,
                child: Text(
                  Place[index],
                  style: TextStyle(fontSize: 18, fontFamily: 'NatoSansThai'),
                ),
              ),
            );
          },
        ));
  }
}

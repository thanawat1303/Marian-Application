import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:like_button/like_button.dart';
import 'package:marian/functions.dart';
import 'package:marian/pageAddPost.dart';

import 'package:marian/UserData.dart';
import 'package:provider/provider.dart';

class reviewUser extends StatefulWidget {
  const reviewUser({super.key});

  @override
  State<reviewUser> createState() => _reviewUserState();
}

class _reviewUserState extends State<reviewUser> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final Storage = FirebaseStorage.instance;

  bool statePage = true;
  List dataReview = [];
  @override
  void dispose() {
    statePage = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBar(
            backgroundColor: const Color.fromARGB(255, 175, 90, 127),
            title: Stack(
              clipBehavior: Clip.none,
              children: [
                Text(
                  "รีวิวของฉัน",
                  style: TextStyle(
                      fontFamily: fontFamilyForm,
                      fontSize: 25,
                      fontWeight: FontWeight.w600),
                ),
                Positioned(
                  left: 100,
                  child: Image.asset(
                    'assets/img/Logo.png',
                    width: 50,
                  ),
                )
              ],
            ),
            leading: GestureDetector(
              child: Icon(
                Icons.arrow_back_rounded,
                size: 35,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          )),
      body: _createListPost(),
    );
  }

  dynamic _createListPost() {
    var nuser = Provider.of<UserProvider>(context, listen: false);
    var userM = nuser.users.last;
    store
        .collection("review")
        .where("idMember", isEqualTo: nuser.users.last.id.toString())
        .get()
        .then((value) {
      if (statePage) {
        setState(() {
          dataReview = value.docs.map((e) => e.data()).toList(growable: false);
        });
      }
    });
    if (dataReview != [] && dataReview.isNotEmpty) {
      return ListView.builder(
          itemCount: dataReview.length,
          itemBuilder: ((context, index) {
            String image = '';
            FirebaseImage? ImageQuery;
            if (dataReview[index]['review_img'] != "" &&
                dataReview[index]['review_img'] != null &&
                dataReview[index]['review_img'].toString().isNotEmpty) {
              image = dataReview[index]['review_img'].toString();

              ImageQuery = FirebaseImage(
                  "gs://marian-ffd83.appspot.com/reviewImg/$image",
                  maxSizeBytes: 5000 * 2000);
              print(ImageQuery.shouldCache);
            }
            print("Title ${dataReview[index]['review_img']}");
            List listMember = dataReview[index]['list_memberLike'];
            return Card(
                child: Container(
              margin: EdgeInsets.only(top: 5, bottom: 5),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                image != ""
                    ? ImageQuery != null
                        ? Container(
                            padding: EdgeInsets.only(right: 20),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image(
                                    height: 110,
                                    image: FirebaseImage(
                                        "gs://marian-ffd83.appspot.com/reviewImg/${dataReview[index]['review_img'].toString()}",
                                        maxSizeBytes: 5000 * 2000))),
                          )
                        : CircularProgressIndicator()
                    : Container(
                        height: 0,
                        width: 0,
                      ),
                Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: dataReview[index]['review_img'] != "" &&
                                dataReview[index]['review_img'] != null
                            ? (MediaQuery.of(context).size.width - 100) * 0.62
                            : (MediaQuery.of(context).size.width - 50),
                        padding: EdgeInsets.all(2.5),
                        child: Stack(
                          children: [
                            like(index),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                dataReview[index]['review_name'],
                                style: TextStyle(
                                    fontFamily: 'NatoSansThai',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: dataReview[index]['review_img'] != "" &&
                                dataReview[index]['review_img'] != null
                            ? (MediaQuery.of(context).size.width - 100) * 0.62
                            : (MediaQuery.of(context).size.width - 50),
                        padding: EdgeInsets.all(2.5),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("ความคิดเห็น:",
                                  style: TextStyle(
                                      fontFamily: 'NatoSansThai',
                                      fontSize: 12)),
                              Container(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: Text(
                                    "   " + dataReview[index]['review_comment'],
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                        fontFamily: 'NatoSansThai',
                                        fontSize: 12)),
                              )
                            ]),
                      ),
                      Container(
                          width: dataReview[index]['review_img'] != "" &&
                                  dataReview[index]['review_img'] != null
                              ? (MediaQuery.of(context).size.width - 100) * 0.62
                              : (MediaQuery.of(context).size.width - 50),
                          padding: EdgeInsets.all(0),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("ความพึงพอใจ: ",
                                      style: TextStyle(
                                          fontFamily: 'NatoSansThai',
                                          fontSize: 11)),
                                  for (int x = 1;
                                      x <= dataReview[index]['review_score'];
                                      x++)
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 18,
                                    )
                                ],
                              ),
                            ],
                          ))
                    ],
                  ),
                ),
              ]),
            ));
          }));
    } else {
      return Center(
        child: CircularProgressIndicator(
          color: ColorThemeSoft,
        ),
      );
    }
  }

  Positioned like(int index) {
    return Positioned(
        right: 0.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.favorite,
              size: 20,
              color: ColorThemeSoft,
            ),
            Text(
              dataReview[index]['like'].toString(),
              style: TextStyle(
                  fontFamily: fontFamilyForm,
                  color: Colors.white,
                  fontSize: 12),
            ),
          ],
        ));
  }
}

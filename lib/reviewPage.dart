// ignore: file_names
import 'dart:io';

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
import 'package:marian/reviewUser.dart';
import 'package:provider/provider.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

class review extends StatefulWidget {
  const review({key});

  @override
  State<review> createState() => _reviewState();
}

class _reviewState extends State<review> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final Storage = FirebaseStorage.instance;
  final message = FirebaseMessaging.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
          width: MediaQuery.of(context).size.width - 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [buttomAdd(), header(), reviewUser()],
          ),
        ),
        const SizedBox(height: 5),
        StreamBuilder(
            stream: _getReviewAll(),
            builder: (context, AsyncSnapshot snapshot) {
              print(snapshot.connectionState);
              return snapshot.connectionState.name == 'waiting'
                  ? CircularProgressIndicator(
                      color: Color.fromARGB(255, 175, 90, 127),
                    )
                  : snapshot.hasData
                      ? buildListReview(snapshot.data!)
                      : Text('');
            }),
      ],
    );
  }

  Stream<QuerySnapshot> _getProfile(String uid) {
    return store.collection('member').where('uid', isEqualTo: uid).snapshots();
  }

  Stream<QuerySnapshot> _getReviewAll() {
    return store.collection('review').snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _getImage(String id) {
    return store.collection('member').doc(id).snapshots();
  }

  Expanded buildListReview(QuerySnapshot data) {
    var dataReview = data.docs;
    var nuser = Provider.of<UserProvider>(context, listen: false);
    var userM = nuser.users.last;
    return Expanded(
        child: ListView.builder(
      primary: true,
      shrinkWrap: true,
      itemCount: dataReview.length,
      itemBuilder: ((context, index) {
        if (dataReview[index]['idMember'].toString().isNotEmpty) {
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
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                          dataReview[index]['idMember'] != userM.id.toString()
                              ? Positioned(
                                  left: 0.0,
                                  child: LikeButton(
                                    isLiked: listMember
                                                .indexOf(userM.id.toString()) >=
                                            0
                                        ? true
                                        : false,
                                    onTap: (isLiked) async {
                                      bool stateLike = !isLiked;
                                      Map<String, dynamic> data;
                                      int like;
                                      if (stateLike) {
                                        like = dataReview[index]['like'] + 1;
                                        Map<String, dynamic> dataNotify = {
                                          dataReview[index].id.toString(): {
                                            'idNotify':
                                                dataReview[index].id.toString(),
                                            'title': userM.fullname.toString(),
                                            'body': like > 1
                                                ? "และอีก ${like - 1} คนถูกใจรีวิวของคุณ"
                                                : "ถูกใจรีวิวของคุณ",
                                            'image': userM.image.toString(),
                                            'dateNotify': DateTime.now()
                                          }
                                        };
                                        await store
                                            .collection('notifyMessage')
                                            .doc(dataReview[index]['idMember'])
                                            .update(dataNotify)
                                            .then((value) async {
                                          print("send Topic");
                                          sendMessageTopic(
                                              dataReview[index]['idMember']
                                                  .toString(),
                                              like > 1
                                                  ? "และอีก ${like - 1} คนถูกใจรีวิวของคุณ"
                                                  : "ถูกใจรีวิวของคุณ",
                                              "รีวิว");
                                        });

                                        listMember.add(userM.id.toString());
                                        data = {
                                          'like': like,
                                          'list_memberLike': listMember
                                        };
                                      } else {
                                        store
                                            .collection('notifyMessage')
                                            .doc(dataReview[index]['idMember'])
                                            .update({
                                          dataReview[index].id.toString():
                                              FieldValue.delete()
                                        });

                                        like = dataReview[index]['like'] - 1;
                                        listMember.remove(userM.id.toString());
                                        data = {
                                          'like': like,
                                          'list_memberLike': listMember
                                        };
                                      }

                                      updateDatabase(
                                          "review",
                                          dataReview[index].id.toString(),
                                          data);
                                      return stateLike;
                                    },
                                    size: 20,
                                    circleColor: CircleColor(
                                        start: Color.fromARGB(255, 255, 0, 85),
                                        end: Color.fromARGB(255, 255, 17, 0)),
                                    bubblesColor: BubblesColor(
                                        dotPrimaryColor:
                                            Color.fromARGB(255, 255, 0, 85),
                                        dotSecondaryColor:
                                            Color.fromARGB(255, 255, 17, 0)),
                                    likeCount: dataReview[index]['like'],
                                  ))
                              : Container(),
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
                          Positioned(
                              top: 0,
                              bottom: 0,
                              right: 5,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: StreamBuilder(
                                  stream:
                                      _getImage(dataReview[index]['idMember']),
                                  builder: (context, AsyncSnapshot snapshot) {
                                    if (snapshot.connectionState.name ==
                                        "active") {
                                      if (snapshot.hasData) {
                                        var data = snapshot.data['image'];
                                        return data.toString().isEmpty
                                            ? Container()
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    radius: 11,
                                                    child: Image.network(
                                                        data.toString())),
                                              );
                                      } else {
                                        return Container(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Color.fromARGB(
                                                255, 175, 90, 127),
                                          ),
                                        );
                                      }
                                    } else {
                                      return Container(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color:
                                              Color.fromARGB(255, 175, 90, 127),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ))
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
                                    fontFamily: 'NatoSansThai', fontSize: 12)),
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
                        padding: EdgeInsets.all(2.5),
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
                                  ),
                              ],
                            ),
                          ],
                        ))
                  ],
                ),
              ),
            ]),
          ));
        } else {
          return Card();
        }
      }),
    ));
  }

  Center header() {
    return const Center(
      child: Text(
        "รีวิว",
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: 'NatoSansThai',
            fontSize: 20,
            fontWeight: FontWeight.w900),
      ),
    );
  }

  Container imgProfile() {
    return Container(
        margin: EdgeInsets.zero,
        alignment: Alignment.center,
        height: 75,
        width: 75,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
        ),
        child: Consumer<UserProvider>(builder:
            ((BuildContext context, UserProvider provider, Widget? child) {
          var user = provider.users.last;
          var image = user.image.toString();
          return image != "" && !image.isNotEmpty && image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CircleAvatar(
                      radius: 38,
                      child: Image(
                        image: FirebaseImage(image),
                      )),
                )
              : Image.asset("assets/img/LogoApp.png");
        })));
  }

  // StreamBuilder(
  //         stream: _getProfile(auth.currentUser!.uid),
  //         builder: (context, snapshot) {
  //           if (snapshot.hasData) {
  //             var data = snapshot.data!.docs.toList(growable: true);
  //             return data[0]['image'] != ""
  //                 ? Image(
  //                     image: FirebaseImage(data[0]['image']),
  //                   )
  //                 : Image.asset(
  //                     "assets/img/LogoApp.png",
  //                   );
  //           } else {
  //             return CircularProgressIndicator();
  //           }
  //         },
  //       )

  Container buttomAdd() {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.zero,
      height: 65,
      width: 65,
      child: GestureDetector(
          onTap: () {
            Navigator.push(context, _createPageAddPost());
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                        color: const Color.fromARGB(255, 26, 0, 143),
                        width: 3)),
                child: const Text(
                  "+",
                  style: TextStyle(
                      fontSize: 25, color: Color.fromARGB(255, 52, 19, 201)),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "เพิ่มโพสต์",
                style: TextStyle(fontSize: 12, fontFamily: 'NatoSansThai'),
              )
            ],
          )),
    );
  }

  Route _createPageAddPost() {
    return PageRouteBuilder(
      pageBuilder: ((context, animation, secondaryAnimation) =>
          const pageAddPost()),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeIn;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Container reviewUser() {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.zero,
      height: 65,
      width: 65,
      child: GestureDetector(
          onTap: () {
            Navigator.push(context, _createPageReviewUser());
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                        color: const Color.fromARGB(255, 26, 0, 143),
                        width: 3)),
                child: Icon(Icons.podcasts,
                    color: Color.fromARGB(255, 52, 19, 201)),
              ),
              const SizedBox(height: 5),
              const Text(
                "รีวิวของฉัน",
                style: TextStyle(fontSize: 12, fontFamily: 'NatoSansThai'),
              )
            ],
          )),
    );
  }
}

Route _createPageReviewUser() {
  return PageRouteBuilder(
    pageBuilder: ((context, animation, secondaryAnimation) =>
        const reviewUser()),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeIn;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

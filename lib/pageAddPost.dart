import 'dart:io';

import 'package:marian/functions.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marian/UserData.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';

class pageAddPost extends StatefulWidget {
  const pageAddPost({key});

  @override
  State<pageAddPost> createState() => _pageAddPostState();
}

class _pageAddPostState extends State<pageAddPost> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  TextEditingController title = TextEditingController();
  TextEditingController comment = TextEditingController();
  FocusNode commentText = FocusNode();
  File? _imageReview;

  final _formPoat = GlobalKey<FormState>();
  double heightComment = 150;
  int score = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBar(
            actions: [_pushPostData(context)],
            backgroundColor: const Color.fromARGB(255, 175, 90, 127),
            title: Stack(
              clipBehavior: Clip.none,
              children: [
                Text(
                  "สร้างโพสต์",
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
      body: ListView(
        padding: EdgeInsets.only(left: 20, right: 20),
        children: [
          _addImage(),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: const Color.fromARGB(255, 26, 0, 143))),
            child: Form(
                key: _formPoat,
                child: Column(
                  children: [
                    Container(
                      height: 45,
                      child: Stack(children: [
                        Align(
                          alignment: Alignment.center,
                          child: textFormTitle(),
                        ),
                        Positioned(
                          top: 0,
                          bottom: 0,
                          right: 2,
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: Consumer(
                                builder:
                                    (context, UserProvider provider, child) {
                                  final user = provider.users.last;
                                  if (user.image.toString() != "") {
                                    return ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: CircleAvatar(
                                            backgroundColor: Colors.transparent,
                                            radius: 20,
                                            child: Image.network(
                                              (user.image.toString()),
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress != null) {
                                                  return Container(
                                                    padding: EdgeInsets.all(20),
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: ColorThemeSoft,
                                                    ),
                                                  );
                                                } else {
                                                  return Image.network(
                                                      user.image.toString());
                                                }
                                              },
                                            )));
                                  } else {
                                    return Container(
                                      child: Icon(
                                        Icons.account_circle_rounded,
                                        color:
                                            Color.fromARGB(162, 238, 129, 176),
                                        size: 40,
                                      ),
                                    );
                                  }
                                },
                              )),
                        )
                      ]),
                    ),
                    textFormBody(context),
                    fieldScore(),
                  ],
                )),
          )
        ],
      ),
    );
  }

  GestureDetector _pushPostData(dynamic context) {
    return GestureDetector(
      onTap: () async {
        try {
          print(
              "Path ${await storage.ref().child('reviewImg/').listAll().then((value) => value.items)}");
        } catch (e) {
          print(e.hashCode);
        }
        if (_formPoat.currentState!.validate() && score != 0) {
          showDialog(
              context: context,
              builder: ((context) {
                return Scaffold(
                  backgroundColor: Color.fromARGB(65, 175, 90, 127),
                  body: Center(
                    child: SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          color: ColorThemeSoft,
                        )),
                  ),
                );
              }));
          String imageName = '';
          if (_imageReview != null) {
            imageName = basename(_imageReview!.path);
          }
          UserProvider userDBall =
              Provider.of<UserProvider>(context, listen: false);
          Map<String, dynamic> data = {
            'idMember': userDBall.users.last.id.toString(),
            'review_comment': comment.text,
            'review_date': DateTime.now(),
            "review_img": imageName,
            "review_name": title.text,
            "review_score": score,
            "like": 0,
            "list_memberLike": []
          };
          if (data['idMember'].toString().isNotEmpty &&
              data['review_comment'].toString().isNotEmpty &&
              data['review_name'].toString().isNotEmpty &&
              data['review_score'].toString().isNotEmpty) {
            try {
              if (imageName != "" && _imageReview != null) {
                try {
                  print(_imageReview);
                  final destination = 'reviewImg/$imageName';
                  try {
                    // ignore: await_only_futures
                    final ref = await storage.ref().child(destination);
                    await ref.putFile(_imageReview!);
                  } catch (e) {
                    print('Error Upload : $e');
                  }
                } catch (e) {
                  print("Upload $e");
                }
              }
              DocumentReference userRef = await store
                  .collection('review')
                  .add(data)
                  .then((value) async {
                Navigator.pop(context);
                Navigator.pop(context);
                return value;
              });
            } catch (e) {
              print(e);
            }
          }
        }
      },
      child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(right: 25),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.public_rounded,
                    size: 30,
                  )),
              Align(
                  alignment: Alignment.topRight,
                  child: Stack(
                    children: [
                      Text(
                        "+",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 3.5
                            ..color = Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 35,
                        ),
                      ),
                      Text(
                        "+",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 175, 90, 127),
                          fontWeight: FontWeight.w500,
                          fontSize: 35,
                        ),
                      )
                    ],
                  )),
            ],
          )),
    );
  }

  GestureDetector _addImage() {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final pickedFile =
            await picker.pickImage(source: ImageSource.camera).then((value) {
          setState(() {
            if (value != null) {
              _imageReview = File(value.path);
            } else {
              print('No image selected.');
            }
          });
        });
      },
      child: _imageReview == null
          ? Icon(
              Icons.image_rounded,
              size: 300,
              color: Color.fromARGB(162, 238, 129, 176),
            )
          : Container(
              padding: EdgeInsets.all(50),
              child: Image.file(
                _imageReview!,
                height: 200,
              ),
            ),
    );
  }

  TextFormField textFormTitle() {
    return TextFormField(
      validator: (value) {
        if (value!.trim().length < 3) {
          return 'Please enter then 3 charecter';
        } else {
          return null;
        }
      },
      style: TextStyle(fontFamily: fontFamilyForm, fontSize: 20),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          hintText: 'รีวิวเรื่อง',
          border: InputBorder.none),
      controller: title,
      textInputAction: TextInputAction.next,
    );
  }

  GestureDetector textFormBody(dynamic context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(commentText);
        },
        child: Container(
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: const Color.fromARGB(255, 26, 0, 143)),
                  bottom: BorderSide(
                      color: const Color.fromARGB(255, 26, 0, 143)))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '  ความคิดเห็น :',
              style: TextStyle(fontFamily: fontFamilyForm, fontSize: 18),
            ),
            Container(
              constraints: BoxConstraints(minHeight: heightComment),
              padding: EdgeInsets.only(left: 20, right: 20),
              child: TextFormField(
                validator: (value) {
                  if (value!.trim().length < 8) {
                    return 'Please enter then 8 charecter';
                  } else {
                    return null;
                  }
                },
                maxLines: null,
                focusNode: commentText,
                controller: comment,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(border: InputBorder.none),
              ),
            )
          ]),
        ));
  }

  SizedBox fieldScore() {
    return SizedBox(
      height: 35,
      child: Row(
        children: [
          Text(
            '  ความพึงพอใจ : ',
            style: TextStyle(fontFamily: fontFamilyForm, fontSize: 18),
          ),
          for (int x = 1; x <= 5; x++)
            GestureDetector(
              child: Icon(
                x <= score ? Icons.star_rounded : Icons.star_border_rounded,
                size: 32,
                color: Colors.amber,
              ),
              onTap: () {
                setState(() {
                  score = x;
                });
              },
            )
        ],
      ),
    );
  }
}

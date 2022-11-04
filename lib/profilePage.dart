import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marian/UserData.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'dart:io';
import 'package:marian/functions.dart';

class profile extends StatefulWidget {
  const profile({key});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> with TickerProviderStateMixin {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final msg = FirebaseMessaging.instance;

  final _formProfileSave = GlobalKey<FormState>();
  String TextError = "";
  File? _imageReview;

  TextEditingController fullname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();

  FocusNode fullnamef = FocusNode();
  FocusNode emailf = FocusNode();
  FocusNode phonef = FocusNode();
  FocusNode passwordf = FocusNode();

  AnimationController? moveEditBt;
  AnimationController? moveSaveBt;

  Animation<Offset>? valueMoveEdit;
  Animation<Offset>? valueMoveSave;

  bool showEdit = false;
  double scalePasswordBox = 0;
  int checkChangeData = 0;

  void initState() {
    super.initState();
    moveEditBt =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    moveSaveBt =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    valueMoveEdit = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1))
        .animate(moveEditBt!)
      ..addListener(() {});
    valueMoveSave = Tween<Offset>(begin: Offset(0.0, -1.0), end: Offset.zero)
        .animate(moveSaveBt!)
      ..addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    return profilePage();
  }

  OverflowBox profilePage() {
    return OverflowBox(
      alignment: Alignment.topCenter,
      minHeight: 0.0,
      minWidth: 0.0,
      maxHeight: double.infinity,
      maxWidth: double.infinity,
      child: Consumer(
        builder: (context, UserProvider provider, child) {
          final user = provider.users.last;
          return Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 45, left: 15, right: 15),
            child: Column(children: [
              user.id != null || user.id != ""
                  ? buildProfile(user, this.context)
                  : CircularProgressIndicator(
                      color: Color.fromARGB(255, 175, 90, 127),
                    ),
            ]),
          );
        },
      ),
    );
  }

  Form buildProfile(UserDB data, dynamic context) {
    return Form(
        key: _formProfileSave,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            exitEditButton(this.context),
            Container(
              child: Column(
                children: [
                  NameAndImg(data, this.context),
                  SizedBox(height: 25),
                  Row(
                    children: [
                      EmailBox(data, this.context),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [PhoneBox(data, this.context)],
                  ),
                  AnimatedSize(
                    duration: Duration(milliseconds: 300),
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        padding:
                            EdgeInsets.only(top: 22.5, bottom: 22.5, left: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextError != ""
                                ? Text(
                                    TextError,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: fontFamilyForm,
                                        color: ColorError),
                                  )
                                : Container()
                          ],
                        )),
                  ),
                  menuProfile(data)
                ],
              ),
            )
          ],
        ));
  }

  Container lineIcon() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25), color: ColorThemeSoft),
      width: 2,
      height: 45,
    );
  }

  Positioned exitEditButton(dynamic context) {
    return Positioned(
      top: -15.0,
      right: -5.0,
      child: AnimatedOpacity(
          opacity: showEdit ? 1.0 : 0.0,
          duration: Duration(milliseconds: 500),
          child: Visibility(
            visible: showEdit ? true : false,
            child: CircleAvatar(
              backgroundColor: Color.fromARGB(96, 255, 193, 214),
              radius: 15,
              child: IconButton(
                padding: EdgeInsets.all(0),
                color: ColorThemeSoft,
                iconSize: 25,
                splashRadius: 20,
                icon: Icon(Icons.close_rounded),
                onPressed: (() {
                  FocusScope.of(context).unfocus();
                  _formProfileSave.currentState!.reset();
                  fullname.text = "";
                  email.text = "";
                  phone.text = "";
                  setState(() {
                    _imageReview = null;
                    moveEditBt!.reverse();
                    moveSaveBt!.reverse();
                    scalePasswordBox = 0;
                    checkChangeData = 0;
                    showEdit = false;
                    TextError = "";
                  });
                }),
              ),
            ),
          )),
    );
  }

  Container menuProfile(UserDB data) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
          color: Color.fromARGB(96, 255, 193, 214),
          borderRadius: BorderRadius.circular(25)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          //settingBt(this.context),
          //lineIcon(),
          Stack(
            alignment: Alignment.center,
            children: [
              SlideTransition(
                position: valueMoveEdit!,
                child: editProfileBt(this.context, data),
              ),
              SlideTransition(
                position: valueMoveSave!,
                child: saveProfileBt(this.context),
              )
            ],
          ),
          lineIcon(),
          logoutBt(this.context)
        ],
      ),
    );
  }

  Row NameAndImg(UserDB data, dynamic context) {
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            _imageReview != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 52.2,
                        child: Image.file(_imageReview!)),
                  )
                : data.image.toString() == ""
                    ? Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(52, 233, 134, 167),
                            borderRadius: BorderRadius.circular(360)),
                        child: Icon(
                          Icons.person_rounded,
                          color: ColorThemeSoft,
                          size: 95,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 52.2,
                          child: Image.network(
                            data.image.toString(),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress != null) {
                                return Container(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(
                                    color: ColorThemeSoft,
                                  ),
                                );
                              } else {
                                return Image.network(data.image.toString());
                              }
                            },
                          ),
                        ),
                      ),
            AnimatedOpacity(
                opacity: showEdit ? 1.0 : 0.0,
                duration: Duration(milliseconds: 300),
                child: Visibility(
                  visible: showEdit ? true : false,
                  child: Stack(alignment: Alignment.center, children: [
                    CircleAvatar(
                      radius: 52.2,
                      backgroundColor: Color.fromARGB(68, 0, 0, 0),
                    ),
                    IconButton(
                        splashRadius: 52.2,
                        color: Colors.white,
                        iconSize: 40,
                        onPressed: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker
                              .pickImage(source: ImageSource.gallery)
                              .then((value) {
                            setState(() {
                              if (value != null) {
                                _imageReview = File(value.path);
                                checkChangeData++;
                              } else {
                                print('No image selected.');
                              }
                            });
                          });
                        },
                        icon: Icon(Icons.camera_alt_outlined)),
                  ]),
                ))
          ],
        ),
        SizedBox(
          width: 22,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ชื่อ-นามสกุล",
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: fontFamilyForm,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 2,
            ),
            Stack(
              children: [
                GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    print(details.localPosition);
                  },
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: AnimatedOpacity(
                        opacity: showEdit ? 0.0 : 1.0,
                        duration: Duration(milliseconds: 300),
                        child: Container(
                            width: MediaQuery.of(context).size.width - 157,
                            child: Text(
                              data.fullname.toString(),
                              style: TextStyle(
                                  fontSize: 18, fontFamily: fontFamilyForm),
                            )),
                      )),
                ),
                AnimatedOpacity(
                  opacity: showEdit ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 200),
                  child: Visibility(
                      visible: showEdit ? true : false,
                      child: Container(
                        alignment: Alignment.center,
                        width: (MediaQuery.of(context).size.width * 0.8) - 127,
                        height: 28,
                        child: TextFormField(
                            focusNode: fullnamef,
                            controller: fullname,
                            validator: (value) {
                              var nuser = Provider.of<UserProvider>(context,
                                  listen: false);
                              var userM = nuser.users.last;
                              if (userM.fullname.toString() != value) {
                                checkChangeData++;
                              }
                              if (value!.isEmpty) {
                                return '';
                              } else if (!validateName(value)) {
                                setState(() {
                                  if (!TextError.contains(
                                      "- invalid Fullname")) {
                                    if (TextError.isEmpty) {
                                      TextError += "- invalid Fullname";
                                    } else {
                                      TextError += "\n- invalid Fullname";
                                    }
                                  }
                                });
                                return '';
                              } else {
                                return null;
                              }
                            },
                            cursorColor: ColorThemeSoft,
                            cursorHeight: 25,
                            textAlignVertical: TextAlignVertical.center,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    top: 5, bottom: 0, left: 10, right: 10),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        width: 1.5, color: ColorThemeSoft)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        width: 1.5, color: ColorThemeSoft)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        width: 1.5, color: ColorThemeSoft)),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        width: 2, color: ColorError)),
                                errorStyle: TextStyle(height: 0)),
                            style: TextStyle(
                                fontSize: 18, fontFamily: fontFamilyForm)),
                      )),
                )
              ],
            )
          ],
        )
      ],
    );
  }

  Column EmailBox(UserDB data, dynamic context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("อีเมล:",
            style: TextStyle(
                fontSize: 18,
                fontFamily: fontFamilyForm,
                fontWeight: FontWeight.w600)),
        Stack(
          children: [
            AnimatedOpacity(
              opacity: showEdit ? 0.0 : 1.0,
              duration: Duration(milliseconds: 300),
              child: Text("   ${data.email.toString()}",
                  style: TextStyle(fontSize: 18, fontFamily: fontFamilyForm)),
            ),
            AnimatedOpacity(
              opacity: showEdit ? 1.0 : 0.0,
              duration: Duration(milliseconds: 200),
              child: Visibility(
                  visible: showEdit ? true : false,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(left: 9),
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 28,
                    child: TextFormField(
                        focusNode: emailf,
                        controller: email,
                        onChanged: (value) {
                          var nuser =
                              Provider.of<UserProvider>(context, listen: false);
                          var userM = nuser.users.last;
                          if (value != userM.email) {
                            setState(() {
                              scalePasswordBox = double.infinity;
                            });
                          } else {
                            setState(() {
                              scalePasswordBox = 0;
                            });
                          }
                        },
                        validator: (value) {
                          var nuser =
                              Provider.of<UserProvider>(context, listen: false);
                          var userM = nuser.users.last;
                          if (userM.email.toString() != value) {
                            checkChangeData++;
                          }
                          if (value!.isEmpty) {
                            return '';
                          } else if (!validateEmail(value)) {
                            setState(() {
                              if (!TextError.contains(
                                  "- invalid Email Address")) {
                                if (TextError.isEmpty) {
                                  TextError += "- invalid Email Address";
                                } else {
                                  TextError += "\n- invalid Email Address";
                                }
                              }
                            });
                            return '';
                          } else {
                            return null;
                          }
                        },
                        cursorColor: ColorThemeSoft,
                        cursorHeight: 25,
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(
                                top: 5, bottom: 0, left: 10, right: 10),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    width: 1.5, color: ColorThemeSoft)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    width: 1.5, color: ColorThemeSoft)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    width: 1.5, color: ColorThemeSoft)),
                            errorText: TextError.contains("Email") ? "" : null,
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(width: 2, color: ColorError)),
                            errorStyle: TextStyle(height: 0)),
                        style: TextStyle(
                            fontSize: 18, fontFamily: fontFamilyForm)),
                  )),
            )
          ],
        ),
        boxPassword(this.context)
      ],
    );
  }

  AnimatedSize boxPassword(dynamic context) {
    return AnimatedSize(
      duration: Duration(milliseconds: 300),
      child: Container(
        constraints: BoxConstraints(maxHeight: scalePasswordBox),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 10),
          Text("รหัสผ่าน:",
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: fontFamilyForm,
                  fontWeight: FontWeight.w600)),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 9),
            width: MediaQuery.of(context).size.width * 0.8,
            height: 28,
            child: TextFormField(
                focusNode: passwordf,
                controller: password,
                validator: (value) {
                  var nuser = Provider.of<UserProvider>(context, listen: false);
                  var userM = nuser.users.last;
                  if (value!.isEmpty && email.text != userM.email.toString()) {
                    setState(() {
                      if (!TextError.contains("- Please enter password")) {
                        if (TextError.isEmpty) {
                          TextError += "- Please enter password";
                        } else {
                          TextError += "\n- Please enter password";
                        }
                      }
                    });
                    return '';
                  } else {
                    return null;
                  }
                },
                cursorColor: ColorThemeSoft,
                cursorHeight: 25,
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    hintText: 'รหัสผ่านเพื่อยืนยันตัวตน',
                    hintStyle: TextStyle(fontSize: 16),
                    contentPadding: const EdgeInsets.only(
                        top: 5, bottom: 0, left: 10, right: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(width: 1.5, color: ColorThemeSoft)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(width: 1.5, color: ColorThemeSoft)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(width: 1.5, color: ColorThemeSoft)),
                    errorText: TextError.contains("Password") ? "" : null,
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(width: 2, color: ColorError)),
                    errorStyle: TextStyle(height: 0)),
                style: TextStyle(fontSize: 18, fontFamily: fontFamilyForm)),
          ),
        ]),
      ),
    );
  }

  Column PhoneBox(UserDB data, dynamic context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("เบอร์โทรศัพท์:",
            style: TextStyle(
                fontSize: 18,
                fontFamily: fontFamilyForm,
                fontWeight: FontWeight.w600)),
        Stack(
          children: [
            AnimatedOpacity(
              opacity: showEdit ? 0.0 : 1.0,
              duration: Duration(milliseconds: 200),
              child: Text(
                  "   ${data.phone.toString() != "" ? data.phone.toString() : "ยังไม่มีเบอร์โทร"}",
                  style: TextStyle(fontSize: 18, fontFamily: fontFamilyForm)),
            ),
            AnimatedOpacity(
              opacity: showEdit ? 1.0 : 0.0,
              duration: Duration(milliseconds: 200),
              child: Visibility(
                  visible: showEdit ? true : false,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(left: 9),
                    width: 150,
                    height: 28,
                    child: TextFormField(
                        focusNode: phonef,
                        controller: phone,
                        validator: (value) {
                          var nuser =
                              Provider.of<UserProvider>(context, listen: false);
                          var userM = nuser.users.last;
                          if (userM.phone.toString() != value) {
                            checkChangeData++;
                          }
                          if (value!.isEmpty || phone.text == "") {
                            return null;
                          } else if (value.length != 10) {
                            setState(() {
                              if (!TextError.contains("Phone")) {
                                if (TextError.isEmpty) {
                                  TextError += "- invalid Phone number";
                                } else {
                                  TextError += "\n- invalid Phone number";
                                }
                              }
                            });
                            return '';
                          } else {
                            return null;
                          }
                        },
                        cursorColor: ColorThemeSoft,
                        cursorHeight: 25,
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(
                                top: 5, bottom: 0, left: 10, right: 10),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    width: 1.5, color: ColorThemeSoft)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    width: 1.5, color: ColorThemeSoft)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    width: 1.5, color: ColorThemeSoft)),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(width: 2, color: ColorError)),
                            errorStyle: TextStyle(height: 0)),
                        style: TextStyle(
                            fontSize: 18, fontFamily: fontFamilyForm)),
                  )),
            )
          ],
        ),
      ],
    );
  }

  IconButton settingBt(dynamic context) {
    return IconButton(
      iconSize: 40,
      color: ColorThemeSoft,
      icon: Icon(Icons.settings),
      onPressed: (() {}),
    );
  }

  IconButton editProfileBt(dynamic context, UserDB data) {
    return IconButton(
      iconSize: 40,
      color: ColorThemeSoft,
      icon: Icon(Icons.edit_sharp),
      onPressed: (() {
        phone.text = data.phone.toString();
        fullname.text = data.fullname.toString();
        email.text = data.email.toString();
        password.text = "";
        moveEditBt!.forward();
        moveSaveBt!.forward();
        setState(() {
          stateWait = false;
          showEdit = true;
        });
      }),
    );
  }

  bool stateWait = false;

  void changePage(int checkPut) {
    if (checkPut == checkChangeData) {
      setState(() {
        stateWait = false;
        showEdit = false;
        moveEditBt!.reverse();
        moveSaveBt!.reverse();
        scalePasswordBox = 0;
        TextError = "";
      });
    }
  }

  IconButton saveProfileBt(dynamic context) {
    return IconButton(
      iconSize: 40,
      color: ColorThemeSoft,
      icon: stateWait
          ? CircleAvatar(
              child: CircularProgressIndicator(color: ColorThemeSoft),
              radius: 16,
              backgroundColor: Colors.transparent,
            )
          : Icon(Icons.save_alt_rounded),
      onPressed: (() async {
        var nuser = Provider.of<UserProvider>(context, listen: false);
        var userM = nuser.users.last;
        TextError = "";
        Map<String, dynamic> dataUpdate = {};
        FocusScope.of(context).unfocus();
        checkChangeData = 0;

        if (_formProfileSave.currentState!.validate()) {
          print("pass Validation $checkChangeData");
          int checkPut = 0;
          setState(() {
            stateWait = true;
          });
          //เช็ครูปแบบ
          if (userM.fullname.toString() != fullname.text) {
            dataUpdate.addAll({'fullname': fullname.text});
            updateDatabase("member", userM.id.toString(), dataUpdate)
                .then((value) {
              checkPut++;
              changePage(checkPut);
            });
          }
          if (userM.email.toString() != email.text) {
            await auth
                .fetchSignInMethodsForEmail(email.text)
                .then((value) async {
              if (value.isEmpty) {
                try {
                  await auth
                      .signInWithEmailAndPassword(
                          email: userM.email.toString(),
                          password: password.text.toString())
                      .then((value) {
                    //พร้อมเปลี่ยน Email
                    value.user!.updateEmail(email.text);
                    dataUpdate.addAll({'email': email.text});
                    updateDatabase("member", userM.id.toString(), dataUpdate)
                        .then((value) {
                      checkPut++;
                      changePage(checkPut);
                    });
                  });
                } on FirebaseAuthException catch (e) {
                  if (e.hashCode == 119918416) {
                    password.text = "";
                    setState(() {
                      stateWait = false;
                      if (!TextError.contains("- Password incorrect")) {
                        if (TextError.isEmpty) {
                          TextError += "- Password incorrect";
                        } else {
                          TextError += "\n- Password incorrect";
                        }
                      }
                    });
                  } else if (e.hashCode == 488397155) {
                    password.text = "";
                    setState(() {
                      stateWait = false;
                      if (!TextError.contains(
                          "- Block request change Email. Try again later")) {
                        if (TextError.isEmpty) {
                          TextError +=
                              "- Block request change Email. Try again later";
                        } else {
                          TextError +=
                              "\n- Block request change Email. Try again later";
                        }
                      }
                    });
                  }
                }
              } else {
                setState(() {
                  stateWait = false;
                  if (!TextError.contains("- Email is already in use")) {
                    if (TextError.isEmpty) {
                      TextError += "- Email is already in use";
                    } else {
                      TextError += "\n- Email is already in use";
                    }
                  }
                });
              }
            });
          }

          if (_imageReview != null) {
            String imageName = '';
            imageName = basename(_imageReview!.path);

            try {
              if (imageName != "" && _imageReview != null) {
                try {
                  final destination = 'profileMember/$imageName';
                  try {
                    // ignore: await_only_futures
                    Reference ref = await storage.ref().child(destination);
                    await ref.putFile(_imageReview!).then((p0) {
                      p0.ref.getDownloadURL().then((value) {
                        dataUpdate.addAll({'image': value.toString()});
                        updateDatabase(
                                "member", userM.id.toString(), dataUpdate)
                            .then((value) {
                          checkPut++;
                          changePage(checkPut);
                          _imageReview = null;
                        }).then((value) {
                          setState(() {
                            stateWait = false;
                          });
                        });
                      });
                    });
                  } catch (e) {
                    print('Error Upload : $e');
                  }
                } catch (e) {
                  print("Upload $e");
                }
              }
            } catch (e) {
              print(e);
            }
          }
          if (userM.phone.toString() != phone.text) {
            dataUpdate.addAll({'phone': phone.text});
            updateDatabase("member", userM.id.toString(), dataUpdate)
                .then((value) {
              checkPut++;
              if (checkPut == checkChangeData) {
                changePage(checkPut);
              }
            });
          }

          if (checkChangeData == 0) {
            setState(() {
              stateWait = false;
              showEdit = false;
              moveEditBt!.reverse();
              moveSaveBt!.reverse();
              scalePasswordBox = 0;
              TextError = "";
            });
          }
        }
        // List check = [];
        // UserCredential userLogin;
        // if (validateEmail(email.text) &&
        //     email.text.isNotEmpty &&
        //     email.text != auth.currentUser!.email) {
        //   check = await auth.fetchSignInMethodsForEmail(email.text);
        //   if (check.isNotEmpty) {
        //     setState(() {
        //       if (!TextError.contains("- Email is already in use")) {
        //         if (TextError.isEmpty) {
        //           TextError += "- Email is already in use";
        //         } else {
        //           TextError += "\n- Email is already in use";
        //         }
        //       }
        //     });
        //     email.text = "";
        //   } else if (password.text.toString().isNotEmpty) {
        //     userLogin = await auth.signInWithEmailAndPassword(
        //         email: userM.email.toString(), password: password.text);
        //   }
        // } else {
        //   if (_formProfileSave.currentState!.validate() && check.isEmpty) {
        //     Map<String, dynamic> dataIn = {};
        //     setState(() {
        //       showEdit = false;
        //       moveEditBt!.reverse();
        //       moveSaveBt!.reverse();
        //       scalePasswordBox = 0;
        //       TextError = "";
        //     });
        //     if (auth.currentUser!.email != email.text) {
        //       dataIn.addAll({'email': email.text});
        //       // await auth.signInWithEmailAndPassword(email: email.text, password: )
        //     }
        //     if (fullname.text != userM.fullname.toString()) {
        //       dataIn.addAll({'fullname': fullname.text});
        //     }
        //     if (phone.text != userM.phone.toString()) {
        //       dataIn.addAll({'phone': phone.text});
        //     }

        //     // if (dataIn.isNotEmpty) {
        //     //   await store
        //     //       .collection("member")
        //     //       .doc(userM.id.toString())
        //     //       .update(dataIn);
        //     // }
        //   } else if (fullname.text.isEmpty || !validateName(fullname.text)) {
        //     FocusScope.of(context).requestFocus(fullnamef);
        //   } else if (email.text.isEmpty ||
        //       !validateEmail(email.text) ||
        //       check.isEmpty && email.text != auth.currentUser!.email) {
        //     FocusScope.of(context).requestFocus(emailf);
        //   } else {
        //     FocusScope.of(context).requestFocus(phonef);
        //   }
        // }
      }),
    );
  }

  IconButton logoutBt(dynamic context) {
    return IconButton(
      iconSize: 40,
      color: ColorThemeSoft,
      icon: Icon(Icons.logout_rounded),
      onPressed: () {
        showDialog(
            context: context,
            builder: ((BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                      Colors.purple,
                      Color.fromARGB(255, 222, 61, 115)
                    ])),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 5,
                      ),
                      SizedBox(height: 25),
                      Text(
                        "Sing out",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      )
                    ],
                  )),
                ),
              );
            }));
        auth.signOut().then((value) {
          var nuser = Provider.of<UserProvider>(context, listen: false);
          msg.unsubscribeFromTopic(nuser.users.last.id.toString());
          Future.delayed(Duration(seconds: 2), () {
            nuser.users.clear();

            Navigator.popAndPushNamed(context, '/');
          });
        });
      },
    );
  }
}

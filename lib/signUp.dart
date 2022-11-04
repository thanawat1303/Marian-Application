import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marian/functions.dart';

class signUp extends StatefulWidget {
  const signUp({key});

  @override
  State<signUp> createState() => _signUpState();
}

class _signUpState extends State<signUp> {
  final _formState = GlobalKey<FormState>();
  TextEditingController? nameuser = TextEditingController();
  TextEditingController? password = TextEditingController();
  TextEditingController? passwordCF = TextEditingController();
  TextEditingController? email = TextEditingController();
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;

  int checkFormValidate = 0;

  int stateErrorName = 0;
  double sizeErrorName = 15;

  int stateErrorEmail = 0;
  double sizeErrorEmail = 15;

  int stateErrorPW = 0;
  double sizeErrorPW = 15;

  int stateErrorPWFc = 0;
  double sizeErrorPWcF = 10;

  bool stateFocusPWcF = false;

  String? _typeMember;

  Color ColorFillRadio = Color.fromARGB(248, 255, 255, 255);

  BorderSide BorderEnable =
      const BorderSide(color: Color.fromARGB(250, 247, 210, 255), width: 1.8);

  BorderSide BorderFocus =
      const BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 2.5);

  BorderSide BorderError = const BorderSide(color: Colors.red, width: 3.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple, Color.fromARGB(255, 222, 61, 115)])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Form(
          // ignore: sort_child_properties_last
          child: OverflowBox(
              minWidth: 0.0,
              minHeight: 0.0,
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                      margin: EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.only(
                          top: 0.0, left: 25, right: 25, bottom: 15),
                      decoration: BoxDecoration(
                          color: Color.fromARGB(183, 255, 255, 255),
                          borderRadius: BorderRadius.circular(20)),
                      width: 350,
                      constraints: BoxConstraints(
                        maxHeight: double.infinity,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                            height: 95,
                            child: Text(
                              "Register",
                              style: TextStyle(
                                  fontFamily: 'Prompt-Bold',
                                  fontSize: 60,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.red),
                            ),
                          ),
                          SizedBox(
                            child: nameUser(),
                            height: 45,
                          ),
                          SizedBox(
                              child: Container(
                                  padding: EdgeInsets.only(left: 15, top: 1),
                                  child: Text(
                                    stateErrorName <= 1
                                        ? ""
                                        : "*Invalid fullname",
                                    style: TextStyle(color: Colors.red),
                                  )),
                              width: double.infinity,
                              height: sizeErrorName),
                          SizedBox(child: emailInput(), height: 45),
                          SizedBox(
                              child: Container(
                                  padding: EdgeInsets.only(left: 15, top: 1),
                                  child: Text(
                                    stateErrorEmail <= 1
                                        ? ""
                                        : stateErrorEmail == 2
                                            ? "*Invalid email"
                                            : "*Email is already in use",
                                    style: TextStyle(color: Colors.red),
                                  )),
                              width: double.infinity,
                              height: sizeErrorEmail),
                          SizedBox(child: pwInput(), height: 45),
                          SizedBox(
                              child: Container(
                                  padding: EdgeInsets.only(left: 15, top: 1),
                                  child: Text(
                                    stateErrorPW <= 1
                                        ? ""
                                        : stateErrorPW == 2
                                            ? "*length must be greater than 8 characters"
                                            : stateErrorPW == 3
                                                ? "*a - z or A - Z and numbers."
                                                : "*length must be greater than 8 characters\n*a - z or A - Z and numbers.",
                                    style: TextStyle(color: Colors.red),
                                  )),
                              width: double.infinity,
                              height: sizeErrorPW),
                          SizedBox(child: pwCfInput(), height: 45),
                          SizedBox(
                              child: Container(
                                  padding: EdgeInsets.only(left: 15, top: 1),
                                  child: Text(
                                    stateErrorPWFc <= 1
                                        ? ""
                                        : "*Passwords don't match",
                                    style: TextStyle(color: Colors.red),
                                  )),
                              width: double.infinity,
                              height: sizeErrorPWcF),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "สถานะ",
                                style: TextStyle(fontFamily: 'Prompt-Bold'),
                              ),
                              Text(
                                " *",
                                style: TextStyle(color: Colors.red),
                              )
                            ],
                          ),
                          SizedBox(
                            child: checkTypeMember(),
                            height: 25,
                          ),
                          SizedBox(height: 15),
                          signUpButton()
                        ],
                      )),
                  exitButton(),
                ],
              )),
          key: _formState,
        ),
      ),
    );
  }

  TextFormField nameUser() {
    return TextFormField(
      controller: nameuser,
      onChanged: (value) {
        setState(() {
          if (!validateName(value) && value.isNotEmpty) {
            stateErrorName = 2;
            sizeErrorName = 20;
          } else {
            stateErrorName = 0;
            sizeErrorName = 15;
          }
        });
      },
      onSaved: (newValue) {
        setState(() {
          if (newValue!.isEmpty) {
            stateErrorName = 1;
            sizeErrorName = 15;
          } else if (!validateName(newValue)) {
            stateErrorName = 2;
            sizeErrorName = 20;
          } else {
            checkFormValidate++;
            stateErrorName = 0;
            sizeErrorName = 15;
          }
        });
      },
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 20),
      decoration: InputDecoration(
          fillColor: Color.fromARGB(105, 255, 255, 255),
          filled: true,
          prefixIcon: const Icon(
            Icons.person,
            size: 30,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          hintText: "Fullname",
          hintStyle: TextStyle(fontSize: 18, fontFamily: 'Prompt-Bold'),
          contentPadding: const EdgeInsets.only(
              top: 0.0, bottom: 0.0, left: 15.0, right: 15.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderFocus,
            borderRadius: BorderRadius.circular(15.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderEnable,
            borderRadius: BorderRadius.circular(15.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderError,
            borderRadius: BorderRadius.circular(15.0),
          ),
          errorText: stateErrorName == 0 ? null : "",
          errorStyle: const TextStyle(height: 0)),
    );
  }

  TextFormField emailInput() {
    return TextFormField(
      controller: email,
      onChanged: (value) {
        setState(() {
          if (!validateEmail(value) && value.isNotEmpty) {
            stateErrorEmail = 2;
            sizeErrorEmail = 20;
          } else {
            stateErrorEmail = 0;
            sizeErrorEmail = 15;
          }
        });
      },
      onSaved: (newValue) {
        setState(() {
          //ต้องมีเช็คการซ้ำอีเมล
          if (newValue!.isEmpty) {
            stateErrorEmail = 1;
          } else if (!validateEmail(newValue)) {
            stateErrorEmail = 2;
            sizeErrorEmail = 20;
          } else {
            checkFormValidate++;
            stateErrorEmail = 0;
          }
        });
      },
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 20),
      decoration: InputDecoration(
          fillColor: Color.fromARGB(105, 255, 255, 255),
          filled: true,
          prefixIcon: const Icon(
            Icons.email_outlined,
            size: 30,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          hintText: "Email address",
          hintStyle: TextStyle(fontSize: 18, fontFamily: 'Prompt-Bold'),
          contentPadding: const EdgeInsets.only(
              top: 0.0, bottom: 0.0, left: 15.0, right: 15.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderFocus,
            borderRadius: BorderRadius.circular(15.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderEnable,
            borderRadius: BorderRadius.circular(15.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderError,
            borderRadius: BorderRadius.circular(15.0),
          ),
          errorText: stateErrorEmail == 0 ? null : "",
          errorStyle: const TextStyle(height: 0)),
    );
  }

  bool showPassword = true;

  TextFormField pwInput() {
    return TextFormField(
      controller: password,
      obscureText: showPassword,
      onChanged: (value) {
        setState(() {
          if (value.length <= 8 && !isPWCorrect(value) && value.isNotEmpty) {
            stateErrorPW = 4;
            stateErrorPWFc = 0;
            stateFocusPWcF = false;
            passwordCF!.text = "";
            sizeErrorPW = 35;
            sizeErrorPWcF = 10;
          } else if (!isPWCorrect(value) && value.isNotEmpty) {
            stateErrorPW = 3;
            stateErrorPWFc = 0;
            stateFocusPWcF = false;
            passwordCF!.text = "";
            sizeErrorPW = 20;
            sizeErrorPWcF = 10;
          } else if (value.length <= 8 && value.isNotEmpty) {
            stateErrorPW = 2;
            stateErrorPWFc = 0;
            stateFocusPWcF = false;
            passwordCF!.text = "";
            sizeErrorPW = 20;
            sizeErrorPWcF = 10;
          } else {
            stateFocusPWcF = true;
            stateErrorPW = 0;
            sizeErrorPW = 15;
            stateErrorPWFc = 0;
            sizeErrorPWcF = 10;
          }
        });
      },
      onSaved: (newValue) {
        setState(() {
          if (newValue!.isEmpty) {
            stateErrorPW = 1;
            stateFocusPWcF = false;
            passwordCF!.text = "";
            sizeErrorPW = 15;
          } else if (newValue.length <= 8 && !isPWCorrect(newValue)) {
            stateErrorPW = 4;
            stateFocusPWcF = false;
            passwordCF!.text = "";
            sizeErrorPW = 35;
          } else if (!isPWCorrect(newValue)) {
            stateErrorPW = 3;
            stateFocusPWcF = false;
            passwordCF!.text = "";
            sizeErrorPW = 20;
          } else if (newValue.length <= 8) {
            stateErrorPW = 2;
            stateFocusPWcF = false;
            passwordCF!.text = "";
            sizeErrorPW = 20;
          } else {
            checkFormValidate++;
            stateFocusPWcF = true;
            stateErrorPW = 0;
            sizeErrorPW = 15;
            stateErrorPWFc = 0;
            sizeErrorPWcF = 10;
          }
        });
      },
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 20),
      decoration: InputDecoration(
          fillColor: Color.fromARGB(105, 255, 255, 255),
          filled: true,
          prefixIcon: const Icon(
            Icons.vpn_key_rounded,
            size: 30,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          suffixIcon: GestureDetector(
            child: Icon(showPassword == true
                ? Icons.remove_red_eye_outlined
                : Icons.password),
            onTap: () {
              setState(() {
                showPassword = !showPassword;
              });
            },
          ),
          hintText: "Password",
          hintStyle: TextStyle(fontSize: 18, fontFamily: 'Prompt-Bold'),
          contentPadding: const EdgeInsets.only(
              top: 0.0, bottom: 0.0, left: 15.0, right: 15.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderFocus,
            borderRadius: BorderRadius.circular(15.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderEnable,
            borderRadius: BorderRadius.circular(15.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderError,
            borderRadius: BorderRadius.circular(15.0),
          ),
          errorText: stateErrorPW == 0 ? null : "",
          errorStyle: const TextStyle(height: 0)),
    );
  }

  TextFormField pwCfInput() {
    return TextFormField(
      controller: passwordCF,
      enabled: stateFocusPWcF,
      obscureText: true,
      onChanged: (value) {
        setState(() {
          if (value != password!.text && password!.text.isNotEmpty) {
            stateErrorPWFc = 2;
            sizeErrorPWcF = 20;
          } else {
            stateErrorPWFc = 0;
            sizeErrorPWcF = 15;
          }
        });
      },
      onSaved: (value) {
        setState(() {
          if (value!.isEmpty) {
            stateErrorPWFc = 1;
            sizeErrorPWcF = 10;
          } else if (value != password!.text && password!.text.isNotEmpty) {
            stateErrorPWFc = 2;
            sizeErrorPWcF = 20;
          } else {
            checkFormValidate++;
            stateErrorPWFc = 0;
            sizeErrorPWcF = 10;
          }
        });
      },
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 20),
      decoration: InputDecoration(
          fillColor: Color.fromARGB(105, 255, 255, 255),
          filled: true,
          prefixIcon: const Icon(
            Icons.vpn_key_outlined,
            size: 30,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          hintText: "Password confirm",
          hintStyle: TextStyle(fontSize: 18, fontFamily: 'Prompt-Bold'),
          contentPadding: const EdgeInsets.only(
              top: 0.0, bottom: 0.0, left: 15.0, right: 15.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderFocus,
            borderRadius: BorderRadius.circular(15.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderEnable,
            borderRadius: BorderRadius.circular(15.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderError,
            borderRadius: BorderRadius.circular(15.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Color.fromARGB(146, 103, 83, 92), width: 1.5),
            borderRadius: BorderRadius.circular(15.0),
          ),
          errorText: stateErrorPWFc == 0 ? null : "",
          errorStyle: const TextStyle(height: 0)),
    );
  }

  Row checkTypeMember() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(children: [
          SizedBox(
            // ignore: sort_child_properties_last
            child: Radio(
                fillColor:
                    MaterialStateColor.resolveWith((states) => ColorFillRadio),
                value: 'อาจารย์',
                groupValue: _typeMember,
                onChanged: (value) {
                  setState(() {
                    ColorFillRadio = Color.fromARGB(248, 255, 255, 255);
                    _typeMember = value.toString();
                  });
                }),
            width: 25,
          ),
          Text("อาจารย์"),
        ]),
        Row(
          children: [
            SizedBox(
              child: Radio(
                  fillColor: MaterialStateColor.resolveWith(
                      (states) => ColorFillRadio),
                  value: 'นักศึกษา',
                  groupValue: _typeMember,
                  onChanged: (value) {
                    setState(() {
                      ColorFillRadio = Color.fromARGB(248, 255, 255, 255);
                      _typeMember = value.toString();
                    });
                  }),
              width: 25,
            ),
            Text("นักศึกษา")
          ],
        ),
        Row(
          children: [
            SizedBox(
              child: Radio(
                  fillColor: MaterialStateColor.resolveWith(
                      (states) => ColorFillRadio),
                  value: 'บุคคลทั่วไป',
                  groupValue: _typeMember,
                  onChanged: (value) {
                    setState(() {
                      ColorFillRadio = Color.fromARGB(248, 255, 255, 255);
                      _typeMember = value.toString();
                    });
                  }),
              width: 25,
            ),
            Text("บุคคลทั่วไป")
          ],
        ),
      ],
    );
  }

  SizedBox signUpButton() {
    return SizedBox(
      width: 135,
      height: 37,
      child: ElevatedButton(
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)))),
          onPressed: () async {
            FocusScope.of(context).unfocus();
            _formState.currentState!.save();
            print("Check : $checkFormValidate");

            List? check;
            if (validateEmail(email!.text) && email!.text.isNotEmpty) {
              check = await auth.fetchSignInMethodsForEmail(email!.text);
              if (check.isNotEmpty) {
                setState(() {
                  stateErrorEmail = 3;
                  sizeErrorEmail = 20;
                });
              }
            }
            if (checkFormValidate == 4 &&
                _typeMember != null &&
                check!.isEmpty) {
              print(nameuser!.text);
              print(email!.text);
              print(password!.text);
              print(passwordCF!.text);
              final _user = await auth.createUserWithEmailAndPassword(
                  email: email!.text.trim(), password: password!.text.trim());
              _user.user!.sendEmailVerification();

              Map<String, dynamic> data = {
                'uid': _user.user!.uid.toString(),
                'email': email!.text,
                'password': password!.text,
                'fullname': nameuser!.text,
                'date': DateTime.now(),
                'type': _typeMember,
                'image': "",
                'phone': ""
              };
              try {
                DocumentReference userRef = await store
                    .collection('member')
                    .add(data)
                    .then((userRefIn) {
                  store.collection('notifyMessage').doc(userRefIn.id).set({});
                  return userRefIn;
                });
                print('save id = ${userRef.id}');

                Navigator.pop(context);
              } catch (e) {
                _user.user!.delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error $e'),
                  ),
                );
              }
            } else if (_typeMember == null) {
              setState(() {
                ColorFillRadio = Color.fromRGBO(244, 67, 54, 1);
              });
            }
            setState(() {
              checkFormValidate = 0;
            });
          },
          child: const Text(
            'Sign Up',
            style: TextStyle(
                fontFamily: 'NatoSansThai',
                fontSize: 24,
                fontWeight: FontWeight.w700),
          )),
    );
  }

  Positioned exitButton() {
    return Positioned(
      right: -15.0,
      top: 0.0,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Align(
          alignment: Alignment.topRight,
          child: CircleAvatar(
            radius: 16.0,
            backgroundColor: Colors.red,
            child: Icon(Icons.close, size: 25, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

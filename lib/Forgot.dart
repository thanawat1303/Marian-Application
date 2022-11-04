import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:marian/functions.dart';
import 'package:marian/messageReturn.dart';

class ForgotPassword extends StatefulWidget {
  String emailPass;
  ForgotPassword({Key? key, required this.emailPass}) : super(key: key);

  @override
  State<ForgotPassword> createState() =>
      _ForgotPasswordState(emailPass: this.emailPass);
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String? emailPass;
  _ForgotPasswordState({Key? key, required this.emailPass});
  TextEditingController email = TextEditingController();

  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;

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
                child: Stack(
              children: [
                exitButton(),
                OverflowBox(
                  minHeight: 0.0,
                  minWidth: 0.0,
                  maxHeight: double.infinity,
                  maxWidth: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [logoForgot(), iconPassword(), formForgot()],
                  ),
                ),
              ],
            ))));
  }

  BorderSide BorderEnable =
      const BorderSide(color: Color.fromARGB(250, 247, 210, 255));

  BorderSide BorderFocus =
      const BorderSide(color: Color.fromARGB(255, 45, 251, 255));

  BorderSide BorderError = const BorderSide(color: Colors.red);

  Stack logoForgot() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(180.0),
                border: Border.all(color: Colors.white, width: 8),
                color: Colors.transparent),
            child: Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 73,
                backgroundImage: AssetImage('assets/img/LockIcon.png'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  SizedBox iconPassword() {
    return SizedBox(
      height: 130,
      child: ImageIcon(
        AssetImage('assets/img/passwordForgot.png'),
        size: 220,
        color: Colors.white,
      ),
    );
  }

  Container formForgot() {
    if (emailPass!.isNotEmpty) {
      email.text = emailPass!;
      emailPass = "";
    }
    return Container(
      width: 350,
      constraints: BoxConstraints(
        maxHeight: double.infinity,
      ),
      padding: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 35),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        SizedBox(height: 15),
        Text(
          "Forgot password ?",
          style: TextStyle(
              color: Colors.red, fontSize: 35, fontFamily: 'Prompt-Bold'),
        ),
        SizedBox(height: 25),
        SizedBox(
          child: emailUser(),
          width: 290,
        ),
        SizedBox(height: 35),
        sendEmail(),
      ]),
    );
  }

  TextFormField emailUser() {
    return TextFormField(
      controller: email,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      style: TextStyle(fontSize: 20, fontFamily: 'NatoSansThai'),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 7),
          prefixIcon: const Icon(
            Icons.person,
            size: 40,
            color: Colors.grey,
          ),
          hintText: 'E-mail',
          hintStyle: TextStyle(fontSize: 24, fontFamily: 'Prompt-Bold'),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderFocus,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderEnable,
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderError,
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: const BorderSide(
                color: Color.fromARGB(146, 103, 83, 92), width: 1.5),
          )),
    );
  }

  SizedBox sendEmail() {
    return SizedBox(
      width: 180,
      height: 50,
      child: ElevatedButton(
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)))),
          onPressed: SendPassWord,
          child: Text(
            "Send",
            style: TextStyle(fontSize: 28, fontFamily: 'Prompt-Bold'),
          )),
    );
  }

  Positioned exitButton() {
    return Positioned(
      right: 25.0,
      top: 25.0,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Align(
          alignment: Alignment.topRight,
          child: CircleAvatar(
            radius: 20.0,
            backgroundColor: Colors.red,
            child: Icon(Icons.close, size: 40, color: Colors.white),
          ),
        ),
      ),
    );
  }

  SendPassWord() async {
    FocusScope.of(context).unfocus();
    if (validateEmail(email.text)) {
      try {
        await auth.sendPasswordResetEmail(email: email.text);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => messageReturn(message: email.text)));
      } on FirebaseAuthException catch (e) {
        if (e.code == "user-not-found") {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No user found for that email.")));
        }
        print(e.code);
      }
    } else if (email.text.isNotEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("E-mail invild")));
    }
  }
}

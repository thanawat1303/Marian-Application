import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marian/Forgot.dart';
import 'package:marian/functions.dart';
import 'package:marian/allBody.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formState = GlobalKey<FormState>();
  TextEditingController? username = TextEditingController();
  TextEditingController? password = TextEditingController();
  final auth = FirebaseAuth.instance;

  FocusNode emailf = FocusNode();
  FocusNode passwordf = FocusNode();

  bool statePassword = true;
  bool stateEmail = true;

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
        body: OverflowBox(
          minWidth: 0.0,
          minHeight: 0.0,
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Image.asset(
                'assets/img/Logo.png',
                width: 350,
                height: 140,
              ),
              Container(
                padding: const EdgeInsets.only(top: 0.0, bottom: 10),
                decoration: BoxDecoration(
                    color: Color.fromARGB(224, 255, 255, 255),
                    borderRadius: BorderRadius.circular(20)),
                width: 350,
                constraints: BoxConstraints(
                  maxHeight: double.infinity,
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(top: 25.0),
                        padding: const EdgeInsets.only(
                            top: 0.0, bottom: 10.0, left: 25.0, right: 25.0),
                        child: Form(
                            key: _formState,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BoxTextLabal("E-mail or Username"),
                                const SizedBox(height: 2),
                                SizedBox(
                                  child: userTextFormField(),
                                  height: 45,
                                ),
                                Container(
                                  height: stateEmail ? 0.0 : 20,
                                  padding: EdgeInsets.only(left: 20, top: 2),
                                  child: Text(
                                    stateEmail
                                        ? ''
                                        : 'No user found for that email.',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                BoxTextLabal("Password"),
                                const SizedBox(height: 2),
                                SizedBox(
                                  child: passWordTextFormField(),
                                  height: 45,
                                ),
                                Container(
                                  height: statePassword ? 0.0 : 20,
                                  padding: EdgeInsets.only(left: 20, top: 2),
                                  child: Text(
                                    statePassword
                                        ? ''
                                        : 'Wrong password provided for that user.',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                )
                              ],
                            )),
                      ),
                      const SizedBox(height: 6),
                      LoginButton(),
                      const SizedBox(height: 10),
                      ForgotPass(),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 125,
                            height: 1,
                            decoration: const BoxDecoration(color: Colors.grey),
                          ),
                          const Text(
                            "Sign In with",
                            style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'NatoSansThai',
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          Container(
                            width: 125,
                            height: 1,
                            decoration: const BoxDecoration(color: Colors.grey),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FacebookIcon(),
                          const SizedBox(width: 20),
                          GoogleIcon()
                        ],
                      ),
                      const SizedBox(height: 10),
                      SignUpButton()
                    ]),
              )
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle styleButtonBorder() {
    return ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return const Color.fromARGB(255, 36, 222, 238);
          }
          return const Color.fromARGB(255, 8, 51, 112);
        }),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))));
  }

  // ignore: non_constant_identifier_names
  SizedBox LoginButton() {
    return SizedBox(
      width: 135,
      height: 37,
      child: ElevatedButton(
          style: styleButtonBorder(),
          onPressed: () async {
            //check found E-mail
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: ((BuildContext context) {
                  return Center(
                    child: Container(
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
                        child: Stack(
                          children: [
                            Align(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          ],
                        )),
                  );
                }));
            try {
              List? check;
              if (validateEmail(username!.text) && username!.text.isNotEmpty) {
                check = await auth.fetchSignInMethodsForEmail(username!.text);
                if (check.isEmpty) {
                  username!.text = "";
                  password!.text = "";
                  setState(() {
                    stateEmail = false;
                  });
                  Navigator.pop(context);
                  FocusScope.of(context).requestFocus(emailf);
                  // ignore: avoid_returning_null_for_void
                  return null;
                }
              } else {
                setState(() {
                  FocusScope.of(context).requestFocus(emailf);
                  stateEmail = true;
                });
              }

              if (_formState.currentState!.validate()) {
                print(username!.text);
                print(password!.text);
                try {
                  await auth
                      .signInWithEmailAndPassword(
                          email: username!.text, password: password!.text)
                      .then((value) async {
                    setState(() {
                      statePassword = true;
                      stateEmail = true;
                    });

                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                    // if (value.user!.emailVerified) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //       const SnackBar(content: Text("Login Pass")));

                    // } else {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //       const SnackBar(content: Text("Please verify email")));
                    // }
                  }).catchError((reason) async {
                    Navigator.pop(context);
                    password!.text = "";
                    setState(() {
                      statePassword = false;
                    });
                    FocusScope.of(context).requestFocus(passwordf);
                  });
                } on FirebaseAuthException catch (e) {
                  Navigator.pop(context);
                  if (e.code == 'user-not-found') {
                    print('No user found for that email.');
                  } else if (e.code == 'wrong-password') {
                    print('Wrong password provided for that user.');
                  }
                }
              } else {
                Navigator.pop(context);
                if (!validateEmail(username!.text) || username!.text.isEmpty) {
                  password!.text = '';
                  FocusScope.of(context).requestFocus(emailf);
                } else {
                  FocusScope.of(context).requestFocus(passwordf);
                }
              }
            } catch (e) {
              if (e.hashCode == 396501758) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Please connect Internet"),
                  duration: Duration(seconds: 5),
                ));
              }
              Navigator.pop(context);
            }
          },
          child: const Text(
            'Login',
            style: TextStyle(
                fontFamily: 'NatoSansThai',
                fontSize: 24,
                fontWeight: FontWeight.w700),
          )),
    );
  }

  SizedBox SignUpButton() {
    return SizedBox(
      width: 84,
      height: 25,
      child: ElevatedButton(
          style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0)),
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return Color.fromARGB(255, 36, 222, 238);
                }
                return Color.fromARGB(255, 43, 113, 219);
              }),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)))),
          onPressed: () {
            _formState.currentState?.reset();
            setState(() {
              stateEmail = true;
              statePassword = true;
              showPassword = true;
            });
            username!.text = '';
            password!.text = '';
            FocusScope.of(context).unfocus();
            Navigator.pushNamed(context, "/signUp");
          },
          child: const Text(
            'Sign Up',
            style: TextStyle(
                fontFamily: 'NatoSansThai',
                fontSize: 14,
                fontWeight: FontWeight.w400),
          )),
    );
  }

  IconButton FacebookIcon() {
    return IconButton(
        padding: EdgeInsets.zero,
        onPressed: () {},
        icon: const Icon(
          Icons.facebook,
          size: 50,
          color: Colors.blue,
        ));
  }

  IconButton GoogleIcon() {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: () {},
      icon: const ImageIcon(
        AssetImage("assets/img/iconGoogle.png"),
        size: 50,
        color: Colors.red,
      ),
    );
  }

  Align ForgotPass() {
    return Align(
        child: GestureDetector(
            onTap: () async {
              List? check;
              setState(() {
                showPassword = true;
              });
              if (validateEmail(username!.text) && username!.text.isNotEmpty) {
                check = await auth.fetchSignInMethodsForEmail(username!.text);
                if (check.isEmpty) {
                  username!.text = "";
                  password!.text = "";
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ForgotPassword(emailPass: username!.text)));
                  // ignore: avoid_returning_null_for_void
                  return null;
                } else {
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ForgotPassword(emailPass: username!.text)));
                }
              } else {
                username!.text = "";
                password!.text = "";
                FocusScope.of(context).unfocus();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ForgotPassword(emailPass: username!.text)));
              }
              print("Forgot");
            },
            child: const Text(
              'forgot password',
              style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'NatoSansThai',
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            )));
  }

  TextFormField userTextFormField() {
    return TextFormField(
      focusNode: emailf,
      controller: username,
      validator: (value) {
        if (value!.isEmpty) {
          return '';
        } else if (!validateEmail(value)) {
          username!.text = '';
          setState(() {
            stateEmail = false;
          });
          return '';
        } else {
          setState(() {
            stateEmail = true;
          });
          return null;
        }
      },
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 20),
      cursorColor: Color.fromARGB(255, 148, 72, 105),
      decoration: InputDecoration(
          fillColor: const Color.fromARGB(105, 168, 95, 127),
          filled: true,
          prefixIcon: const Icon(
            Icons.mail_outline_rounded,
            color: Color.fromARGB(255, 148, 72, 105),
          ),
          contentPadding: const EdgeInsets.only(
              top: 0.0, bottom: 0.0, left: 15.0, right: 15.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50.0)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Color.fromARGB(255, 148, 72, 105), width: 2.0),
            borderRadius: BorderRadius.circular(50.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Color.fromARGB(105, 168, 95, 127), width: 0.0),
            borderRadius: BorderRadius.circular(50.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
            borderRadius: BorderRadius.circular(50.0),
          ),
          errorText: stateEmail ? null : '',
          errorStyle: const TextStyle(height: 0)),
    );
  }

  bool showPassword = true;

  TextFormField passWordTextFormField() {
    return TextFormField(
        focusNode: passwordf,
        controller: password,
        validator: (value) {
          if (value!.isEmpty) {
            setState(() {
              statePassword = true;
            });
            return '';
          } else {
            return null;
          }
        },
        cursorColor: Color.fromARGB(255, 148, 72, 105),
        obscureText: showPassword,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        style: const TextStyle(fontSize: 20),
        decoration: InputDecoration(
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
          fillColor: const Color.fromARGB(105, 168, 95, 127),
          filled: true,
          prefixIcon: const Icon(
            Icons.lock,
            color: Color.fromARGB(255, 148, 72, 105),
          ),
          contentPadding: const EdgeInsets.only(
              top: 0.0, bottom: 0.0, left: 15.0, right: 15.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50.0)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Color.fromARGB(255, 148, 72, 105), width: 2.0),
            borderRadius: BorderRadius.circular(50.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Color.fromARGB(105, 168, 95, 127), width: 0.0),
            borderRadius: BorderRadius.circular(50.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
            borderRadius: BorderRadius.circular(50.0),
          ),
          errorText: statePassword ? null : '',
          errorStyle: const TextStyle(height: 0),
        ));
  }

  Text BoxTextLabal(word) {
    return Text(
      word,
      style: const TextStyle(
          fontSize: 18,
          fontFamily: 'NatoSansThai',
          fontWeight: FontWeight.w900),
    );
  }
}

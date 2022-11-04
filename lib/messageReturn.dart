import 'package:flutter/material.dart';

class messageReturn extends StatelessWidget {
  final String? message;
  const messageReturn({Key? key, required this.message}) : super(key: key);

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
          body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text("Please check your email inbox."),
                Text(
                  message!,
                  style: TextStyle(fontFamily: 'Prompt-Bold', fontSize: 20),
                ),
                SizedBox(
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(fontSize: 21),
                      )),
                  width: 100,
                )
              ])),
        ));
  }
}

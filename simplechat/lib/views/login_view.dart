import 'package:flutter/material.dart';
import 'room_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => new _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  String smsCode = '';
  AuthCredential _credential;
  Future registerUser(String mobile, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.verifyPhoneNumber(
        phoneNumber: mobile,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential authCredential) {
          _auth.signInWithCredential(authCredential).then((AuthResult result) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => RoomView(result.user)));
          }).catchError((e) {
            print(e);
          });
        },
        verificationFailed: (AuthException authException) {
          print(authException.message);
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          //show dialog to take input from the user
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                    title: Text("Enter SMS Code"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(
                          controller: _codeController,
                          textAlign: TextAlign.center,
                          textCapitalization: TextCapitalization.characters,
                          obscureText: true,
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Done"),
                        textColor: Colors.white,
                        color: Colors.redAccent,
                        onPressed: () {
                          FirebaseAuth auth = FirebaseAuth.instance;
                          smsCode = _codeController.text.trim();
                          _codeController.text = "";
                          _credential = PhoneAuthProvider.getCredential(
                              verificationId: verificationId, smsCode: smsCode);
                          auth
                              .signInWithCredential(_credential)
                              .then((AuthResult result) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        RoomView(result.user)));
                          }).catchError((e) {
                            print(e);
                          });
                        },
                      )
                    ],
                  ));
        },
        codeAutoRetrievalTimeout: null);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Container(
      padding: EdgeInsets.all(32),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Login",
              style: TextStyle(
                  color: Colors.lightBlue,
                  fontSize: 36,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 16,
            ),
            TextFormField(
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Colors.grey[200])),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Colors.grey[300])),
                  filled: true,
                  fillColor: Colors.grey[100],
                  hintText: "Phone Number"),
              controller: _phoneController,
            ),
            SizedBox(
              height: 16,
            ),
            Container(
              width: double.infinity,
              child: FlatButton(
                child: Text("Login"),
                textColor: Colors.white,
                padding: EdgeInsets.all(16),
                onPressed: () {
                  final mobile = _phoneController.text.trim();
                  registerUser(mobile, context);
                },
                color: Colors.blue,
              ),
            )
          ],
        ),
      ),
    ));
  }
}

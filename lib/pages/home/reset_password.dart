import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rehabnow_app/services/login.http.service.dart';
import 'package:rehabnow_app/utils/loading.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _successMessage;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(
                        "assets/images/login-bg.png",
                      ))),
              child: Center(
                child: Card(
                    margin: EdgeInsets.all(20),
                    child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "Reset Password",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5),
                            ),
                            Text(
                              "No worries, it is normal to be forgetful. We got you covered!",
                              textAlign: TextAlign.center,
                              // style: TextStyle(),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                            ),
                            _errorMessage != null
                                ? Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : Container(),
                            _successMessage != null
                                ? Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 18.0),
                                    child: Text(
                                      _successMessage!,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : Container(),
                            TextFormField(
                              controller: _emailController,
                              validator: (value) => value!.length > 0
                                  ? null
                                  : "Email address is required.",
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.mail_outline),
                                  border: OutlineInputBorder(),
                                  labelText: "Email Address"),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5),
                            ),
                            RaisedButton(
                              onPressed: () {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                if (_formKey.currentState!.validate()) {
                                  showLoadingDialog(context);
                                  _errorMessage = _successMessage = null;
                                  print(_emailController.text);
                                  resetPassword(_emailController.text)
                                      .then((value) {
                                    Navigator.of(context).pop();
                                    if (value.status == "success") {
                                      setState(() {
                                        _successMessage =
                                            "Email to reset password is sent to your email.";
                                      });
                                      _emailController.clear();
                                    } else {
                                      setState(() {
                                        _errorMessage = value.errorMessage!;
                                      });
                                    }
                                  });
                                }
                              },
                              color: Colors.blue,
                              child: Text(
                                "Submit",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Divider(
                              color: Colors.black54,
                            ),
                            InkWell(
                              child: Text(
                                "Back to login page",
                                style: TextStyle(
                                  color: Colors.blue,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () => Navigator.of(context).pop(),
                            )
                          ],
                        ))),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

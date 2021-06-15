import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rehabnow_app/constants/routes.constant.dart';
import 'package:rehabnow_app/main.dart';
import 'package:rehabnow_app/pages/prelogin/main_page.dart';
import 'package:rehabnow_app/pages/home/reset_password.dart';
import 'package:rehabnow_app/services/login.http.service.dart';
import 'package:rehabnow_app/utils/flutter_secure_storage.dart';
import 'package:rehabnow_app/utils/loading.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _passwordVisibility = true;
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

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(
                      "assets/images/login-bg.png",
                    ))),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Card(
                  elevation: 2,
                  margin: EdgeInsets.all(20),
                  child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Image.asset(
                            "assets/images/logo1.png",
                            width: 100,
                          ),
                          Text(
                            "Welcome To RehabNow",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          _errorMessage != null
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Container(),
                          Padding(
                            padding: EdgeInsets.all(10),
                          ),
                          TextFormField(
                            controller: _emailController,
                            validator: (value) => value!.length > 0
                                ? null
                                : "Email address is required.",
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.mail_outline),
                                labelText: "Email Address",
                                border: OutlineInputBorder()),
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                          TextFormField(
                            controller: _passwordController,
                            validator: (value) => value!.length > 0
                                ? null
                                : "Password is required.",
                            obscureText: _passwordVisibility,
                            decoration: InputDecoration(
                                labelText: "Password",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_passwordVisibility
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () => setState(() =>
                                      _passwordVisibility =
                                          !_passwordVisibility),
                                )),
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                          RaisedButton(
                            color: Colors.blue,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                print(
                                    "validate ${_emailController.text} ${_passwordController.text}");
                                showLoadingDialog(context);

                                login(_emailController.text,
                                        _passwordController.text)
                                    .then((value) {
                                  print(value.status);
                                  Navigator.of(context).pop();
                                  if (value.status == "success") {
                                    RehabnowFlutterSecureStorage.storage.write(
                                        key: "token", value: value.data.token);
                                    Navigator.of(context).pushReplacementNamed(
                                        RoutesConstant.MAIN_PAGE);
                                  } else {
                                    print(value.errorMessage);
                                    setState(() =>
                                        _errorMessage = value.errorMessage!);
                                  }
                                });
                              }
                            },
                            child: Text(
                              "Login",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            padding: EdgeInsets.all(10),
                          ),
                          Divider(
                            color: Colors.black54,
                          ),
                          Text(
                            "Forgot Password?",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          InkWell(
                            child: Text(
                              "Reset here",
                              style: TextStyle(color: Colors.blue[500]),
                            ),
                            onTap: () => {
                              Navigator.of(context)
                                  .pushNamed(RoutesConstant.RESET_PASSWORD)
                            },
                          ),
                        ],
                      )),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

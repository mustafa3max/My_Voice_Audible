import 'dart:developer';
import 'package:flutter/material.dart';
import 'home.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var _isLogin = false;
  var _isResetPass = false;

  final _formKey = GlobalKey<FormState>();

  final _focusName = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPass = FocusNode();
  final _focusConfirm = FocusNode();

  final _ctrlName = TextEditingController();
  final _ctrlEmail = TextEditingController();
  final _ctrlPass = TextEditingController();
  final _ctrlConfirm = TextEditingController();

  @override
  void dispose() {
    _focusName.dispose();
    _focusEmail.dispose();
    _focusPass.dispose();
    _focusConfirm.dispose();

    _ctrlName.dispose();
    _ctrlEmail.dispose();
    _ctrlPass.dispose();
    _ctrlConfirm.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => Home(),
          ),
          (route) => false),
      child: SafeArea(
        child: Material(
          child: Stack(
            children: [
              // صورة الخلفية
              Image.asset("assets/images/background_login.webp",
                  height: double.maxFinite, fit: BoxFit.cover),
              // لون شفاف على الخلفية
              Container(
                color: Colors.black87,
              ),

              SingleChildScrollView(
                reverse: true,
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      left: 10,
                      right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 30),
                      // شعار التطبيق
                      Align(
                          child: Image.asset("assets/images/logo_app.webp",
                              width: 100)),

                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          _isLogin
                              ? _isResetPass
                                  ? "Reset Password"
                                  : "Sign in"
                              : "Sign up",
                          style: TextStyle(fontSize: 28),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // حقول الادخال وزر التسجيل
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _textField(
                              isShow: !_isLogin,
                              focus: _focusName,
                              ctrlEdit: _ctrlName,
                              maxLength: 12,
                              type: TextInputType.name,
                              icon: Icons.person,
                              hint: "Name",
                            ),
                            _textField(
                              isShow: true,
                              focus: _focusEmail,
                              ctrlEdit: _ctrlEmail,
                              maxLength: 255,
                              type: TextInputType.emailAddress,
                              icon: Icons.email,
                              hint: "Email",
                            ),
                            _textField(
                              isShow: !_isResetPass || !_isLogin,
                              focus: _focusPass,
                              ctrlEdit: _ctrlPass,
                              maxLength: 12,
                              type: TextInputType.visiblePassword,
                              icon: Icons.lock,
                              hint: "Password",
                            ),
                            _textField(
                              isShow: !_isLogin,
                              focus: _focusConfirm,
                              ctrlEdit: _ctrlConfirm,
                              maxLength: 12,
                              type: TextInputType.visiblePassword,
                              icon: Icons.lock_outline,
                              hint: "Confirm Password",
                            ),

                            // زر تسجيل الدخول او انشاء حساب
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    log(_formKey.currentState
                                        .validate()
                                        .toString());
                                  }
                                },
                                icon: Icon(Icons.login),
                                label: Text(_isLogin
                                    ? _isResetPass
                                        ? "Reset Password"
                                        : "Sign in"
                                    : "Sign up"),
                                style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                      EdgeInsets.all(18),
                                    ),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(100)))),
                              ),
                            ),

                            // رسالة خطأ في الباسورد او الايميل
                            Visibility(
                              visible: _isLogin && !_isResetPass,
                              child: Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  "The email or password is incorrect.",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      // رسالة هل عندك حساب
                      Visibility(
                        visible: !_isResetPass,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Text(_isLogin
                                  ? "Don’t have an account?"
                                  : "Already have an account?"),
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLogin = !_isLogin;
                                    });
                                  },
                                  child: Text(_isLogin ? "Sign up" : "Sign in"))
                            ],
                          ),
                        ),
                      ),

                      Visibility(
                        visible: _isLogin,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Row(
                            children: [
                              Text("forgot password?"),
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isResetPass = !_isResetPass;
                                    });
                                  },
                                  child: Text("Reset"))
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة مخصصة لاضافة حقل ادخال مخصص
  Widget _textField({isShow, focus, ctrlEdit, maxLength, type, icon, hint}) {
    return Visibility(
      visible: isShow,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          focusNode: focus,
          controller: ctrlEdit,
          keyboardType: type,
          cursorColor: Colors.red,
          maxLength: focus.hasFocus ? maxLength : null,
          onTap: () {
            setState(() {});
          },
          validator: (value) {
            // التحقق من الاسم
            if (icon == Icons.person) {
              if (value.isEmpty) return "The field is empty";
              if (value.length > 12) return "The name is long";
              if (value.length < 3) return "The name is short";
            }
            // التحقق من الايميل
            if (icon == Icons.email) {
              if (value.isEmpty) return "The field is empty";
              if (value.length > 255) return "The email is long";
              if (value.length < 5) return "The email is short";
            }
            // التحقق من الباسورد
            if (icon == Icons.lock || icon == Icons.lock_outline) {
              if (value.isEmpty) return "The field is empty";
              if (value.length > 12) return "The password is long";
              if (value.length < 4) return "The password is short";
            }
            return null;
          },
          decoration: InputDecoration(
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent),
                borderRadius: BorderRadius.circular(100)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide.none),
            prefixIcon: Icon(
              icon,
              color: Colors.white,
            ),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Color(0x20ffffff),
            focusColor: Colors.red,
            focusedBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}

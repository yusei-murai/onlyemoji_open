import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:onlyemoji/model/account.dart';
import 'package:onlyemoji/utils/authentication.dart';
import 'package:onlyemoji/utils/firestore/users.dart';
import 'package:onlyemoji/utils/function_utils.dart';
import 'package:onlyemoji/utils/validator/input_validator.dart';
import 'package:onlyemoji/view/account/check_email_page.dart';
import 'package:onlyemoji/view/account/signin_page.dart';
import 'package:url_launcher/url_launcher.dart';


class SignUpPage extends StatefulWidget {
  final bool isSignInWithGoogle;
  SignUpPage({this.isSignInWithGoogle = false});


  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  File? image;
  bool hidePassword = true;
  String errorMsg = "";

  bool _flag = false;

  void _handleCheckbox(bool? e) {
    setState(() {
      _flag = e!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(errorMsg,style: const TextStyle(color: Colors.red),),
                      const SizedBox(height: 10,),
                      GestureDetector(
                        onTap: () async {
                          var result = await FunctionUtils.getImageFromGallery();
                          if(result != null){
                            if(result != null){
                              setState(() {
                                image = File(result.path);
                              });
                            }
                          }
                        },
                        child: CircleAvatar(
                          foregroundImage: image == null ? null : FileImage(image!),
                          radius: 40,
                          child: const Icon(Icons.add),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      TextFormField(
                        controller: nameController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          return InputValidator.nameValidator(value);
                        },
                        decoration: const InputDecoration(
                          //hintText: '名前',
                          icon: Icon(Icons.perm_identity_outlined),
                          labelText: 'ニックネーム',
                        ),
                      ),
                      const SizedBox(height: 10,),
                      TextFormField(
                        controller: commentController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          return InputValidator.nameValidator(value);
                        },
                        decoration: const InputDecoration(
                          icon: Icon(Icons.comment),
                          hintText: '😆😂😡😉',
                          labelText: 'ひとこと',
                        ),
                      ),
                      const SizedBox(height: 10,),
                      widget.isSignInWithGoogle ? Container() : Column(
                        children: [
                          TextFormField(
                            controller: emailController,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              return InputValidator.emailValidator(value);
                            },
                            decoration: const InputDecoration(
                              icon: Icon(Icons.mail),
                              hintText: 'example@mail.com',
                              labelText: 'メールアドレス',
                            ),
                          ),
                          const SizedBox(height: 10,),
                          TextFormField(
                            controller: passController,
                            obscureText: hidePassword,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              return InputValidator.passValidator(value);
                            },
                            decoration: InputDecoration(
                              icon: const Icon(Icons.lock),
                              labelText: 'パスワード',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  hidePassword ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    hidePassword = !hidePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment:MainAxisAlignment.center,
                        children: [
                          RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                      text: "利用規約",
                                      style: const TextStyle(color: Colors.blue),
                                      recognizer: TapGestureRecognizer()..onTap = () async {
                                        FunctionUtils.openUri("https://muuchan.wp.xdomain.jp/kiyaku/");
                                      }
                                  ),
                                  const TextSpan(text: "に同意"),
                                ],
                              )
                          ),
                          Checkbox(
                            activeColor: Colors.pink,
                            value: _flag,
                            onChanged: _handleCheckbox,
                          )
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if(nameController.text.isNotEmpty&&
                          commentController.text.isNotEmpty&&
                          image != null&&
                          InputValidator.nameValidator(nameController.text)==null&&
                              InputValidator.nameValidator(commentController.text)==null&&
                              _flag == true
                          ){
                            // if(widget.isSignInWithGoogle){
                            //   var _result = await createAccount(Authentication.currentFirebaseUser!.uid);
                            //   if(_result == true){
                            //     await UserFirestore.getUser(Authentication.currentFirebaseUser!.uid);
                            //     Navigator.pop(context);
                            //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Screen()));
                            //   }
                            // }
                            var result = await Authentication.signUp(email: emailController.text, pass: passController.text);
                            if(result is UserCredential){
                              var _result = await createAccount(result.user!.uid);
                              if(_result == true){
                                result.user!.sendEmailVerification();
                                Navigator.push(context, MaterialPageRoute(builder: (context) => CheckEmailPage(email: emailController.text, pass: passController.text)));
                              }
                            }else{
                              setState(() {
                                errorMsg = "入力項目に誤りがあります";
                              });
                            }
                          }else{
                            setState(() {
                              errorMsg = "入力項目に誤りがあります";
                            });
                          }
                        },
                        child: const Text('アカウントを作成'),
                      ),
                      const SizedBox(height: 10,),
                      RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black),
                            children: [
                              const TextSpan(text: "アカウント作成済の方は"),
                              TextSpan(
                                  text: "こちらからログイン",
                                  style: const TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()..onTap = (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignInPage()));
                                  }
                              )
                            ],
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> createAccount(String uid) async {
    String imagePath = await FunctionUtils.uploadImage(uid,image!);
    Account newAccount = Account(
      id: uid,
      name: nameController.text,
      imagePath: imagePath,
      comment: commentController.text,
    );
    var _result = await UserFirestore.setUser(newAccount);

    return _result;
  }
}

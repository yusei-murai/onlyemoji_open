import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:onlyemoji/main.dart';
import 'package:onlyemoji/model/account.dart';
import 'package:onlyemoji/utils/authentication.dart';
import 'package:onlyemoji/utils/firestore/users.dart';
import 'package:onlyemoji/utils/validator/input_validator.dart';
import 'package:onlyemoji/view/account/signup_page.dart';
import 'package:onlyemoji/view/screen.dart';

class SignInPage extends StatefulWidget {
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool hidePassword = true;
  String errorMsg = "";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.pink,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(errorMsg,style: const TextStyle(color: Colors.red),),
                    TextFormField(
                      controller: emailController,
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
                    const SizedBox(height: 10,),
                    ElevatedButton(
                      onPressed: () async {
                        if(InputValidator.emailValidator(emailController.text)==null&&
                            InputValidator.passValidator(passController.text)==null){
                          var result = await Authentication.emailSignIn(email: emailController.text, pass: passController.text);
                          if(result is UserCredential){
                            if(result.user!.emailVerified == true){
                              var _result = await UserFirestore.authGetUser(result.user!.uid);
                              if(_result == true){
                                if(!mounted) return;
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Screen()));
                              }
                            }else{
                              print("認証できてない");
                            }
                          }else{
                            setState(() {
                              errorMsg = result;
                            });
                          }
                        }else{
                          setState(() {
                            errorMsg = "入力項目に誤りがあります";
                          });
                        }
                      },
                      child: const Text('ログイン'),
                    ),
                    // const SizedBox(height: 10,),
                    // SignInButton(
                    //     Buttons.Google,
                    //     onPressed: () async {
                    //       var result = await Authentication.signInWithGoogle();
                    //       if(result is UserCredential){
                    //         var result = await UserFirestore.getUser(Authentication.currentFirebaseUser!.uid);
                    //         if(result == true){
                    //           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Screen()));
                    //         }else{
                    //           Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                    //         }
                    //       }
                    //     }
                    // ),
                    const SizedBox(height: 10,),
                    RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black),
                          children: [
                            const TextSpan(text: "アカウント作成がお済みでない方は"),
                            TextSpan(
                                text: "こちら",
                                style: const TextStyle(color: Colors.blue),
                                recognizer: TapGestureRecognizer()..onTap = (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
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
    );
  }
}

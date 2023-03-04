import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlyemoji/utils/authentication.dart';
import 'package:onlyemoji/utils/firestore/users.dart';
import 'package:onlyemoji/utils/widget_utils.dart';
import 'package:onlyemoji/view/screen.dart';

class CheckEmailPage extends StatefulWidget {
  final String email;
  final String pass;
  CheckEmailPage({required this.email,required this.pass});

  @override
  _CheckEmailPageState createState() => _CheckEmailPageState();
}

class _CheckEmailPageState extends State<CheckEmailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarUtils.screenAppBar(context,''),
      body: Column(
        children: [
          Text("登録されたメールアドレス宛に確認メールを送信しました。そちらに記載されているURLにアクセスし、認証をお願いします。"),
          OutlinedButton(
            onPressed: () async {
              var result = await Authentication.emailSignIn(email: widget.email, pass: widget.pass);
              if(result is UserCredential){
                if(result.user!.emailVerified == true){
                  while (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  await UserFirestore.authGetUser(result.user!.uid);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Screen()));
                }else{
                  print("失敗");
                }
              }
            },
            child: const Text("認証完了"),
          )
        ],
      ),
    );
  }
}

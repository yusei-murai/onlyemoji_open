import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:onlyemoji/model/account.dart';
import 'package:onlyemoji/utils/authentication.dart';
import 'package:onlyemoji/utils/firestore/users.dart';
import 'package:onlyemoji/utils/widget_utils.dart';
import 'package:onlyemoji/view/account/signin_page.dart';


class DeleteAccountPage extends StatelessWidget {
  const DeleteAccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Account me = Authentication.myAccount!;

    return Scaffold(
      appBar: AppBarUtils.screenAppBar(context,'アカウントの削除'),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  foregroundImage: NetworkImage(me.imagePath),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(me.name,style: const TextStyle(fontSize:20,fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
              ],
            ),
          ),
          RichText(text: TextSpan(
              text: "アカウントを削除",
              style: const TextStyle(color: Colors.red),
              recognizer: TapGestureRecognizer()..onTap = (){
                showDialog(
                    context: context,
                    builder: (context) {
                      return CupertinoAlertDialog(
                        title: const Text("アカウントを削除"),
                        content: Text("本当に ${me.name} を削除しますか？"),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () => Navigator.pop(context),
                            child: const Text("キャンセル"),
                          ),
                          CupertinoDialogAction(
                              child: const Text("アカウントを削除"),
                              onPressed: () {
                                UserFirestore.deleteUser(me.id);
                                Authentication.deleteAuth();

                                while (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(
                                        builder: (context) => SignInPage()));
                              }
                          ),
                        ],
                      );
                    }
                );

              }
          ))
        ],
      ),
    );
  }
}

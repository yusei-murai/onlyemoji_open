import 'package:flutter/material.dart';
import 'package:onlyemoji/model/post.dart';
import 'package:onlyemoji/utils/authentication.dart';
import 'package:onlyemoji/utils/firestore/posts.dart';
import 'package:onlyemoji/utils/validator/input_validator.dart';
import 'package:onlyemoji/utils/widget_utils.dart';

class NewPostPage extends StatelessWidget {
  TextEditingController newPostController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        appBar: AppBarUtils.createAppbar(context,TextButton(
          onPressed: () async {
            if(newPostController.text.isNotEmpty&&
                InputValidator.emojiValidator(newPostController.text)==null
            ){
              Post newPost = Post(
                  userId: Authentication.myAccount!.id,
                  content: newPostController.text,
              );
              var result = await PostFirestore.addPost(newPost);
              if(result == true){
                SnackBarUtils.doneSnackBar("投稿が送信されました！", context);
                Navigator.pop(context);
              }
            }
          },
          child: const Text("投稿"),
        )),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      return InputValidator.emojiValidator(value);
                    },
                    controller: newPostController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "😁😆",),
                  ),
                ),
              ],
            ),
          ),
        ),

      ),
    );
  }
}

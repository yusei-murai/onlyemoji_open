import 'dart:io';

import 'package:flutter/material.dart';
import 'package:onlyemoji/model/account.dart';
import 'package:onlyemoji/utils/authentication.dart';
import 'package:onlyemoji/utils/infra/users.dart';
import 'package:onlyemoji/utils/function_utils.dart';
import 'package:onlyemoji/utils/validator/input_validator.dart';
import 'package:onlyemoji/utils/widget_utils.dart';


class EditAccountPage extends StatefulWidget {
  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  Account me = Authentication.myAccount!;
  TextEditingController nameController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  File? image;

  ImageProvider getImage() {
    if(image == null){
      return NetworkImage(me.imagePath);
    } else {
      return FileImage(image!);
    }
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: me.name);
    commentController = TextEditingController(text: me.comment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarUtils.createAppbar(context,
          TextButton(
            onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    commentController.text.isNotEmpty&&
                     InputValidator.nameValidator(nameController.text)==null&&
                    InputValidator.nameValidator(commentController.text)==null
                ) {
                  String imagePath = '';
                  if (image == null) {
                    imagePath = me.imagePath;
                  } else {
                    var result = await FunctionUtils.uploadImage(me.id, image!);
                    imagePath = result;
                  }

                  Account updateAccount = Account(
                    id: me.id,
                    name: nameController.text,
                    imagePath: imagePath,
                    comment: commentController.text,
                  );
                  Authentication.myAccount = updateAccount;
                  var result = await UserFirestore.updateUser(updateAccount);
                  if (result == true) {
                    Navigator.pop(context, true);
                  }
                }
        },
        child: const Text("更新"),
      )
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  var result = await FunctionUtils.getImageFromGallery();
                  if(result != null){
                    setState(() {
                      image = File(result.path);
                    });
                  }
                },
                child: CircleAvatar(
                  foregroundImage: getImage(),
                  radius: 40,
                  child: const Icon(Icons.add),
                ),
              ),
              const SizedBox(height: 10,),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  return InputValidator.nameValidator(value);
                },
                controller: nameController,
                decoration: const InputDecoration(
                  //hintText: '名前',
                  icon: Icon(Icons.perm_identity_outlined),
                  labelText: 'ニックネーム',
                ),
              ),
              const SizedBox(height: 10,),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  return InputValidator.nameValidator(value);
                },
                controller: commentController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.comment),
                  hintText: '😆😂😡😉',
                  labelText: 'ひとこと',
                ),
              ),
              const SizedBox(height: 10,),
            ],
          ),
        ),
      ),

    );
  }
}

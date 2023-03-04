import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  String id; //ガチのID
  String name;
  String imagePath;
  String comment;
  Timestamp? createdTime;
  Timestamp? updatedTime;

  Account({required this.id,required this.name,required this.imagePath,this.createdTime,this.updatedTime,required this.comment});
}
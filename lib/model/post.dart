import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String id;
  String userId;
  String content;
  Timestamp? createdTime;
  Timestamp? updatedTime;

  Post({this.id = '',this.userId = '',this.content = '',this.createdTime,this.updatedTime});
}
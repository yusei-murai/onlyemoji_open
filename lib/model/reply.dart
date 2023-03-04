import 'package:cloud_firestore/cloud_firestore.dart';

class Reply {
  String id;
  String userId;
  String content;
  String parentPostId;
  Timestamp? createdTime;
  Timestamp? updatedTime;

  Reply({this.id = '',this.userId = '',this.content = '',this.parentPostId = '',this.createdTime,this.updatedTime});
}
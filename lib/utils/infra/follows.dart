import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyemoji/model/account.dart';
import 'package:onlyemoji/model/follow.dart';
import 'package:onlyemoji/utils/authentication.dart';
import 'package:sqflite/sqflite.dart';

class FollowFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static Account me = Authentication.myAccount!;
  static final CollectionReference _followedUsers = _firestoreInstance.collection('users').doc(me.id).collection('followed_users');

  static Future<dynamic> insertFollow(String accountId) async {
    try{
      _followedUsers.doc(accountId).set({
        'user_id': accountId,
      });
      return true;
    } on FirebaseException catch(e) {
      return false;
    }
  }

  static Future<List<String>?> getFollowUserIds() async {
    try{
      try{
        var doc = await _followedUsers.get(const GetOptions(source: Source.cache));
        final List<String> userIds = doc.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;

          final String followUserId = data['user_id'];
          return followUserId;
        }).toList();

        return userIds;
      } on FirebaseException catch(e) {
        var doc = await _followedUsers.get(const GetOptions(source: Source.server));
        final List<String> userIds = doc.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;

          final String followUserId = data['user_id'];
          return followUserId;
        }).toList();

        return userIds;
      }
    } on FirebaseException catch(e) {
      return null;
    }
  }

  static Future<dynamic> deleteFollow(String accountId) async {
    try{
      await _followedUsers.doc(accountId).delete();

      return true;
    } on FirebaseException catch(e){
      return false;
    }
  }

  static Future<bool> isFollow(String accountId) async {
    try{
      try{
        var result = await _followedUsers.doc(accountId).get(const GetOptions(source: Source.cache));
        if(result.exists){
          return true;
        }else{
          return false;
        }
      } on FirebaseException catch(e){
        var result = await _followedUsers.doc(accountId).get(const GetOptions(source: Source.server));
        if(result.exists){
          return true;
        }else{
          return false;
        }
      }
    } on FirebaseException catch(e){
      return false;
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyemoji/model/account.dart';
import 'package:onlyemoji/utils/authentication.dart';
import 'package:onlyemoji/utils/firestore/posts.dart';

class UserFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference users = _firestoreInstance.collection('users');

  static Future<dynamic> setUser(Account newAccount) async {
    try {
      await users.doc(newAccount.id).set({
        'name': newAccount.name,
        'comment': newAccount.comment,
        'image_path': newAccount.imagePath,
        'created_time': Timestamp.now(),
        'updated_time': Timestamp.now(),
      });
      return true;
    } on FirebaseException catch(e) {
      return false;
    }
  }

  static Future<dynamic> authGetUser(String uid) async {
    try {
      DocumentSnapshot documentSnapshot = await users.doc(uid).get();
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      Account myAccount = Account(
          id: uid,
          name: data['name'],
          imagePath: data['image_path'],
          comment: data['comment'],
          createdTime: data['created_time'],
          updatedTime: data['updated_time'],
      );
      Authentication.myAccount = myAccount;
      return true;
    } on FirebaseException catch(e) {
      return false;
    }
  }

  static Future<Account?> getUser(String uid) async {
    try {
      DocumentSnapshot documentSnapshot = await users.doc(uid).get();
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      Account account = Account(
        id: uid,
        name: data['name'],
        imagePath: data['image_path'],
        comment: data['comment'],
        createdTime: data['created_time'],
        updatedTime: data['updated_time'],
      );

      return account;
    } on FirebaseException catch(e) {
      return null;
    }
  }

  static Future<dynamic> updateUser(Account updateAccount) async {
    if(updateAccount.id == Authentication.myAccount!.id){
      try {
        await users.doc(updateAccount.id).update({
          'name': updateAccount.name,
          'comment': updateAccount.comment,
          'image_path': updateAccount.imagePath,
          'updated_time': Timestamp.now(),
        });
        return true;
      } on FirebaseException catch(e) {
        return false;
      }
    }
  }

  static Future<Map<String,Account>?> getPostUserMap(List<String> accountIds) async {
    Map<String,Account> map = {};
    try{
      await Future.forEach(accountIds, (String accountId) async {
        var doc = await users.doc(accountId).get();
        Map<String,dynamic> data = doc.data() as Map<String,dynamic>;
        Account postAccount = Account(
            id: accountId,
            name: data['name'],
            imagePath: data['image_path'],
            comment: data['comment'],
            createdTime: data['created_time'],
            updatedTime: data['updated_data']
        );
        map[accountId] = postAccount;
      }
      );
      return map;
    }on FirebaseException catch(e){
      return null;
    }
  }

  static Future<dynamic> deleteUser(String accountId) async {
    if(accountId == Authentication.myAccount!.id){
      await users.doc(accountId).delete();
      PostFirestore.deletePosts(accountId);
    }
  }

  static Future<bool> blockUser(String accountId) async {
      try{
        Account me = Authentication.myAccount!;
        final CollectionReference _blockedUsers = users.doc(me.id).collection('blocked_users');

        _blockedUsers.doc(accountId).set({
          'user_id': accountId,
          'created_time': Timestamp.now()
        });
        return true;
      }on FirebaseException catch(e){
        return false;
      }
  }

  static Future<dynamic> deleteMyBlockedUser(String accountId) async {
    try{
      Account me = Authentication.myAccount!;
      final CollectionReference _blockedUsers = users.doc(me.id).collection('blocked_users');

      _blockedUsers.doc(accountId).delete();

      return true;
    }on FirebaseException catch(e){
      return false;
    }
  }

  static Future<dynamic> isBlockedUser(String accountId) async {
    try{
      Account me = Authentication.myAccount!;
      var user = await users.doc(me.id).collection('blocked_users').doc(accountId).get();

      if(user.exists){
        return true;
      }else{
        return false;
      }
    }on FirebaseException catch(e){
      return false;
    }
  }

  static Future<List<String>?> getMyBlockedUserIdList() async {
    Account me = Authentication.myAccount!;

    final QuerySnapshot snapshot = await users.doc(me.id).collection('blocked_users').get();

    final List<String> blockIds = snapshot.docs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      final String blockUserId = data['user_id'];
      return blockUserId;
    }).toList();

    return blockIds;
  }
}
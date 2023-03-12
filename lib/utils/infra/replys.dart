import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyemoji/model/reply.dart';

class ReplyFirestore{
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference replys = _firestoreInstance.collection('replys');

  static Future<dynamic> addReply(Reply newReply) async {
    final CollectionReference _postReplys = _firestoreInstance.collection('posts').doc(newReply.parentPostId).collection('my_replys');

    try{
      //全体に対する投稿を作成
      var result = await replys.add({
        'content':newReply.content,
        'user_id':newReply.userId,
        'parent_post_id':newReply.parentPostId,
        'created_time':Timestamp.now(),
        'updated_time':Timestamp.now(),
      });

      _postReplys.doc(result.id).set({
        'reply_id': result.id,
        'created_time': Timestamp.now()
      });

      return true;
    } on FirebaseException catch(e) {
      return false;
    }
  }

  static Future<List<Reply>?> getReplysFromIds(List<String> ids) async {
    List<Reply> replyList = [];
    try{
      await Future.forEach(ids, (String id) async{
        var doc = await replys.doc(id).get();
        Map<String,dynamic> data = doc.data() as Map<String,dynamic>;
        Reply reply = Reply(
          id: doc.id,
          content: data['content'],
          userId: data['user_id'],
          parentPostId: data['parent_post_id'],
          createdTime: data['created_time'],
          updatedTime: data['updated_time'],
        );
        replyList.add(reply);
      });
      return replyList;
    }on FirebaseException catch(e){
      return null;
    }
  }

  static Future<dynamic> deleteOneReply(String postId,String replyId) async {
    final CollectionReference _postReplys = _firestoreInstance.collection('posts').doc(postId).collection('my_replys');

    await replys.doc(replyId).delete();
    _postReplys.doc(replyId).delete();
  }

  static Future<dynamic> deleteReplys(String postId) async {
    final CollectionReference _postReplys = _firestoreInstance.collection('posts').doc(postId).collection('my_replys');
    var snapshot = await _postReplys.get();

    snapshot.docs.forEach((doc) async {
      await replys.doc(doc.id).delete();
      _postReplys.doc(doc.id).delete();
    });
  }
}
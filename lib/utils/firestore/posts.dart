import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyemoji/model/account.dart';
import 'package:onlyemoji/model/post.dart';
import 'package:onlyemoji/utils/firestore/replys.dart';

class PostFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference posts = _firestoreInstance.collection('posts');

  static Future<dynamic> addPost(Post newPost) async {
    try{
      final CollectionReference _userPosts = _firestoreInstance.collection('users').doc(newPost.userId).collection('my_posts');
      //全体に対する投稿を作成
      var result = await posts.add({
        'content':newPost.content,
        'user_id':newPost.userId,
        'created_time':Timestamp.now(),
        'updated_time':Timestamp.now(),
      });

      //全体に対する投稿の情報を元に自分のみの投稿としても保存
      _userPosts.doc(result.id).set({
        'post_id': result.id,
        'created_time': Timestamp.now()
      });
      return true;
    } on FirebaseException catch(e) {
      return false;
    }
  }

  static Future<List<Post>?> getPostsFromIds(List<String> ids) async {
    List<Post> postList = [];
    try{
      await Future.forEach(ids, (String id) async{
        var doc = await posts.doc(id).get();
        Map<String,dynamic> data = doc.data() as Map<String,dynamic>;
        Post post = Post(
          id: doc.id,
          content: data['content'],
          userId: data['user_id'],
          createdTime: data['created_time'],
          updatedTime: data['updated_time'],
        );
        postList.add(post);
      });
      return postList;
    }on FirebaseException catch(e){
      return null;
    }
  }

  static Future<dynamic> deletePosts(String accountId) async {
    final CollectionReference _userPosts = _firestoreInstance.collection('users').doc(accountId).collection('my_posts');
    var snapshot = await _userPosts.get();

    snapshot.docs.forEach((doc) async {
      ReplyFirestore.deleteReplys(doc.id);
      await posts.doc(doc.id).delete();
      _userPosts.doc(doc.id).delete();
    });
  }

  static Future<dynamic> deleteOnePost(String accountId,String postId) async {
    final CollectionReference _userPosts = _firestoreInstance.collection('users').doc(accountId).collection('my_posts');

    ReplyFirestore.deleteReplys(postId);
    await posts.doc(postId).delete();
    _userPosts.doc(postId).delete();
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onlyemoji/model/post.dart';
import 'package:onlyemoji/model/account.dart';
import 'package:onlyemoji/utils/authentication.dart';
import 'package:onlyemoji/utils/firestore/posts.dart';
import 'package:onlyemoji/utils/firestore/users.dart';
import 'package:onlyemoji/utils/widget_utils.dart';
import 'package:onlyemoji/view/account/edit_account_page.dart';
import 'package:onlyemoji/view/timeline/onepost_page.dart';

class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    Account me = Authentication.myAccount!;

    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
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
                                Text(me.name,style: const TextStyle(fontSize:25,fontWeight: FontWeight.bold),),
                                Text(me.comment,style: const TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide.none,
                            ),
                              onPressed: () async {
                                var result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditAccountPage()));
                                if(result == true){
                                  setState(() {
                                    me = Authentication.myAccount!;
                                  });
                                }
                              },
                              child: const Icon(Icons.edit),
                          )
                        ],
                    ),
                     ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: UserFirestore.users.doc(me.id).collection('my_posts').orderBy('created_time',descending: true).snapshots(),
                      builder: (context, snapshot) {
                        if(snapshot.hasData){
                          List<String> myPostIds = List.generate(snapshot.data!.docs.length, (index) {
                            return snapshot.data!.docs[index].id;
                          });

                          return FutureBuilder<List<Post>?>(
                            future: PostFirestore.getPostsFromIds(myPostIds),
                            builder: (context, snapshot) {
                              if(snapshot.hasData){
                                return ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      Post post = snapshot.data![index];
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                        decoration: BoxDecoration(
                                            border: index == 0 ? const Border(
                                              top: BorderSide(color: Colors.grey,width: 0.2),
                                              bottom: BorderSide(color: Colors.grey,width: 0.2),
                                            ) : const Border(
                                              bottom: BorderSide(color: Colors.grey,width: 0.2),
                                            )
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CircleAvatar(
                                              radius: 22,
                                              foregroundImage: NetworkImage(me.imagePath),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(me.name,style: const TextStyle(fontWeight: FontWeight.bold),),
                                                          Text(" - ${DateFormat('yyyy/M/d').format(post.createdTime!.toDate())}",style: const TextStyle(color: Colors.grey),),
                                                        ],
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.delete),
                                                        color: Colors.grey,
                                                        onPressed: () {
                                                          PostFirestore.deleteOnePost(me.id, post.id);
                                                          SnackBarUtils.doneSnackBar("投稿が削除されました",context);
                                                        },
                                                        padding: EdgeInsets.zero,
                                                        constraints: const BoxConstraints(),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10,),
                                                  GestureDetector(
                                                      onTap: (){
                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => OnepostPage(me,post)));
                                                      },
                                                      child: Text(post.content,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 25),))
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    }
                                );
                              }else{
                                return Container();
                              }
                            }
                          );
                        }else{
                          return Container();
                        }
                      }
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

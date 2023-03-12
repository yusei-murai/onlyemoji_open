import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:onlyemoji/model/account.dart';
import 'package:onlyemoji/model/post.dart';
import 'package:onlyemoji/utils/infra/posts.dart';
import 'package:onlyemoji/utils/infra/users.dart';
import 'package:onlyemoji/view/timeline/individual_page.dart';
import 'package:onlyemoji/view/timeline/onepost_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<String>?>(
          future: UserFirestore.getMyBlockedUserIdList(),
          builder: (context, blockedSnapshot){
            List<String> postAccountIds = [];
            if (blockedSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(), //whereNotIn: blockedSnapshot.data
              );
            }
            if(blockedSnapshot.hasData && blockedSnapshot.data!.isNotEmpty){
              return StreamBuilder<QuerySnapshot>(
                  stream: PostFirestore.posts.where('user_id', whereNotIn: blockedSnapshot.data).limit(100).snapshots(),
                  builder: (context, postSnapshot){
                    if (postSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if(postSnapshot.hasData){
                      postSnapshot.data!.docs.forEach((doc) {
                        Map<String,dynamic> data = doc.data() as Map<String,dynamic>;
                        if(!postAccountIds.contains(data['user_id']) && !blockedSnapshot.data!.contains(data['user_id'])){
                          postAccountIds.add(data['user_id']);
                        }
                      });
                      return FutureBuilder<Map<String,Account>?>(
                          future: UserFirestore.getPostUserMap(postAccountIds),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if(userSnapshot.hasData){
                              return ListView.builder(
                                  itemCount: postSnapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    Map<String,dynamic> data = postSnapshot.data!.docs[index].data() as Map<String,dynamic>;
                                    Post post = Post(
                                      id:postSnapshot.data!.docs[index].id,
                                      userId: data['user_id'],
                                      content: data['content'],
                                      createdTime: data['created_time'],
                                      updatedTime: data['updated_time'],
                                    );

                                    Account postAccount = userSnapshot.data![post.userId]!;
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
                                          GestureDetector(
                                            onTap: (){
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => IndividualPage(postAccount)));
                                            },
                                            child: CircleAvatar(
                                              radius: 22,
                                              foregroundImage: NetworkImage(postAccount.imagePath),
                                            ),
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
                                                        GestureDetector(
                                                          child: Text(postAccount.name,style: const TextStyle(fontWeight: FontWeight.bold),),
                                                          onTap: (){
                                                            Navigator.push(context, MaterialPageRoute(builder: (context) => IndividualPage(postAccount)));
                                                          },
                                                        ),
                                                        Text(" - ${DateFormat('yyyy/M/d').format(post.createdTime!.toDate())}",style: const TextStyle(color: Colors.grey),),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10,),
                                                GestureDetector(
                                                    onTap: (){
                                                      Navigator.push(context, MaterialPageRoute(builder: (context) => OnepostPage(postAccount,post)));
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
              );
            }else{
              return StreamBuilder<QuerySnapshot>(
                  stream: PostFirestore.posts.orderBy('created_time',descending: true).limit(100).snapshots(),
                  builder: (context, postSnapshot){
                    if (postSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if(postSnapshot.hasData){
                      postSnapshot.data!.docs.forEach((doc) {
                        Map<String,dynamic> data = doc.data() as Map<String,dynamic>;
                        if(!postAccountIds.contains(data['user_id'])){
                          postAccountIds.add(data['user_id']);
                        }
                      });
                      return FutureBuilder<Map<String,Account>?>(
                          future: UserFirestore.getPostUserMap(postAccountIds),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if(userSnapshot.hasData){
                              return ListView.builder(
                                  itemCount: postSnapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    Map<String,dynamic> data = postSnapshot.data!.docs[index].data() as Map<String,dynamic>;
                                    Post post = Post(
                                      id:postSnapshot.data!.docs[index].id,
                                      userId: data['user_id'],
                                      content: data['content'],
                                      createdTime: data['created_time'],
                                      updatedTime: data['updated_time'],
                                    );

                                    Account postAccount = userSnapshot.data![post.userId]!;
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
                                          GestureDetector(
                                            onTap: (){
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => IndividualPage(postAccount))).then((value) {
                                                if(mounted){
                                                  setState(() {});
                                                }
                                              });
                                            },
                                            child: CircleAvatar(
                                              radius: 22,
                                              foregroundImage: NetworkImage(postAccount.imagePath),
                                            ),
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
                                                        GestureDetector(
                                                          child: Text(postAccount.name,style: const TextStyle(fontWeight: FontWeight.bold),),
                                                          onTap: (){
                                                            Navigator.push(context, MaterialPageRoute(builder: (context) => IndividualPage(postAccount))).then((value) {
                                                              setState(() {});
                                                            });
                                                          },
                                                        ),
                                                        Text(" - ${DateFormat('yyyy/M/d').format(post.createdTime!.toDate())}",style: const TextStyle(color: Colors.grey),),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10,),
                                                GestureDetector(
                                                    onTap: (){
                                                      Navigator.push(context, MaterialPageRoute(builder: (context) => OnepostPage(postAccount,post)));
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
              );
            }
          }
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onlyemoji/model/post.dart';
import 'package:onlyemoji/model/account.dart';
import 'package:onlyemoji/utils/authentication.dart';
import 'package:onlyemoji/utils/infra/follows.dart';
import 'package:onlyemoji/utils/infra/posts.dart';
import 'package:onlyemoji/utils/infra/users.dart';
import 'package:onlyemoji/utils/function_utils.dart';
import 'package:onlyemoji/utils/widget_utils.dart';

class IndividualPage extends StatefulWidget {
  IndividualPage(this.person);
  Account person;

  @override
  State<IndividualPage> createState() => _IndividualPageState();
}

class _IndividualPageState extends State<IndividualPage> {
  bool isfollow = false;

  @override
  void initState() {
    super.initState();
    Future(() async {
      isfollow = await FollowFirestore.isFollow(widget.person.id);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Account person = widget.person;
    Account me = Authentication.myAccount!;

    return Scaffold(
      appBar: AppBarUtils.screenAppBar(context, ""),
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
                        foregroundImage: NetworkImage(person.imagePath),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(person.name,style: const TextStyle(fontSize:20,fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                      (me.id != person.id) ? OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size(30, 30),
                            backgroundColor: (isfollow == true) ? Colors.pink : Colors.white
                        ),
                        onPressed: () async {
                          if(isfollow == true){
                            var _result = await FollowFirestore.deleteFollow(person.id);
                            if (_result == true){
                              setState(() {
                                isfollow = false;
                              });
                            }
                          }else{
                            var _result = await FollowFirestore.insertFollow(person.id);
                            if (_result == true){
                              setState(() {
                                isfollow = true;
                              });
                            }
                          }
                        },
                        child: (isfollow == true) ? const Text('フォロー中',style: TextStyle(color: Colors.white),) : const Text('フォロー'),
                      ) : const SizedBox(),
                      (me.id != person.id) ? PopupMenuButton<String>(
                          onSelected: (value) async {
                            if(value == "block"){
                                if (await UserFirestore.isBlockedUser(person.id,me)==true){
                                  await UserFirestore.deleteMyBlockedUser(person.id);
                                  if (!mounted) return;
                                  SnackBarUtils.doneSnackBar("ブロックを解除しました🤚",context);

                                }else{
                                  var _result = await UserFirestore.blockUser(person.id);
                                  if(_result == true){
                                    if (!mounted) return;
                                    SnackBarUtils.doneSnackBar("このユーザをブロックしました🤚",context);
                                  }
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                }
                            }else if(value == "call"){
                              await FunctionUtils.openUri("https://docs.google.com/forms/d/e/1FAIpQLSfFXDaHIKEljWo-ULKbOoDcB_sj6_-iE1Uzs4FFCdgN4SIqhw/viewform?usp=pp_url&entry.847780658=%E7%B5%B5%E6%96%87%E5%AD%97%E3%81%A7%E6%9B%B8%E3%81%8D%E3%81%93%E3%81%BF&entry.1484185680=${me.id}&entry.1701889341=${person.id}");
                              await UserFirestore.blockUser(person.id);
                              if (!mounted) return;
                              Navigator.pop(context);
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              const PopupMenuItem<String>(
                                value: "block",
                                child: Text("このユーザをブロック"),
                              ),
                              const PopupMenuItem<String>(
                                value: "call",
                                child: Text("このユーザを通報"),
                              ),
                            ];
                          },
                      ) : const SizedBox(),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: UserFirestore.users.doc(person.id).collection('my_posts').orderBy('created_time',descending: true).snapshots(),
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
                                            children: [
                                              CircleAvatar(
                                                radius: 22,
                                                foregroundImage: NetworkImage(person.imagePath),
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
                                                            Text(person.name,style: const TextStyle(fontWeight: FontWeight.bold),),
                                                            Text(" - ${DateFormat('yyyy/M/d').format(post.createdTime!.toDate())}",style: const TextStyle(color: Colors.grey),),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10,),
                                                    Text(post.content,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 25),)
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

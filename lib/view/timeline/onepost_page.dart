import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onlyemoji/model/post.dart';
import 'package:onlyemoji/model/account.dart';
import 'package:onlyemoji/model/reply.dart';
import 'package:onlyemoji/utils/authentication.dart';
import 'package:onlyemoji/utils/infra/posts.dart';
import 'package:onlyemoji/utils/infra/users.dart';
import 'package:onlyemoji/utils/infra/replys.dart';
import 'package:onlyemoji/utils/validator/input_validator.dart';
import 'package:onlyemoji/utils/widget_utils.dart';
import 'package:onlyemoji/view/timeline/individual_page.dart';

class OnepostPage extends StatefulWidget {
  OnepostPage(this.postAccount,this.post);
  Account postAccount;
  Post post;

  @override
  State<OnepostPage> createState() => _OnepostPageState();
}

class _OnepostPageState extends State<OnepostPage> {
  TextEditingController replyController = TextEditingController();

  @override
  void dispose() {
    replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarUtils.screenAppBar(context, ""),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => IndividualPage(widget.postAccount))).then((value) {
                                  setState(() {});
                                });
                              },
                              child: CircleAvatar(
                                radius: 22,
                                foregroundImage: NetworkImage(widget.postAccount.imagePath),
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
                                            child: Text(widget.postAccount.name,style: const TextStyle(fontWeight: FontWeight.bold),),
                                          ),
                                          Text(" - ${DateFormat('yyyy/M/d').format(widget.post.createdTime!.toDate())}",style: const TextStyle(color: Colors.grey),),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10,),
                                  Text(widget.post.content,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 40),)
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        const Divider(
                          height: 0,
                          thickness: 1,
                          endIndent: 0,
                          color: Colors.black,
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width,
                            maxHeight: double.infinity,
                          ),
                          child: StreamBuilder<QuerySnapshot>(
                              stream: PostFirestore.posts.doc(widget.post.id).collection('my_replys').orderBy('created_time',descending: true).snapshots(),
                              builder: (context, snapshot) {
                                if(snapshot.hasData){
                                  List<String> thisPostReplyIds = List.generate(snapshot.data!.docs.length, (index) {
                                    return snapshot.data!.docs[index].id;
                                  });

                                  return FutureBuilder<List<Reply>?>(
                                      future: ReplyFirestore.getReplysFromIds(thisPostReplyIds),
                                      builder: (context, snapshot){
                                        if(snapshot.hasData){
                                          return ListView.builder(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemCount: snapshot.data!.length,
                                              itemBuilder: (context, index){
                                                Reply reply = snapshot.data![index];
                                                Future<Account?> replyAccount = UserFirestore.getUser(reply.userId);

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
                                                      FutureBuilder(
                                                            future: replyAccount,
                                                            builder: (context, snapshot) {
                                                              if(snapshot.hasData){
                                                                return CircleAvatar(
                                                                  radius: 22,
                                                                  foregroundImage: NetworkImage(snapshot.data!.imagePath),
                                                                );
                                                              }else{
                                                                return CircleAvatar(
                                                                  radius: 22,
                                                                );
                                                              }
                                                            }
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
                                                                    FutureBuilder(
                                                                        future: replyAccount,
                                                                        builder: (context, snapshot) {
                                                                          if(snapshot.hasData){
                                                                            return Text(snapshot.data!.name,style: const TextStyle(fontWeight: FontWeight.bold),);
                                                                          }else{
                                                                            return Text("",style: const TextStyle(fontWeight: FontWeight.bold),);
                                                                          }
                                                                        }
                                                                    ),
                                                                    Text(" - ${DateFormat('yyyy/M/d').format(reply.createdTime!.toDate())}",style: const TextStyle(color: Colors.grey),),
                                                                  ],
                                                                ),
                                                                (Authentication.myAccount!.id == reply.userId) ? IconButton(
                                                                  icon: const Icon(Icons.delete),
                                                                  color: Colors.grey,
                                                                  onPressed: () {
                                                                    ReplyFirestore.deleteOneReply(widget.post.id, reply.id);
                                                                    SnackBarUtils.doneSnackBar("返信が削除されました",context);
                                                                  },
                                                                  padding: EdgeInsets.zero,
                                                                  constraints: const BoxConstraints(),
                                                                ) : Container(),
                                                              ],
                                                            ),
                                                            const SizedBox(height: 10,),
                                                            Text(reply.content,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 25),)
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
                SizedBox(
                  height: MediaQuery.of(context).size.height/9,
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
                                  ),
                                  hintText: "返信😁",
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                return InputValidator.emojiValidator(value);
                              },
                              controller: replyController,

                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                            ),
                            onPressed: () async {
                              if(replyController.text.isNotEmpty&&
                                  InputValidator.emojiValidator(replyController.text)==null
                              ){
                                Reply newReply = Reply(
                                  userId: Authentication.myAccount!.id,
                                  parentPostId: widget.post.id,
                                  content: replyController.text,
                                );
                                var result = await ReplyFirestore.addReply(newReply);
                                if(result == true){
                                  SnackBarUtils.doneSnackBar("返信が送信されました",context);
                                  replyController.text = "";
                                  FocusScope.of(context).unfocus();
                                }
                              }
                            },
                            child: const Icon(Icons.arrow_forward),
                          )
                        ],
                      ),
                    ),

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

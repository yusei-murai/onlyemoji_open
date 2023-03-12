import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:onlyemoji/model/account.dart';
import 'package:onlyemoji/utils/authentication.dart';
import 'package:onlyemoji/utils/infra/users.dart';
import 'package:onlyemoji/utils/widget_utils.dart';

class BlockedUsers extends StatefulWidget {
  const BlockedUsers({Key? key}) : super(key: key);

  @override
  _BlockedUsersState createState() => _BlockedUsersState();
}

class _BlockedUsersState extends State<BlockedUsers> {
  @override
  Widget build(BuildContext context) {
    Account me = Authentication.myAccount!;

    return Scaffold(
      appBar: AppBarUtils.screenAppBar(context, "ブロック中のユーザ"),
      body: StreamBuilder<QuerySnapshot>(
        stream: UserFirestore.users.doc(me.id).collection('blocked_users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if(snapshot.hasData){
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index){
                  Map<String,dynamic> data = snapshot.data!.docs[index].data() as Map<String,dynamic>;
                  if(data['user_id'] != null){
                    return Slidable(
                      key: UniqueKey(),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (BuildContext context) async {
                              await UserFirestore.deleteMyBlockedUser(data['user_id']);
                              SnackBarUtils.doneSnackBar("ブロックを解除しました", context);
                            },
                            backgroundColor: Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            label: 'ブロックを解除',
                          ),
                        ],
                      ),
                      child: FutureBuilder<Account?>(
                        future: UserFirestore.getUser(data["user_id"]),
                        builder: (context, userSnapshot){
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if(userSnapshot.hasData){
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
                                    foregroundImage: NetworkImage(userSnapshot.data!.imagePath),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(userSnapshot.data!.name,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),
                                ],
                              ),
                            );
                          }else{
                            UserFirestore.deleteMyBlockedUser(data['user_id']);
                            return Container();
                          }
                        },
                      ),
                    );
                  }else{
                    return Container();
                  }
                }
            );
          }else{
            return Container();
          }
        },
      ),
    );
  }
}

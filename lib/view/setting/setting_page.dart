import 'package:flutter/material.dart';
import 'package:onlyemoji/utils/widget_utils.dart';
import 'package:onlyemoji/view/account/delete_account_page.dart';
import 'package:onlyemoji/view/setting/blocked_users_page.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarUtils.screenAppBar(context,"設定"),
      body: ListView(
        children: [
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Icon(Icons.perm_identity_outlined),
                Text(' アカウント'),
              ],
            ),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DeleteAccountPage()),
              );
            },
          ),
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Icon(Icons.pan_tool_outlined),
                Text(' ブロック中のユーザ'),
              ],
            ),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BlockedUsers()),
              );
            },
          ),
        ],
      ),

    );
  }
}

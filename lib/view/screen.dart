import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onlyemoji/model/account.dart';
import 'package:onlyemoji/provider/bottom_navigation_bar_provider.dart';
import 'package:onlyemoji/utils/authentication.dart';
import 'package:onlyemoji/utils/widget_utils.dart';
import 'package:onlyemoji/view/account/signin_page.dart';
import 'package:onlyemoji/view/setting/qr_page.dart';
import 'package:onlyemoji/view/setting/setting_page.dart';
import 'package:onlyemoji/view/timeline/home_page.dart';
import 'package:onlyemoji/view/timeline/my_page.dart';
import 'package:provider/provider.dart';
import 'package:onlyemoji/view/timeline/newpost_page.dart';

class Screen extends StatelessWidget {
  List<Widget> pageList = [
    HomePage(),
    HomePage(),
    MyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomNavigationBar = Provider.of<BottomNavigationBarProvider>(context);
    Account me = Authentication.myAccount!;

    return Scaffold(
      appBar: AppBarUtils.screenAppBar(context,''),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                radius: 22,
                foregroundImage: NetworkImage(me.imagePath),
              ),
              accountName: Text(me.name,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
              accountEmail: Text(me.comment,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
              // onDetailsPressed: () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) => Screen()),
              //   );
              // },
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Icon(Icons.qr_code),
                  Text(' QR'),
                ],
              ),
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QrPage(me)),
                );
              },
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Icon(Icons.settings_outlined),
                  Text(' 設定'),
                ],
              ),
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingPage()),
                );
              },
            ),
            ListTile(
              onTap: (){
                showDialog(
                  context: context,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      title: const Text("ログアウト"),
                      content: Text("${me.name}からログアウトしますか？"),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () => Navigator.pop(context),
                          child: const Text("キャンセル"),
                        ),
                        CupertinoDialogAction(
                            child: const Text("ログアウト"),
                            onPressed: () {
                              Authentication.signOut();
                              while (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(
                                      builder: (context) => SignInPage()));
                            }
                        ),
                      ],
                    );
                  }
                );
              },

              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Icon(Icons.logout_outlined),
                  Text(' ログアウト'),
                ],
            ),
            ),
          ],
        ),
      ),
      body: pageList[bottomNavigationBar.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap:(index){
          bottomNavigationBar.currentIndex = index;
        } ,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.public),
              label: '',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outlined),
              label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.perm_identity_outlined),
            label: '',
          ),
        ],
        currentIndex: bottomNavigationBar.currentIndex,
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewPostPage()),
            );
          }
      ),
    );
  }
}
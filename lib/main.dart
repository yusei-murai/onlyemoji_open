import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onlyemoji/model/account.dart';
import 'package:onlyemoji/provider/bottom_navigation_bar_provider.dart';
import 'package:onlyemoji/utils/authentication.dart';
import 'package:onlyemoji/utils/infra/users.dart';
import 'package:onlyemoji/view/account/signin_page.dart';
import 'package:onlyemoji/view/screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final firebaseUser = await FirebaseAuth.instance.userChanges().first;
  if(firebaseUser != null){
    await UserFirestore.authGetUser(firebaseUser.uid);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => BottomNavigationBarProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "onlyemoji",
          theme: ThemeData(
            primarySwatch: Colors.pink,
            textTheme: GoogleFonts.zenKurenaidoTextTheme(
                Theme.of(context).textTheme
            ),
          ),
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              }
              if (snapshot.hasData) {
                if(Authentication.myAccount != null){
                  return Screen();
                }
              }
              return SignInPage();
            },
          ),
        ),
    );
  }
}
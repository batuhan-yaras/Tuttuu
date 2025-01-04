

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuttuu_app/UI/core/appbar_set.dart';
import 'package:tuttuu_app/UI/product/all_colors.dart';
import 'package:tuttuu_app/login_page.dart';
import 'package:tuttuu_app/mainAppPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<bool> checkUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('rememberMe') ?? false;

    if(rememberMe){
      final user = FirebaseAuth.instance.currentUser;
      if(user != null){
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: FutureBuilder<bool>(
          future: checkUserLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData && snapshot.data == true) {
              return const MainAppPage();
            } else {
              return const LoginPage();
            }
          },
        ),
      theme: ThemeData(appBarTheme: appBarTheme(),scaffoldBackgroundColor: MainColors().appBackgroundColor,

    )
    );
  }
}






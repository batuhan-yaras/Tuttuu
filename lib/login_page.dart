import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuttuu_app/UI/core/button_theme.dart';
import 'package:tuttuu_app/UI/core/textField_theme.dart';
import 'package:tuttuu_app/UI/product/all_paddings.dart';
import 'package:tuttuu_app/UI/product/all_texts.dart';
import 'package:tuttuu_app/UI/product/artist_Q_page.dart';
import 'package:tuttuu_app/UI/product/login_signup_row.dart';
import 'package:tuttuu_app/core/forgot_password_func.dart';
import 'package:tuttuu_app/product/error_container.dart';
import 'package:tuttuu_app/product/general_popup.dart';
import 'package:tuttuu_app/signup_page.dart';

import 'UI/product/all_colors.dart';
import 'UI/product/informationPageView.dart';
import 'UI/product/title_settings.dart';
import 'core/gallery.dart';
import 'mainAppPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showSpinner = false;
  bool rememberMeLOCAL = false;
  String errorMessage = ''; // Hata mesajını saklayacak değişken
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _popUpTextFieldController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  Future<void> _setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', value);
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset(AppFeatures().appNameLogo, height: 120),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: MainPaddings().appPadding,
            child: Column(
              children: [
                const SizedBox(height: 40),
                MainTitle('GİRİŞ YAP', size: 20),
                const SizedBox(height: 20),
                TextFieldStyles(
                  controller: _emailController,
                  labelText: FieldTexts().fieldEmail,
                  iconField: Icons.email_outlined,
                  maxLength: 40,
                  fieldInputType: TextInputType.emailAddress,
                  invisibleBool: false,
                ),
                TextFieldStyles(
                  controller: _passwordController,
                  labelText: FieldTexts().fieldPassword,
                  iconField: Icons.key_outlined,
                  maxLength: 32,
                  fieldInputType: TextInputType.visiblePassword,
                  invisibleBool: true,
                ),
                // Hata mesajı için container
                if (errorMessage.isNotEmpty) ErrorContainer(text: errorMessage, color: MainColors().errorContainer),
                Row(
                  children: [
                    const Spacer(),
                    Theme(
                      data: Theme.of(context).copyWith(
                        checkboxTheme: CheckboxThemeData(
                          checkColor: WidgetStatePropertyAll(MainColors().fieldTitleColorL),
                          fillColor: WidgetStatePropertyAll(MainColors().appBackgroundColor),
                        ),
                      ),
                      child: CheckboxMenuButton(
                        value: rememberMeLOCAL,
                        onChanged: (value) {
                          setState(() {
                            rememberMeLOCAL = value!;
                          });
                          print(rememberMeLOCAL);
                        },
                        child: Text(
                          'Beni Hatırla',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: MainColors().textFieldFocusedL, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButtonRow(
                    text: FieldTexts().forgotPassword,
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return PasswordResetPage();
                          });
                    },
                  ),
                ),
                GeneralButtons(
                  buttonText: ButtonTexts().buttonLogin,
                  onPressed: () async {
                    setState(() {
                      showSpinner = true;
                      errorMessage = ''; // Hata mesajını sıfırla
                    });

                    try {
                      final userCredential = await _auth.signInWithEmailAndPassword(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                      );

                      final user = userCredential.user;

                      if (user != null) {
                        if (user.emailVerified) {
                          final userId = user.uid;
                          final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

                          if (userDoc.exists) {
                            await _setRememberMe(rememberMeLOCAL);
                            final data = userDoc.data();
                            final fullName = data?['fullName'] ?? '';
                            final isTattooArtist = data?['isTattooArtist'] ?? false;

                            if (fullName.isEmpty) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InformationPage(isTattooArtist: isTattooArtist),
                                ),
                                (route) => false,
                              );
                            } else {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const MainAppPage()),
                                (route) => false,
                              );
                            }
                          } else {
                            setState(() {
                              errorMessage = 'Kullanıcı verileri bulunamadı.';
                            });
                          }
                        } else {
                          await user.sendEmailVerification();
                          setState(() {
                            errorMessage = 'E-posta doğrulaması yapılmamış. Lütfen e-postanızı kontrol edin.';
                          });
                        }
                      }
                    } on FirebaseAuthException catch (e) {
                      print("Error code: ${e.code}");
                      print("Error message: ${e.message}");

                      setState(() {
                        if (e.code == 'invalid-credential') {
                          errorMessage = 'Girilen bilgiler yanlış. E-mail adresinizi ve şifrenizi kontrol edin.';
                        } else if (e.code == 'invalid-email') {
                          errorMessage = 'Lütfen geçerli bir E-Mail adresi girin.';
                        } else if (e.code == 'wrong-password') {
                          errorMessage = 'Şifre yanlış';
                        } else {
                          errorMessage = 'Bir hata oluştu.';
                        }
                      });
                    } catch (e) {
                      setState(() {
                        errorMessage = 'Beklenmeyen bir hata oluştu.';
                      });
                    } finally {
                      setState(() {
                        showSpinner = false;
                      });
                    }
                  },
                ),
                rowForLoginandSignup(context, ButtonTexts().signup, const ArtistQPage(), ButtonTexts().newHere),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

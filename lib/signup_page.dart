
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tuttuu_app/UI/core/button_theme.dart';
import 'package:tuttuu_app/UI/core/textField_theme.dart';
import 'package:tuttuu_app/UI/product/all_colors.dart';
import 'package:tuttuu_app/UI/product/all_paddings.dart';
import 'package:tuttuu_app/UI/product/all_texts.dart';
import 'package:tuttuu_app/UI/product/artist_Q_page.dart';
import 'package:tuttuu_app/UI/product/login_signup_row.dart';
import 'package:tuttuu_app/UI/product/main_divider.dart';
import 'package:tuttuu_app/UI/product/title_settings.dart';
import 'package:tuttuu_app/core/register_type.dart';
import 'package:tuttuu_app/product/error_container.dart';
import 'package:tuttuu_app/product/general_popup.dart';

import 'UI/core/buildPageIndicator.dart';
import 'UI/core/indicator_with_photo.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  SignupPage({super.key, required this.isTattooArtist});

  bool isTattooArtist;
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  bool  showSpinner = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool usedEmail = false;
  bool weakPassword = false;
  bool invalidEmail = false;
  bool passwordsMatch = true;
  String pageTitle = isTattooArtist
      ? "Share Your Art with the World"
      : "Discover Unique Designs for You";

  late PageController _pageController;
  int _currentIndex = 0;
  int _currentIndex2 = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(); // burada başlatılıyor
  }

  @override
  void dispose() {
    _pageController.dispose(); // kullanıldıktan sonra serbest bırakıyoruz
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index; // sayfa değiştiğinde güncelleniyor
    });
  }
  void _onPageChanged2(int index) {
    setState(() {
      _currentIndex2 = index; // sayfa değiştiğinde güncelleniyor
    });
  }

  Widget buildPhotoAndIndicator() {
    if (isTattooArtist) {
      return Column(
        children: [
          PhotoAndTextWidget(
            pageController: _pageController,
            textItems: itemsTexts,
            subtext: itemsSubTexts,
            photoItems: itemsPhotos,
            onPageChanged: _onPageChanged2,
          ),
          BuildPageIndicatorGeneral(
            currentIndex: _currentIndex2,
            items: itemsTexts2,
          ),
        ],
      );
    } else {
      return Column(
        children: [
          PhotoAndTextWidget(
            pageController: _pageController,
            textItems: itemsTexts2,
            subtext: itemsSubTexts2,
            photoItems: itemsPhotos2,
            onPageChanged: _onPageChanged,
          ),
          BuildPageIndicatorGeneral(
            currentIndex: _currentIndex,
            items: itemsTexts,
          ),
        ],
      );
    }
  }

  Widget WhichTitle(){
    if(isTattooArtist){
      return MainTitle('SIGN UP - ARTIST',size: 20);
    } else {
      return MainTitle('SIGN UP - ENTHUSIAST',size: 20);
    }
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
                MainTitle(pageTitle),
                MainDivider(40),
                SizedBox(height: 40),
                WhichTitle(),
                SizedBox(height: 20),
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
                TextFieldStyles(
                  controller: _confirmController,
                  labelText: FieldTexts().fieldPasswordAgain,
                  iconField: Icons.key_outlined,
                  maxLength: 32,
                  fieldInputType: TextInputType.visiblePassword,
                  invisibleBool: true,
                ),
                // ErrorContainer sadece şifreler eşleşmiyorsa gösterilecek
                if (!passwordsMatch)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ErrorContainer(
                      text: 'Passwords do not match. Please try again.',
                      color: MainColors().errorContainer,
                    ),
                  ),
                // Diğer hata mesajları
                if (usedEmail == true)
                  ErrorContainer(
                    text: 'Email is already in used.',
                    color: MainColors().errorContainer,
                  ),
                if (invalidEmail == true)
                  ErrorContainer(
                    text: 'Invalid E-mail Address.',
                    color: MainColors().errorContainer,
                  ),
                if (weakPassword == true)
                  ErrorContainer(
                    text: 'Password is too weak.',
                    color: MainColors().errorContainer,
                  ),
                GeneralButtons(
                  buttonText: ButtonTexts().buttonSignup,
                  onPressed: () async {
                    setState(() {
                      passwordsMatch = _passwordController.text.trim() == _confirmController.text.trim();
                    });
                    if (!passwordsMatch) return; // Şifreler eşleşmiyorsa devam etme

                    registerUser(
                      context,
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                      isTattooArtist,
                          (bool value) {
                        setState(() {
                          usedEmail = value;
                          weakPassword = false;
                          invalidEmail = false;
                        });
                      },
                          (bool value) {
                        setState(() {
                          weakPassword = value;
                          usedEmail = false;
                          invalidEmail = false;
                        });
                      },
                          (bool value) {
                        setState(() {
                          invalidEmail = value;
                          weakPassword = false;
                          usedEmail = false;
                        });
                      },
                    );
                    setState(() {
                      invalidEmail = false;
                      weakPassword = false;
                      usedEmail = false;
                    });
                  },
                ),
                rowForLoginandSignup(
                  context,
                  ButtonTexts().buttonLogin,
                  LoginPage(),
                  ButtonTexts().alreadyHave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


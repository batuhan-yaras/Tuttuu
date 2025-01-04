import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuttuu_app/product/general_popup.dart';

class PasswordResetPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  void resetPassword(BuildContext context) async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen geçerli bir e-posta adresi girin.')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Şifre sıfırlama e-postası gönderildi.')),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bu e-posta ile kayıtlı bir kullanıcı bulunmamaktadır.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GeneralPopUp(
      textTitle: 'Reset Your Password',
      textSubtitle: 'A password reset link will be sent to your email.',
      isTextField: true,
      buttonText: 'Send',
      isButton: true,
      textFieldController: emailController,
      maxLengthField: 40,
      labelTextField: 'E-mail',
      invisibleTextFieldText: false,
      fieldInputType: TextInputType.emailAddress,
      onPressed: (){
        resetPassword(context);
      },
    );
  }
}

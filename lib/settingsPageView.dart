import 'package:flutter/material.dart';
import 'package:tuttuu_app/UI/product/all_paddings.dart';
import 'package:tuttuu_app/UI/product/all_texts.dart';
import 'package:tuttuu_app/UI/product/title_settings.dart';
import 'package:tuttuu_app/account_screen.dart';
import 'package:tuttuu_app/product/privacySettingsPageView.dart';
import 'UI/product/all_colors.dart';

class SettingsPageView extends StatefulWidget {
  const SettingsPageView({super.key});

  @override
  State<SettingsPageView> createState() => _SettingsPageViewState();
}

class _SettingsPageViewState extends State<SettingsPageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(AppFeatures().appNameLogo, height: 120,),
        centerTitle: true,
      ),
      body: Padding(
        padding: MainPaddings().appPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: MainTitle('Ayarlar',size: 20),
            ),
            ListTileWithCard(leadingButton: Icons.notifications, title: 'Bildirimler',onTap: (){},),
            SizedBox(height: 10,),
            ListTileWithCard(leadingButton: Icons.visibility_off, title: 'Gizlilik',onTap: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PrivacySettingsPage())
              );
            },),
            SizedBox(height: 10,),
            ListTileWithCard(leadingButton: Icons.lock, title: 'Güvenlik',onTap: (){},),
            SizedBox(height: 10,),
            ListTileWithCard(leadingButton: Icons.support, title: 'Destek ve Yardım',onTap: (){},),
            SizedBox(height: 10,),
            ListTileWithCard(leadingButton: Icons.thumb_up, title: 'Uygulamayı Değerlendir',onTap: (){},),
          ],
        ),
      ),
    );
  }
}


class ListTileWithCard extends StatelessWidget {
  const ListTileWithCard({
    super.key,
    this.leadingButton,
    required this.title,
    this.trailingButton = Icons.navigate_next,
    this.onTap,
    this.showLeading = true,
    this.showSwitch = false,
    this.switchValue = false,
    this.onSwitchChanged, this.subtitleText = '', this.showSubtitle = false,
  });

  final IconData? leadingButton;
  final bool showLeading;
  final String title;
  final bool showSubtitle;
  final String subtitleText;
  final IconData trailingButton;
  final onTap;
  final bool showSwitch;
  final bool switchValue;  // Switch'in mevcut durumu
  final ValueChanged<bool>? onSwitchChanged;  // Switch'in durum değişikliği için callback

  @override
  Widget build(BuildContext context) {
    return Card(
      color: MainColors().appBackgroundColor,
      child: ListTile(
        subtitle: showSubtitle ? Text(subtitleText,style: TextStyle(color: MainColors().fieldLabelColorLighter,fontSize: 12),) : null,
        leading: showLeading ? Icon(leadingButton) : null,
        title: Text(title),
        trailing: showSwitch
            ? Switch(
          value: switchValue,
          onChanged: onSwitchChanged,
        )
            : Icon(trailingButton),
        onTap: onTap,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tuttuu_app/UI/core/buildPageIndicator.dart';
import 'package:tuttuu_app/UI/core/button_theme.dart';
import 'package:tuttuu_app/UI/core/indicator_with_photo.dart';
import 'package:tuttuu_app/UI/product/all_colors.dart';
import 'package:tuttuu_app/UI/product/all_paddings.dart';
import 'package:tuttuu_app/UI/product/all_texts.dart';
import 'package:tuttuu_app/UI/product/title_settings.dart';
import 'package:tuttuu_app/signup_page.dart';

class ArtistQPage extends StatefulWidget {
  const ArtistQPage({super.key});

  @override
  State<ArtistQPage> createState() => _ArtistQPageState();
}

bool isTattooArtist = false;
class _ArtistQPageState extends State<ArtistQPage> {

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MainColors().appBackgroundColor,
        title: Text(
          QuestionTexts().isArtist,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,color: MainColors().fieldTitleColorL,
          ),
        ),
      ),
      body: Padding(
        padding: MainPaddings().appPadding,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MainTitle('Enthusiast',size: 24),
              PhotoAndTextWidget(pageController: _pageController, textItems: itemsTexts2, subtext: itemsSubTexts2, photoItems: itemsPhotos2, onPageChanged: _onPageChanged2),
              BuildPageIndicatorGeneral(currentIndex: _currentIndex2, items: itemsTexts2),
              GeneralButtons(buttonText: "Here to find my dream tattoo.", width: double.infinity,fontSize: 14,onPressed: (){
                setState(() {
                  isTattooArtist = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupPage(isTattooArtist: isTattooArtist,)),
                );
              },),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 7),
                child: Divider(color: Colors.black54,height: 10,thickness: 0.6,),
              ),
              MainTitle('Artist',size: 24),
              PhotoAndTextWidget(pageController: _pageController, textItems: itemsTexts, subtext: itemsSubTexts, photoItems: itemsPhotos, onPageChanged: _onPageChanged),
              BuildPageIndicatorGeneral(currentIndex: _currentIndex, items: itemsTexts),
              GeneralButtons(buttonText: "I’m a tattoo artist based in a studio.",width: double.infinity,fontSize: 14,onPressed: (){
                setState(() {
                  isTattooArtist = true;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupPage(isTattooArtist: isTattooArtist,)),
                );
              },),
          
            ],
          ),
        ),
      ),
    );
  }

}

import 'package:flutter/material.dart';
import 'package:tuttuu_app/UI/product/title_settings.dart';
import 'package:tuttuu_app/core/image_services.dart';
import 'package:tuttuu_app/product/CategoryDetailScreen.dart';

class FavouritePageView extends StatefulWidget {
  const FavouritePageView({super.key, required this.userId});
  final String userId;

  @override
  State<FavouritePageView> createState() => _FavouritePageViewState();
}

class _FavouritePageViewState extends State<FavouritePageView> {
  late Stream<List<String>> favourites;

  @override
  void initState() {
    super.initState();
    favourites = ImageService().getFavouritePhotos(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MainTitle('Favoriler',size: 22),
      ),
      body: StreamBuilder<List<String>>(
        stream: favourites, // Burada doğrudan sınıf seviyesindeki stream kullanılıyor
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Favorileri yüklerken bir sorun oldu.'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('Henüz favorilenmiş bir dövme yok.'));
          } else if (snapshot.hasData) {
            return CategoryDetailScreen(
              showAppBar: false,
              images: snapshot.data!, category: '',
            );
          } else {
            return const Center(child: Text('Beklenmedik hata!'));
          }
        },
      ),
    );
  }
}


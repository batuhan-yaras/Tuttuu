import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tuttuu_app/UI/core/button_theme.dart';
import 'package:tuttuu_app/UI/core/studio_popup.dart';
import 'package:tuttuu_app/UI/product/all_colors.dart';
import 'package:tuttuu_app/UI/product/all_paddings.dart';
import 'package:tuttuu_app/core/StudioButtonOnMap.dart';
import 'package:tuttuu_app/product/CategoryDetailScreen.dart';
import 'package:tuttuu_app/product/ProfilePageView.dart';

import 'core/user_data_services.dart';
// TODO: İzin vermesek de map geliyor. Onu düzelt.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}
class _MapScreenState extends State<MapScreen> {
  bool showSpinner = false;
  LatLng _currentPosition = const LatLng(41.0369, 28.9850);
  bool _isLoading = true;
  LatLng? _studioPosition;
  bool _hasPermission = false;
  bool _isMyStudioClicked = false;
  final MapController _mapController = MapController();
  List<LatLng> _userStudioLocations = [];
  final String studioId = FirebaseFirestore.instance.collection('studios').doc().id;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchUserStudioLocations();
    _checkIfTattooArtistAndFetchLocation();
  }

  // Eğer kullanıcı artistse bu fonksiyon stüdyosunu init içerisinde çalıştıracak.
  Future<void> _checkIfTattooArtistAndFetchLocation() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final isTattooArtist = userDoc['isTattooArtist'] as bool? ?? false;

        if (isTattooArtist) {
          _getStudioLocation();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  Future<void> _fetchUserStudioLocations() async {
    try {
      // Mevcut kullanıcının ID'sini alıyoruz
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Firebase'den 'users' koleksiyonundaki tüm belgeleri alıyoruz
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('isTattooArtist', isEqualTo: true) // sadece tattoo artist olanları al
          .get();

      List<LatLng> userLocations = [];

      for (var doc in snapshot.docs) {
        // Kullanıcı dokümanındaki studioLocation'ı alıyoruz
        String userId = doc.id;  // Kullanıcı ID'si
        GeoPoint? geoPoint = doc['studioLocation'];

        // Eğer studioLocation varsa ve bu kullanıcı mevcut kullanıcı değilse
        if (geoPoint != null && userId != currentUserId) {
          userLocations.add(LatLng(geoPoint.latitude, geoPoint.longitude));
        }
      }

      setState(() {
        // Kullanıcıların studioLocation'larını içeren listeyi state'e set ediyoruz
        _userStudioLocations = userLocations;
      });
    } catch (e) {
      // Hata olursa hata mesajını konsola yazdırıyoruz
      print("Error fetching user locations: $e");
    }
  }



  final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
  Future<void> _determineStudioLocation() async {
    LatLng position = _mapCenter;
    setState(() {
      _studioPosition = LatLng(position.latitude, position.longitude);
    });
    await _saveStudioLocation();
  }
  Future<void> _getStudioLocation() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // "studioLocation" alanının var olup olmadığını kontrol et
        if (userDoc.data() != null && userDoc.data()!.containsKey('studioLocation')) {
          final geoPoint = userDoc['studioLocation'] as GeoPoint?;

          // studioLocation var ise
          if (geoPoint != null) {
            setState(() {
              _studioPosition = LatLng(geoPoint.latitude, geoPoint.longitude);
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Stüdyonuzun konumunu 'Stüdyom' butonu ile belirtin!")),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }


  Future<void> _getCurrentLocation() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      setState(() {
        showSpinner = true;
        _hasPermission = true;
      });

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _mapController.move(_currentPosition, 12.0); // Haritayı yeni konuma taşır
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No permission!')),
      );
    }
    setState(() {
      showSpinner = false;
    });
  }


  Future<void> _saveStudioLocation() async {
    if (_studioPosition == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'studioLocation': GeoPoint(
          _studioPosition!.latitude,
          _studioPosition!.longitude,
        ),
        'studioId': studioId, // Benzersiz studioId
      });


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stüdyo konumu kaydedildi!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  Future<void> onMarkerTapped(LatLng position) async {
    try {
      // Firestore'da 'users' koleksiyonundaki 'studioLocation' ile tıklanan koordinatı karşılaştırıyoruz
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('studioLocation', isEqualTo: GeoPoint(position.latitude, position.longitude))
          .get();

      if (snapshot.docs.isNotEmpty) {
        double averageRating = 0.0;
        final targetUserId = snapshot.docs.first.id;

        double rating = await UserDataService().calculateAverageRating(targetUserId);
        setState(() {
          averageRating = rating;
        });
        // Kullanıcı verilerini alıyoruz
        final userData = await UserDataService().fetchUserData(targetUserId);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return StudioPopUp(
              fullName: userData!['fullName'],
              userId: targetUserId,
              userData: userData,
              aboutMe: userData!['aboutMe'],
              onPressed: () async {
                await isStudioClicked(position);},
              averageRating: averageRating,
            );
          },
        );

      } else {
        // Eşleşen stüdyo bulunmazsa kullanıcıya mesaj gösterilir
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Studio not found!")),
        );
      }
    } catch (e) {
      print("Error fetching studio: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> isStudioClicked(LatLng position) async {
    try {
      // Firestore'da 'users' koleksiyonundaki 'studioLocation' ile tıklanan koordinatı karşılaştırıyoruz.
      // Ancak dikkat: Firestore'da GeoPoint sorgulaması tam eşleşme gerektirir ve bu her zaman işe yaramayabilir.
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('studioLocation', isEqualTo: GeoPoint(position.latitude, position.longitude))
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Eşleşen bir stüdyo bulundu
        final studioId = snapshot.docs.first['studioId'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePageView(
              studioId: studioId, // ProfilePageView'e studioId parametre olarak gönderilir
            ),
          ),
        );
      } else {
        // Eşleşen stüdyo bulunmazsa kullanıcıya mesaj gösterilir
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Studio not found!")),
        );
      }
    } catch (e) {
      print("Error fetching studio: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }


  LatLng _mapCenter = LatLng(41.0369, 28.9850);
  void _onMapPositionChanged(
      LatLng center,
      bool zoom,
      ) {
    setState(() {
      _mapCenter = center; // Haritanın ortasındaki yeni koordinatlar
    });
  }


  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              onPositionChanged: (position, zoom) => _onMapPositionChanged(position.center, zoom),
              initialCenter: _currentPosition,
              initialZoom: 12.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              openStreetMapTileLayer,
              MarkerLayer(
                markers: [
                  // Mevcut konum marker'ı
                  Marker(
                    point: _currentPosition,
                    child: const Icon(Icons.my_location, color: Colors.blue, size: 25),
                  ),
                  // Diğer kullanıcıların studioLocation'ları
                  for (var location in _userStudioLocations)
                    Marker(
                      point: location,
                      width: 40,
                      height: 40,
                      child: IconButton(padding: const EdgeInsets.only(bottom: 10),
                        onPressed: () {
                          onMarkerTapped(location);
                          },
                        icon: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ),
                  if (_studioPosition != null)
                    Marker(
                      point: _studioPosition!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.home,
                        size: 40,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),

            ],
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(_isMyStudioClicked)
                Padding(
                  padding: MainPaddings().mainButtonPadding,
                  child: IconButton(
                      onPressed: (){
                        setState(() {
                          _isMyStudioClicked = false;
                        });
                      },
                      icon: Icon(Icons.cancel,color: MainColors().fieldLabelColorL,size: 30,)),
                ),
              Expanded(child: SizedBox()),
              Padding(
                padding: MainPaddings().mainButtonPadding,
                child: IconButton(
                    onPressed: (){_mapController.move(_currentPosition, 12);},
                    icon: Icon(Icons.assistant_navigation,color: MainColors().fieldLabelColorL,size: 30,)
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ArtistButtons(
              text: 'Stüdyom',
              onPressed: () {
                setState(() {
                  _isMyStudioClicked = true;
                });
              },
            ),
          ),
          if (_isMyStudioClicked)
            Column(
              children: [
                Expanded(child: SizedBox(),),
                 const Padding(
                   padding: EdgeInsets.only(top: 60),
                   child: Icon(
                    Icons.place,
                    size: 50,
                    color: Colors.red,),
                 ),
                const Expanded(child: SizedBox(),),
                Center(
                  child: GeneralButtons(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Emin misin?"),
                            content: Text("Burası stüdyonuzun konumu olarak işaretlensin mi?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                  setState(() {
                                    _isMyStudioClicked = false;
                                  });
                                },
                                child: Text("Hayır"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await _determineStudioLocation();
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _isMyStudioClicked = false;
                                  });
                                },
                                child: Text("Evet"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    buttonText: 'Kaydet',

                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}


TileLayer get openStreetMapTileLayer => TileLayer(
  urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
  retinaMode: true,
);

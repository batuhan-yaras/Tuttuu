import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tuttuu_app/UI/core/button_theme.dart';
import 'package:tuttuu_app/UI/core/gender_selector_styles.dart';
import 'package:tuttuu_app/UI/core/textField_theme.dart';
import 'package:tuttuu_app/UI/product/all_paddings.dart';
import 'package:tuttuu_app/UI/product/artist_Q_page.dart';
import 'package:tuttuu_app/UI/product/title_settings.dart';
import '../../mainAppPage.dart';
import '../core/date_picker_styles.dart';

// ToDo Stüdyo belgesi yükleme işlemi ayarlanacak. Telefon numarası yerine email gelecek (Kayıt olma telefon numarasıyla olacak).
// ToDo Mail daha sonra değiştirilemez popup.

class InformationPage extends StatefulWidget {
  InformationPage({super.key,required this.isTattooArtist});
  bool isTattooArtist;
  @override
  State<InformationPage> createState() => _InformationPageState();
}


class _InformationPageState extends State<InformationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController studioNameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedGender = 'Male';

  Widget WhichTitle() {
    if (widget.isTattooArtist == true) {
      return MainTitle('Artist Information', size: 20);
    } else {
      return MainTitle('User Information', size: 20);
    }
  }

  final _auth = FirebaseAuth.instance;


  int calculateAge(DateTime birthDate){
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;

    if(today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)){
        age--;
    }
    return age;
  }
 late final int age;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: WhichTitle(),
        centerTitle: true,
      ),
      body: Padding(
        padding: MainPaddings().appPadding,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Form doğrulaması için anahtar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                MainTitle('Please fill in your details'),
                const SizedBox(height: 10),
                TextFieldStyles(
                  controller: nameController,
                  fieldInputType: TextInputType.name,
                  invisibleBool: false,
                  labelText: 'Full Name*',
                  maxLength: 30,
                  iconField: Icons.person,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Full Name is required.';
                    } else if (value.length < 3) {
                      return 'Full Name must be at least 3 characters.';
                    }
                    return null;
                  },
                ),
                if (widget.isTattooArtist)
                  TextFieldStyles(
                    controller: studioNameController,
                    fieldInputType: TextInputType.name,
                    invisibleBool: false,
                    labelText: 'Studio Name*',
                    maxLength: 30,
                    iconField: Icons.store,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Studio Name is required.';
                      } else if (value.length < 3) {
                        return 'Studio Name must be at least 3 characters.';
                      }
                      return null;
                    },
                  ),
                DatePickerStyles(
                  iconField: Icons.calendar_month,
                  selectedDate: _selectedDate,
                  onDateSelected: (pickedDate) {
                    setState(() {
                      _selectedDate = pickedDate;
                      age = calculateAge(pickedDate);
                    });
                  },
                ),
                TextFieldStyles(
                  controller: phoneController,
                  fieldInputType: TextInputType.phone,
                  invisibleBool: false,
                  labelText: 'Phone Number',
                  maxLength: 10,
                  iconField: Icons.phone,
                ),
                GenderSelectorStyles(
                  selectedGender: _selectedGender,
                  onGenderChanged: (newGender) {
                    setState(() {
                      _selectedGender = newGender;
                    });
                  },
                ),
                const SizedBox(height: 10),
                Center(
                  child: GeneralButtons(
                    buttonText: 'Submit',
                    onPressed: () async {
                      if (_formKey.currentState?.validate() != true) {
                        return; // Form geçerli değilse işleme devam etme
                      }
                      if (_selectedDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a birth date.')),
                        );
                        return;
                      }

                      final userId = _auth.currentUser?.uid;
                      if (userId != null) {
                        final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

                        try {
                          await userRef.update({
                            'fullName': nameController.text.trim(),
                            'gender': _selectedGender,
                            'birth': _selectedDate,
                            'phoneNumber': phoneController.text.trim(),
                            'age': age.toString(),
                            if (widget.isTattooArtist == true)
                              'studioName': studioNameController.text.trim(),
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Information saved successfully!')),
                          );

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const MainAppPage()),
                                (route) => false,
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('An error occurred: $e')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No user session found.')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




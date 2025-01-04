import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuttuu_app/UI/product/all_colors.dart';
import 'package:tuttuu_app/UI/product/all_paddings.dart';

class ErrorContainer extends StatelessWidget {
  const ErrorContainer({super.key, required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(6)), // Köşeleri yuvarlama
        ),
        child: Center(
          child: Row(
            children: [
              Icon(Icons.error, color: Colors.red,),
              SizedBox(width: 10,),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(color: MainColors().errorColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
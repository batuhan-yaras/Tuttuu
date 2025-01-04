import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'all_colors.dart';

Widget MainDivider(double height){
  return Divider(
    height: height,
    color: MainColors().fieldLabelColorLighter,
    thickness: 0.8,
  );
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../product/all_colors.dart';

AppBarTheme appBarTheme() => AppBarTheme(
      color: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: true,
  surfaceTintColor: MainColors().appBackgroundColor
    );

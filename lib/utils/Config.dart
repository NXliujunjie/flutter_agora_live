import 'package:flutter/material.dart';

const APP_ID = '1c1a0f61d9cc4ca68c9d1ad880ef99f3';

class PhoneSize {
  double width;
  double height;
  PhoneSize(BuildContext context) {
    final size =MediaQuery.of(context).size;
    this.width = size.width;
    this.height = size.height;
  }
}


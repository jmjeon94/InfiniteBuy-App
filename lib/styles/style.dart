import 'dart:io';

import 'package:flutter/material.dart';

const mainColor = Colors.deepPurple;
// const mainColor = Color(0xFF561D93);

const fgColor = Color(0xff18171d); // black-grey(toss-foreground)
const bgColor = Color(0xff0a090e); // black-grey(toss-background)

const fontColorTitleWhite = Color(0xffFDFDFC);
const fontColorWhite = Color(0xffE1E1E1);
const fontColorGrey = Color(0xffC6C6C8);
const fontColorTitleGrey = Color(0xff62626C);
const fontColorBlue = Color(0xff5175D7);
const fontColorWarning = Colors.deepOrangeAccent;
const fontColorMain = mainColor;

var textStyleWarning = TextStyle(
    fontStyle: FontStyle.italic,
    color: fontColorWarning,
    fontSize: Platform.isIOS ? 12 : 11);

const btnColorPurple = mainColor;
const btnColorGrey = Color(0xff2C2C34);

// const btnColorBlue = Color(0xff4880EE);
// const btnColorGrey = Color(0xff2C2C34);

var boxDecoration =
    BoxDecoration(color: fgColor, borderRadius: BorderRadius.circular(20));

const iconColorSelected = Color(0xffE1E1E1);
const iconColorUnSelected = Color(0xff4D4D59);

const List<Color> circularChartColorList = [
  mainColor,
  fontColorTitleGrey,
  fontColorGrey
];

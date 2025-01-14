import 'dart:core';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application_1/Components/styles.dart';

class LinkSpan extends TextSpan {
  late final Uri? _url;
  LinkSpan({
    required String link,
    required String text,
    required VoidCallback onTap,
  }) : super(
          text: text,
          style: bodyLinkTextStyle,
          recognizer: TapGestureRecognizer()..onTap = onTap,)
          {
            try{
              Uri temp = Uri.parse(link);
              _url = temp;
            }
            catch(e){
              print("Link doesnt have valid url..");
              _url = null;
            }
          }
  
  
  void openURL(){
    // ToDo: Implement method for opening URLS in default browser!
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ArticleWebsiteComponents/article_component.dart';

class TitleComponent extends ArticleComponent{
  late int _size;
  late InlineSpan _text;

  TitleComponent({required InlineSpan text, required int size}){
    _size = size;
    _text = text;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: RichText(text: _text,),
    );
  }

  // To update size of heading, newContent == [Strign text, int size]
  /*
  @override
  bool updateContent(List<dynamic> newContent) {
    int len = newContent.length;
    if(len > 2) throw Exception("ERROR: newContent-list need to be formatted like this for Title-compoenent: [Strign text, int size]");

    len == 2 ? _size = newContent.last:"";
    _text = newContent.first;
    return true;
  }
  */

  int getSize(){
    return _size;
  }

}
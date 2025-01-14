

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ArticleWebsiteComponents/article_component.dart';

/*
 CONTAINS PICTURE AND CAPTION, IF TEXT IS NOT EMPTY
*/

class Pic extends ArticleComponent{
  late Uri _linkToPic;
  late InlineSpan _text;
  
  Pic({super.key, required InlineSpan text, required Uri linkToPic}){
    _linkToPic = linkToPic;
    _text = text;
  }

  Uri get linkToPic => _linkToPic;

  void setText(InlineSpan text){
    _text = text;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Column(
        children: [
          createImg(_linkToPic.toString()),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0,),
            child: RichText(text: _text),
          )
        ],
      ),
    );
  }

  // Format newContent == [Uri linkToPic, String text]
  @override
  bool updateContent(List<dynamic> newContent){
    int len = newContent.length;
    if(len > 2) throw Exception("ERROR: newContent-list need to be formatted like this for Pic-compoenent: [Uri linkToPic, Strign text]");
    
    newContent.first != null ? _linkToPic = newContent.first: "";
    newContent.last != null ? _text = newContent.last: "";
    return true;
  }

}

Widget createImg(String url){
  return Container(
    padding: EdgeInsets.all(2.0),
    decoration: const BoxDecoration(
      color: Colors.black, 
      borderRadius: BorderRadius.all(Radius.circular(4.0))),
    //color: Colors.black45,
    child: Image.network(url,)
  );
}
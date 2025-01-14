import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/ArticleWebsiteComponents/article_component.dart';
import 'package:flutter_application_1/ArticleWebsiteComponents/paragraph.dart';
import 'package:flutter_application_1/ArticleWebsiteComponents/pic.dart';
import 'package:flutter_application_1/Components/url_handler.dart';

class Article {
  late Uri _link;
  String _title = "NO TITLE";
  DateTime? _publishedDate;
  late List<String> _authors = [];
  late List<Widget> _content = [];

  Uri get link => _link;
  String get title => _title;
  List<Widget> get content => _content;
  List<String> get author => _authors;

  bool equals(Object o) {
    if (o is Article) {
      return _link == o._link;
    }
    return false;
  }

  Article({required Uri link, required List<Widget> content, required String title, required List<String> authors, DateTime? publishedDate}) {
    publishedDate == null ? _publishedDate = null : _publishedDate = publishedDate;
    _link = link;
    _title = title;
    _content = content;
    _authors = authors;

  }

  void addContent(Widget c){
    _content.add(c);
  }

  void addAllContent(List<Widget> c){
    _content.addAll(c);
  }

  Uri? getFirstPic(){
    Widget pic = content.firstWhere((element) => element is Pic, orElse: () => Pic(text: TextSpan(), linkToPic: Uri.parse("images/Mouse_pic.jpg")));
    if(pic != null){
      return (pic as Pic).linkToPic;
    }
  }

  String getFirstText(){
    String subtitle = "";
    for(Widget comp in content){
      if(comp is Paragraph){
        subtitle += comp.text.toPlainText();
      }
      else if(comp is BlockquoteComponent){
        subtitle += comp.text.toPlainText();
      }
      if(subtitle.split(" ").length > 25) break;
      
    }
    return subtitle.split(" ").getRange(0, 25).join(" ") + "...";
  }

  String toJson() {
    final jsonData = {
      'title': _title,
      'link': _link.toString(),
      'authors': _authors,
      'content': _content,
    };
    return jsonEncode(jsonData);
  }
}

import 'dart:core';

import 'package:flutter_application_1/Components/article.dart';

class ArticleCollection {
  late String _title;
  final List<Article> _articles = [];

  List<Article> get articles => _articles;

  ArticleCollection({required String title}) {
    _title = title;
  }

  void addArticle(Article article){
    //article.getContentFromURL();
    _articles.add(article);
    //TODO: Add article to Google Sheet
  }

  void removeArticle(Article article){
    _articles.remove(article);
    //TODO: remove article to Google Sheet
  }

  bool containsArticle(Article article){
    for (var a in _articles) {
      if(article.equals(a)){
        return true;
      }
    }
    return false;
  }
  //TODO: Check article in Google Sheet?

  int countArticle(){
    return _articles.length;
  }

}

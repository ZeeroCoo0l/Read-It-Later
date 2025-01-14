import 'package:flutter/material.dart';
import 'package:flutter_application_1/Components/article_collection.dart';
import 'package:flutter_application_1/Screens/my_articles_page.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ArticleCollection articleCollection = ArticleCollection(title: "My Articles");


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Article Reader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyArticlesPage(collection: articleCollection),
      //home: ArticlePage(article: article), 
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_application_1/ArticleWebsiteComponents/pic.dart';
import 'package:flutter_application_1/ArticleWebsiteComponents/title.dart';
import 'package:flutter_application_1/ArticleWebsiteComponents/article_component.dart';
import 'package:flutter_application_1/Components/article.dart';
import 'package:flutter_application_1/Components/create_text_components.dart';
import 'package:go_router/go_router.dart';

class ArticlePage extends StatefulWidget {
  final Article article;

  const ArticlePage({super.key, required this.article});
  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  Article? _article;
  

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    _article = widget.article; 

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(_article!.title),//const Text("How to right click on Mac like you want to"),
          leading: IconButton(
              onPressed: () {
                //Navigator.push(context, MaterialPageRoute(builder: (context) => const MyArticlesPage()));
                Navigator.pop(context);
              }, 
              icon: Icon(Icons.adaptive.arrow_back)),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(Icons.adaptive.more),
                )
              ],
        ),
        body: SizedBox(
            height: size.height,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 64.0),
              children: writeOutContent(_article!)
            
            ),
          ),
        );
  }

  List<Widget> writeOutContent(Article article){
    List<Widget> content = [];//[const SizedBox(height: 32)];
    content.addAll(article.content);
    content.add(const SizedBox(height: 128,));

    if(content.first is TitleComponent){
      
    }

    return content;
  }
  

  /*
  List<Widget> writeOutContent(Article article) {
    List<Widget> content = [];

    content.add(const SizedBox(height: 32,));

    String previousComponentType = "";
    for(ArticleComponent component in article.content){
      String componentType = component.runtimeType.toString().toLowerCase();

      if(previousComponentType.trim().isEmpty){
      }
      else if(componentType == previousComponentType){
        content.add(SizedBox(height: 12,));
      }
      else{
        content.add(SizedBox(height: 24,));
      }
      previousComponentType = componentType;

      switch (componentType){
        case "paragraph":
          if(component.textContent != null){
            content.add(createParagraph(component.textContent!));
          }
          break;
        case "orderedlistparagraph":
          if(component.textContent != null){
            content.add(createOrderedList(component.textContent!));
          }
          break;
        case "pic":
          if((component as Pic).linkToPic != null){
            content.add(createImg(component.linkToPic.toString()));
          }
          break;
        case "titlecomponent":
          if(component.textContent != null){
            content.add(createTitle(component.textContent!, (component as TitleComponent).getSize()));
          }
          break;
        case "blockquote":
          if(component.textContent != null){
            content.add(createBlockquote(component.textContent!));
          }
          break;
      }
    }
    content.add(const SizedBox(height: 128,));
    return content;
  }
  */
}
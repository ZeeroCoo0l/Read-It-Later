import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ArticleWebsiteComponents/link_span.dart';
import 'package:flutter_application_1/Components/article.dart';
import 'package:flutter_application_1/ArticleWebsiteComponents/paragraph.dart';
import 'package:flutter_application_1/ArticleWebsiteComponents/pic.dart';
import 'package:flutter_application_1/ArticleWebsiteComponents/title.dart';
import 'package:flutter_application_1/ArticleWebsiteComponents/article_component.dart';
import 'package:flutter_application_1/Components/styles.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:source_span/src/file.dart';

/*
OBS!
Before you can run extraction-methods, 
you need to run:
1. setLink(Uri link).
*/

class ParserHtml {
  Uri? _link;
  //List<dynamic> parsedContent = [];
  dom.Document? htmlDocument;

  ParserHtml({required Uri? link}) : _link = link;

  Future<Article?> createArticle() async {
    // Load HTML before parsing
    bool done = await _getHTML();
    if (!done) throw Exception("ERROR: Couldn't find htmlDocument");

    // PARSING
    String title = extractTitle();
    List<Widget> content = [];
    List<String> authors = [];

    _extractArticleContent(content);

    //title = title.replaceAll("#", "");

    if (_link != null) {
      Article article = Article(
          link: _link!,
          content: content,
          authors: authors,
          title: title.trim(),
          publishedDate: null);
      return article;
    }
    return null;
  }

  void setLink(Uri link) {
    _link = link;
  }

  Future<bool> _getHTML() async {
    if (_link == null) {
      print("_link is null inside the html_parser");
      return false;
    }
    final response = await http.get(_link!);
    if (response.statusCode == 200) {
      // Remove footer from html-code!
      String adjustedResponse = response.body.replaceAll(
        RegExp(r'<footer[^>]*>.*?<\/footer>', dotAll: true),
        '',
      );
      print("Statuscode == 200");
      htmlDocument = parse(adjustedResponse);

      return true;
    }
    return false;
  }

  String extractTitle() {
    if (htmlDocument != null) {
      final titleElement = htmlDocument!.querySelector('title');
      return titleElement != null ? titleElement.text.trim() : '';
    }
    return "";
  }

  dom.Element? _getArticleElement() {
    final possibleContainers = [
      'article',
      'main',
      'main-content',
      '.post-content',
      '.blog-body',
      '#content',
      '#main',
      '.article__main-container',
      '.article',
      'body',
    ];
    if (htmlDocument == null) {
      throw Exception(
          'HTML document is null. Did you forget to await getHTML()?');
    }

    dom.Element? articleElement;
    for (String selector in possibleContainers) {
      articleElement = htmlDocument!.querySelector(selector);

      if (articleElement != null) {
        return articleElement;
      }
    }
    return articleElement;
  }

  void _extractArticleContent(List<Widget> parsedContent) {
    dom.Element? element = _getArticleElement();
    element == null ? throw Exception("ERROR: Article-element is null!") : "";
    List<dom.Element> elements = [];
    if (element == null) {
      elements.addAll(htmlDocument!
          .querySelectorAll('body')); //'body, div, section, article, p'
    } else {
      elements.addAll(element.querySelectorAll(
        'p, h1, h2, h3,h4, ol, ul, img, figcaption, picture, blockquote',
      ));
    }
    if (elements.isEmpty) {
      return;
    }

    // PARSE ALL CONTENT IN HTML
    for (var element in elements) {
      if (element.localName == 'blockquote') {
        _parseBlockQuote(element, parsedContent);
      } else if (element.localName == 'p') {
        //print("ADDED PARAGRAPH");
        if (element.parent?.localName == 'blockquote' ||
            element.parent?.localName == "li") continue;
        _parseParagraph(parsedContent, element);

        //element.text.trim().isNotEmpty? parsedContent.add(element.text.trim()) : '';
      } else if (element.localName == 'span') {
        if (element.parent!.localName == 'p') continue;
        _parseSpan(parsedContent, element);
      } else if (['h1', 'h2', 'h3', 'h4'].contains(element.localName)) {
        _parseHeaders(element, parsedContent);
      } else if (element.localName == 'ol') {
        _parseOL(element, parsedContent);
      } else if (element.localName == 'ul') {
        _parseUL(element, parsedContent);
      } else if (element.localName == 'img') {
        if (element.parent!.parent!.localName == 'figure')
          continue; // To prevent duplicates.
        _parseImg(element, parsedContent);
      } else if (element.localName == 'picture') {
        _parsePicture(element, parsedContent);
      } else if (element.localName == 'figure') {
        // Find picture --> parseImg()
        parseFigure(element, parsedContent);

        // or Find Img --> parseImg()
      } else if (element.localName == "figcaption") {
        _parseFigCaption(element, parsedContent);
      }
    }
  }

  void _parseFigCaption(dom.Element element, List<Widget> parsedContent) {
    if (element.text.trim().isEmpty) return;
    Widget lastComponent = parsedContent.last;
    if (lastComponent is Pic) {
      lastComponent.updateContent(
          [null, TextSpan(text: element.text, style: figCaptionTextStyle)]);
    }
  }

  void _parsePicture(dom.Element element, List<Widget> parsedContent) {
    if (element.parent!.localName == 'figure') return; // To prevent duplicates.

    dom.Element? child = element.querySelector('img');
    if (child == null) return;

    if (_parseImg(child, parsedContent)) return;

    // If <img> has no src, try <source>
    String? url = "";
    dom.Element? sourceChild = element.querySelector('source');
    if (sourceChild != null) {
      url = sourceChild.attributes['srcset']?.split(',').first.trim();
    }

    if (url == null) return; // Skip image-url if it still null

    // Remove size-constant
    List<String> temp = url.split(" ");
    if (temp.isNotEmpty && temp.length <= 2) {
      url = temp.first;
    }
    Pic pic = Pic(text: TextSpan(), linkToPic: Uri.parse(url));
    parsedContent.add(pic);
  }

  void _parseHeaders(dom.Element element, List<Widget> parsedContent) {
    if (element.text.trim().isEmpty) return;

    int parsedSize =
        int.parse(element.localName.toString().replaceAll("h", "").trim());
    TextSpan textSpan =
        TextSpan(text: element.text, style: getTitleTextStyle(parsedSize));

    TitleComponent title = TitleComponent(text: textSpan, size: parsedSize);
    parsedContent.add(title);
  }

  void _parseBlockQuote(dom.Element element, List<Widget> parsedContent) {
    BlockquoteComponent blockquote = BlockquoteComponent(
        text: TextSpan(text: element.text, style: blockQuoteTextStyle));
    parsedContent.add(blockquote);
  }

  void _parseParagraph(List<Widget> parsedContent, dom.Element element) {
    String text = element.text.trim();
    if (text.isEmpty) return;
    if (text.split(" ").length < 2) return;

    // Get outerhtml of element
    String outerHtml = element.outerHtml.replaceFirst("<p>", "");

    // extract text with attributes from html.
    TextSpan textSpan = _extractParagraphAttributes(element);

    Paragraph paragraph = Paragraph(text: textSpan);
    parsedContent.add(paragraph);
  }

  void _parseUL(dom.Element element, List<Widget> parsedContent) {
    List<dom.Element> lis = element.querySelectorAll("li");
    InlineSpan ul = _extractListAttributes(element, false, -1);
    UnOrderedListParagraph unOrderedListParagraph =
        UnOrderedListParagraph(ul: ul);
    parsedContent.add(unOrderedListParagraph);
  }

  // TODO: Handle if author wrote list with both ol and paragraphs. How can you make the count right?
  void _parseOL(dom.Element element, List<Widget> parsedContent) {
    int count = -1;
    var temp = parsedContent.reversed
        .firstWhere((element) => element is! OrderedListParagraph);
    count = parsedContent.length - parsedContent.indexOf(temp);

    InlineSpan ol = _extractListAttributes(element, true, count);
    OrderedListParagraph orderedListParagraph = OrderedListParagraph(ol: ol);
    parsedContent.add(orderedListParagraph);
  }

  InlineSpan _extractListAttributes(
      dom.Element element, bool isOrdered, int count) {
    List<InlineSpan> children = [];
    int count = 0;

    // ITERERA ÖVER ALLA LIST ITEMS I OL
    for (var node in element.nodes) {
      if (node.text == null || node.text!.trim().isEmpty) continue;
      if (node.runtimeType.toString().toLowerCase() == "comment") continue;
      // Sets marker to number or bullet point, depending on bool ordered.
      count += 1;
      String marker = isOrdered == true ? "\n$count. " : "\n-";

      TextSpan markSpan = TextSpan(text: marker, style: markerToListTextStyle);
      InlineSpan n = TextSpan();
      if (node.runtimeType.toString().toLowerCase() == "text") {
        n = TextSpan(
            text: node.text!.trimLeft(),
            style: bodyTextStyle); //REMOVE NEWLINE!
      } else if (node.runtimeType.toString().toLowerCase() == "element") {
        n = _switchToSpanForListParagraph((node as dom.Element), n, markSpan);
      } else {
        //print("OBS! Undhandled text from html_parsing! - ${node.runtimeType}");
        //print(node.text);
      }
      children.add(n);
    }
    TextSpan textSpan = TextSpan(children: children, text: null);
    return textSpan;
  }

  InlineSpan _switchToSpanForListParagraph(
      dom.Element li, InlineSpan n, TextSpan countSpan) {
    List nodes = li.nodes;
    List<InlineSpan> spans = [];
    spans.add(countSpan);

    for (var node in nodes) {
      // SKIPPAR TOMMA NODES
      if (node.text.trim().length == 0) continue;

      if (node.runtimeType.toString().toLowerCase() == "text") {
        spans.add(
            TextSpan(text: " " + node.text.trimLeft(), style: bodyTextStyle));
        //count += 1;
        continue;
      } else {
        switch ((node as dom.Element).localName.toString().toLowerCase()) {
          case "p":
            //n = TextSpan(children: [countSpan, TextSpan(text: node.text, style: bodyTextStyle)]);
            spans.add(_extractParagraphAttributes(node));
            //spans.add(TextSpan(text: node.text, style: bodyTextStyle));
            //count += 1;
            break;
          case "a":
            //n = TextSpan(children: [countSpan, TextSpan(text: node.text, style: bodyLinkTextStyle)]);

            spans.add(TextSpan(text: node.text, style: bodyLinkTextStyle));
            //count += 1;
            break;
          case "b":
          case "strong":
            //n = TextSpan(children: [countSpan, TextSpan(text: node.text, style: bodyBoldTextStyle)]);
            //spans.add(TextSpan(children: [countSpan, TextSpan(text: node.text, style: bodyBoldTextStyle)]));
            spans.add(TextSpan(text: node.text, style: bodyBoldTextStyle));
            //count = count + 1;
            break;
          case "i":
          case "em":
            //n = TextSpan(children: [countSpan, TextSpan(text: node.text, style: bodyitalicTextStyle)]);
            spans.add(TextSpan(text: node.text, style: bodyitalicTextStyle));
            //count += 1;
            break;
          case "text":
            //n = TextSpan(children: [countSpan, TextSpan(text: node.text, style: bodyTextStyle)]);
            spans.add(TextSpan(text: node.text, style: bodyTextStyle));
            //count += 1;
            break;
          default:
            //n = TextSpan(children: [countSpan, TextSpan(text: node.text, style: bodyTextStyle)]);
            spans.add(TextSpan(text: node.text, style: bodyTextStyle));
            //count += 1;
            break;
        }
      }
    }
    n = TextSpan(children: spans, text: null);
    //n = WidgetSpan(child: RichText(textAlign: TextAlign.center, text: WidgetSpan(children: spans)));

    return n;
  }

  TextSpan _extractParagraphAttributes(dom.Element element) {
    List<TextSpan> children = [];
    for (var node in element.nodes) {
      //print(node.runtimeType.toString().toLowerCase());
      TextSpan n = TextSpan();
      if (node.runtimeType.toString().toLowerCase() == "text") {
        n = TextSpan(text: node.text, style: bodyTextStyle);
      } else if (node.runtimeType.toString().toLowerCase() == "element") {
        //print((node as dom.Element).localName);
        //print("localname " + (node as dom.Element).localName.toString());
        switch ((node as dom.Element).localName.toString().toLowerCase()) {
          case "p":
            n = TextSpan(text: node.text, style: bodyTextStyle);
            break;
          case "a":
            String? link = node.attributes['href'];
            if(link != null && Uri.tryParse(link) != null && link.startsWith("http")){
              n = LinkSpan(link: link, text: node.text, onTap: () => print("LINK: $link"), );  
            }
            else if (link != null /*&& link.length > 1 && link.split(" ").length > 1 */){
              n = TextSpan(
              text: node.text,
              style: bodyTextStyle,
              /*recognizer: TapGestureRecognizer()
                ..onTap = () {
                  print("NO LINK FOUND IN SPAN");
                },*/);
            }
            else{
              print("DID NOT CREATE LINK AS LINKSPAN OR TEXTSPAN");
            }
            
            
            break;
          case "b":
          case "strong":
            n = TextSpan(text: node.text, style: bodyBoldTextStyle);
            break;
          case "i":
          case "em":
            n = TextSpan(
              text: node.text,
              style: bodyitalicTextStyle,
            );
            break;
          case "text":
            n = TextSpan(text: node.text, style: bodyTextStyle);
            break;
        }
      } else {
        //print("OBS! Undhandled text from html_parsing! - ${node.runtimeType}");
        //print(node.text);
      }
      children.add(n);
    }
    TextSpan textSpan = TextSpan(children: children);
    return textSpan;
  }

  bool _parseImg(dom.Element element, List<Widget> parsedContent) {
    String? url = element.attributes['src'];
    if (url == null) return false;
    Uri link = Uri.parse(url);

    Pic pic = Pic(text: TextSpan(), linkToPic: link);
    bool alreadyContainsIt = false;
    for (var component in parsedContent) {
      if (component is Pic) {
        if (component.linkToPic == pic.linkToPic) {
          alreadyContainsIt = true;
          continue;
        }
      }
    }

    if (!alreadyContainsIt) {
      parsedContent.add(pic);
      return true;
    }
    return false;
    //print(url);
  }

  void _parseSpan(List<Widget> parsedContent, dom.Element element) {
    // TODO: Implement to parse the spans in html.
  }

  void parseFigure(dom.Element element, List<Widget> parsedContent) {
    //TODO: Implement to parse the picture and caption.
    Widget lastComponent = parsedContent.last;
    if (lastComponent is Pic) {
      //Uri lastCLink = lastComponent.linkToPic;
      dom.Element? image = element.querySelector('img');
      dom.Element? caption = element.querySelector('figcaption');

      if (image != null) {
        _parseImg(image, parsedContent);

        if (caption != null) {
          Widget lastC = parsedContent.last;
          if (lastC is Pic) {
            (lastC as Pic).setText(TextSpan(
                text: caption.text.trim().isEmpty
                    ? null
                    : caption
                        .text)); // = caption.text.trim().isEmpty ? null:caption.text;
          }
        }
      }
    }
  }

  TextStyle getTitleTextStyle(int parsedSize) {
    TextStyle style;
    switch (parsedSize) {
      case 1:
        style = h1TextStyle;
        break;
      case 2:
        style = h2TextStyle;
        break;
      case 3:
        style = h3TextStyle;
        break;
      case 4:
        style = h4TextStyle;
        break;
      default:
        style = h4TextStyle;
    }
    return style;
  }
}

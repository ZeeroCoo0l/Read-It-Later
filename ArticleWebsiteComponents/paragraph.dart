

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ArticleWebsiteComponents/article_component.dart';

import 'package:flutter/widgets.dart';

class Paragraph extends ArticleComponent {
  final InlineSpan text;
  const Paragraph({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    text.style?.apply(color: Colors.black87);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: RichText(text: text),
    );
  }
}

class UnOrderedListParagraph extends ArticleComponent {
  final InlineSpan ul;
  const UnOrderedListParagraph({super.key, required this.ul});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0, right: 8.0, top:2),
      child: RichText(text: ul),
    );
  }

}

class OrderedListParagraph extends ArticleComponent {
  final InlineSpan ol;
  const OrderedListParagraph({super.key, required this.ol});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0, right: 8.0, top:2),
      child: RichText(text: ol),
    );
  }

}

/*class OrderedListItemParagraph extends ArticleComponent {
  final InlineSpan text;
  const OrderedListItemParagraph({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0, right: 8.0, top:2),
      child: RichText(text: text),
    );
  }

}*/

class BlockquoteComponent extends ArticleComponent {
  final InlineSpan text;
  const BlockquoteComponent({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 8.0),
      child: RichText(text: text),
    );
  }

}

/*
class OrderedListParagraph extends ArticleComponent{
  OrderedListParagraph({required super.textContent}){
    textContent = textContent!.trim();
  }
}

class Blockquote extends ArticleComponent{
  Blockquote({required super.textContent});

}
*/
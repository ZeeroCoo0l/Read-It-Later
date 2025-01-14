import 'package:flutter/material.dart';

Widget createParagraph(String text){
  return Text(text);
}

Widget createOrderedList(String text){
  return Padding(
    padding: const EdgeInsets.only(left:32.0),
    child: Text(text),
  );
}

Widget createBlockquote(String blockquote){
  return Text(blockquote, style: const TextStyle(fontStyle: FontStyle.italic),);
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

Widget createTitle(String title, int size){
  double fontSize;
  switch (size){
    case 1:
      fontSize = 30;
      break;
    case 2:
      fontSize = 26;
      break;
    case 3:
      fontSize = 24;
      break;
    case 4:
      fontSize = 22;
      break;
    default:
      fontSize = 22;
  }
  return Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),);
}


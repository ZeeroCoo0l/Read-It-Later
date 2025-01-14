import 'package:flutter/material.dart';
import 'package:flutter_application_1/Components/article.dart';
import 'package:flutter_application_1/Components/article_collection.dart';
import 'package:flutter_application_1/Components/html_parser_program.dart';
import 'package:flutter_application_1/Screens/article_page.dart';
import 'package:go_router/go_router.dart';

class MyArticlesPage extends StatefulWidget {
  final ArticleCollection collection;
  const MyArticlesPage({super.key, required this.collection});
  @override
  State<StatefulWidget> createState() => MyArticlesPageState();
}

class MyArticlesPageState extends State<MyArticlesPage> {
  bool ready = false;
  late ArticleCollection collection; //ArticleCollection(title: "My Collection");
  ParserHtml parser = ParserHtml(link: null);

  @override
  void initState() {
    collection = widget.collection;
    initialArticleFetch();
  }

  Future<void> initialArticleFetch() async {
    setState(() {
      ready = false;
    });
    Uri link = Uri.parse("https://jamesclear.com/five-step-creative-process");
    Uri link2 = Uri.parse("https://jamesclear.com/journaling-one-sentence");
    ParserHtml parserHtml = ParserHtml(link: link);
    Article? article = await parserHtml.createArticle();
    parserHtml = ParserHtml(link: link2);
    Article? article2 = await parserHtml.createArticle();
    if(article == null) return;
    if(article2 == null) return;

    // Lägger till test-artikel i collection
    collection.addArticle(article); 
    collection.addArticle(article2);

    setState(() {
      ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    var cellImage = const AssetImage("images/Mouse_pic.jpg");

    return !ready
        ? const Center(child: CircularProgressIndicator.adaptive())
        : Scaffold(
            appBar: AppBar(
              title: const Text("My saved Articles"),
              actions: [
                IconButton(
                    onPressed: () async {
                      Article? article = await addArticleAlert(context, parser, collection);
                      if(article != null){
                        setState(() {
                          collection.addArticle(article);
                          print("ADDED ARTICLE TO COLLECTION");
                        });
                        print(collection.countArticle());
                      }
                      else{
                        print("RETURNED_ARTICLE IS NULL");
                      }
                    },
                    icon: const Icon(Icons.add_rounded))
              ],
              leading: IconButton(
                  onPressed: () {
                    GoRouter.of(context).pop();
                  },
                  icon: Icon(Icons.adaptive.arrow_back)),
            ),
            body: SizedBox(
              height: size.height,
              width: size.width,
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: ListView.builder(
                    itemCount: collection.countArticle(),
                    itemBuilder: (BuildContext context, int index) {
                      Article article = collection.articles[index];
                      Image image = Image.network(article.getFirstPic().toString());
                      return articleCell(
                          article,
                          image,
                          article.getFirstText(),
                          context);
                    },
                  )),
            ));
  }
}

Future<Article?> addArticleAlert(BuildContext context, ParserHtml parser,ArticleCollection collection) async {
  final TextEditingController controller = TextEditingController();
  Article? returnedArticle = null;
  await showDialog(
    context: context, 
    builder: (context) => AlertDialog(
      title: const Text("Add Article:"),
      content: TextField(controller: controller,),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Use the entered URL
                String url = controller.text;
                if (url.isNotEmpty) {
                  try{
                    parser.setLink(Uri.parse(url));
                    Article? newArticle = await parser.createArticle();

                    if(newArticle != null){
                      print("New Article is not null!");
                      returnedArticle = newArticle;
                    }
                  }
                  catch(e){
                    return;
                  }

                  controller.clear();
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Submit'),
            ),
          ],
      ),
    );
    return returnedArticle;
}

Widget articleCell(Article article, Image cellImage, String subtitle,
    BuildContext context) {
  String title = article.title;

  return GestureDetector(
    onTap: () {
      print("Going to Article page: ${article.title}");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ArticlePage(article: article)));
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Container(
            decoration: BoxDecoration(
              //borderRadius: const BorderRadius.all(Radius.circular(16)),
              color: Colors.grey[300],
              image: DecorationImage(
                fit: BoxFit.cover,
                image: cellImage.image,
              ),
              //borderRadius: const BorderRadius.all(Radius.circular(16))
            ),
            height: 320,
            width: double.infinity,
            //color: Colors.grey[300],
            child: Column(
              children: [
                const Spacer(
                  flex: 3,
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey[300]!.withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 24)),
                        Text(subtitle),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ),
    ),
  );
}

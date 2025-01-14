import 'package:url_launcher/url_launcher.dart';

class UrlHandler {

  Future<void> launchUrlSite({required String url}) async {
  try{
    final Uri urlParsed = Uri.parse(url);

  if (await canLaunchUrl(urlParsed)) {
    await launchUrl(urlParsed);
  } else {
    throw 'Could not launch $url';
  }
  }
  catch(e){
    print("No url was passed to url_launcher");
  }
}

}
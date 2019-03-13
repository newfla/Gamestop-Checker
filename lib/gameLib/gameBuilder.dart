import 'dart:convert';
import 'game.dart';
import 'dart:io';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class GameBuilder {

  //Fields
  final GamePlatform  _platform;
  static final String _url = "https://offertevg.it/gspo.php";
  static Element _table;

  //Constuctor
  GameBuilder(this._platform);

  //Get html
  static Future<void> loadPage() async {

    HttpClientRequest request = await HttpClient().getUrl(Uri.parse(_url));
    HttpClientResponse response = await request.close(); 
      
    StringBuffer buffer = StringBuffer();

    Document page;
    List<Element> elements;

    await for (var contents in response.transform(Utf8Decoder()))
      buffer.write(contents);

    page = parse(buffer.toString());

    elements = page.body.getElementsByTagName("ul");
    for (Element element in elements) {
      if(element.attributes["id"] == "list"){
        _table = element;
        break;
      }
    }
  }

  //Build gameList based on the selected Platform
  List<Game> buildPlatformList(){
    
    List<Game> games = List<Game>();

    for (Element element in _table.getElementsByTagName("li")) {

      if(checkStringType(element.getElementsByTagName("span")[0].innerHtml)){

        String name = extractGameName(element.getElementsByTagName("h2")[0].innerHtml);
        String url = extractURL(element.getElementsByTagName("a")[0]);
        List<String> prices = extractPrices(element.getElementsByTagName("p")[0].innerHtml);

        games.add( Game(name, _platform, prices[0], prices[1], url));
      }
    }
    return games;
  }
  
  bool checkStringType (String typeString){
    return _platform.toString().toUpperCase().contains(typeString.substring(1,typeString.length-2).toUpperCase());
  }

  String extractGameName(String name){

    int index = 1 + name.lastIndexOf(">");

    return name.substring(index);
  }

  List<String> extractPrices(String priceDesc){

    List<String> temp = priceDesc.split(":");
    List<String> prices = [" ", " "];

    try {
      if (temp.length == 3)
        prices[0] = temp[2].substring(0,temp[2].indexOf("."));
      else if (temp.length >= 4){
        prices[0] = temp[2].substring(0,temp[2].indexOf("."));
        prices[1] = temp[3].substring(0,temp[3].indexOf("."));
      }
    } catch (e) { }

    return prices;
  }

  String extractURL(Element element){
    return element.attributes["href"];
  }
}
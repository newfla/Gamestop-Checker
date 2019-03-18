import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gamestop_games/gamestop.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:admob_flutter/admob_flutter.dart';



void main() {
  Admob.initialize('adMob id here');
  runApp(MaterialApp(home: GamesSplashScreen()));
}

class GamesSplashScreen extends StatefulWidget{
  @override
  _GamesSplashScreenState createState() => _GamesSplashScreenState();
}

class _GamesSplashScreenState extends State<GamesSplashScreen>{
  @override
  Widget build(BuildContext context) {
    GamesContainer();
    return new SplashScreen(
      seconds: 3,
      navigateAfterSeconds: GamesApp(),
      title: Text('GameStop Checker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0, height: 2.5),
      ),
      image: Image(image: AssetImage('images/web_hi_res_512.png')),
      backgroundColor: Colors.white,
      photoSize: 80.0,
      loaderColor: Colors.red,
      loadingText: Text('Powered by OfferteVG.it')
    );
  }
}

class GamesApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gamestop Checker',
      theme: ThemeData(
        primarySwatch: Colors.red,
        hintColor: Colors.white
      ),
      home: GamesHomePage(title: 'Gamestop Checker'),
    );
  }
}

class GamesHomePage extends StatefulWidget  {
  GamesHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _GamesHomePageState createState() => _GamesHomePageState();
}

class _GamesHomePageState extends State<GamesHomePage> {

  final List<Tab> tabs = <Tab>[
    Tab(text: GamePlatform.XBOXONE.toString().split(".")[1]),
    Tab(text: GamePlatform.PS4.toString().split(".")[1]),
    Tab(text: GamePlatform.SWITCH.toString().split(".")[1])
  ];

  final TextEditingController _filter = new TextEditingController();

  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Gamestop Checker');
  String _searchText='';
  AdmobBanner _banner = AdmobBanner(
    adUnitId: 'unitid here',
    adSize: AdmobBannerSize.BANNER);


  final GamesContainer _container = GamesContainer();

  Future<void> _populateContainer() async {
   await _container.populate();
   setState(() {});
  }

  _GamesHomePageState() {
    _populateContainer();
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = '';
        });
      } else {//if(_filter.text.length>2){
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: tabs.indexWhere((tab) =>
      tab.text == GamePlatform.PS4.toString().split(".")[1]),
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: _appBarTitle,
          actions: <Widget>[
            IconButton(
              icon: _searchIcon,
              onPressed: ()=> _searchPressed()
            )
          ],
          bottom: TabBar(
            tabs: tabs,
          ),
        ),
        body:
         Column(
           mainAxisSize: MainAxisSize.max,
           children: <Widget>[
            Expanded(
              child: TabBarView(
                children: tabs.map((Tab tab) {
                  GamePlatform _platform = GamePlatform.values[GamePlatform.values
                      .indexWhere((elem) => elem.toString().contains(tab.text))];
                  List<Game> _games = _filterGames(_container.getByPlatform(_platform));
                  return RefreshIndicator(
                    child: ListView.builder(
                        itemCount: _games.length,
                        itemBuilder: (BuildContext context, int index) => _buildRow(_games[index], _platform)
                    ),
                    onRefresh: _populateContainer,
                  );
                }).toList(),
              ),
            ),
             Container(
               child: _banner
             )
          ],
         )

      ),
    );
  }

  Widget _buildRow(Game game, GamePlatform platform) {
    StringBuffer buffer = StringBuffer();
    buffer.write("Prezzo nuovo: ");
    buffer.write(game.priceNew);
    if (game.priceUsed
        .toString()
        .length > 1) {
      buffer.write(" Prezzo usato: ");
      buffer.write(game.priceUsed);
    }
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(GamePlatformIcons.getIcon(platform)),
              title: Text(game.title),
              subtitle: Text(buffer.toString()),
            ),

            ButtonTheme.bar(
              child: ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: const Text("CONTROLLA SUL SITO"),
                    onPressed: () {
                      _launchURL(game.url);
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url))
      await launch(url);
    else
      throw 'Could not launch $url';
  }

  void _searchPressed(){
    final String searchText = 'Cerca...';
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = Icon(Icons.close);
        this._appBarTitle = TextField(
          controller: _filter,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.white),
              hintText: searchText

          ),
        );
      } else {
        this._searchIcon = Icon(Icons.search);
        this._appBarTitle = Text( widget.title );
        _filter.clear();
      }
    });
  }

  List<Game> _filterGames(List<Game> list){

    if(list == null)
      return List<Game>();

    if (_searchText.isEmpty)
      return list;

    List<Game> games = List<Game>();

    for(Game game in list){
      if(game.title.toString().toLowerCase().contains(_searchText.toLowerCase()))
        games.add(game);
    }
    return games;
  }
}


import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gamestop_games/gamestop.dart';
import 'package:splashscreen/splashscreen.dart';


void main() => runApp(MaterialApp(
    home: GamesSplashScreen())
);

class GamesSplashScreen extends StatefulWidget{
  @override
  _GamesSplashScreenState createState() => _GamesSplashScreenState();
}

class _GamesSplashScreenState extends State<GamesSplashScreen>{
  @override
  Widget build(BuildContext context) {
    GamesContainer();
    return new SplashScreen(
      seconds: 2,
      navigateAfterSeconds: GamesApp(),
      title: Text('GameStopChecker',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30.0,
            height: 2.5
        ),
      ),
      image: Image(
          image: AssetImage('images/web_hi_res_512.png')
      ),
      backgroundColor: Colors.white,
      photoSize: 80.0,
      loaderColor: Colors.red,
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
  String _searchtext='';


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
          _searchtext = '';
        });
      } else {//if(_filter.text.length>2){
        setState(() {
          _searchtext = _filter.text;
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
        body: TabBarView(
          children: tabs.map((Tab tab) {
            GamePlatform _platform = GamePlatform.values[GamePlatform.values
                .indexWhere((elem) => elem.toString().contains(tab.text))];
            List<Game> _games = _container.getByPlatform(_platform);
            return RefreshIndicator(
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    if (_games != null && index < _games.length && (_searchtext.isEmpty || _games[index].title.toString().toLowerCase().contains(_searchtext.toLowerCase())))
                      return _buildRow(_games[index], _platform);
                  }
                ),
              onRefresh: _populateContainer,
            );
          }).toList(),
        ),
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

  _launchURL(String url) async {
    if (await canLaunch(url))
      await launch(url);
    else
      throw 'Could not launch $url';
  }

  _searchPressed(){
    final String searchText = 'Cerca per';
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search),
              hintText: searchText
          ),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text( widget.title );
        _filter.clear();
      }
    });
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gamestop_games/gamestop.dart';

void main() => runApp(GamesApp());

class GamesApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contollo Validità Gamestop',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: GamesHomePage(title: 'Contollo Validità Gamestop'),
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

  final GamesContainer _container = GamesContainer();

  void _populateContainer() {
    _container.populate().then((_) => setState(() {}));
  }

  _GamesHomePageState() {
    _populateContainer();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: tabs.indexWhere((tab) =>
      tab.text == GamePlatform.PS4.toString().split(".")[1]),
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (String selected) => print(selected), //TODO
              itemBuilder: (BuildContext context) =>
              <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                    value: "Info",
                    child: Text("Info")
                )
              ],
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
            return ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  if (_games != null && index < _games.length)
                    return _buildRow(_games[index], _platform);
                }
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
}

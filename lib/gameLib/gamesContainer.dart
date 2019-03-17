import 'dart:core';
import 'game.dart';
import 'gameBuilder.dart';

class GamesContainer {

  //Singleton remember Dart Lazy init
  static final GamesContainer _instance = GamesContainer._internal();

  //Fields
  Map<GamePlatform,List<Game>> _mapPlatformGames = Map();
  Map<GamePlatform,GameBuilder> _mapPlatformBuilder = Map();
  Future<void> _loadPage;

  //Singleton factory
  factory GamesContainer() => _instance;

  //Getter methods
  List<Game> getByPlatform(GamePlatform platform) => _mapPlatformGames[platform];

  List<Game> getAll(){
    List<Game> games = List<Game>();

    for(List<Game> list in _mapPlatformGames.values)
      games.addAll(list);

    return games;
  }

  //Constructor
  GamesContainer._internal(){
    
    //Start loading the site
    _loadPage = GameBuilder.loadPage();

    //Set Builder objext
    for (var type in GamePlatform.values)
      _mapPlatformBuilder[type] = GameBuilder(type);
  }

  //Public Populate Method
  Future<void> populate() async {

    await _loadPage;

    for (var platform in GamePlatform.values)
      _internalPopulate(platform);
  }

  //Private Populate
  void _internalPopulate(GamePlatform platform)  {
    _mapPlatformGames[platform] = _mapPlatformBuilder[platform].buildPlatformList();
  }
}
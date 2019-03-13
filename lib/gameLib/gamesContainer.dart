import 'dart:core';
import 'game.dart';
import 'gameBuilder.dart';

class GamesContainer {

  //Fields
  Map<GamePlatform,List<Game>> _mapPlatformGames = Map();
  Map<GamePlatform,GameBuilder> _mapPlatformBuilder = Map();
  Future<void> _loadPage;

  //Getter methods
  List<Game> getByPlatform(GamePlatform platform) => _mapPlatformGames[platform];

  //Constructor
  GamesContainer(){
    
    //Start loading the site
    _loadPage = GameBuilder.loadPage();

    //Set Builder objext
    for (var type in GamePlatform.values)
      _mapPlatformBuilder[type] = GameBuilder(type);
  }

  //Public Populate Method
  Future<void> populate() async {

    Set<Future<void>> futures = Set();

    await _loadPage;

    for (var platform in GamePlatform.values)
      futures.add(_internalPopulate(platform));

    await Future.wait(futures);
  }

  //Private Populate
  Future<void> _internalPopulate(GamePlatform platform) async {
    _mapPlatformGames[platform] = await _mapPlatformBuilder[platform].buildPlatformList();
  }
}
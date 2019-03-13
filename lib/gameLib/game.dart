class Game {
  //Fields 
  final String _title, _priceNew, _priceUsed, _url;
  final GamePlatform _platform;

  //Getter Methods
  get title => _title;
  get type => _platform;
  get priceNew => _priceNew;
  get priceUsed => _priceUsed;
  get url => _url;

  //Constructor
  Game(this._title, this._platform, this._priceNew, this._priceUsed, this._url);
}

  //Enum Game Platoform
  enum GamePlatform{PS4, XBOXONE, SWITCH}

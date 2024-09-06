
class Soccermatch{
  Fixture fixture;
  Team home;
  Team away;
  Goal goal;
  LeagueS league;
  ScoreS scoreS;
  Soccermatch({required this.fixture,required this.away,required this.goal,required this.scoreS,required this.home,required this.league});
  factory Soccermatch.fromJson(Map<String,dynamic>json){
    return Soccermatch(fixture: Fixture.fromJson(json['fixture']),
        league:LeagueS.fromJson(json['league']),
        away: Team.fromJson(json['teams']['away']),
        goal: Goal.fromJson(json['goals']),
        scoreS: ScoreS.fromJson(json['score']),
        home:Team.fromJson(json['teams']['home']));
  }

}
class ScoreS {
  Halftime halftime;
  Fulltime fulltime;
  Extratime extratime;
  Penalty penalty;

  ScoreS({required this.halftime, required this.fulltime, required this.extratime, required this.penalty});

  factory ScoreS.fromJson(Map<String, dynamic> json) {
    return ScoreS(
      halftime: Halftime.fromJson(json['halftime']),
      fulltime: Fulltime.fromJson(json['fulltime']),
      extratime: Extratime.fromJson(json['extratime']),
      penalty: Penalty.fromJson(json['penalty']),
    );
  }
}

class Halftime {
  int home;
  int away;

  Halftime({required this.home, required this.away});

  factory Halftime.fromJson(Map<String, dynamic> json) {
    return Halftime(
      home: json['home']??0,
      away: json['away']??0,
    );
  }
}

class Fulltime {
  int home;
  int away;

  Fulltime({required this.home, required this.away});

  factory Fulltime.fromJson(Map<String, dynamic> json) {
    return Fulltime(
      home: json['home']??0,
      away: json['away']??0,
    );
  }
}

class Extratime {
  int home;
  int away;

  Extratime({required this.home, required this.away});

  factory Extratime.fromJson(Map<String, dynamic> json) {
    return Extratime(
      home: json['home']??0,
      away: json['away']??0,
    );
  }
}

class Penalty {
  int home;
  int away;

  Penalty({required this.home, required this.away});

  factory Penalty.fromJson(Map<String, dynamic> json) {
    return Penalty(
      home: json['home']??0,
      away: json['away']??0,
    );
  }
}


class Lineup {
  final Team team;
  final Coach coach;
  final String formation;
  final List<Player> startXI;
  final List<Player> substitutes;

  Lineup({
    required this.team,
    required this.coach,
    required this.formation,
    required this.startXI,
    required this.substitutes,
  });

  factory Lineup.fromJson(Map<String, dynamic> json) {
    var startXIList = json['startXI'] as List;
    List<Player> startXI = [];
    startXI=startXIList.map((player) => Player.fromJson(player)).toList();
    var substitutesList = json['substitutes'] as List;
    List<Player> substitutes = [];
    substitutes=substitutesList.map((player) => Player.fromJson(player)).toList();

    return Lineup(
      team: Team.fromJson(json['team']),
      coach: Coach.fromJson(json['coach']),
      formation: json['formation']??'',
      startXI: startXI,
      substitutes: substitutes,
    );
  }
}



class Coach {
  final int id;
  final String name;
  final String photo;

  Coach({required this.id, required this.name, required this.photo});

  factory Coach.fromJson(Map<String, dynamic> json) {
    return Coach(
      id: json['id']??0,
      name: json['name']??'',
      photo: json['photo']??'',
    );
  }
}

class Player {
  final int id;
  final String name;
  final int number;
  final String pos;
  final String? grid;

  Player({required this.id, required this.name, required this.number, required this.pos, this.grid});

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['player']['id']??0,
      name: json['player']['name']??'',
      number: json['player']['number']??0,
      pos: json['player']['pos']??'',
      grid: json['player']['grid']??'',
    );
  }
}
class Scorer {
  final int id;
  final String name;
  final int number;
  final String pos;
  final String? grid;
  final String time;

  Scorer({required this.id,
    required this.name,
    required this.number,
    required this.pos,
    required this.time,
    this.grid});

  factory Scorer.fromJson(Map<String, dynamic> json) {
    return Scorer(
      id: json['player']['id']??0,
      name: json['player']['name']??'',
      number: json['player']['number']??0,
      pos: json['player']['pos']??'',
      grid: json['player']['grid']??'',
      time: json['player']['time']??'',
    );
  }
}
class Paging {
  final int current;
  final int total;

  Paging({required this.current, required this.total});

  factory Paging.fromJson(Map<String, dynamic> json) {
    return Paging(
      current: json['current']??0,
      total: json['total']??0,
    );
  }
}


class Fixture{
  int id;
  String dates;
  Status status;
  Venue venue;
  Fixture({required this.status,required this.id,required this.dates,required this.venue});
  factory Fixture.fromJson(Map<String,dynamic>json){
    return Fixture(status: Status.fromJson(json['status']),
        id: json['id']??0, dates: json['date']??'', venue: Venue.fromJson(json['venue']));
  }
}

class LeagueS{
  int id;
  String name;
  String logo;
  String flag;
  String country;
  dynamic season;
  LeagueS({
    required this.name,
    required this.id,
    required this.country,
    required this.logo,
    required this.flag,
    required this.season,
    });
  factory LeagueS.fromJson(Map<String,dynamic>json){
    dynamic seasonValue = json['season'];
    if (seasonValue is int || seasonValue is String) {
      return LeagueS(flag: json['flag']??'',
          id: json['id']??0,
          country: json['country']??'',
          logo: json['logo']??'',
          season: seasonValue,
          name:json['name']??'');
    } else {
      // Handle unexpected type
      throw Exception('Unexpected type for season');
    }

  }
}
class Status{
  int elapsedTime;
  String long;
  String short;
  Status({required this.elapsedTime,required this.long,required this.short});
  factory Status.fromJson(Map<String,dynamic>json){
    return Status(elapsedTime: json['elapsed']??0, long: json['long']??'',short:json['short']??'');
  }

}
class Venue{
  int id;
  String name;
  String city;
  Venue({required this.id,required this.name,required this.city});
  factory Venue.fromJson(Map<String,dynamic>json){
    return Venue(id: json['id']??0, city: json['city']??'',name:json['name']??'');
  }
}
class Team{
  int id;
  String name;
  String logourl;
  bool winner;
  Team({required this.id,required this.logourl,required this.name,required this.winner});
  factory Team.fromJson(Map<String,dynamic>json){
    return Team(id: json['id']??0,
        logourl: json['logo']??'',
        name: json['name']??'',
        winner: json['winner']??false);
  }
}
class Goal{
  int home;
  int away;
  Goal({required this.away,required this.home});
  factory Goal.fromJson(Map<String,dynamic>json){
    return Goal(home:json['home']??0,
        away: json['away']??0);
  }
}


class BasketBall {
  Teams home;
  Teams away;
  Scores scores;
  Country country;
  Statusb status;
  League league;
  String time;
  BasketBall({required this.status,required this.time,required this.league,required this.home,required this.away,required this.scores,required this.country});

  factory BasketBall.fromJson(Map<String, dynamic> json) {
    return BasketBall(
      time: json['time']??"",
    home:Teams.fromJson(json['teams']['home']),
    away:Teams.fromJson(json['teams']['away']),
      scores: Scores.fromJson(json['scores']),
      country:  Country.fromJson(json['country']), 
        status: Statusb.fromJson(json['status']),
      league: League.fromJson(json['league']),
    );
  }
}

class Statusb {
  String short;
  String long;
  Statusb({
    required this.short,
    required this.long,
  });

  factory Statusb.fromJson(Map<String, dynamic> json) {
    return Statusb(
      short: json['short'] ?? '',
      long: json['long'] ?? '',
      
    );
  }
}
class Scores {
HomeScores hscores;
AwayScores ascores;
  Scores({
  required this.ascores,
    required this.hscores
  });

  factory Scores.fromJson(Map<String, dynamic> json) {
    return Scores(
      ascores:AwayScores.fromJson(json['away']),
      hscores:HomeScores.fromJson(json['home']),
    );
  }
}

class HomeScores{
  int quarter1Home;
  int quarter2Home;
  int quarter3Home;
  int quarter4Home;
  int over_time;
  int totalHome;
  HomeScores({required this.quarter1Home,
    required this.quarter2Home,
    required this.quarter3Home,
    required this.quarter4Home,
    required this.totalHome,required this.over_time});
  factory HomeScores.fromJson(Map<String, dynamic> json) {
    return HomeScores(
      quarter1Home: json['quarter_1'] ?? 0,
      quarter2Home: json['quarter_2'] ?? 0,
      quarter3Home: json['quarter_3'] ?? 0,
      quarter4Home: json['quarter_4'] ?? 0,
      over_time: json['over_time']??0,
      totalHome: json['total'] ?? 0,
    );
  }
}

class AwayScores{
  int quarter1Away;
  int quarter2Away;
  int quarter3Away;
  int quarter4Away;
  int over_time;
  int totalAway;
  AwayScores({
required this.quarter1Away,
required this.quarter2Away,
required this.quarter3Away,
required this.quarter4Away,
required this.totalAway,required this.over_time});
  factory AwayScores.fromJson(Map<String, dynamic> json) {
    return AwayScores(
      quarter1Away: json['quarter_1'] ?? 0,
      quarter2Away: json['quarter_2'] ?? 0,
      quarter3Away: json['quarter_3'] ?? 0,
      quarter4Away: json['quarter_4'] ?? 0,
      over_time: json['over_time']??0,
      totalAway: json['total'] ?? 0,
    );
  }
}
class Teams{
  int id;
  String name;
  String logourl;
  Teams({required this.id,required this.logourl,required this.name});
  factory Teams.fromJson(Map<String,dynamic>json){
    return Teams(id: json['id'],
        logourl: json['logo']??'',
        name: json['name']??'');
  }
}
class League{
  int id;
  String name;
  dynamic season;
  String logo;
  String type;
  League({required this.id,required this.name,required this.season,required this.logo,required this.type});
  factory League.fromJson(Map<String,dynamic>json){
    dynamic seasonValue = json['season'];
    if (seasonValue is int || seasonValue is String) {
      return League(
        id: json['id'],
        name: json['name'],
        type: json['type'],
        season: seasonValue,
        logo: json['logo'],
      );
    } else {
      // Handle unexpected type
      throw Exception('Unexpected type for season');
    }
  }
  }

class Country{
  int id;
  String name;
  String flag;
  String code;
  Country({required this.id,required this.flag,required this.name,required this.code});
  factory Country.fromJson(Map<String,dynamic>json){
    return Country(id: json['id']??0,
        flag: json['flag']??'',
        name: json['name']??'',
        code: json['code']??'');
  }
}


class RUGBY {
Teamsrby home;
Teamsrby away;
GameScoresrby scores;
Statusb status;
String time;
RUGBY({ required this.home,required this.time,required this.away,required this.scores,required this.status});

factory RUGBY.fromJson(Map<String, dynamic> json) {

return RUGBY(
  time: json['time']??"",
  status: Statusb.fromJson(json['status']),
home:Teamsrby.fromJson(json['teams']['home']),
away:Teamsrby.fromJson(json['teams']['away']),
scores: GameScoresrby.fromJson(json['scores']),
);
}
}
class GameScoresrby {
int away;
int home;

GameScoresrby({required this.away, required this.home});

factory GameScoresrby.fromJson(Map<String, dynamic> json) {
return GameScoresrby(
away: json['away']??0,
home: json['home']??0,
);
}
}
class Teamsrby{
int id;
String name;
String logourl;
Teamsrby({required this.id,
required this.logourl,
required this.name,
});
factory Teamsrby.fromJson(Map<String,dynamic>json){
return Teamsrby(id: json['id']??0,
logourl: json['logo']??'',
name: json['name']??'',
);
}
}



class VOLLEYBALL {
  String time;
  Teamsrby home;
  Teamsrby away;
  GameScoresrby scores;
  Countryvol country;
  Statusb status;
  VOLLEYBALL({ required this.home,required this.time,required this.status,required this.away,required this.scores,required this.country});

  factory VOLLEYBALL.fromJson(Map<String, dynamic> json) {

    return VOLLEYBALL(
        time: json['time']??'',
      status: Statusb.fromJson(json['status']),
      home:Teamsrby.fromJson(json['teams']['home']),
      away:Teamsrby.fromJson(json['teams']['away']),
      scores: GameScoresrby.fromJson(json['scores']),
      country: Countryvol.fromJson(json['country'])
    );
  }
}
class GameScoresvol {
  int away;
  int home;

  GameScoresvol({required this.away, required this.home});

  factory GameScoresvol.fromJson(Map<String, dynamic> json) {
    return GameScoresvol(
      away: json['away']??0,
      home: json['home']??0,
    );
  }
}
class Teamsvol{
  int id;
  String name;
  String logourl;
  Teamsvol({required this.id,
    required this.logourl,
    required this.name,
  });
  factory Teamsvol.fromJson(Map<String,dynamic>json){
    return Teamsvol(id: json['id']??0,
      logourl: json['logo']??'',
      name: json['name']??'',
    );
  }
}

class Countryvol{
  int id;
  String name;
  String flag;
  String code;
  Countryvol({required this.id,required this.flag,required this.name,required this.code});
  factory Countryvol.fromJson(Map<String,dynamic>json){
    return Countryvol(id: json['id']??0,
        flag: json['flag']??"",
        name: json['name']??'',
        code: json['code']??'');
  }
}


class NewsArticle {
  String status;
  int totalResults;
  List<Article> articles;

  NewsArticle({required this.status, required this.totalResults, required this.articles});

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      status: json['status'] ?? '',
      totalResults: json['totalResults'] ?? 0,
      articles: List<Article>.from((json['articles'] ?? []).map((article) => Article.fromJson(article))),
    );
  }
}

class Article {
  String articleId;
  String title;
  String link;
  String sourceId;
  int sourcePriority;
  List<String> keywords;
  String creator;
  String imageUrl;
  String videoUrl;
  String description;
  String pubDate;
  String content;
  String country;
  String category;
  String language;

  Article({
    required this.articleId,
    required this.title,
    required this.link,
    required this.sourceId,
    required this.sourcePriority,
    required this.keywords,
    required this.creator,
    required this.imageUrl,
    required this.videoUrl,
    required this.description,
    required this.pubDate,
    required this.content,
    required this.country,
    required this.category,
    required this.language,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      articleId: json['article_id'] ?? '',
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      sourceId: json['source_id'] ?? '',
      sourcePriority: json['source_priority'] ?? 0,
      keywords: List<String>.from(json['keywords'] ?? []),
      creator: json['creator'] ?? '',
      imageUrl: json['image_url'] ?? '',
      videoUrl: json['video_url'] ?? '',
      description: json['description'] ?? '',
      pubDate: json['pubDate'] ?? '',
      content: json['content'] ?? '',
      country: json['country'] ?? '',
      category: json['category'] ?? '',
      language: json['language'] ?? '',
    );
  }
}
// Assuming you have the JSON data for one article stored in a variable called 'articleJson'


class ArticleResponse {
  String status;
  int totalResults;
  List<ArticleData> results;

  ArticleResponse({
    required this.status,
    required this.totalResults,
    required this.results,
  });

  factory ArticleResponse.fromJson(Map<String, dynamic> json) {
    return ArticleResponse(
      status: json['status'] ?? '',
      totalResults: json['totalResults'] ?? 0,
      results: List<ArticleData>.from(
        (json['results'] ?? []).map((article) => ArticleData.fromJson(article)),
      ),
    );
  }
}

class ArticleData {
  String articleId;
  String title;
  String link;
  List<String>? keywords;
  List<String> creator;
  String videoUrl;
  String description;
  String content;
  String pubDate;
  String imageUrl;
  String sourceId;
  int sourcePriority;
  List<String> country;
  List<String> category;
  String language;

  ArticleData({
    required this.articleId,
    required this.title,
    required this.link,
    this.keywords,
    required this.creator,
   required this.videoUrl,
    required this.description,
    required this.content,
    required this.pubDate,
    required this.imageUrl,
    required this.sourceId,
    required this.sourcePriority,
    required this.country,
    required this.category,
    required this.language,
  });

  factory ArticleData.fromJson(Map<String, dynamic> json) {
    return ArticleData(
      articleId: json['article_id'] ?? '',
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      keywords: List<String>.from(json['keywords'] ?? []),
      creator: List<String>.from(json['creator'] ?? []),
      videoUrl: json['video_url'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      pubDate: json['pubDate'] ?? '',
      imageUrl: json['image_url'] ?? '',
      sourceId: json['source_id'] ?? '',
      sourcePriority: json['source_priority'] ?? 0,
      country: List<String>.from(json['country'] ?? []),
      category: List<String>.from(json['category'] ?? []),
      language: json['language'] ?? '',
    );
  }
}

class Parameters {
  String date;

  Parameters({
    required this.date,
  });

  factory Parameters.fromJson(Map<String, dynamic> json) {
    return Parameters(
      date: json['date'] ?? '',
    );
  }
}

class GameResponse {
  int id;
  String league;
  int season;
  Date date;
  int stage;
  Status1 status;
  Periods periods;
  Arena arena;
  Teams1 teams;
  Scores1 scores;
  List<dynamic> officials;
  dynamic timesTied;
  dynamic leadChanges;
  dynamic nugget;

  GameResponse({
    required this.id,
    required this.league,
    required this.season,
    required this.date,
    required this.stage,
    required this.status,
    required this.periods,
    required this.arena,
    required this.teams,
    required this.scores,
    required this.officials,
    required this.timesTied,
    required this.leadChanges,
    required this.nugget,
  });

  factory GameResponse.fromJson(Map<String, dynamic> json) {
    return GameResponse(
      id: json['id'] ?? 0,
      league: json['league'] ?? '',
      season: json['season'] ?? 0,
      date: Date.fromJson(json['date'] ?? {}),
      stage: json['stage'] ?? 0,
      status: Status1.fromJson(json['status'] ?? {}),
      periods: Periods.fromJson(json['periods'] ?? {}),
      arena: Arena.fromJson(json['arena'] ?? {}),
      teams: Teams1.fromJson(json['teams'] ?? {}),
      scores: Scores1.fromJson(json['scores'] ?? {}),
      officials: json['officials'] ?? [],
      timesTied: json['timesTied'],
      leadChanges: json['leadChanges'],
      nugget: json['nugget'],
    );
  }
}

class Date {
  String start;
  dynamic end;
  dynamic duration;

  Date({
    required this.start,
    required this.end,
    required this.duration,
  });

  factory Date.fromJson(Map<String, dynamic> json) {
    return Date(
      start: json['start'] ?? '',
      end: json['end'],
      duration: json['duration'],
    );
  }
}

class Status1 {
  String clock;
  bool halftime;
  int short;
  String long;

  Status1({
    required this.clock,
    required this.halftime,
    required this.short,
    required this.long,
  });

  factory Status1.fromJson(Map<String, dynamic> json) {
    return Status1(
      clock: json['clock'] ?? '',
      halftime: json['halftime'] ?? false,
      short: json['short'] ?? 0,
      long: json['long'] ?? '',
    );
  }
}

class Periods {
  int current;
  int total;
  bool endOfPeriod;

  Periods({
    required this.current,
    required this.total,
    required this.endOfPeriod,
  });

  factory Periods.fromJson(Map<String, dynamic> json) {
    return Periods(
      current: json['current'] ?? 0,
      total: json['total'] ?? 0,
      endOfPeriod: json['endOfPeriod'] ?? false,
    );
  }
}

class Arena {
  String name;
  String city;
  String state;
  dynamic country;

  Arena({
    required this.name,
    required this.city,
    required this.state,
    required this.country,
  });

  factory Arena.fromJson(Map<String, dynamic> json) {
    return Arena(
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'],
    );
  }
}

class Teams1 {
  Team1 visitors;
  Team1 home;

  Teams1({
    required this.visitors,
    required this.home,
  });

  factory Teams1.fromJson(Map<String, dynamic> json) {
    return Teams1(
      visitors: Team1.fromJson(json['visitors'] ?? {}),
      home: Team1.fromJson(json['home'] ?? {}),
    );
  }
}

class Team1 {
  int id;
  String name;
  String nickname;
  String code;
  String logo;

  Team1({
    required this.id,
    required this.name,
    required this.nickname,
    required this.code,
    required this.logo,
  });

  factory Team1.fromJson(Map<String, dynamic> json) {
    return Team1(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nickname: json['nickname'] ?? '',
      code: json['code'] ?? '',
      logo: json['logo'] ?? '',
    );
  }
}

class Scores1 {
  Score visitors;
  Score home;

  Scores1({
    required this.visitors,
    required this.home,
  });

  factory Scores1.fromJson(Map<String, dynamic> json) {
    return Scores1(
      visitors: Score.fromJson(json['visitors'] ?? {}),
      home: Score.fromJson(json['home'] ?? {}),
    );
  }
}

class Score {
  int win;
  int loss;
  Series1 series;
  List<String> linescore;
  int points;

  Score({
    required this.win,
    required this.loss,
    required this.series,
    required this.linescore,
    required this.points,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      win: json['win'] ?? 0,
      loss: json['loss'] ?? 0,
      series: Series1.fromJson(json['series'] ?? {}),
      linescore: List<String>.from(json['linescore'] ?? []),
      points: json['points'] ?? 0,
    );
  }
}

class Series1 {
  int win;
  int loss;

  Series1({
    required this.win,
    required this.loss,
  });

  factory Series1.fromJson(Map<String, dynamic> json) {
    return Series1(
      win: json['win'] ?? 0,
      loss: json['loss'] ?? 0,
    );
  }
}


class HOCKEY {
  String time;
  Teamsrby home;
  Teamsrby away;
  GameScoresrby scores;
  Countryvol country;
  Statusb status;

  HOCKEY(
      { required this.home,
        required this.time,
        required this.status,
        required this.away,
        required this.scores,
        required this.country});
  factory HOCKEY.fromJson(Map<String, dynamic> json) {

    return HOCKEY(
        time: json['time']??'',
        status: Statusb.fromJson(json['status']),
        home:Teamsrby.fromJson(json['teams']['home']),
        away:Teamsrby.fromJson(json['teams']['away']),
        scores: GameScoresrby.fromJson(json['scores']),
        country: Countryvol.fromJson(json['country'])
    );
  }
}


class NFL{
  Game game;
  Teams home;
  Teams away;
  Scoresnfl scores;
  Leaguenfl leagues;
  NFL({required this.away,required this.scores,required this.home,required this.game,required this.leagues});
  factory NFL.fromJson(Map<String,dynamic>json){
    return NFL(
      leagues: Leaguenfl.fromJson(json['league']),
        game: Game.fromJson(json['game']),
        away: Teams.fromJson(json['teams']['away']),
        scores: Scoresnfl.fromJson(json['scores']),
        home:Teams.fromJson(json['teams']['home']));
  }
}
class Game {
  int id;
  String stage;
  String week;
  GameDate date;
  Statusb status;

  Game({
    required this.id,
    required this.stage,
    required this.week,
    required this.date,
    required this.status
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      status: Statusb.fromJson(json['status']??{}),
      id: json['id'] ?? 0,
      stage: json['stage'] ?? '',
      week: json['week'] ?? '',
      date: GameDate.fromJson(json['date'] ?? {}),
    );
  }
}

class GameDate {
  String timezone;
  String date;
  String time;
  int timestamp;

  GameDate({
    required this.timezone,
    required this.date,
    required this.time,
    required this.timestamp,
  });

  factory GameDate.fromJson(Map<String, dynamic> json) {
    return GameDate(
      timezone: json['timezone'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      timestamp: json['timestamp'] ?? 0,
    );
  }
}

class BASEBALL{
  String time;
  Teams home;
  Teams away;
  BaseballScores baseballScores;
  Statusb status;
  BASEBALL({required this.away,required this.baseballScores,required this.home,required this.status,required this.time});
  factory BASEBALL.fromJson(Map<String,dynamic>json){
    return BASEBALL(
        time: json['time']??'',
        status: Statusb.fromJson(json['status']),
        away: Teams.fromJson(json['teams']['away']),
        baseballScores:BaseballScores.fromJson(json['scores']),
        home:Teams.fromJson(json['teams']['home']));
  }
}
class BaseballScores {
  BaseballTeamScores home;
  BaseballTeamScores away;

  BaseballScores({
    required this.home,
    required this.away,
  });

  factory BaseballScores.fromJson(Map<String, dynamic> json) {
    return BaseballScores(
      home: BaseballTeamScores.fromJson(json['home']),
      away: BaseballTeamScores.fromJson(json['away']),
    );
  }
}

class BaseballTeamScores {
  int hits;
  int errors;
  BaseballInningScores innings;
  int total;

  BaseballTeamScores({
    required this.hits,
    required this.errors,
    required this.innings,
    required this.total,
  });

  factory BaseballTeamScores.fromJson(Map<String, dynamic> json) {
    return BaseballTeamScores(
      hits: json['hits'] ?? 0,
      errors: json['errors'] ?? 0,
      innings: BaseballInningScores.fromJson(json['innings']),
      total: json['total'] ?? 0,
    );
  }
}

class BaseballInningScores {
  int? inning1;
  int? inning2;
  int? inning3;
  int? inning4;
  int? inning5;
  int? inning6;
  int? inning7;
  int? inning8;
  int? inning9;
  int? extra;

  BaseballInningScores({
    this.inning1,
    this.inning2,
    this.inning3,
    this.inning4,
    this.inning5,
    this.inning6,
    this.inning7,
    this.inning8,
    this.inning9,
    this.extra,
  });

  factory BaseballInningScores.fromJson(Map<String, dynamic> json) {
    return BaseballInningScores(
      inning1: json['1'],
      inning2: json['2'],
      inning3: json['3'],
      inning4: json['4'],
      inning5: json['5'],
      inning6: json['6'],
      inning7: json['7'],
      inning8: json['8'],
      inning9: json['9'],
      extra: json['extra'],
    );
  }
}

class HANDBALL{
  String time;
  Teams home;
  Teams away;
  Goal goal;
  Statusb status;
  HANDBALL({required this.away,required this.goal,required this.home,required this.status,required this.time});
  factory HANDBALL.fromJson(Map<String,dynamic>json){
    return HANDBALL(
      time: json['time']??'',
        status: Statusb.fromJson(json['status']),
        away: Teams.fromJson(json['teams']['away']),
        goal: Goal.fromJson(json['scores']),
        home:Teams.fromJson(json['teams']['home']));
  }
}

class Leaguenfl {
  int id;
  String name;
  String season;
  String logo;
  Countrynfl country;

  Leaguenfl({
    required this.id,
    required this.name,
    required this.season,
    required this.logo,
    required this.country,
  });

  factory Leaguenfl.fromJson(Map<String, dynamic> json) {
    return Leaguenfl(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      season: json['season'] ?? '',
      logo: json['logo'] ?? '',
      country: Countrynfl.fromJson(json['country'] ?? {}),
    );
  }
}

class Countrynfl {
  String name;
  String code;
  String flag;

  Countrynfl({
    required this.name,
    required this.code,
    required this.flag,
  });

  factory Countrynfl.fromJson(Map<String, dynamic> json) {
    return Countrynfl(
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      flag: json['flag'] ?? '',
    );
  }
}
class Scoresnfl {
  HomeScoresnfl hscores;
  AwayScoresnfl ascores;
  Scoresnfl({
    required this.ascores,
    required this.hscores
  });

  factory Scoresnfl.fromJson(Map<String, dynamic> json) {
    return Scoresnfl(
      ascores:AwayScoresnfl.fromJson(json['away']),
      hscores:HomeScoresnfl.fromJson(json['home']),
    );
  }
}

class HomeScoresnfl{
  int quarter1Home;
  int quarter2Home;
  int quarter3Home;
  int quarter4Home;
  int over_time;
  int totalHome;
  HomeScoresnfl({required this.quarter1Home,
    required this.quarter2Home,
    required this.quarter3Home,
    required this.quarter4Home,
    required this.totalHome,required this.over_time});
  factory HomeScoresnfl.fromJson(Map<String, dynamic> json) {
    return HomeScoresnfl(
      quarter1Home: json['quarter_1'] ?? 0,
      quarter2Home: json['quarter_2'] ?? 0,
      quarter3Home: json['quarter_3'] ?? 0,
      quarter4Home: json['quarter_4'] ?? 0,
      over_time: json['overtime']??0,
      totalHome: json['total'] ?? 0,
    );
  }
}

class AwayScoresnfl{
  int quarter1Away;
  int quarter2Away;
  int quarter3Away;
  int quarter4Away;
  int over_time;
  int totalAway;
  AwayScoresnfl({
    required this.quarter1Away,
    required this.quarter2Away,
    required this.quarter3Away,
    required this.quarter4Away,
    required this.totalAway,required this.over_time});
  factory AwayScoresnfl.fromJson(Map<String, dynamic> json) {
    return AwayScoresnfl(
      quarter1Away: json['quarter_1'] ?? 0,
      quarter2Away: json['quarter_2'] ?? 0,
      quarter3Away: json['quarter_3'] ?? 0,
      quarter4Away: json['quarter_4'] ?? 0,
      over_time: json['overtime']??0,
      totalAway: json['total'] ?? 0,
    );
  }
}


class RaceData {
  int id;
  Competition competition;
  Circuit circuit;
  int season;
  String type;
  Laps laps;
  FastestLap fastestLap;
  String distance;
  String timezone;
  String date;
  dynamic weather;
  String status;

  RaceData({
    required this.id,
    required this.competition,
    required this.circuit,
    required this.season,
    required this.type,
    required this.laps,
    required this.fastestLap,
    required this.distance,
    required this.timezone,
    required this.date,
    required this.weather,
    required this.status,
  });

  factory RaceData.fromJson(Map<String, dynamic> json) {
    return RaceData(
      id: json['id'] ?? 0,
      competition: Competition.fromJson(json['competition'] ?? {}),
      circuit: Circuit.fromJson(json['circuit'] ?? {}),
      season: json['season'] ?? 0,
      type: json['type'] ?? '',
      laps: Laps.fromJson(json['laps'] ?? {}),
      fastestLap: FastestLap.fromJson(json['fastest_lap'] ?? {}),
      distance: json['distance'] ?? '',
      timezone: json['timezone'] ?? '',
      date: json['date'] ?? '',
      weather: json['weather'],
      status: json['status'] ?? '',
    );
  }
}

class Competition {
  int id;
  String name;
  Location location;

  Competition({
    required this.id,
    required this.name,
    required this.location,
  });

  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      location: Location.fromJson(json['location'] ?? {}),
    );
  }
}

class Location {
  String country;
  String city;

  Location({
    required this.country,
    required this.city,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      country: json['country'] ?? '',
      city: json['city'] ?? '',
    );
  }
}

class Circuit {
  int id;
  String name;
  String image;

  Circuit({
    required this.id,
    required this.name,
    required this.image,
  });

  factory Circuit.fromJson(Map<String, dynamic> json) {
    return Circuit(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class Laps {
  dynamic current;
  int total;

  Laps({
    required this.current,
    required this.total,
  });

  factory Laps.fromJson(Map<String, dynamic> json) {
    return Laps(
      current: json['current'],
      total: json['total'] ?? 0,
    );
  }
}

class FastestLap {
  Driver driver;
  String time;

  FastestLap({
    required this.driver,
    required this.time,
  });

  factory FastestLap.fromJson(Map<String, dynamic> json) {
    return FastestLap(
      driver: Driver.fromJson(json['driver'] ?? {}),
      time: json['time'] ?? '',
    );
  }
}

class Driver {
  int id;
  Driver({
    required this.id,
  });
  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? 0,
    );
  }
}

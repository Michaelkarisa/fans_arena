import 'dart:convert';
import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:fans_arena/joint/data/sportsapi/sportsmodel.dart';
import 'package:http/http.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../appid.dart';
import '../../../fans/screens/results.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../reusablewidgets/carouselslider.dart';

class SportsApiF extends ChangeNotifier{
  DateTime date=DateTime.now();


  //Football
  final String apiurl = "https://v3.football.api-sports.io/fixtures?live=all"; // Path, don't include the host
  final String host = "v3.football.api-sports.io"; // Host

  static  Map<String, String> headers = {
    'x-rapidapi-key': footballapi,
    'x-rapidapi-host': 'v3.football.api-sports.io'
  };

  Future<List<Soccermatch>> getAllMatches() async {
    Response res = await get(Uri.parse(apiurl), headers: headers);
    if (res.statusCode == 200) {
      List<dynamic> fixturesList = jsonDecode(res.body)['response']??[];
      List<Soccermatch> matches = fixturesList.map((dynamic item) {
        return Soccermatch.fromJson(item);
      }).toList();
      return matches;
    } else {
      // Handle the case when the HTTP response status code is not 200
      // You can either return an empty list or throw an exception, depending on your app's requirements.
      return [];
    }
  }
  Future<List<Soccermatch>> getAllMatches1(String date) async {
    final String apiurl0='https://v3.football.api-sports.io/fixtures?date=$date';
    Response res = await get(Uri.parse(apiurl0), headers: headers);
    if (res.statusCode == 200) {
      List<dynamic> fixturesList = jsonDecode(res.body)['response']??[];
      List<Soccermatch> matches = fixturesList.map((dynamic item) {
        return Soccermatch.fromJson(item);
      }).toList();
      return matches;
    } else {
      return [];
    }
  }
  Future<List<Lineup>> getFixtureLineups(String fixtureId) async {
    final String apiurl0='https://v3.football.api-sports.io/fixtures?date=2024-03-02';
    final String apiUrl1 = 'https://v3.football.api-sports.io/fixtures/lineups';
    final Map<String, String> queryParams = {'fixture': fixtureId};

    final Uri uri = Uri.parse(apiUrl1).replace(queryParameters: queryParams);
    final response = await get(uri, headers:headers);

    if (response.statusCode == 200) {
      List<dynamic> fixturesList = jsonDecode(response.body)['response']??[];
      List<Lineup> matches = fixturesList.map((dynamic item) {
        return Lineup.fromJson(item);
      }).toList();
      return matches;
    } else {
      throw Exception('Failed to load fixture lineups');
    }
  }
//Basketball
  // Path, don't include the host
  final String host1 = "v1.basketball.api-sports.io"; // Host

  static  Map<String, String> headers1 = {
    'x-rapidapi-key': footballapi,
    'x-rapidapi-host': 'v1.basketball.api-sports.io'
  };

  Future<List<BasketBall>> getAllMatchesnba() async {
    String today='${date.year}-${date.month}-${date.day}';
    final String apiurl1 = "https://v1.basketball.api-sports.io/games?date=$today";
    Response res = await get(Uri.parse(apiurl1), headers: headers1);
    if (res.statusCode == 200) {
      List<dynamic> fixturesList = jsonDecode(res.body)['response']??[];
      List<BasketBall> matches = fixturesList.map((dynamic item) {
        return BasketBall.fromJson(item);
      }).toList();
      return matches;
    } else {
      // Handle the case when the HTTP response status code is not 200
      // You can either return an empty list or throw an exception, depending on your app's requirements.
      return [];
    }
  }
  Future<List<BasketBall>> getAllMatchesnba1(String date) async {
    final String apiurl1 = "https://v1.basketball.api-sports.io/games?date=$date";
    Response res = await get(Uri.parse(apiurl1), headers: headers1);
    if (res.statusCode == 200) {
      List<dynamic> fixturesList = jsonDecode(res.body)['response']??[];
      List<BasketBall> matches = fixturesList.map((dynamic item) {
        return BasketBall.fromJson(item);
      }).toList();
      return matches;
    } else {
      // Handle the case when the HTTP response status code is not 200
      // You can either return an empty list or throw an exception, depending on your app's requirements.
      return [];
    }
  }
  Future<List<BasketBall>> getAllMatchesbas() async {
    String today='${date.year}-${date.month}-${date.day}';
    final String apiurl1 = "https://v1.basketball.api-sports.io/games?date=$today";
    Response res = await get(Uri.parse(apiurl1), headers: headers1);
    if (res.statusCode == 200) {
      List<dynamic> fixturesList = jsonDecode(res.body)['response']??[];
      List<BasketBall> matches = fixturesList.map((dynamic item) {
        return BasketBall.fromJson(item);
      }).toList();
      return matches;
    } else {
      // Handle the case when the HTTP response status code is not 200
      // You can either return an empty list or throw an exception, depending on your app's requirements.
      return [];
    }
  }
  Future<List<BasketBall>> getAllMatchesbas1(String date) async {
    final String apiurl1 = "https://v1.basketball.api-sports.io/games?date=$date";
    Response res = await get(Uri.parse(apiurl1), headers: headers1);
    if (res.statusCode == 200) {
      List<dynamic> fixturesList = jsonDecode(res.body)['response']??[];
      List<BasketBall> matches = fixturesList.map((dynamic item) {
        return BasketBall.fromJson(item);
      }).toList();
      return matches;
    } else {
      // Handle the case when the HTTP response status code is not 200
      // You can either return an empty list or throw an exception, depending on your app's requirements.
      return [];
    }
  }
  //NBA
  // Path, don't include the host
  final String hostnba = "v2.nba.api-sports.io"; // Host
  static  Map<String, String> headersnba = {
    'x-rapidapi-key': footballapi,
    'x-rapidapi-host': 'v2.nba.api-sports.io'
  };
  Future<List<GameResponse>> fetchNBAData() async {
    String today='${date.year}-${date.month}-${date.day}';
    final String apiurlnba = "https://v2.nba.api-sports.io/games?date=$today";
    final response = await get(Uri.parse(apiurlnba), headers: headersnba);

    if (response.statusCode == 200) {
      // Successfully fetched data
      List<dynamic> fixturesList = jsonDecode(response.body)['response']??[];
      List<GameResponse> matches = fixturesList.map((dynamic item) {
        return GameResponse.fromJson(item);
      }).toList();
      return matches;
    } else {
      // Handle errors
      print('Failed to load data. Status code: ${response.statusCode}');
      return [];
    }
  }
  Future<List<GameResponse>> fetchNBAData1(String date) async {
    final String apiurlnba = "https://v2.nba.api-sports.io/games?date=$date";
    final response = await get(Uri.parse(apiurlnba), headers: headersnba);

    if (response.statusCode == 200) {
      // Successfully fetched data
      List<dynamic> fixturesList = jsonDecode(response.body)['response']??[];
      List<GameResponse> matches = fixturesList.map((dynamic item) {
        return GameResponse.fromJson(item);
      }).toList();
      return matches;
    } else {
      // Handle errors
      print('Failed to load data. Status code: ${response.statusCode}');
      return [];
    }
  }
  //Volleyball
  // Path, don't include the host
  final String hostvol= "v1.volleyball.api-sports.io"; // Host

  static  Map<String, String> headersvol = {
    'x-rapidapi-key': footballapi,
    'x-rapidapi-host': 'v1.volleyball.api-sports.io'
  };

  Future<List<VOLLEYBALL>> getAllMatchesvol() async {
    String today='${date.year}-${date.month}-${date.day}';
    final String apiurlvol = "https://v1.volleyball.api-sports.io/games?date=$today";
    Response res = await get(Uri.parse(apiurlvol), headers: headersvol);
    if (res.statusCode == 200) {
      List<dynamic> fixturesList = jsonDecode(res.body)['response']??[];
      List<VOLLEYBALL> matches = fixturesList.map((dynamic item) {
        return VOLLEYBALL.fromJson(item);
      }).toList();
      return matches;
    } else {
      // Handle the case when the HTTP response status code is not 200
      // You can either return an empty list or throw an exception, depending on your app's requirements.
      return [];
    }
  }
  Future<List<VOLLEYBALL>> getAllMatchesvol1(String date) async {
    final String apiurlvol = "https://v1.volleyball.api-sports.io/games?date=$date";
    Response res = await get(Uri.parse(apiurlvol), headers: headersvol);
    if (res.statusCode == 200) {
      List<dynamic> fixturesList = jsonDecode(res.body)['response']??[];
      List<VOLLEYBALL> matches = fixturesList.map((dynamic item) {
        return VOLLEYBALL.fromJson(item);
      }).toList();
      return matches;
    } else {
      // Handle the case when the HTTP response status code is not 200
      // You can either return an empty list or throw an exception, depending on your app's requirements.
      return [];
    }
  }
  //Rugby
  // Path, don't include the host
  final String hostrby = "v1.rugby.api-sports.io"; // Host

  static  Map<String, String> headersrby = {
    'x-rapidapi-key': footballapi,
    'x-rapidapi-host': 'v1.rugby.api-sports.io'
  };

  Future<List<RUGBY>> getAllMatchesrby() async {
    String today='${date.year}-${date.month}-${date.day}';
    final String apiurlrby = "https://v1.rugby.api-sports.io/games?date=$today";
    Response res = await get(Uri.parse(apiurlrby), headers: headersrby);
    if (res.statusCode == 200) {
      List<dynamic> fixturesList = jsonDecode(res.body)['response']??[];
      List<RUGBY> matches = fixturesList.map((dynamic item) {
        return RUGBY.fromJson(item);
      }).toList();
      return matches;
    } else {
      // Handle the case when the HTTP response status code is not 200
      // You can either return an empty list or throw an exception, depending on your app's requirements.
      return [];
    }
  }
  Future<List<RUGBY>> getAllMatchesrby1(String date) async {
    final String apiurlrby = "https://v1.rugby.api-sports.io/games?date=$date";
    Response res = await get(Uri.parse(apiurlrby), headers: headersrby);
    if (res.statusCode == 200) {
      List<dynamic> fixturesList = jsonDecode(res.body)['response']??[];
      List<RUGBY> matches = fixturesList.map((dynamic item) {
        return RUGBY.fromJson(item);
      }).toList();
      return matches;
    } else {
      // Handle the case when the HTTP response status code is not 200
      // You can either return an empty list or throw an exception, depending on your app's requirements.
      return [];
    }
  }
//Formula one
  final String hostf1 = "v1.formula-1.api-sports.io"; // Host

  static  Map<String, dynamic> headersf1 = {
    'x-rapidapi-key': footballapi,
    'x-rapidapi-host': 'v1.formula-1.api-sports.io'
  };

  Future<List<RaceData>> getAllMatchesf1() async {
    String today='${date.year}';
    final String apiurlhky = "https://v1.formula-1.api-sports.io/races?season=$today";
    Response res = await get(Uri.parse(apiurlhky), headers: headershky);
    if (res.statusCode == 200) {
      List<dynamic> fixturesList = jsonDecode(res.body)['response']??[];
      List<RaceData> matches = fixturesList.map((dynamic item) {
        return RaceData.fromJson(item);
      }).toList();
      return matches;
    } else {
      // Handle the case when the HTTP response status code is not 200
      // You can either return an empty list or throw an exception, depending on your app's requirements.
      return [];
    }
  }
  Future<List<RaceData>> getAllMatchesf11(String date) async {
    final String apiurlhky = "https://v1.formula-1.api-sports.io/races?season=$date";
    Response res = await get(Uri.parse(apiurlhky), headers: headershky);
    if (res.statusCode == 200) {
      List<dynamic> fixturesList = jsonDecode(res.body)['response']??[];
      List<RaceData> matches = fixturesList.map((dynamic item) {
        return RaceData.fromJson(item);
      }).toList();
      return matches;
    } else {
      // Handle the case when the HTTP response status code is not 200
      // You can either return an empty list or throw an exception, depending on your app's requirements.
      return [];
    }
  }
//Baseball
  final String hostbsb = "v1.baseball.api-sports.io"; // Host

  static  Map<String, String> headersbsb = {
    'x-rapidapi-key': footballapi,
    'x-rapidapi-host': 'v1.baseball.api-sports.io'
  };

  Future<List<BASEBALL>> getAllMatchesbsb() async {
    String today='${date.year}-${date.month}-${date.day}';
    final String apiurlrby = "https://v1.baseball.api-sports.io/games?date=$today";
    Response res = await get(Uri.parse(apiurlrby), headers: headersbsb);
    if (res.statusCode == 200) {
      List<dynamic> fixturesList = jsonDecode(res.body)['response']??[];
      List<BASEBALL> matches = fixturesList.map((dynamic item) {
        return BASEBALL.fromJson(item);
      }).toList();
      return matches;
    } else {
      // Handle the case when the HTTP response status code is not 200
      // You can either return an empty list or throw an exception, depending on your app's requirements.
      return [];
    }
  }
  Future<List<BASEBALL>> getAllMatchesbsb1(String date) async {
    final String apiurlrby = "https://v1.baseball.api-sports.io/games?date=$date";
    Response res = await get(Uri.parse(apiurlrby), headers: headersbsb);
    if (res.statusCode == 200) {
      List<dynamic> fixturesList = jsonDecode(res.body)['response']??[];
      List<BASEBALL> matches = fixturesList.map((dynamic item) {
        return BASEBALL.fromJson(item);
      }).toList();
      return matches;
    } else {
      // Handle the case when the HTTP response status code is not 200
      // You can either return an empty list or throw an exception, depending on your app's requirements.
      return [];
    }
  }
//Golf
//Handball
  final String hosthb = "v1.handball.api-sports.io"; // Host

  static  Map<String, String> headershb = {
    'x-rapidapi-key': footballapi,
    'x-rapidapi-host': 'v1.handball.api-sports.io'
  };

  Future<List<HANDBALL>> getAllMatcheshb() async {
    String today='${date.year}-${date.month}-${date.day}';
    final String apiurlrby = "https://v1.handball.api-sports.io/games?date=$today";
    Response res = await get(Uri.parse(apiurlrby), headers: headersbsb);
    if (res.statusCode == 200) {
      List<dynamic> fixturesList = jsonDecode(res.body)['response']??[];
      List<HANDBALL> matches = fixturesList.map((dynamic item) {
        return HANDBALL.fromJson(item);
      }).toList();
      return matches;
    } else {
      // Handle the case when the HTTP response status code is not 200
      // You can either return an empty list or throw an exception, depending on your app's requirements.
      return [];
    }
  }
  Future<List<HANDBALL>> getAllMatcheshb1(String date) async {
    final String apiurlrby = "https://v1.handball.api-sports.io/games?date=$date";
    Response res = await get(Uri.parse(apiurlrby), headers: headersbsb);
    if (res.statusCode == 200) {
      List<dynamic> fixturesList = jsonDecode(res.body)['response']??[];
      List<HANDBALL> matches = fixturesList.map((dynamic item) {
        return HANDBALL.fromJson(item);
      }).toList();
      return matches;
    } else {
      // Handle the case when the HTTP response status code is not 200
      // You can either return an empty list or throw an exception, depending on your app's requirements.
      return [];
    }
  }
  //Nfl
  final String hostab = "v1.american-football.api-sports.io"; // Host

  static  Map<String, String> headersab = {
    'x-rapidapi-key': footballapi,
    'x-rapidapi-host': 'v1.american-football.api-sports.io'
  };

  Future<List<NFL>> getAllMatchesab() async {
    String today='${date.year}-${date.month}-${date.day}';
    final String apiurlrby = "https://v1.american-football.api-sports.io/games?date=$today";
    Response res = await get(Uri.parse(apiurlrby), headers: headersbsb);
    if (res.statusCode == 200) {
      List<dynamic> fixturesList = jsonDecode(res.body)['response']??[];
      List<NFL> matches = fixturesList.map((dynamic item) {
        return NFL.fromJson(item);
      }).toList();
      return matches;
    } else {
      // Handle the case when the HTTP response status code is not 200
      // You can either return an empty list or throw an exception, depending on your app's requirements.
      return [];
    }
  }

  Future<List<NFL>> getAllMatchesab1(String date) async {
    final String apiurlrby = "https://v1.american-football.api-sports.io/games?date=$date";
    Response res = await get(Uri.parse(apiurlrby), headers: headersbsb);
    if (res.statusCode == 200) {
      List<dynamic> fixturesList = jsonDecode(res.body)['response']??[];
      List<NFL> matches = fixturesList.map((dynamic item) {
        return NFL.fromJson(item);
      }).toList();
      return matches;
    } else {
      // Handle the case when the HTTP response status code is not 200
      // You can either return an empty list or throw an exception, depending on your app's requirements.
      return [];
    }
  }
  //HOCKEY
  // Path, don't include the host
  final String hosthky = "v1.hockey.api-sports.io"; // Host

  static Map<String, String> headershky = {
    'x-rapidapi-key': footballapi,
    'x-rapidapi-host': 'v1.hockey.api-sports.io'
  };

  Future<List<HOCKEY>> getAllMatcheshky() async {
    String today='${date.year}-${date.month}-${date.day}';
    final String apiurlhky = "https://v1.hockey.api-sports.io/games?date=$today";
    Response res = await get(Uri.parse(apiurlhky), headers: headershky);
    if (res.statusCode == 200) {
      List<dynamic> fixturesList = jsonDecode(res.body)['response']??[];
      List<HOCKEY> matches = fixturesList.map((dynamic item) {
        return HOCKEY.fromJson(item);
      }).toList();
      return matches;
    } else {
      // Handle the case when the HTTP response status code is not 200
      // You can either return an empty list or throw an exception, depending on your app's requirements.
      return [];
    }
  }
  Future<List<HOCKEY>> getAllMatcheshky1(String date) async {
    final String apiurlhky = "https://v1.hockey.api-sports.io/games?date=$date";
    Response res = await get(Uri.parse(apiurlhky), headers: headershky);
    if (res.statusCode == 200) {
      List<dynamic> fixturesList = jsonDecode(res.body)['response']??[];
      List<HOCKEY> matches = fixturesList.map((dynamic item) {
        return HOCKEY.fromJson(item);
      }).toList();
      return matches;
    } else {
      // Handle the case when the HTTP response status code is not 200
      // You can either return an empty list or throw an exception, depending on your app's requirements.
      return [];
    }
  }
//sports news
  Future<String> retrieveUserData1() async {
    try {
      QuerySnapshot querySnapshotA = await FirebaseFirestore.instance
          .collection('Fans')
          .where('Fanid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .limit(1)
          .get();
      QuerySnapshot querySnapshotB = await FirebaseFirestore.instance
          .collection('Professionals')
          .where('profeid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .limit(1)
          .get();
      QuerySnapshot querySnapshotC = await FirebaseFirestore.instance
          .collection('Clubs')
          .where('Clubid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .limit(1)
          .get();
      if (querySnapshotA.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotA.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        return data['favourite']??'';
      } else if (querySnapshotB.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotB.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        return data['genre']??'';
      } else if (querySnapshotC.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotC.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        return data['Genre'] ??'';
      }else{
        return 'Premierleague';
      }
    } catch (e) {
      return 'Premierleague';
    }}

  final String baseUrl = "https://newsdata.io/api/1/news";

  Future<List<ArticleData>> fetchData({required String genre}) async {
    String genre1= await retrieveUserData1();
    final response = await get(Uri.parse('$baseUrl?apikey=$newsapikey&q=$genre1&language=en'));
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body)??[];
      ArticleResponse articleResponse = ArticleResponse.fromJson(jsonResponse);
      return articleResponse.results;
    } else {
      return [];

    }
  }
  Future<List<ArticleData>> fetchArticleData() async {
    const String baseUrl = "https://newsdata.io/api/1/news";
    const String searchQuery = "Premier%20league";

    try {
      final response = await get(Uri.parse('$baseUrl?apikey=$newsapikey&q=$searchQuery&language=en'));

      if (response.statusCode == 200) {
        // Successfully fetched data
        Map<String, dynamic> jsonResponse = jsonDecode(response.body)??[];
        ArticleResponse articleResponse = ArticleResponse.fromJson(jsonResponse);
        return articleResponse.results;
      } else {
        // Handle errors
        print('Failed to load data. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}


class Matcheslider extends StatefulWidget {
  String genre;

  Matcheslider({super.key,required this.genre});

  @override
  State<Matcheslider> createState() => _MatchesliderState();
}

class _MatchesliderState extends State<Matcheslider> {
  bool isloading=true;
  @override
  void initState(){
    super.initState();
    if (widget.genre.isNotEmpty) {
      setState(() {
        isloading=false;
      });
    }
  }
  @override
  void didUpdateWidget(covariant Matcheslider oldWidget) {
    if (widget.genre.isNotEmpty) {
      setState(() {
        isloading=false;
      });
    }
    super.didUpdateWidget(oldWidget);
  }
  @override
  Widget build(BuildContext context) {
    if(isloading){
      return const Center(child: CircularProgressIndicator(),);
    }else if(widget.genre=="Football"){
      return const MatchW();
    }else if(widget.genre=="Basketball"){
      return const Basketball1();
    }else if(widget.genre=="Volleyball"){
      return const Volleyballc();
    }else if(widget.genre=="Formula one"){
      return const F1();
    }else if(widget.genre=="Tennis"){
      return const Text('Not Available');
    }else if(widget.genre=="Cricket"){
      return const Text('Not Available');
    }else if(widget.genre=="Rugby"){
      return const Rugbyc();
    }else if(widget.genre=="Cycling"){
      return const Text('Not Available');
    }else if(widget.genre=="Marathon"){
      return const Text('Not Available');
    }else if(widget.genre=="Swimming"){
      return const Text('Not Available');
    }else if(widget.genre=="Golf"){
      return const Text('Not Available');
    }else if(widget.genre=="Hockey"){
      return const Hockeyc();
    }else if(widget.genre=="Motorsport"){
      return const Text('Not Available');
    }else if(widget.genre=="Horse racing"){
      return const Text('Not Available');
    }else if(widget.genre=="Netball"){
      return const Text('Not Available');
    }else if(widget.genre=="Wrestling"){
      return const Text('Not Available');
    }else if(widget.genre=="Boxing"){
      return const Text('Not Available');
    }else if(widget.genre=="Polo"){
      return const Text('Not Available');
    }else if(widget.genre=="Rally"){
      return const Text('Not Available');
    }else if(widget.genre=="Baseball"){
      return const Baseballc();
    }else if(widget.genre=="chess"){
      return const Text('Not Available');
    }else if(widget.genre=="Handball"){
      return const Handballc();
    }else if(widget.genre=="Badminton"){
      return const Text('Not Available');
    }else if(widget.genre=="NFL"){
      return const Nflc();
    }else if(widget.genre=="NBA"){
      return const NbaW();
    }else{
      return const Center(child: Text('Unknown'));
    }
  }
}

//Baseball
class Baseballc extends StatefulWidget {
  const Baseballc({super.key});

  @override
  State<Baseballc> createState() => _BaseballcState();
}

class _BaseballcState extends State<Baseballc> with AutomaticKeepAliveClientMixin{
  late Future<List<Baseball>> matchesFuture;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    matchesFuture = DataFetcher().fetchbaseball();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure that the mixin's build is called.
    return FutureBuilder<List<Baseball>>(
      future: matchesFuture,
      builder: (context, snapshot) {
        if(snapshot.connectionState==ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }else if(!snapshot.hasData){
          return const Center(child: Text("No data"));
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${snapshot.error}"),
                const SizedBox(height: 10),
                IconButton(
                  onPressed: () {
                    setState(() {
                      matchesFuture = DataFetcher().fetchbaseball();
                    });
                  },
                  icon: const Icon(Icons.refresh, color: Colors.black),
                ),
                const Text('Refresh'),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          final matches = snapshot.data!;
          final matchWidgets = matches.map((match) => BaseballWidget(match)).toList();
          return Stack(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.3,
                  aspectRatio: 16 / 9,
                  autoPlay: true,
                  enlargeCenterPage: false,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: matchWidgets,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2,left: 2,right: 2),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width*0.96,
                    height: MediaQuery.of(context).size.height * 0.019,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: matches
                              .asMap()
                              .entries
                              .map((entry) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentIndex = entry.key;
                                });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.015,
                                height: MediaQuery.of(context).size.height * 0.015,
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentIndex == entry.key ? Colors.blue : Colors.grey,
                                ),
                              ),
                            );
                          })
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }else{
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
//Formula 1
class F1 extends StatefulWidget {
  const F1({super.key});

  @override
  State<F1> createState() => _F1State();
}

class _F1State extends State<F1> with AutomaticKeepAliveClientMixin{
  late Future<List<Formula1>> matchesFuture;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    matchesFuture = DataFetcher().fetchF1();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure that the mixin's build is called.
    return FutureBuilder<List<Formula1>>(
      future: matchesFuture,
      builder: (context, snapshot) {
        if(snapshot.connectionState==ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }else if(!snapshot.hasData){
          return const Center(child: Text("No data"));
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${snapshot.error}"),
                const SizedBox(height: 10),
                IconButton(
                  onPressed: () {
                    setState(() {
                      matchesFuture =DataFetcher().fetchF1();
                    });
                  },
                  icon: const Icon(Icons.refresh, color: Colors.black),
                ),
                const Text('Refresh'),
              ],
            ),
          );
        } else
        if (snapshot.hasData) {
          final matches = snapshot.data!;
          final matchWidgets = matches.map((match) => F1Widget(f1:match)).toList();

          return Stack(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.3,
                  aspectRatio: 16 / 9,
                  autoPlay: true,
                  enlargeCenterPage: false,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: matchWidgets,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2,left: 2,right: 2),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width*0.96,
                    height: MediaQuery.of(context).size.height * 0.019,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: matches
                              .asMap()
                              .entries
                              .map((entry) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentIndex = entry.key;
                                });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.015,
                                height: MediaQuery.of(context).size.height * 0.015,
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentIndex == entry.key ? Colors.blue : Colors.grey,
                                ),
                              ),
                            );
                          })
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }else{
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
//Nfl
class Nflc extends StatefulWidget {
  const Nflc({super.key});

  @override
  State<Nflc> createState() => _NflcState();
}

class _NflcState extends State<Nflc> with AutomaticKeepAliveClientMixin {
  late Future<List<Nfl>> matchesFuture;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    matchesFuture = DataFetcher().fetchnfl();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure that the mixin's build is called.
    return FutureBuilder<List<Nfl>>(
      future: matchesFuture,
      builder: (context, snapshot) {
        if(snapshot.connectionState==ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }else if(!snapshot.hasData){
          return const Center(child: Text("No data"));
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${snapshot.error}"),
                const SizedBox(height: 10),
                IconButton(
                  onPressed: () {
                    setState(() {
                      matchesFuture = DataFetcher().fetchnfl();
                    });
                  },
                  icon: const Icon(Icons.refresh, color: Colors.black),
                ),
                const Text('Refresh'),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          final matches = snapshot.data!;
          final matchWidgets = matches.map((match) =>NflWidget(match)).toList();

          return Stack(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.3,
                  aspectRatio: 16 / 9,
                  autoPlay: true,
                  enlargeCenterPage: false,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: matchWidgets,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2,left: 2,right: 2),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width*0.96,
                    height: MediaQuery.of(context).size.height * 0.019,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: matches
                              .asMap()
                              .entries
                              .map((entry) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentIndex = entry.key;
                                });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.015,
                                height: MediaQuery.of(context).size.height * 0.015,
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentIndex == entry.key ? Colors.blue : Colors.grey,
                                ),
                              ),
                            );
                          })
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }else{
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

//Handball
class Handballc extends StatefulWidget {
  const Handballc({super.key});

  @override
  State<Handballc> createState() => _HandballcState();
}

class _HandballcState extends State<Handballc> with AutomaticKeepAliveClientMixin {
  late Future<List<Handball>> matchesFuture;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    matchesFuture = DataFetcher().fetchhandball();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure that the mixin's build is called.
    return FutureBuilder<List<Handball>>(
      future: matchesFuture,
      builder: (context, snapshot) {
        if(snapshot.connectionState==ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }else if(!snapshot.hasData){
          return const Center(child: Text("No data"));
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${snapshot.error}"),
                const SizedBox(height: 10),
                IconButton(
                  onPressed: () {
                    setState(() {
                      matchesFuture = DataFetcher().fetchhandball();
                    });
                  },
                  icon: const Icon(Icons.refresh, color: Colors.black),
                ),
                const Text('Refresh'),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          final matches = snapshot.data!;
          final matchWidgets = matches.map((match) => HandballWidget(match)).toList();

          return Stack(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.3,
                  aspectRatio: 16 / 9,
                  autoPlay: true,
                  enlargeCenterPage: false,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: matchWidgets,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2,left: 2,right: 2),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width*0.96,
                    height: MediaQuery.of(context).size.height * 0.019,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: matches
                              .asMap()
                              .entries
                              .map((entry) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentIndex = entry.key;
                                });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.015,
                                height: MediaQuery.of(context).size.height * 0.015,
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentIndex == entry.key ? Colors.blue : Colors.grey,
                                ),
                              ),
                            );
                          })
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }else{
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

//football
class MatchW extends StatefulWidget {
  const MatchW({super.key});

  @override
  _MatchWState createState() => _MatchWState();
}

class _MatchWState extends State<MatchW> with AutomaticKeepAliveClientMixin {
  late Future<List<Football>> matchesFuture;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    matchesFuture = DataFetcher().fetchfootball();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure that the mixin's build is called.
    return FutureBuilder<List<Football>>(
      future: matchesFuture,
      builder: (context, snapshot) {
        if(snapshot.connectionState==ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${snapshot.error}"),
                const SizedBox(height: 10),
                IconButton(
                  onPressed: () {
                    setState(() {
                      matchesFuture = DataFetcher().fetchfootball();
                    });
                  },
                  icon: const Icon(Icons.refresh, color: Colors.black),
                ),
                const Text('Refresh'),
              ],
            ),
          );
        } else  if(!snapshot.hasData){
          return const Center(child: Text("No data"));
        }else if (snapshot.hasData) {
          final matches = snapshot.data!;
          final matchWidgets = matches.map((match) => SoccermatchWidget(match)).toList();
          return Stack(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.3,
                  aspectRatio: 16 / 9,
                  autoPlay: true,
                  enlargeCenterPage: false,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: matchWidgets,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 1,left: 2,right: 2),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width*0.96,
                    height: MediaQuery.of(context).size.height * 0.019,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: matches
                              .asMap()
                              .entries
                              .map((entry) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentIndex = entry.key;
                                });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.015,
                                height: MediaQuery.of(context).size.height * 0.015,
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentIndex == entry.key ? Colors.blue : Colors.grey,
                                ),
                              ),
                            );
                          })
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }else{
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}


//nba

class NbaW extends StatefulWidget {
  const NbaW({super.key});

  @override
  _NbaWState createState() => _NbaWState();
}

class _NbaWState extends State<NbaW> with AutomaticKeepAliveClientMixin {
  late Future<List<Nba>> nba;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    nba = DataFetcher().fetchnba();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure that the mixin's build is called.
    return FutureBuilder<List<Nba>>(
      future: nba,
      builder: (context, snapshot) {
        if(snapshot.connectionState==ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }else if(!snapshot.hasData){
          return const Center(child: Text("No data"));
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${snapshot.error}"),
                const SizedBox(height: 10),
                IconButton(
                  onPressed: () {
                    setState(() {
                      nba = DataFetcher().fetchnba();
                    });
                  },
                  icon: const Icon(Icons.refresh, color: Colors.black),
                ),
                const Text('Refresh'),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          final matches = snapshot.data!;
          final matchWidgets = matches.map((match) => NBAWc(match)).toList();

          return Stack(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.3,
                  aspectRatio: 16 / 9,
                  autoPlay: true,
                  enlargeCenterPage: false,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: matchWidgets,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2,left: 2,right: 2),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width*0.96,
                    height: MediaQuery.of(context).size.height * 0.019,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: matches
                              .asMap()
                              .entries
                              .map((entry) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentIndex = entry.key;
                                });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.015,
                                height: MediaQuery.of(context).size.height * 0.015,
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentIndex == entry.key ? Colors.blue : Colors.grey,
                                ),
                              ),
                            );
                          })
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }else{
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

//Basketball
class Basketball1 extends StatefulWidget {
  const Basketball1({super.key});

  @override
  _Basketball1State createState() => _Basketball1State();
}

class _Basketball1State extends State<Basketball1> with AutomaticKeepAliveClientMixin {
  late Future<List<BasketBall>> nba;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    nba = SportsApiF().getAllMatchesbas();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure that the mixin's build is called.
    return FutureBuilder<List<BasketBall>>(
      future: nba,
      builder: (context, snapshot) {
        if(snapshot.connectionState==ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }else if(!snapshot.hasData){
          return const Center(child: Text("No data"));
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${snapshot.error}"),
                const SizedBox(height: 10),
                IconButton(
                  onPressed: () {
                    setState(() {
                      nba = SportsApiF().getAllMatchesbas();
                    });
                  },
                  icon: const Icon(Icons.refresh, color: Colors.black),
                ),
                const Text('Refresh'),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          final matches = snapshot.data!;
          final matchWidgets = matches.map((match) => BasketballWidget(match)).toList();

          return Stack(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.3,
                  aspectRatio: 16 / 9,
                  autoPlay: true,
                  enlargeCenterPage: false,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: matchWidgets,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2,left: 2,right: 2),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width*0.96,
                    height: MediaQuery.of(context).size.height * 0.019,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: matches
                              .asMap()
                              .entries
                              .map((entry) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentIndex = entry.key;
                                });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.015,
                                height: MediaQuery.of(context).size.height * 0.015,
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentIndex == entry.key ? Colors.blue : Colors.grey,
                                ),
                              ),
                            );
                          })
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }else{
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}


//Rugby
class Rugbyc extends StatefulWidget {
  const Rugbyc({super.key});

  @override
  _RugbycState createState() => _RugbycState();
}

class _RugbycState extends State<Rugbyc> with AutomaticKeepAliveClientMixin {
  late Future<List<Rugby>> nba;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    nba = DataFetcher().fetchrugby();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure that the mixin's build is called.
    return FutureBuilder<List<Rugby>>(
      future: nba,
      builder: (context, snapshot) {
        if(snapshot.connectionState==ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }else if(!snapshot.hasData){
          return const Center(child: Text("No data"));
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${snapshot.error}"),
                const SizedBox(height: 10),
                IconButton(
                  onPressed: () {
                    setState(() {
                      nba = DataFetcher().fetchrugby();
                    });
                  },
                  icon: const Icon(Icons.refresh, color: Colors.black),
                ),
                const Text('Refresh'),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          final matches = snapshot.data!;
          final matchWidgets = matches.map((match) => RugbyW(match)).toList();

          return Stack(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.3,
                  aspectRatio: 16 / 9,
                  autoPlay: true,
                  enlargeCenterPage: false,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: matchWidgets,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2,left: 2,right: 2),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width*0.96,
                    height: MediaQuery.of(context).size.height * 0.019,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: matches
                              .asMap()
                              .entries
                              .map((entry) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentIndex = entry.key;
                                });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.015,
                                height: MediaQuery.of(context).size.height * 0.015,
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentIndex == entry.key ? Colors.blue : Colors.grey,
                                ),
                              ),
                            );
                          })
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }else{
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}


//Volleyball
class Volleyballc extends StatefulWidget {
  const Volleyballc({super.key});

  @override
  _VolleyballcState createState() => _VolleyballcState();
}

class _VolleyballcState extends State<Volleyballc> with AutomaticKeepAliveClientMixin {
  late Future<List<Volleyball>> nba;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    nba = DataFetcher().fetchvolleyball();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure that the mixin's build is called.
    return FutureBuilder<List<Volleyball>>(
      future: nba,
      builder: (context, snapshot) {
        if(snapshot.connectionState==ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }else if(!snapshot.hasData){
          return const Center(child: Text("No data"));
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${snapshot.error}"),
                const SizedBox(height: 10),
                IconButton(
                  onPressed: () {
                    setState(() {
                      nba = DataFetcher().fetchvolleyball();
                    });
                  },
                  icon: const Icon(Icons.refresh, color: Colors.black),
                ),
                const Text('Refresh'),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          final matches = snapshot.data!;
          final matchWidgets = matches.map((match) => VolleyballW(match)).toList();
          return Stack(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.3,
                  aspectRatio: 16 / 9,
                  autoPlay: true,
                  enlargeCenterPage: false,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: matchWidgets,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2,left: 2,right: 2),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width*0.96,
                    height: MediaQuery.of(context).size.height * 0.019,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: matches
                              .asMap()
                              .entries
                              .map((entry) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentIndex = entry.key;
                                });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.015,
                                height: MediaQuery.of(context).size.height * 0.015,
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentIndex == entry.key ? Colors.blue : Colors.grey,
                                ),
                              ),
                            );
                          })
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }else{
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

//Hockey
class Hockeyc extends StatefulWidget {
  const Hockeyc({super.key});

  @override
  _HockeycState createState() => _HockeycState();
}

class _HockeycState extends State<Hockeyc> with AutomaticKeepAliveClientMixin {
  late Future<List<Hockey>> nba;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    nba = DataFetcher().fetchhockey();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure that the mixin's build is called.
    return FutureBuilder<List<Hockey>>(
      future: nba,
      builder: (context, snapshot) {
        if(snapshot.connectionState==ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }else if(!snapshot.hasData){
          return const Center(child: Text("No data"));
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${snapshot.error}"),
                const SizedBox(height: 10),
                IconButton(
                  onPressed: () {
                    setState(() {
                      nba = DataFetcher().fetchhockey();
                    });
                  },
                  icon: const Icon(Icons.refresh, color: Colors.black),
                ),
                const Text('Refresh'),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          final matches = snapshot.data!;
          final matchWidgets = matches.map((match) => HockeyW(match)).toList();

          return Stack(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.3,
                  aspectRatio: 16 / 9,
                  autoPlay: true,
                  enlargeCenterPage: false,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: matchWidgets,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2,left: 2,right: 2),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width*0.96,
                    height: MediaQuery.of(context).size.height * 0.019,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: matches
                              .asMap()
                              .entries
                              .map((entry) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentIndex = entry.key;
                                });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.015,
                                height: MediaQuery.of(context).size.height * 0.015,
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentIndex == entry.key ? Colors.blue : Colors.grey,
                                ),
                              ),
                            );
                          })
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }else{
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
class SportsNews extends StatefulWidget {
  String genre;
  SportsNews({super.key,required this.genre});

  @override
  _SportsNewsState createState() => _SportsNewsState();
}

class _SportsNewsState extends State<SportsNews> with AutomaticKeepAliveClientMixin {
  late Future<List<News>> news;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    setState(() {
      news = DataFetcher().fetchNews(genre: widget.genre);
    });
    getData();
  }
  void getData()async{
    await Future.delayed(const Duration(milliseconds: 150));
    setState(() {
      news = DataFetcher().fetchNews(genre: widget.genre);
    });
  }
  @override
  void didUpdateWidget(covariant SportsNews oldWidget) {
    if (oldWidget.genre != widget.genre) {
      setState(() {
        news = DataFetcher().fetchNews(genre: widget.genre);
      });
    }
    super.didUpdateWidget(oldWidget);
  }
  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure that the mixin's build is called.
    return FutureBuilder<List<News>>(
      future: news,
      builder: (context, snapshot) {
        if(snapshot.connectionState==ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }else if(!snapshot.hasData){
          return const Center(child: Text("No Data"));
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${snapshot.error}"),
                const SizedBox(height: 10),
                IconButton(
                  onPressed: () {
                    news = DataFetcher().fetchNews(genre: widget.genre);
                    setState(() {});
                  },
                  icon: const Icon(Icons.refresh, color: Colors.black),
                ),
                const Text('Refresh'),
              ],
            ),
          );
        }else if (snapshot.hasData) {
          final data = snapshot.data!;
          final matchWidgets = data.map((match) => NewsWidget(data: match,)).toList();
          return Stack(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.3,
                  aspectRatio: 16 / 9,
                  autoPlay: true,
                  enlargeCenterPage: false,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: matchWidgets,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(left: 2,right: 2),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width*0.96,
                    height: MediaQuery.of(context).size.height * 0.019,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: data
                              .asMap()
                              .entries
                              .map((entry) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentIndex = entry.key;
                                });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.015,
                                height: MediaQuery.of(context).size.height * 0.015,
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentIndex == entry.key ? Colors.blue : Colors.grey,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }else{
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}


class NewsWidget extends StatefulWidget {
  News data;
  NewsWidget({super.key,required this.data});

  @override
  State<NewsWidget> createState() => _NewsWidgetState();
}

class _NewsWidgetState extends State<NewsWidget> {
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        _launchURL(widget.data.link);
        //Navigator.push(context, MaterialPageRoute(builder: (context)=>SportNews(title: widget.data.title,
        // content: widget.data.content, url: widget.data.imageUrl)));
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              imageUrl: widget.data.imageUrl,
              progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                child: SizedBox(
                  width: 35,
                  height: 35,
                  child: CircularProgressIndicator(
                    value: downloadProgress.progress,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => const Center(child: Icon(Icons.error,color: Colors.white,size: 40,)),
            ),
          ),


          Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10,left: 5,right: 5),
                child: Text(widget.data.title.toString(),style:const TextStyle(fontWeight: FontWeight.bold,backgroundColor: Colors.white)),
              )),


        ],
      ),
    );
  }
}

class NewsWidget1 extends StatefulWidget {
  News data;
  NewsWidget1({super.key,required this.data});

  @override
  State<NewsWidget1> createState() => _NewsWidget1State();
}

class _NewsWidget1State extends State<NewsWidget1> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.data.title.toString(),style:const TextStyle(fontWeight: FontWeight.bold,fontSize:16)),
        Image.network(
          widget.data.imageUrl,
          fit: BoxFit.fill,
          width: MediaQuery.of(context).size.width * 0.99,
          height: MediaQuery.of(context).size.height * 0.275,
        ),
        Text(widget.data.content.toString())

      ],
    );
  }
}

class SportNews extends StatelessWidget {
  String title;
  String url;
  String content;
  SportNews({super.key,required this.title,required this.content,required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading:IconButton(onPressed: (){
          Navigator.pop(context);
        },icon: const Icon(Icons.arrow_back,color: Colors.black,),),
        title:const Text('Sports News',style: TextStyle(color: Colors.black)),
        elevation:1,
      ),
      body:SingleChildScrollView(
        scrollDirection:Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Column(
              children:[
                Text(title.toString(),style:const TextStyle(fontWeight: FontWeight.bold,fontSize:16)),
                CachedNetworkImage(
                  fit: BoxFit.fill,
                  width: MediaQuery.of(context).size.width * 0.99,
                  height: MediaQuery.of(context).size.height * 0.275,
                  imageUrl:url,
                  progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                    child: SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        value: downloadProgress.progress,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Center(child: Icon(Icons.error,color: Colors.white,size: 40,)),
                ),
                Text(content.toString()),
                const SizedBox(height: 10,)
              ]
          ),
        ),
      ),
    );
  }
}

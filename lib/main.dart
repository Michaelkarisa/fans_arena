import 'package:fans_arena/fans/components/likebutton.dart';
import 'package:fans_arena/fans/screens/notifications.dart';
import 'package:fans_arena/reusablewidgets/adstrial.dart';
import 'package:fans_arena/reusablewidgets/firebaseanalytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'appid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'clubs/screens/lineupcreation.dart';
import 'fans/data/newsfeedmodel.dart';
import 'fans/data/notificationsmodel.dart';
import 'fans/data/videocontroller.dart';
import 'fans/screens/matchwatch.dart';
import 'fans/screens/messages.dart';
import 'joint/data/screens/feed_item.dart';
import 'joint/filming/data/filming0.dart';
import 'professionals/screens/splashscreen.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
 // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
   SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
     statusBarColor: Colors.white,
     statusBarIconBrightness: Brightness.dark,
   ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [

  ]);
  SystemChrome.setPreferredOrientations( [DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });
   await NetworkProvider().connectivity();
  await for (var _ in Stream.fromFuture(ApiData.instance.dataStream.first)) {
    final apiData = ApiData.instance;
    appId = apiData.agoraapi;
    appIkey = apiData.appIkey;
    mConsumerKey = apiData.mConsumerKey;
    mConsumerSecret = apiData.mConsumerSecret;
    newsapikey = apiData.newsapikey;
    tokenserver = apiData.tokenserver;
    footballapi = apiData.footballapi;
    muxTokenId = apiData.muxTokenId;
    muxTokenSecret = apiData.muxTokenSecret;
    agorasecret=apiData.agorasecret;
    agorakey=apiData.agorakey;
    fcmserverkey=apiData.fcmTokenServerkey;
    mapsApi= apiData.mapsApi;
    emailApi= apiData.emailApi;
  }
  await NotifyFirebase().initNotifications();
  ApiData.instance.dispose();
  await NotifyFirebase().notify();
  //MobileAds.instance.initialize();
  EventLogger().openApp();
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    return MultiProvider(
      providers: [
        Provider(create: (_) => Newsfeedservice()),
        ChangeNotifierProvider(create:(_) => FilmingProvider()),
        ChangeNotifierProvider(create:(_) => MatchwatchProvider()),
        ChangeNotifierProvider(create:(_) => VideoControllerProvider()),
        ChangeNotifierProvider(create:(_) => LineUpProvider()),
        ChangeNotifierProvider(create:(_) => AdProvider()),
        ChangeNotifierProvider(create:(_) => LikingProvider()),
        ChangeNotifierProvider(create:(_) => MessageProvider()),
        ChangeNotifierProvider(create:(_) => ViewsProvider()),
        ChangeNotifierProvider(create:(_) => NetworkProvider()),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Fans Arena',
          navigatorKey: navigatorKey,
          home: const Splashscreen(),
        routes:{
          NotificationsScreen.route:(context)=> const NotificationsScreen(allnotifications: [], hroute: false,),}
      ),
    );
  }
}

class NetworkProvider extends ChangeNotifier{

  List<ConnectivityResult> _connectivityResult = [];
  bool isConnected = false;
  bool isNetworkResumed = false;
  Future<void> connectivity()async{
    await NetworkProvider().checkInternetConnection();
    Connectivity().onConnectivityChanged.listen((result) async{
       connection=await connected();
      _connectivityResult = result;
      if (result != ConnectivityResult.none && !isConnected) {
        isConnected = true;
        isnonet=false;
        if (isNetworkResumed) {
          showToastMessage('Network connection has resumed');
          isNetworkResumed = false;
          notifyListeners();
        }
        notifyListeners();
      } else if (result == ConnectivityResult.none && isConnected) {
        isConnected = false;
        isNetworkResumed = true;
        isnonet=true;
        showToastMessage('No internet connection');
        notifyListeners();
      }
      notifyListeners();
    });
    notifyListeners();
  }
  Future<bool> connected() async {
    try {
      final response = await http.get(
          Uri.parse('http://clients3.google.com/generate_204'));
      if (response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
  void showToastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
    );
  }


  Future<void> checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _connectivityResult = connectivityResult;
    connection=await connected();
    if (_connectivityResult != ConnectivityResult.none) {
      isConnected = true;
      isnonet=false;
      if (!isNetworkResumed) {
        isNetworkResumed = true;
        notifyListeners();
      }
      notifyListeners();
    } else {
      isConnected = false;
      isnonet=true;
      notifyListeners();
    }
    notifyListeners();
  }


}

class Readmore extends StatefulWidget {
  final String text;
  final Color? color;
  List<String> hashes;
  Readmore({Key? key,
    required this.text,
    this.color,
    required this.hashes}) : super(key: key);

  @override
  State<Readmore> createState() => _ReadmoreState();
}

class _ReadmoreState extends State<Readmore> {
  bool isExpanded = false;
  int maxTextLength = 150;
  String username='';
  @override
  void initState() {
    super.initState();
    setState(() {
      username = _truncateText(widget.text);
    });
  }

  String _truncateText(String text) {
    if (text.length <= maxTextLength) {
      return text;
    } else if (text.length > maxTextLength && !isExpanded) {
      return "${text.substring(0, maxTextLength-5)}...";
    } else {
      return "$text ";
    }
  }

  double calculateTextWidth(String text) {
    double totalWidth = 0.0;
    for (int i = 0; i < text.length; i++) {
      totalWidth += calculateCharacterWidth(text[i]);
    }
    return totalWidth;
  }

  double calculateCharacterWidth(String character) {
    if (character == ' ') {
      return 4.0;
    }else {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(text: character, style: TextStyle()),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: double.infinity);
      return textPainter.width;
    }
  }

  double calculateCharacterHeight(String character) {
    if (character == ' ') {
      return 4.0;
    }else {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(text: character, style: TextStyle()),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: double.infinity);
      return textPainter.width;
    }
  }
  Widget _moreString() {
    double width=MediaQuery.of(context).size.width*0.84;
    //double height=calculateCharacterHeight(widget.text[0])*(calculateTextWidth(widget.text)/width);
    if(isExpanded){
      return SizedBox(
        width: width,
        height:MediaQuery.of(context).size.height*0.238663484,
        child: ListView.builder(
          itemCount: 2,
          scrollDirection: Axis.vertical,
          physics: ScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            if(index==0){
              return RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$username $username",
                      style: TextStyle(
                          color: widget.color ?? Colors.black
                      ),
                    ),
                    TextSpan(
                      text: isExpanded
                          ? ' less'
                          : ' more',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          setState(() {
                            isExpanded = !isExpanded;
                            username = _truncateText(widget.text);
                          });
                        },
                    ),
                  ],
                ),
              );
            }else{
              return  Wrap(
                children: widget.hashes.map((h)=> Text('#$h', style: const TextStyle(color: Colors.blue)),
                ).toList(),
              );
            }
          },
        ),
      );}else{
      return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: username,
                style: TextStyle(
                    color: widget.color ?? Colors.black
                ),
              ),
              TextSpan(
                text: isExpanded
                    ? ' less'
                    : ' more',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    setState(() {
                      isExpanded = !isExpanded;
                      username = _truncateText(widget.text);
                    });
                  },
              ),

            ],
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.text.length <= maxTextLength){
      return Text(username, style: TextStyle(color: widget.color ?? Colors.black));
    }else{
      return _moreString();
    }}
}


class Readmore1 extends StatefulWidget {
  final String text;
  final Color? color;
  Readmore1({Key? key, required this.text, this.color,}) : super(key: key);

  @override
  State<Readmore1> createState() => _Readmore1State();
}

class _Readmore1State extends State<Readmore1> {
  bool isExpanded = false;
  int maxTextLength = 200;
  String username='';
  @override
  void initState() {
    super.initState();
    setState(() {
      username = _truncateText(widget.text);
    });
  }
  String _truncateText(String text) {
    if (text.length <= maxTextLength) {
      return text;
    } else if (text.length > maxTextLength && !isExpanded) {
      return "${text.substring(0, maxTextLength-5)}...";
    } else {
      return text;
    }
  }


  Widget _moreString() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: username,
            style: TextStyle(
                color: widget.color ?? Colors.black
            ),
          ),
          const TextSpan(
            text: ' ',
          ),
          TextSpan(
            text: isExpanded
                ? 'less'
                : 'more',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                setState(() {
                  isExpanded = !isExpanded;
                  username = _truncateText(widget.text);
                });
              },
          ),

        ],
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    if(widget.text.length <= maxTextLength){
     return Text(username,
          style: TextStyle(
          color: widget.color ?? Colors.black
      ),
    );
    }else{
      return _moreString();
    }}
}




class ReadMore0 extends StatefulWidget {
  final String text;
  final Color? color;
  ReadMore0({Key? key, required this.text, this.color,}) : super(key: key);

  @override
  State<ReadMore0> createState() => _ReadMore0State();
}

class _ReadMore0State extends State<ReadMore0> {
  bool isExpanded = false;
  int maxTextLength = 500;
  String username='';
  @override
  void initState() {
    super.initState();
    setState(() {
      username = _truncateText(widget.text);
    });
  }


  String _truncateText(String text) {
    if (text.length <= maxTextLength) {
      return text;
    } else if (text.length > maxTextLength && !isExpanded) {
      return "${text.substring(0, maxTextLength-5)}...";
    } else {
      return text;
    }
  }


  Widget _moreString() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$username",
            style: TextStyle(
                color: widget.color ?? Colors.black
            ),
          ),
          TextSpan(
            text: isExpanded
                ? ' less'
                : ' more',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                setState(() {
                  isExpanded = !isExpanded;
                  username = _truncateText(widget.text);
                });
              },
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    if( widget.text.length <= maxTextLength){
      return Text("$username",style: TextStyle(color: widget.color ?? Colors.black),);
    }else{
      return _moreString();
    }}
}


class ReplyW extends StatefulWidget {
  final String text;
  final Color? color;
  ReplyW({Key? key, required this.text, this.color,}) : super(key: key);

  @override
  State<ReplyW> createState() => _ReplyWState();
}

class _ReplyWState extends State<ReplyW> {
  int maxTextLength = 100;
  String username='';
  @override
  void initState() {
    super.initState();
    setState(() {
      username = _truncateText(widget.text);
    });
  }

  @override
  void didUpdateWidget(covariant ReplyW oldWidget) {
    if (oldWidget.text != widget.text) {
      setState(() {
        username = _truncateText(widget.text);
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  String _truncateText(String text) {
    if (text.length <= maxTextLength) {
      return text;
    } else if (text.length > maxTextLength) {
      return "${text.substring(0, maxTextLength-5)}...";
    } else {
      return "$text ";
    }
  }
  @override
  Widget build(BuildContext context) {
      return RichText(
          maxLines:widget.text.length~/10,
          text: TextSpan(
              children: [
                TextSpan(
                  text: username,
                  style: TextStyle(
                      color: widget.color ?? Colors.black
                  ),
                ),]));
    }
}
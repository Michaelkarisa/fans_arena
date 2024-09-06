import 'package:fans_arena/fans/bloc/accountchecker5.dart';
import 'package:fans_arena/fans/screens/highlights.dart';
import 'package:fans_arena/fans/screens/notifications.dart';
import 'package:fans_arena/fans/screens/results.dart';
import 'package:fans_arena/joint/components/colors.dart';
import 'package:fans_arena/reusablewidgets/firebaseanalytics.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:geolocator/geolocator.dart';
import '../../appid.dart';
import '../../joint/data/sportsapi/sportsapi.dart';
import 'package:uuid/uuid.dart';
import '../../main.dart';
import '../../reusablewidgets/googlepay.dart';
import '../components/bottomnavigationbar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'newsfeed.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<NotificationModel>allnotifications = [];
  bool container1Visible = false;
  bool container2Visible = false;
  bool container3Visible = false;
 String collectionName='';
  bool isLoading = true;
late DateTime  _startTime;
  late NetworkProvider connectivityProvider;

  @override
  void initState() {
    super.initState();
    getCount();
    retrieveUserData1();
    // Access the provider and listen for changes
    connectivityProvider = Provider.of<NetworkProvider>(context, listen: false);
    // Add a listener to react to changes in connectivity
    connectivityProvider.addListener(_connectivityChanged);
    // Optionally, start checking connectivity in initState
    connectivityProvider.connectivity();
    _startTime = DateTime.now();
    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() {
        container1Visible = true;
      });
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        container2Visible = true;
      });
    });

    Future.delayed(const Duration(milliseconds: 750), () {
      setState(() {
        container3Visible = true;
      });
    });
  }
  Future<void> getLikeCount()async {
    allnotifications =await DataFetcher().getNotifications();
    setState(() {
      Count = allnotifications.length;
      allnotifications.sort((a, b){
        Timestamp latestTimestampA = a.timestamp;
        Timestamp latestTimestampB = b.timestamp;
        return latestTimestampB.compareTo(latestTimestampA);
      });
    });
    await setCount();
  }
  int Count=0;
  Future<void> setCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setInt('count', Count);
    });

  }
  void getCount()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      genre = prefs.getString('genre')??"Football";
      count = prefs.getInt('count')??0;
    });
  }

String genre="Football";
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

int count=0;

 void retrieveUserData1() async {
   SharedPreferences prefs = await SharedPreferences.getInstance();
   if(prefs.getBool('signup')==null&&prefs.getBool('signin')==null&&prefs.getString('cname')==null){
     setCamera2();
   }else if(prefs.getBool('signup')!=null){
     setCamera1();
     setState(() {
       prefs.remove('signup');
     });
   }else if(prefs.getBool('signin')!=null){
     setCamera();
     setState(() {
       prefs.remove('signin');
     });
   }
 }

  void setCamera(){
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title:const Text('Welcome back to Fans Arena',style: TextStyle(fontSize: 20),),
            content: SizedBox(
              height: collectionNamefor=="Club"||collectionNamefor=="Professional"?130:50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 50,
                    child: AnimatedTextKit(
                      totalRepeatCount: 1,
                      pause: const Duration(milliseconds: 200),
                      animatedTexts: [
                        TyperAnimatedText(
                          'You logged in as a $collectionNamefor account $username!.',
                          curve: Curves.linear,
                          textStyle: const TextStyle(fontSize: 14),
                          speed: const Duration(milliseconds: 150),
                        ),
                      ],
                    ),
                  ),

                  if(collectionNamefor=="Club"||collectionNamefor=="Professional")
                    SizedBox(
                      height: 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top:5,bottom: 5),
                            child: Text('New offers just for you check out.'),
                          ),
                          Button(text: 'check them out', onTap: (){
                             getFilm().then((value) =>  Navigator.of(context, rootNavigator: true).pop());
                          },colorA:0xFF00B4DB, colorB: 0xFF0083B0, fsize: 14,),
                        ],
                      ),)
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(onPressed: (){
                   getProfile().then((value) => Navigator.of(context, rootNavigator: true).pop());
                    }, child: const Text('visit profile')),
                  TextButton(onPressed: (){Navigator.of(context, rootNavigator: true).pop();}, child: const Text('dismis')),
                ],)
            ],
          );
        }
    );}

  void setCamera1(){
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)),
        title: const Text('Welcome to Fans Arena',style: TextStyle(fontSize: 20),),
        content: SizedBox(
          height: collectionNamefor=="Club"||collectionNamefor=="Professional"?210:100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
                child: AnimatedTextKit(
                  totalRepeatCount: 1,
                  pause: const Duration(milliseconds: 200),
                  animatedTexts: [
                    TyperAnimatedText(
                      '$username,The Account You have Created is a $collectionName account'
                          '. This account will determine your role in the app.'
                          ' To customize your profile press visit profile then edit profile',
                      curve: Curves.linear,
                      textStyle: const TextStyle(fontSize: 14),
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                ),
              ),

              if(collectionNamefor=="Club"||collectionNamefor=="Professional")
                SizedBox(
                  height: 95,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top:5,bottom: 5),
                        child: Text('visit the filming page to check out different streaming packages'
                            ' and free trial to find out which package is suitable for you.'),
                      ),
                      Button(text: 'check them out', onTap: (){
                        getFilm().then((value) => Navigator.of(context, rootNavigator: true).pop());

                      },colorA:0xFF00B4DB, colorB: 0xFF0083B0, fsize: 14,),
                    ],
                  ),)
            ],
          ),
        ),
     actions: [
       Row(
         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
         children: [
           TextButton(onPressed: (){
              getProfile().then((value) => Navigator.of(context, rootNavigator: true).pop());
             }, child: const Text('visit profile')),
         TextButton(onPressed: (){Navigator.of(context, rootNavigator: true).pop();}, child: const Text('dismis')),
       ],)
     ],
      );
        }
    );}
 void setCamera2(){
   showDialog(
       barrierDismissible: false,
       context: context,
       builder: (context) {
         return AlertDialog(
           shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(20.0)),
           title: const Text('Welcome to Fans Arena',style: TextStyle(fontSize: 20),),
           content: AnimatedTextKit(
             totalRepeatCount: 1,
             pause: const Duration(milliseconds: 200),
             animatedTexts: [
               TyperAnimatedText(
                 'First time at Fans Arena ? To create an account press sign in , then sign up on the login screen, choose the account of your choice and follow the provided steps to create an account.',
                 curve: Curves.linear,
                 textStyle: const TextStyle(fontSize: 14),
                 speed: const Duration(milliseconds: 80),
               ),
             ],
           ),
           actions: [
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: [
                 TextButton(onPressed: (){
                   getProfile().then((value) => Navigator.of(context, rootNavigator: true).pop());
                  }, child: const Text('sign in')),
               TextButton(onPressed: (){Navigator.of(context, rootNavigator: true).pop();}, child: const Text('dismis')),
             ],)
           ],
         );
       }
   );}

 Future<void> getFilm()async {
   Bottomnavbar.setCamera3(context);
 }
 Future<void> getProfile()async {
   Bottomnavbar.setCamera1(context);
 }
 @override
 void dispose(){
   EventLogger().screenView('Homescreen', 'Homescreen', _startTime);
   Engagement().engagement('Homescreen',_startTime,'');
   connectivityProvider.removeListener(_connectivityChanged);
   super.dispose();
 }
  Future<void> _connectivityChanged() async {
    if (connectivityProvider.isConnected) {
      getLikeCount();
    } else {
      getLikeCount();
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
        if (MediaQuery.of(context).size.width> 600) {
          return
        Scaffold(
        backgroundColor: Colors.white,
          resizeToAvoidBottomInset:false,
          appBar: AppBar(
          elevation: 1,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
                height: MediaQuery.of(context).size.height * 0.085,
                child: Stack(
                  children: [IconButton(
                      icon: Icon(Icons.notifications_none,color: Colors.black,size: MediaQuery.sizeOf(context).height*0.046,),
                      onPressed: () {
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context) =>   NotificationsScreen(allnotifications: allnotifications, hroute: true,),
                          ),
                        );
                      }
                  ),
                    Align(
                        alignment: Alignment.topRight,
                        child:  Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: allnotifications.length>count? Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ):const Text(''),

                        )
                    )
               ] ),
              ),
            ),
          ],
          title: Text('Fans Arena', style: TextStyle(color: Textn),),
          backgroundColor: Appbare,
        ),
        body: RefreshIndicator(
          onRefresh: ()async {
          },
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child:  Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Accountchecker5H(),
                  ),
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    width: container1Visible ? MediaQuery.of(context).size.width * 0.33:0,
                    height: MediaQuery.of(context).size.height * 1,
                    child:Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            color: Colors.white60,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: Colors.white,
                        child: const Accountchecker5()),
                  ),
                ],
              ),
            ),

                Column(
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context) =>  Results(genre: genre,),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Sports News',style: TextStyle(color: Colors.blueGrey,fontSize: 22,fontWeight: FontWeight.bold)),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      width: container2Visible ? MediaQuery.of(context).size.width * 0.33:0,
                                  height: MediaQuery.of(context).size.height * 1,
                                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  margin: const EdgeInsets.all(2.0),
                                  child: Stack(
                      children: [
                        Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                color: Colors.white60,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            color: Colors.white,
                            child: container2Visible ?  SportsNews(genre: genre,):const SizedBox.shrink()),
                      ]),
                                ),
                  ],
                ),

                Column(
                  children: [
                    Align(
                        alignment: Alignment.topCenter,
                        child: InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>MatchFixture(genre: genre)));
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Match Fixtures',style: TextStyle(color: Colors.blueGrey,fontSize: 22,fontWeight: FontWeight.bold),),
                            ))),
                    AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      width: container3Visible ? MediaQuery.of(context).size.width * 0.33:0,
                      height: MediaQuery.of(context).size.height * 1,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15)
                      ),
                      margin: const EdgeInsets.all(2.0),
                      child: Stack(
                        children: [
                          Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                color: Colors.white60,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            color: Colors.white,
                            child:container3Visible? Matcheslider(genre: genre,):const SizedBox.shrink()
                            ),
                      ]),
                    ),
                  ],
                )
              ]
            ),
          ),
        ),
            );
          }else{
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 1,
              automaticallyImplyLeading: false,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: MediaQuery.of(context).size.height * 0.085,
                    child: Stack(
                        children: [IconButton(
                            icon: Icon(Icons.notifications_none,color: Colors.black,size: MediaQuery.sizeOf(context).height*0.046,),
                            onPressed: () {
                              Navigator.push(context,
                                MaterialPageRoute(builder: (context) =>  NotificationsScreen(allnotifications: allnotifications, hroute: true,),
                                ),
                              );
                            }
                        ),
                          Align(
                            alignment: Alignment.topRight,
                            child:  Padding(
                              padding: const EdgeInsets.only(top: 7),
                              child: allnotifications.length>count? Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      ):const Text(''),
                            )
                          )] ),
                  ),
                ),
              ],
              title: Text('Fans Arena', style: TextStyle(color: Textn),),
              backgroundColor: Appbare,
            ),
            resizeToAvoidBottomInset: false,
            body: RefreshIndicator(
              onRefresh: ()async {
                await _connectivityChanged();
              },
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.only(left: 3,right: 3),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: Accountchecker5H()),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6,),
                          child:InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>  PaymentOptionsPage()));
                            },
                            child: AnimatedContainer(
                              duration: const Duration(seconds: 1),
                              width: container1Visible ? MediaQuery.of(context).size.width:0,
                              child:Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                      color: Colors.white60,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  color: Colors.white,
                                  child: const Accountchecker5()),
                            ),
                          ),
                        ),
                        Center(
                          child: InkWell(
                            onTap: (){
                              Navigator.push(context,
                                MaterialPageRoute(builder: (context) =>  Results(genre: genre,),
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Sports News',style: TextStyle(color: Colors.blueGrey,fontSize: 22,fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(seconds: 1),
                          width: container2Visible ? MediaQuery.of(context).size.width:0,
                          height: MediaQuery.of(context).size.height * 0.265,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          margin: const EdgeInsets.all(2.0),
                          child: Stack(
                              children: [
                                Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        color: Colors.white60,
                                      ),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    color: Colors.white,
                                    child:container2Visible ? SportsNews(genre: genre,):const SizedBox.shrink()),
                              ]),
                        ),
                        Center(
                          child: InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>MatchFixture(genre: genre)));
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Match Fixtures',style: TextStyle(color: Colors.blueGrey,fontSize: 22,fontWeight: FontWeight.bold),),
                              )),
                        ),
                        AnimatedContainer(
                          duration: const Duration(seconds: 1),
                          width: container3Visible ? MediaQuery.of(context).size.width:0,
                          height: MediaQuery.of(context).size.height * 0.265,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15)
                          ),
                          margin: const EdgeInsets.all(2.0),
                          child: Stack(
                              children: [
                                Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                      color: Colors.white60,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  color: Colors.white,
                                  child:container3Visible? Matcheslider(genre: genre,):const SizedBox.shrink()
                                  ),
                              ]),
                        ),
                        const SizedBox(
                          height: 70,
                        ),
                      ]
                  ),
                ),
              ),
            ),
          );
        }
        }
        ),
      );
    }
}
class Engagement{
  String generateUniqueNotificationId() {
    final String uniqueId = const Uuid().v4();
    return uniqueId;
  }

  double watchhours=0.0;
  Future<void> engagement(String activity,DateTime startTime,String otheruser ) async {
    location= await getCurrentLocation();
    final timeSpentInSeconds = DateTime.now().difference(startTime).inSeconds;
    final newHoursSpent = timeSpentInSeconds / 3600;
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection('Engagement')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('engagement');
String engageId=generateUniqueNotificationId();
    final Timestamp timestamp = Timestamp.now();
    final like = {
      'engageId': engageId,
      'timestamp': timestamp,
      'timespent':newHoursSpent,
      'activity ':activity,
      'otheruser':otheruser,
      'latitude': location.latitude,
      'longitude': location.longitude,
    };
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    if (documents.isNotEmpty) {
      final DocumentSnapshot latestDoc = documents.first;
      List<dynamic> likesArray = latestDoc['engagement'];
      if (likesArray.length < 10000) {
        likesArray.add(like);
        await latestDoc.reference.update({'engagement': likesArray});
      } else {
        await likesCollection.add({'engagement': [like]});
      }
    } else {
      await likesCollection.add({'engagement': [like]});
    }
  }
  late Position location;
  Future<Position> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return position;
  }
}


class Button extends StatefulWidget {
  int colorA;
  int colorB;
  String text;
  double fsize;
  void Function() onTap;
  Button({super.key, required this.text,required this.onTap,required this.colorA,required this.colorB,required this.fsize});
  @override
  _ButtonState createState() => _ButtonState();
}

class _ButtonState extends State<Button> with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _textBounceController;
  late Animation<Alignment> top;
  late Animation<Alignment> bottom;
  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
    _textBounceController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    top= TweenSequence<Alignment>(
      [
        TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topLeft,end: Alignment.topRight), weight:1),
        TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topRight,end: Alignment.bottomRight), weight:1),
        TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.bottomRight,end: Alignment.bottomLeft), weight:1),
        TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.bottomLeft,end: Alignment.topLeft), weight:1),
      ],
    ).animate(_gradientController);
    bottom= TweenSequence<Alignment>(
      [
        TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.bottomRight,end: Alignment.bottomLeft), weight:1),
        TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.bottomLeft,end: Alignment.topLeft), weight:1),
        TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topLeft,end: Alignment.topRight), weight:1),
        TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topRight,end: Alignment.bottomRight), weight:1),
      ],
    ).animate(_gradientController);

  }

  @override
  void dispose() {
    _gradientController.dispose();
    _textBounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: ElevatedButton(
        onPressed: (){
          widget.onTap();
          },
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(3.0),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.blue.withOpacity(0.1);
              }
              return Colors.white;
            },
          ),
        ),
        child: AnimatedBuilder(
          animation: _gradientController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(widget.colorA),
                    Color(widget.colorB),
                  ],
                  begin: top.value,
                  end: bottom.value,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: AnimatedBuilder(
                  animation: _textBounceController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1 + _textBounceController.value * 0.2,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10,bottom: 10,left: 20,right: 20),
                        child: Text(
                          widget.text,
                          style: TextStyle(
                            fontSize: widget.fsize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LineChartSample extends StatefulWidget {
  @override
  _LineChartSampleState createState() => _LineChartSampleState();
}

class _LineChartSampleState extends State<LineChartSample> {
  List<FlSpot> dataPoints = [
    FlSpot(0, 1),
    FlSpot(1, 1.5),
    FlSpot(2, 1.4),
    FlSpot(3, 3.4),
    FlSpot(4, 2),
    FlSpot(5, 2.2),
    FlSpot(6, 1.8),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interactive Line Chart'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.blueAccent,
                ),
                touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                  if (!event.isInterestedForInteractions ||
                      touchResponse == null ||
                      touchResponse.lineBarSpots == null) {
                    return;
                  }
                  final value = touchResponse.lineBarSpots![0].y;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Value: $value'),
                    ),
                  );
                },
                handleBuiltInTouches: true,
              ),
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d), width: 1),
              ),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: 4,
              lineBarsData: [
                LineChartBarData(
                  spots: dataPoints,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

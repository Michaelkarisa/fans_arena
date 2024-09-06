import 'package:fans_arena/fans/bloc/accountchecker13.dart';
import 'package:fans_arena/fans/bloc/accountchecker4.dart';
import 'package:cached_network_image/cached_network_image.dart' show CachedNetworkImage;
import 'package:fans_arena/fans/components/homebottomnav.dart';
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:fans_arena/joint/bloc/loginchecker.dart';
import 'package:fans_arena/joint/bloc/loginchecker1.dart';
import 'package:fans_arena/fans/screens/fans_tv.dart';
import 'package:fans_arena/fans/screens/search.dart';
import 'package:fans_arena/joint/components/animatedicon.dart';
import 'package:fans_arena/joint/components/animatedicon1.dart';
import 'package:fans_arena/joint/screens/camera.dart';
import 'package:fans_arena/reusablewidgets/firebaseanalytics.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../appid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/homescreen.dart';
class Bottomnavbar extends StatefulWidget {
  int? index;
  Bottomnavbar({super.key,this.index});

  @override
  State<Bottomnavbar> createState() => _BottomnavbarState();
  static void setCamera(BuildContext context, ){
    _BottomnavbarState? state = context.findAncestorStateOfType<_BottomnavbarState>();
    state?.setCamera();
  }
  static void setCamera1(BuildContext context, ){
    _BottomnavbarState? state = context.findAncestorStateOfType<_BottomnavbarState>();
    state?.setCamera1();
  }
  static void setCamera2(BuildContext context,PostModel1 post ){
    _BottomnavbarState? state = context.findAncestorStateOfType<_BottomnavbarState>();
    state?.setCamera2(post);
  }
  static void setCamera3(BuildContext context, ){
    _BottomnavbarState? state = context.findAncestorStateOfType<_BottomnavbarState>();
    state?.setCamera3();
  }
}

class _BottomnavbarState extends State<Bottomnavbar>
  with SingleTickerProviderStateMixin {

  Future<void> _setCname(String userId) async {
    Person p=await Newsfeedservice().getPerson(userId: userId);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      collectionNamefor=p.collectionName;
      username=p.name;
      profileimage=p.url;
      prefs.setString('cname', p.collectionName);
      prefs.setString('name',p.name);
      prefs.setString('profile', p.url);
      prefs.setString('genre', p.genre);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDrawerOpen = true;

  int _currentIndex = 0;

  DateTime? _startTime;

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  void load()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
    username=prefs.getString('name')??'';
    profileimage= prefs.getString('profile')??'';
    collectionNamefor=prefs.getString('cname')??"";
    });
    if(collectionNamefor.isEmpty||profileimage.isEmpty||username.isEmpty){
      _setCname(FirebaseAuth.instance.currentUser!.uid);
    }
  }
  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    load();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..reverse();
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0),
      end: const Offset(-1.0, 0),
    ).animate(_controller);
    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (msg == AppLifecycleState.paused.toString()) {
        _updateAppUsage();
      } else if (msg == AppLifecycleState.resumed.toString()) {
        _startTime = DateTime.now();
      }
      return Future.value('');
    });
  }
  void _updateAppUsage() async {
    final timeSpentInSeconds = DateTime.now().difference(_startTime!).inSeconds;
    final newHoursSpent = timeSpentInSeconds / 3600.0;
    final currentDate = DateTime.now();
    final currentDateWithoutTime = DateTime(currentDate.year, currentDate.month, currentDate.day);
    final appUsage = AppUsage(
      date: currentDateWithoutTime,
      hoursSpent: newHoursSpent,
    );
    await DatabaseHelper.instance.insertOrUpdateAppUsage(appUsage);
  }




   List<Widget> _pages = <Widget>[
  const Homebottomnav(index:0 ,),
  const Fans_tv(),
  const Accountchecker4(),
  const AccountChecker13(),
  const Search(),
  const Loginchecker1(),
  const Loginchecker(),
  const Camera(),
   ];

  void changePageState() {
    setState(() {
      _currentIndex = 0;
      _pages = [
        const Homebottomnav(index: 0,),
        const Fans_tv(),
        const Accountchecker4(),
        const AccountChecker13(),
        const Search(),
        const Loginchecker1(),
        const Loginchecker(),
        const Camera()
      ];
    });
  }
  bool isDrawerOpen = false;



setCamera(){
  setState(() {
    _currentIndex = 7;
  });
}
  setCamera1(){
    setState(() {
      _currentIndex = 6;

    });
  }
  late PostModel1 post1;
  setCamera2(PostModel1 post){
    setState(() {
      _currentIndex = 1;
post1=post;
    });
  }
  setCamera3(){
    setState(() {
      _currentIndex = 5;

    });
  }

  late AnimationController _controller1;
  @override
  Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Fans Arena',
    home:SafeArea(
    child: SizedBox(
      width: MediaQuery.of(context).size.width,
      height:MediaQuery.of(context).size.height ,
      child: Stack(
      children: [
      WillPopScope(
        onWillPop: () async {
          if (_currentIndex > 0) {
            setState(() {
              _currentIndex = 0;
            });
            return false;
          }
          return true;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        body: Center(
        child:_pages[_currentIndex],
        ),
        ),
      ),
        AnimatedBuilder(
          builder: (BuildContext, Widget) {
            return SlideTransition(
              position: _offsetAnimation,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (MediaQuery.of(context).size.height >650) {
                    return Align(
                      alignment:  const Alignment(-0.95,0.7),
                      child: Material(
                        color: Colors.white,
                        elevation: 5,
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.32,
                          height: MediaQuery.of(context).size.height * 0.26,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.06,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.125,
                                      height: MediaQuery.of(context).size.height * 0.057,
                                      child: BottomNavItem1(
                                        label: 'Home',
                                        isSelected: _currentIndex == 0,
                                        onTap: () {
                                          setState(() => _currentIndex = 0);
                                          EventLogger().logButtonPress('Home', 'setState to Home page');
                                        },
                                        child: Icon(Icons.home, size: MediaQuery.sizeOf(context).height*0.037,),
                                      ),
                                    ),

                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.125,
                                      height: MediaQuery.of(context).size.height * 0.057,
                                      child: BottomNavItem1(
                                        label: 'FansTV',
                                        isSelected: _currentIndex == 1,
                                        onTap: () {
                                          setState(() => _currentIndex = 1);
                                          EventLogger().logButtonPress('FansTv', 'setState to FansTv page');
                                        },
                                        child: Icon(Icons.live_tv,size: MediaQuery.sizeOf(context).height*0.037,),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.057,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children:[
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.125,
                                      height: MediaQuery.of(context).size.height * 0.057,
                                      child: BottomNavItem1(
                                        label: 'Events',
                                        isSelected: _currentIndex == 2,
                                        onTap: (){ setState(() => _currentIndex = 2);EventLogger().logButtonPress('Events', 'setState to Events page');},
                                        child: Icon(Icons.event_sharp,size: MediaQuery.sizeOf(context).height*0.037,),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.125,
                                      height: MediaQuery.of(context).size.height * 0.057,
                                      child: BottomNavItem1(
                                        label: 'Camera',
                                        isSelected: _currentIndex == 7,
                                        onTap: () {
                                          setState(() => _currentIndex = 7);
                                          EventLogger().logButtonPress('Camera', 'setState to Camera page');
                                        },
                                        child: Icon(Icons.camera_alt_outlined, size: MediaQuery.sizeOf(context).height*0.037,),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.057,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.125,
                                      height: MediaQuery.of(context).size.height * 0.057,
                                      child: BottomNavItem1(
                                        label: 'Search',
                                        isSelected: _currentIndex == 4,
                                        onTap: (){ setState(() => _currentIndex = 4);
                                        EventLogger().logButtonPress('Search', 'setState to Search page');},
                                        child: Icon(Icons.search,size: MediaQuery.sizeOf(context).height*0.037,),
                                      ),
                                    ),

                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.125,
                                      height: MediaQuery.of(context).size.height * 0.057,
                                      child: BottomNavItem1(
                                        label: 'Chats',
                                        isSelected: _currentIndex == 3,
                                        onTap: (){ setState(() => _currentIndex = 3);
                                        EventLogger().logButtonPress('chats', 'setState to chats page');},
                                        child: Icon(Icons.chat_bubble_outline,size: MediaQuery.sizeOf(context).height*0.037,),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.057,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children:[
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.125,
                                      height: MediaQuery.of(context).size.height * 0.057,
                                      child: BottomNavItem1(
                                        label: 'Profile',
                                        isSelected: _currentIndex == 6,
                                        onTap: (){ setState(() => _currentIndex = 6);
                                        EventLogger().logButtonPress('Profile', 'setState to Profile page');},
                                        child:  CachedNetworkImage(
                                          imageUrl: profileimage,
                                          imageBuilder: (context, imageProvider) => CircleAvatar(
                                            radius: 8,
                                            backgroundImage: imageProvider,
                                          ),
                                          placeholder: (context, url) => Icon(Icons.person_2_outlined,size: MediaQuery.sizeOf(context).height*0.037,color: Colors.black,),
                                          errorWidget: (context, url, error) => Icon(Icons.person_2_outlined,size: MediaQuery.sizeOf(context).height*0.037,color: Colors.black,),
                                        ),
                                      ),
                                    ),

                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.125,
                                      height: MediaQuery.of(context).size.height * 0.057,
                                      child: BottomNavItem1(
                                        label: 'Filming',
                                        isSelected: _currentIndex == 5,
                                        onTap: (){ setState(() => _currentIndex = 5);
                                        EventLogger().logButtonPress('Filming', 'setState to Filming page');},
                                        child: Icon(Icons.videocam_outlined,size: MediaQuery.sizeOf(context).height*0.037,),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }else if (MediaQuery.of(context).size.width >400){
                    return Align(
                      alignment: const Alignment(-0.99,0.15),
                      child:  Material(
                        color: Colors.white,
                        elevation: 5,
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.13,
                          height: MediaQuery.of(context).size.height * 0.55,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.122,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.065,
                                      child: BottomNavItem1(
                                        label: 'Home',
                                        isSelected: _currentIndex == 0,
                                        onTap: () { setState(() => _currentIndex = 0);
                                        EventLogger().logButtonPress('Home', 'setState to Home page');},
                                        child: Icon(Icons.home, size: MediaQuery.sizeOf(context).height*0.07,),
                                      ),
                                    ),

                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.065,
                                      child: BottomNavItem1(
                                        label: 'FansTV',
                                        isSelected: _currentIndex == 1,
                                        onTap: () { setState(() => _currentIndex = 1);
                                        EventLogger().logButtonPress('FansTv', 'setState to FansTv page');},
                                        child: Icon(Icons.live_tv,size: MediaQuery.sizeOf(context).height*0.07,),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.122,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.065,
                                      child: BottomNavItem1(
                                        label: 'Events',
                                        isSelected: _currentIndex == 2,
                                        onTap: (){ setState(() => _currentIndex = 2);
                                        EventLogger().logButtonPress('Events', 'setState to Events page');},
                                        child: Icon(Icons.event_sharp,size: MediaQuery.sizeOf(context).height*0.07,),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.065,
                                      child: BottomNavItem1(
                                        label: 'Camera',
                                        isSelected: _currentIndex == 7,
                                        onTap: () {
                                          setState(() => _currentIndex = 7);
                                          EventLogger().logButtonPress('Camera', 'setState to Camera page');
                                        },
                                        child: Icon(Icons.camera_alt_outlined, size: MediaQuery.sizeOf(context).height*0.07,),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.122,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.065,
                                      child: BottomNavItem1(
                                        label: 'Search',
                                        isSelected: _currentIndex == 4,
                                        onTap: (){ setState(() => _currentIndex = 4);
                                        EventLogger().logButtonPress('Search', 'setState to Search page');},
                                        child: Icon(Icons.search,size: MediaQuery.sizeOf(context).height*0.07,),
                                      ),
                                    ),

                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.065,
                                      child: BottomNavItem1(
                                        label: 'Chats',
                                        isSelected: _currentIndex == 3,
                                        onTap: () { setState(() => _currentIndex = 3);
                                        EventLogger().logButtonPress('chats', 'setState to chats page');},
                                        child: Icon(Icons.chat_bubble_outline,size: MediaQuery.sizeOf(context).height*0.07,),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.122,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.065,
                                      child: BottomNavItem1(
                                        label: 'Profile',
                                        isSelected: _currentIndex == 6,
                                        onTap: () { setState(() => _currentIndex = 6);
                                        EventLogger().logButtonPress('Profile', 'setState to Profile page');},
                                        child:  CachedNetworkImage(
                                          imageUrl: profileimage,
                                          imageBuilder: (context, imageProvider) => CircleAvatar(
                                            radius: 10,
                                            backgroundImage: imageProvider,
                                          ),
                                          placeholder: (context, url) => Icon(Icons.person_2_outlined,size:MediaQuery.sizeOf(context).height*0.07,color: Colors.black,),
                                          errorWidget: (context, url, error) => Icon(Icons.person_2_outlined,size: MediaQuery.sizeOf(context).height*0.07,color: Colors.black,),
                                        ),
                                      ),
                                    ),

                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.065,
                                      child: BottomNavItem1(
                                        label: 'Filming',
                                        isSelected: _currentIndex == 5,
                                        onTap: () { setState(() => _currentIndex = 5);
                                        EventLogger().logButtonPress('Filming', 'setState to Filming page');},
                                        child: Icon(Icons.videocam_outlined,size: MediaQuery.sizeOf(context).height*0.07,),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return  Align(
                      alignment:const Alignment(-0.95,0.6),
                      child:  Material(
                        color: Colors.white,
                        elevation: 5,
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.31,
                          height: MediaQuery.of(context).size.height * 0.305,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.07,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.14,
                                      height: MediaQuery.of(context).size.height * 0.07,
                                      child: BottomNavItem(
                                        label: 'Home',
                                        isSelected: _currentIndex == 0,
                                        onTap: (){ setState(() => _currentIndex = 0);
                                        EventLogger().logButtonPress('Home', 'setState to Home page');},
                                        child: Icon(Icons.home, size: MediaQuery.sizeOf(context).height*0.041,),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.14,
                                      height: MediaQuery.of(context).size.height * 0.07,
                                      child: BottomNavItem(
                                        label: 'FansTV',
                                        isSelected: _currentIndex == 1,
                                        onTap: () { setState(() => _currentIndex = 1);
                                        EventLogger().logButtonPress('FansTv', 'setState to FansTv page');},
                                        child: Icon(Icons.live_tv,size: MediaQuery.sizeOf(context).height*0.041,),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.07,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.14,
                                      height: MediaQuery.of(context).size.height * 0.07,
                                      child: BottomNavItem(
                                        label: 'Events',
                                        isSelected: _currentIndex == 2,
                                        onTap: () { setState(() => _currentIndex = 2);
                                        EventLogger().logButtonPress('Events', 'setState to Events page');},
                                        child: Icon(Icons.event_sharp,size: MediaQuery.sizeOf(context).height*0.041,),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.14,
                                      height: MediaQuery.of(context).size.height * 0.07,
                                      child: BottomNavItem(
                                        label: 'Camera',
                                        isSelected: _currentIndex == 7,
                                        onTap: () {
                                          setState(() => _currentIndex = 7);
                                          EventLogger().logButtonPress('Camera', 'setState to Camera page');
                                        },
                                        child: Icon(Icons.camera_alt_outlined, size: MediaQuery.sizeOf(context).height*0.041,),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.07,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.14,
                                      height: MediaQuery.of(context).size.height * 0.07,
                                      child: BottomNavItem(
                                        label: 'Search',
                                        isSelected: _currentIndex == 4,
                                        onTap: () { setState(() => _currentIndex = 4);
                                        EventLogger().logButtonPress('Search', 'setState to Search page');},
                                        child: Icon(Icons.search,size: MediaQuery.sizeOf(context).height*0.041,),
                                      ),
                                    ),

                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.14,
                                      height: MediaQuery.of(context).size.height * 0.07,
                                      child: BottomNavItem(
                                        label: 'Chats',
                                        isSelected: _currentIndex == 3,
                                        onTap: (){ setState(() => _currentIndex = 3);
                                        EventLogger().logButtonPress('chats', 'setState to chats page');},
                                        child: Icon(Icons.chat_bubble_outline,size: MediaQuery.sizeOf(context).height*0.041,),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.07,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children:[
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.14,
                                      height: MediaQuery.of(context).size.height * 0.07,
                                      child: BottomNavItem(
                                        label: 'Profile',
                                        isSelected: _currentIndex == 6,
                                        onTap: () { setState(() => _currentIndex = 6);
                                        EventLogger().logButtonPress('Profile', 'setState to Profile page');},
                                        child:  CachedNetworkImage(
                                          imageUrl: profileimage,
                                          imageBuilder: (context, imageProvider) => CircleAvatar(
                                            radius: MediaQuery.sizeOf(context).height*0.006,
                                            backgroundImage: imageProvider,
                                          ),
                                          placeholder: (context, url) => Icon(Icons.person_2_outlined,size: MediaQuery.sizeOf(context).height*0.041,color: Colors.black,),
                                          errorWidget: (context, url, error) => Icon(Icons.person_2_outlined,size: MediaQuery.sizeOf(context).height*0.041,color: Colors.black,),
                                        ),
                                      ),
                                    ),

                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.14,
                                      height: MediaQuery.of(context).size.height * 0.07,
                                      child: BottomNavItem(
                                        label: 'Filming',
                                        isSelected: _currentIndex == 5,
                                        onTap: () {setState(() => _currentIndex = 5);
                                        EventLogger().logButtonPress('Filming', 'setState to Filming page');},
                                        child: Icon(Icons.videocam_outlined,size: MediaQuery.sizeOf(context).height*0.041,),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            );
          }, animation: _controller,
        ),
        GestureDetector(
            key: ValueKey<bool>(_isDrawerOpen),
            onDoubleTap: () {
              if(username.isEmpty||profileimage.isEmpty){
                load();
              }
              late DateTime  startTime;
              startTime=DateTime.now();
              Engagement().engagement('DoubleTapNavigationDrawer',startTime,'');
              EventLogger().logButtonPress('NavigationDrawerGestureDetector', 'setState to NavigationDrawer');
              setState(() {
                if (!_isDrawerOpen) {
                  _controller.reverse();
                  _isDrawerOpen=true;
                } else {
                  _controller.forward();
                  _isDrawerOpen=false;
                }
              });
            },
        ),
          LayoutBuilder(
          builder: (context, constraints) {
        if (MediaQuery.of(context).size.width >400) {
          return
        Align(
          alignment: const Alignment(-1.06,0.975),
          child: MaterialButton(
              key: ValueKey<bool>(_isDrawerOpen),
              onPressed: () {
                if(username.isEmpty||profileimage.isEmpty){
                  load();
                }
                late DateTime  startTime;
                startTime=DateTime.now();
                Engagement().engagement('ButtonTapNavigationDrawer',startTime,'');
                EventLogger().logButtonPress('ButtonTapNavigationDrawer', 'setState to NavigationDrawer');
                setState(() {
                  if (!_isDrawerOpen) {
                    _controller.reverse();
                    _isDrawerOpen=true;
                  } else {
                    _controller.forward();
                    _isDrawerOpen=false;
                  }
                });
              },
              child: _isDrawerOpen
                  ?const ThreeIconAnimation()
                  : const ThreeIconAnimation1()
          ),
        );
          }
        else {
          return  Align(
            alignment: const Alignment(-1.085,0.975),
            child: MaterialButton(
                key: ValueKey<bool>(_isDrawerOpen),
                onPressed: () {
                  if(username.isEmpty||profileimage.isEmpty){
                    load();
                  }
                  late DateTime  startTime;
                  startTime=DateTime.now();
                  Engagement().engagement('ButtonTapNavigationDrawer',startTime,'');
                  EventLogger().logButtonPress('ButtonTapNavigationDrawer', 'setState to NavigationDrawer');
                  setState(() {
                    if (!_isDrawerOpen) {
                      _controller.reverse();
                      _isDrawerOpen=true;
                    } else {
                      _controller.forward();
                      _isDrawerOpen=false;
                    }
                  });
                },
                child: _isDrawerOpen
                    ?const ThreeIconAnimation()
                    : const ThreeIconAnimation1()
            ),
          );
        }
          },
          ),
      ]),
    ),
  ),
  );
  }



  }
class BottomNavItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Widget child;
  final void Function()? onTap;

  const BottomNavItem({
    Key? key,
    required this.child,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isSelected ? Colors.grey : Colors.transparent,
            ),
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width * 0.1,
            child: child,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blueAccent : Colors.grey,
              fontSize: 11.0,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavItem1 extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Widget child;
  final void Function()? onTap;

  const BottomNavItem1({super.key, 
    required this.child,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isSelected ? Colors.grey : Colors.transparent,
            ),
            height: 35,
            width: 35,
            child: child,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blueAccent : Colors.grey,
              fontSize: 11.0,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class AppUsage {
  int? id;
  DateTime date;
  double hoursSpent;

  AppUsage({this.id, required this.date, required this.hoursSpent});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'hoursSpent': hoursSpent,
    };
  }

  factory AppUsage.fromMap(Map<String, dynamic> map) {
    return AppUsage(
      id: map['id'],
      date: DateTime.parse(map['date']),
      hoursSpent: map['hoursSpent'],
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_usage.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE app_usage (
        id INTEGER PRIMARY KEY,
        date TEXT,
        hoursSpent REAL
      )
    ''');
  }

  Future<void> insertOrUpdateAppUsage(AppUsage appUsage) async {
    final db = await database;
    final dateWithoutTime = DateTime(appUsage.date.year, appUsage.date.month, appUsage.date.day);
    final existingEntry = await db?.query(
      'app_usage',
      where: 'date = ?',
      whereArgs: [dateWithoutTime.toIso8601String()],
    );
    if (existingEntry != null && existingEntry.isNotEmpty) {
      final existingHoursSpent = existingEntry[0]['hoursSpent'] as double;
      final updatedHoursSpent = existingHoursSpent + appUsage.hoursSpent;
      await db?.update(
        'app_usage',
        {'hoursSpent': updatedHoursSpent,},
        where: 'date = ?',
        whereArgs: [dateWithoutTime.toIso8601String()],
      );
    } else {
      await db?.insert('app_usage', appUsage.toMap());
    }
    await deleteOldestAppUsage();
  }

  Future<void> deleteAllAppUsage() async {
    final db = await database;
    await db?.delete('app_usage');
  }

  Future<List<AppUsage>> getAppUsages() async {
    final db = await database;
    final List<Map<String, Object?>>? maps = await db?.query('app_usage');
    return List.generate(maps!.length, (i) {
      return AppUsage.fromMap(maps[i]);
    });
  }

  Future<void> deleteOldestAppUsage() async {
    final db = await database;
    final DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 6));
    final String formattedSevenDaysAgo = DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day).toIso8601String();
    final List<Map<String, Object?>>? oldestEntries = await db?.query(
      'app_usage',
      where: 'date < ?',
      whereArgs: [formattedSevenDaysAgo],
      orderBy: 'date ASC',
      limit: 1,
    );
    if (oldestEntries != null && oldestEntries.isNotEmpty) {
      final oldestEntryDate = oldestEntries[0]['date'] as String;
      await db?.delete('app_usage', where: 'date = ?', whereArgs: [oldestEntryDate]);
    }
  }
}



class DatabaseHelper1 {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper1._();

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user(
    userId TEXT PRIMARY KEY,
    url TEXT,
    collection TEXT,
    location TEXT,
    name TEXT
      )
    ''');
  }


  Future<void> insertAppUsage(Person appUsage) async {
    final db = await database;
    await db?.insert('user', appUsage.toMap());
  }

  Future<void> updateAppUsage(Person appUsage) async {
    final db = await database;
    final existingEntry = await db?.query(
      'user',
      where: 'userId = ?',
      whereArgs: [appUsage.userId],);
    if (existingEntry != null && existingEntry.isNotEmpty) {
      final updatedy =  appUsage.name;
      final updatedx =  appUsage.url;
      await db?.update(
        'user',
        {'url': updatedx,
          'name': updatedy,},
        where: 'userId = ?',
        whereArgs: [appUsage.userId],
      );
    } else {
      await db?.insert('user', appUsage.toMap());
    }
  }

  Future<void> deleteAllAppUsage() async {
    final db = await database;
    await db?.delete('user');
  }

  Future<Person?> getUser(String userId) async {
    final db = await database;
    final List<Map<String, Object?>>? result = await db?.query(
      'user',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    if (result != null && result.isNotEmpty) {
      return Person.fromJson(result[0]);
    } else {
      return null;
    }
  }


  Future<List<Person>> getAppUsages() async {
    final db = await database;
    final List<Map<String, Object?>>? maps = await db?.query('user');
    return List.generate(maps!.length, (i) {
      return Person.fromJson(maps[i]);
    });
  }
  Future<int?>remove(String userId)async{
    final db = await database;
    return await db?.delete('user',where:'userId=?',whereArgs: [userId]);
  }
}
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:fans_arena/fans/screens/homescreen.dart';
import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:fans_arena/fans/screens/search.dart';
import 'package:fans_arena/joint/components/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fans/screens/accountpage.dart';
import '../../fans/screens/debate.dart';
import '../../main.dart';
import '../../reusablewidgets/cirularavatar.dart';
import 'package:fans_arena/fans/bloc/accountchecker4.dart';
import 'lineupcreation.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
class EventsClubs extends StatefulWidget {
  const EventsClubs({super.key});

  @override
  State<EventsClubs> createState() => _EventsClubsState();
}

class _EventsClubsState extends State<EventsClubs>with SingleTickerProviderStateMixin {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<MatchM> posts = [];
  List<EventM> events = [];
  late MatchM lastmatch;
  late EventM lastevent;
  Set<String>matchIds={};
  Set<String>eventIds={};
  String status='0';
  String ex="Failed host lookup: 'us-central1-fans-arena.cloudfunctions.net'";
  Newsfeedservice news =Newsfeedservice();
  ScrollController controller1=ScrollController();
  ScrollController controller=ScrollController();
  @override
  bool get wantKeepAlive => true; // To keep the state of the widget alive

  late NetworkProvider connectivityProvider;
  @override
  void initState() {
    super.initState();
    connectivityProvider = Provider.of<NetworkProvider>(context, listen: false);
    connectivityProvider.addListener(_connectivityChanged);
    connectivityProvider.connectivity();
    _startTime=DateTime.now();
    _tabController = TabController(length: 2, vsync: this, initialIndex: index);
    _tabController.addListener(_handleTabChange);
    controller.addListener(() {
      if (controller.position.pixels >= controller.position.maxScrollExtent * 0.5) {
        setState(() {
          isscrollable=true;
        });
      }
      if (controller.position.pixels >= controller.position.maxScrollExtent * 0.5) {
        if(index==0){
          loadMore();
        }else{
          loadMore1();
        }
      }
    });
  }
  Future<void> _connectivityChanged() async {
    if(isLoading||isLoading1){
      if (connectivityProvider.isConnected) {
        getData();
      } else {
        getData();
      }}
  }
  bool isscrollable=false;
  late DateTime _startTime;
  bool noposts=false;
  bool noevents=false;
  bool isLoading=true;
  bool isLoading1=true;
  bool fetched1=false;
  bool fetched2=false;
  Future<void> getData() async{
    if(index==0) {
      setState(() {
        posts.clear();
        matchIds.clear();
        isLoading = true;
      });
      try {
        List<MatchM> data = await DataFetcher().getmymatches(
            FirebaseAuth.instance.currentUser!.uid);
        for (final d in data) {
          await Future.delayed(const Duration(milliseconds: 300));
          if(!matchIds.contains(d.matchId)) {
            setState(() {
              posts.add(d);
              matchIds.add(d.matchId);
            });
          }
        }
        setState(() {
          if (data.isEmpty) {
            noposts = true;
            isLoading = false;
            fetched1=true;
          } else {
            isLoading = false;
            lastmatch = data.last;
            fetched1=true;
          }
        });
      }catch(e){
        if(e.toString()==ex){
          dialoge("No internet");
        }else if(e=='Exception: Failed to load matches'){
        List<MatchM> data1 = await Newsfeedservice().getallMatches(
            userId: FirebaseAuth.instance.currentUser!.uid);
        for (final d in data1) {
          await Future.delayed(const Duration(milliseconds: 300));
          if(!matchIds.contains(d.matchId)) {
          setState(() {
            posts.add(d);
            matchIds.add(d.matchId);
          });}
        }
        setState(() {
          if (data1.isEmpty) {
            noposts = true;
            isLoading = false;
          } else {
            isLoading = false;
            lastmatch = data1.last;
          }
        });
      }}
    }else{
      setState(() {
        events.clear();
        isLoading1=true;
        eventIds.clear();
      });
      try{
        List<EventM> data1=await DataFetcher().getmyevents(FirebaseAuth.instance.currentUser!.uid);
        for(final d in data1){
          await Future.delayed(const Duration(milliseconds: 300));
          if(!eventIds.contains(d.eventId)) {
          setState(() {
            events.add(d);
            eventIds.add(d.eventId);
          });}
        }
        setState(() {
          if(data1.isEmpty){
            isLoading1=false;
            noevents=true;
            fetched=true;
            fetched2=true;
          }else{
            isLoading1=false;
            lastevent=data1.last;
            fetched=true;
            fetched2=true;
          }
        });
      }catch(e){
        if(e.toString()==ex){
          dialoge("No internet");
        }else if(e=='Exception: Failed to load events'){
        List<EventM> data1 = await Newsfeedservice().getallEvents(
            userId: FirebaseAuth.instance.currentUser!.uid);
        for (final d in data1) {
          await Future.delayed(const Duration(milliseconds: 300));
          if(!eventIds.contains(d.eventId)) {
          setState(() {
            events.add(d);
            eventIds.add(d.eventId);
          });}
        }
        setState(() {
          if(data1.isEmpty){
            isLoading1=false;
            noevents=true;
            fetched=true;
          }else{
            isLoading1=false;
            lastevent=data1.last;
            fetched=true;
          }
        });}
      }
    }
  }
  void dialoge(String e){
    showDialog(
        context: context,
        builder: (context) {
          return  AlertDialog(
            title: Text('Error'),
            content: Text(e),
          );
        });
  }
  void loadMore()async{
    setState(() {
      isLoading=true;
    });
    try {
      List<MatchM> data = await DataFetcher().getmoremymatches(
          FirebaseAuth.instance.currentUser!.uid, lastmatch.matchId);
      for(var d in data) {
        if(!matchIds.contains(d.matchId)) {
          posts.add(d);
          matchIds.add(d.matchId);
        }
      }
      setState(() {
        if (data.isEmpty) {
          noposts = true;
          isLoading = false;
        } else {
          isLoading = false;
          lastmatch = data.last;
        }
      });
    }catch(e){
      if(e.toString()==ex){
        dialoge("No internet");
      }else if(e=='Exception: Failed to load matches'){
      List<MatchM> data1 = await Newsfeedservice().getallMatches1(
          userId: FirebaseAuth.instance.currentUser!.uid, lastmatch: lastmatch);
      for(var d in data1) {
        if(!matchIds.contains(d.matchId)) {
          posts.add(d);
          matchIds.add(d.matchId);
        }
      }
      setState(() {
        if (data1.isEmpty) {
          noposts = true;
          isLoading = false;
        } else {
          posts.addAll(data1);
          isLoading = false;
          lastmatch = data1.last;
        }
      });
    }}
  }
  void loadMore1()async{
    setState(() {
      isLoading1=true;
    });
    try{
      List<EventM> data1=await DataFetcher().getmoremyevents(FirebaseAuth.instance.currentUser!.uid,lastevent.eventId);
      for(var d in data1) {
        if(!eventIds.contains(d.eventId)) {
          events.add(d);
          eventIds.add(d.eventId);
        }
      }
      setState(() {
        if(data1.isEmpty){
          noevents=true;
          isLoading1=false;
        }else{
          isLoading1=false;
          lastevent=data1.last;
        }
      });
    }catch(e){
      if(e.toString()==ex){
        dialoge("No internet");
      }else if(e=='Exception: Failed to load events'){
        List<EventM> data1 = await Newsfeedservice().getallEvents1(
            userId: FirebaseAuth.instance.currentUser!.uid,
            lastevent: lastevent);
        for(var d in data1) {
          if(!eventIds.contains(d.eventId)) {
            events.add(d);
            eventIds.add(d.eventId);
          }
        }
        setState(() {
          if (data1.isEmpty) {
            noevents = true;
            isLoading1 = false;
          } else {
            isLoading = false;
            lastevent = data1.last;
          }
        });
      }
    }
  }
  @override
  void dispose(){
    Engagement().engagement('EventsClubs',_startTime,'');
    connectivityProvider.removeListener(_connectivityChanged);
    super.dispose();
  }

  TextEditingController t =TextEditingController();

  late TabController _tabController;
  bool isselected = false;
  bool fetched=false;
  void _handleTabChange(){
    setState(() {
      index = _tabController.index;
    });
    if(index>0&&!fetched){
      getData();
    }

  }
  int index=0;

  double radius=24;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          automaticallyImplyLeading: false,
          title: Text('Events',style: TextStyle(color: Textn),),
          backgroundColor: Appbare,
          actions: [
            IconButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>Filter(getdata: (DateTime? from, DateTime? to)async {
                if(index==0){
                  setState(() {
                    posts.clear();
                    isLoading=true;
                  });
                  List<MatchM> matchs=await DataFetcher().getfiltermatches(FirebaseAuth.instance.currentUser!.uid,from!,to!,);
                  setState(() {
                    posts.addAll(matchs);
                    isLoading=false;
                    if(matchs.isNotEmpty){
                    }else{
                      noposts=true;
                    }
                  });}else{
                  setState(() {
                    events.clear();
                    isLoading1=true;
                  });
                  List<EventM> matchs=await DataFetcher().getfilterevents(FirebaseAuth.instance.currentUser!.uid,from!,to!);
                  setState(() {
                    events.addAll(matchs);
                    isLoading1=false;
                    if(matchs.isNotEmpty){
                    }else{
                      noevents=true;
                    }
                  });
                }
              }, choice: index==0?"Matches":"Events",)));
            }, icon: const Icon(Icons.filter_alt,color: Colors.black,))

          ],
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width:MediaQuery.of(context).size.width,
          child: NestedScrollView(
            controller: controller,
            headerSliverBuilder: (context, _) {
              return [
                SliverToBoxAdapter(
                  child:InkWell(
                    onTap: (){
                      Navigator.push(context,
                        MaterialPageRoute(builder: (
                            context) => const AccountChecker7(),
                        ),
                      );
                    },
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.97,
                          height: 100,
                          child: const Card(
                              elevation: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Create new Event',
                                    style: TextStyle(color: Colors.grey,fontSize: 22,fontWeight: FontWeight.bold),),
                                  Icon(Icons.add,size: 40,color: Colors.black,)
                                ],
                              )),
                        )),
                  ),
                ),
                SliverPersistentHeader(
                    floating: true,
                    pinned: true,
                    delegate: MyDelegate(
                      TabBar(
                        labelStyle: const TextStyle(fontSize: 18),
                        labelColor: Colors.white,
                        controller: _tabController,
                        unselectedLabelColor: Colors.white,
                        indicatorWeight: 1,
                        indicatorColor: Colors.white,
                        tabs: [
                          Selected(label: 'Matches', isActive:_tabController.index == 0,fsize: 18,),
                          Selected(label: 'Events', isActive: _tabController.index == 1,fsize: 18,),
                        ],
                      ),
                    ))
              ];
            },
            body:  TabBarView(
              controller: _tabController,
              children: [
                RefreshIndicator(
                  triggerMode: RefreshIndicatorTriggerMode.anywhere,
                  onRefresh:()async{
                    setState(() {
                      isLoading=true;
                    });
                    await _connectivityChanged();
                  },
                  child: EVCM(matches: posts, isLoading: isLoading, nomatches: noposts, isscrollable: isscrollable, radius: radius,),
                ),
                RefreshIndicator(
                  triggerMode: RefreshIndicatorTriggerMode.anywhere,
                  onRefresh:()async{
                    setState(() {
                      isLoading1=true;
                    });
                    await _connectivityChanged();
                  },
                  child:EVCE(events: events, isLoading: isLoading1, noevents: noevents, isscrollable: isscrollable, radius: radius,)
                )
              ],

            ),

          ),
        ),
      ),
    );
  }
}
class EVCM extends StatefulWidget {
  bool isLoading;
  List<MatchM>matches;
  bool nomatches;
  bool isscrollable;
  double radius;
  EVCM({super.key,
    required this.matches,
    required this.isLoading,
    required this.nomatches,
    required this.isscrollable,
    required this.radius});

  @override
  State<EVCM> createState() => _EVCMState();
}

class _EVCMState extends State<EVCM> {
  @override
  Widget build(BuildContext context) {
    if(widget.isLoading && widget.matches.isEmpty){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }else if(!widget.isLoading&& widget.matches.isEmpty){
      return const Center(
        child: Text('No matches'),
      );
    }else{
      return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: widget.isscrollable? const AlwaysScrollableScrollPhysics():const NeverScrollableScrollPhysics(),
          itemCount:widget.matches.length+1,
          itemBuilder: (BuildContext context, int index) {
            if(index==widget.matches.length){
              if(widget.isLoading) {
                return   Column(
                  children: [
                    MatchesShimmer(s:"Update",s1:'Line-Up'),
                    const SizedBox(height: 60,)
                  ],
                );
              }else if(widget.nomatches){
                return const SizedBox(
                  height: 80,
                  child: Center(
                    child: Text('No more matches'),
                  ),
                );
              }else{
                return const SizedBox.shrink();
              }
            }else {
              return Eclubm(match:
              widget.matches[index], radius: widget.radius, set: () {
                setState(() {
                  widget.matches.removeAt(index);
                });
              },);
            }});
    }
  }
}

class EVCE extends StatefulWidget {
  bool isLoading;
  List<EventM>events;
  bool noevents;
  bool isscrollable;
  double radius;
  EVCE({super.key,
    required this.events,
    required this.isLoading,
    required this.noevents,
    required this.isscrollable,
    required this.radius});


  @override
  State<EVCE> createState() => _EVCEState();
}

class _EVCEState extends State<EVCE> {
  @override
  Widget build(BuildContext context) {
    if(widget.isLoading && widget.events.isEmpty){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }else if(!widget.isLoading&& widget.events.isEmpty){
      return const Center(
        child: Text('No events'),
      );
    }else{
      return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: widget.events.length+1,
          physics: widget.isscrollable? const AlwaysScrollableScrollPhysics():const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            if(index==widget.events.length){
              if(widget.isLoading) {
                return  Column(
                  children: [
                    EventsShimmer(s:'Update',s1:'',),
                    const SizedBox(height: 60,)
                  ],
                );
              }else if(widget.noevents){
                return const SizedBox(
                  height: 80,
                  child: Center(
                    child: Text('No more Events'),
                  ),
                );
              }else{
                return const SizedBox.shrink();
              }
            }else {
              return Eclube(event: widget.events[index], radius: widget.radius, set: () {
                setState(() {
                  widget.events.removeAt(index);
                });
              },);
            }});
    }
  }
}

class MatchesShimmer extends StatelessWidget {
  String s;
  String s1;
  MatchesShimmer({super.key,required this.s,required this.s1});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          right: 10, left: 10, top: 5),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.95,
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                color: Colors.white60,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 5, right: 5, top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10,right: 10),
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.85,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],

                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6,left: 6, right: 6 ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 55,
                                      width: 55,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        period: const Duration(milliseconds: 800),
                                        child: Container(
                                          height: 55,
                                          width: 55,
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.circular(50)
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 10,right: 1),
                                      child: Center(child: Text('0',style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold,fontSize: 26),)),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5,top: 5),
                                  child: SizedBox(
                                    width: 90,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        const Text("Loading",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                        AnimatedTextKit(
                                          totalRepeatCount: 100,
                                          pause: const Duration(milliseconds: 200),
                                          animatedTexts: [
                                            TyperAnimatedText(
                                              '....',
                                              curve: Curves.linear,
                                              textStyle: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                              speed: const Duration(milliseconds: 100),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                ),
                              ],
                            ),

                            SizedBox(
                              width: MediaQuery.of(context).size.width*0.22,
                              height: 60,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 3,right: 3),
                                    child: Center(child: Text('VS',style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold,fontSize: 16.5),)),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceEvenly,
                                    children: [
                                      Text('date'),
                                      Text('time'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(left: 1,right: 10),
                                      child: Center(child: Text('0',style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold,fontSize: 26),)),
                                    ),
                                    Container(
                                      height: 55,
                                      width: 55,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        period: const Duration(milliseconds: 800),
                                        child: Container(
                                          height: 55,
                                          width: 55,
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.circular(50)
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5,top:5),
                                  child: SizedBox(
                                    width: 90,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        const Text("Loading",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                        AnimatedTextKit(
                                          totalRepeatCount: 100,
                                          pause: const Duration(milliseconds: 200),
                                          animatedTexts: [
                                            TyperAnimatedText(
                                              '....',
                                              curve: Curves.linear,
                                              textStyle: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                              speed: const Duration(milliseconds: 100),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 35,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceEvenly,
                      children: [
                        TextButton(onPressed: (){}, child:  Text(s)),
                        Container(
                          height: 28,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.35,
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius
                                .circular(10),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment
                                .start,
                            children: [
                              Padding(
                                padding: EdgeInsets
                                    .only(left: 3,
                                    right: 2),
                                child: Icon(Icons
                                    .location_on_outlined,
                                  color: Colors.black,),
                              ),
                              SizedBox(
                                  width: 120,
                                  height: 20,
                                  child: OverflowBox(
                                      child: Text(
                                        overflow: TextOverflow
                                            .ellipsis,
                                        maxLines: 1,
                                        'location',
                                        style: TextStyle(
                                            color: Colors
                                                .black,
                                            fontSize: 15),))),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 35,
                          child: TextButton(
                            onPressed: () {
                            }, child:  Text(s1),),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EventsShimmer extends StatelessWidget {
  String s;
  String s1;
  EventsShimmer({super.key,required this.s,required this.s1});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          right: 10, left: 10, top: 5),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.95,
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                color: Colors.white60,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 5, right: 5, top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .center,
                children: [
                  SizedBox(
                    width: 180,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text("Loading Event Title",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                        AnimatedTextKit(
                          totalRepeatCount: 100,
                          pause: const Duration(milliseconds: 200),
                          animatedTexts: [
                            TyperAnimatedText(
                              '.....',
                              curve: Curves.linear,
                              textStyle: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                              speed: const Duration(milliseconds: 100),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10),
                    child: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.85,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],

                          borderRadius: BorderRadius
                              .circular(10)
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets
                                .only(top: 6,
                                left: 6,
                                right: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .center,
                              children: [
                                Container(
                                  height: 55,
                                  width: 55,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    period: const Duration(milliseconds: 800),
                                    child: Container(
                                      height: 55,
                                      width: 55,
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(50)
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child:    SizedBox(
                                    width: 140,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        const Text("Loading author name",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                        AnimatedTextKit(
                                          totalRepeatCount: 100,
                                          pause: const Duration(milliseconds: 200),
                                          animatedTexts: [
                                            TyperAnimatedText(
                                              '.....',
                                              curve: Curves.linear,
                                              textStyle: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                              speed: const Duration(milliseconds: 100),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.5,
                            height: 40,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceEvenly,
                              children: [
                                Text('date'),
                                Text('time'),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 35,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceEvenly,
                      children: [
                        TextButton(onPressed: (){}, child:Text(s)),
                        Container(
                          height: 28,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.35,
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius
                                .circular(10),
                          ),

                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment
                                .start,
                            children: [
                              Padding(
                                padding: EdgeInsets
                                    .only(
                                    left: 3, right: 2),
                                child: Icon(Icons
                                    .location_on_outlined,
                                  color: Colors.black,),
                              ),
                              SizedBox(
                                  width: 120,
                                  height: 20,
                                  child: OverflowBox(
                                      child: Text(
                                        overflow: TextOverflow
                                            .ellipsis,
                                        maxLines: 1,
                                        '         ',
                                        style: TextStyle(
                                            color: Colors
                                                .black,
                                            fontSize: 15),))),
                            ],
                          ),
                        ),
                        s1.isNotEmpty?TextButton(onPressed: (){}, child:Text(s1)):const SizedBox.shrink(),
                        //Textbutton area
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Eclubm extends StatelessWidget {
  MatchM match;
  double radius;
  void Function()set;
  Eclubm({super.key,
    required this.match,
    required this.radius,required this.set});
  double radiusL=18;
  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.only(
          right: 10, left: 10, top: 5),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.95,
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                color: Colors.white60,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 5, right: 5, top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .center,
                children: [
                  match.league.userId.isNotEmpty? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomAvatar(imageurl:match.league.url, radius: 18),
                      const SizedBox(width: 5,),
                      CustomName(
                        username: match.league.name,
                        maxsize: 180,
                        style:const TextStyle(color: Colors.black,fontSize: 16),),
                    ],
                  ):const SizedBox.shrink(),
                  Padding(
                    padding: const EdgeInsets.only(left: 10,right: 10),
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.85,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],

                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6,left: 6, right: 6 ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CustomAvatar( radius: radius, imageurl:match.club1.url),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10,right: 1),
                                      child: Center(child: Text('${match.score1}',style: const TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold,fontSize: 26),)),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5,top: 5),
                                  child: CustomName(
                                    username:match.club1.name,
                                    maxsize: 90,
                                    style:const TextStyle(color: Colors.black,fontSize: 16),),
                                ),
                              ],
                            ),

                            SizedBox(
                              width: MediaQuery.of(context).size.width*0.3,
                              height: 60,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 3,right: 3),
                                    child: Center(child: Text('VS',style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold,fontSize: 16.5),)),
                                  ),
                                  match.status != '0'||match.duration!=0 ?Time(matchId: match.matchId, club1Id: match.club1.userId, ): Column(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceEvenly,
                                    children: [
                                      Text(match
                                          .createdat),
                                      Text(match
                                          .starttime),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 1,right: 10),
                                      child: Center(child: Text('${match.score2}',style: const TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold,fontSize: 26),)),
                                    ),
                                    CustomAvatar( radius: radius, imageurl:match.club2.url),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5,top:5),
                                  child: CustomName(
                                    username:match.club2.name,
                                    maxsize: 90,
                                    style:const TextStyle(color: Colors.black,fontSize: 16),),
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 35,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceEvenly,
                      children: [
                        Updatematch(match: match, set: set,),
                        Container(
                          height: 28,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.35,
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius
                                .circular(10),
                          ),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .start,
                            children: [
                              const Padding(
                                padding: EdgeInsets
                                    .only(left: 3,
                                    right: 2),
                                child: Icon(Icons
                                    .location_on_outlined,
                                  color: Colors.black,),
                              ),
                              SizedBox(
                                  width: 120,
                                  height: 20,
                                  child: OverflowBox(
                                      child: Text(
                                        overflow: TextOverflow
                                            .ellipsis,
                                        maxLines: 1,
                                        match
                                            .location,
                                        style: const TextStyle(
                                            color: Colors
                                                .black,
                                            fontSize: 15),))),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 35,
                          child:match.club1.collectionName=="Club"? TextButton(
                            onPressed: () {
                              Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (
                                        context) =>
                                        Lineupcreation(
                                          matchId: match.matchId,
                                          club1Id: match.club1.userId,
                                          club2Id: match.club2.userId,)
                                ),
                              );
                            }, child: const Text('Line-Up'),):const SizedBox.shrink(),
                        ),
                        //Textbutton area
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class CustomName extends StatefulWidget {
  String username;
  double maxsize;
  TextStyle style;
  CustomName({super.key,
    required this.username,
    required this.maxsize,
    required this.style});

  @override
  State<CustomName> createState() => _CustomNameState();
}

class _CustomNameState extends State<CustomName> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets
            .only(left: 5),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            color: Colors.transparent,
            height: 25,
            constraints: BoxConstraints(
              minWidth: 10.0,
              maxWidth: widget.maxsize,
            ),
            child: Text(
              widget.username,
              style: widget.style,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ));
    // Adjust the spac;
  }
}


class Eclube extends StatelessWidget {
  EventM event;
  double radius;
  void Function()set;
  Eclube({super.key,required this.event,required this.radius,required this.set});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          right: 10, left: 10, top: 5),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.95,
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                color: Colors.white60,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 5, right: 5, top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .center,
                children: [
                  event.title.isNotEmpty
                      ? FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery
                              .of(context)
                              .size
                              .width * 0.7,
                          maxHeight: 50,
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        child: Text(
                          maxLines: 2,
                          overflow: TextOverflow
                              .ellipsis,
                          event.title,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight
                                  .bold),)),
                  )
                      : const SizedBox(height: 0, width: 0,),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10),
                    child: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.85,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],

                          borderRadius: BorderRadius
                              .circular(10)
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets
                                .only(top: 6,
                                left: 6,
                                right: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .center,
                              children: [
                                CustomAvatar( radius: radius, imageurl:event.user.url),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child:CustomName(
                                    username: event.user.name,
                                    maxsize: 140,
                                    style:const TextStyle(color: Colors.black,fontSize: 16),),
                                ),

                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.5,
                            height: 40,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceEvenly,
                              children: [
                                Text(event.createdat),
                                Text(event.starttime),

                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 35,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceEvenly,
                      children: [
                        Updateevents(
                          matchId: event.eventId, set: set,),
                        Container(
                          height: 28,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.35,
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius
                                .circular(10),
                          ),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .start,
                            children: [
                              const Padding(
                                padding: EdgeInsets
                                    .only(left: 3,
                                    right: 2),
                                child: Icon(Icons
                                    .location_on_outlined,
                                  color: Colors.black,),
                              ),
                              SizedBox(
                                  width: 120,
                                  height: 20,
                                  child: OverflowBox(
                                      child: Text(
                                        overflow: TextOverflow
                                            .ellipsis,
                                        maxLines: 1,
                                        event
                                            .location,
                                        style: const TextStyle(
                                            color: Colors
                                                .black,
                                            fontSize: 15),))),
                            ],
                          ),
                        ),
                       TextButton(onPressed: (){
                         Navigator.push(context, MaterialPageRoute(builder: (context)=>EventStats(match: event)));
                       }, child: const Text("View stats"))
                        //Textbutton area
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class Updatematch extends StatefulWidget {
  MatchM match;
  void Function()set;
  Updatematch({super.key,required this.match,required this.set});

  @override
  State<Updatematch> createState() => _UpdatematchState();
}

class _UpdatematchState extends State<Updatematch> {
  TextEditingController location = TextEditingController();
  DateTime? _selectedDate;
  TextEditingController time = TextEditingController();
  void saveDataToFirestore3() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Matches')
          .where('matchId', isEqualTo:widget.match.matchId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var documentSnapshot = querySnapshot.docs[0];
        var oldData = documentSnapshot.data() as Map<String, dynamic>;

        Map<String, dynamic> newData = {};
        if (time.text.isNotEmpty && time.text != oldData['time']) {
          newData['time'] = time.text;
        }

        if (_selectedDate.toString().isNotEmpty && _selectedDate != oldData['scheduledDate']) {
          newData['scheduledDate'] = _selectedDate;
        }
        if (location.text.isNotEmpty && location.text != oldData['location']) {
          newData['location'] = location.text;
        }
        if (newData.isNotEmpty) {
          await documentSnapshot.reference.update(newData);
          Navigator.pop(context);
          print('Data saved successfully');
        } else {
          print('No changes to update');
        }
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error saving data: $e');
    }
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.utc(2050),

    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
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
  void deletematch(String matchId){
    showToastMessage('Deleting match...');
    widget.set();
    FirebaseFirestore.instance
        .collection('Matches')
        .doc(matchId)
        .get()
        .then((doc) {
      doc.reference.delete();
    });
    showToastMessage('Match Deleted');
  }
  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      height: 35,
      child: TextButton(onPressed: (){
        showDialog(context: context, builder: (context){
          return AlertDialog(
            content: SizedBox(
              height: 150,
              child: Column(
                children: [
                  TextButton(onPressed: (){
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>MatchInsights(match: widget.match)));
                  }, child: const Text('View Insights')),
                  TextButton(onPressed: (){
                    Navigator.pop(context);
                    showModalBottomSheet(
                        isScrollControlled: true,
                        isDismissible: true,
                        backgroundColor: Colors.transparent,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10))),
                        context: context,
                        builder: (BuildContext context) {
                          return Align(
                            alignment: const Alignment(0.0,0.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                color: Colors.white,
                                height: 250,
                                width: MediaQuery.of(context).size.width*0.85,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text('Edit Match',style: TextStyle(fontWeight: FontWeight.bold),),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width*0.6,
                                        height: 38,
                                        child: TextFormField(
                                            controller: location,
                                            textAlignVertical: TextAlignVertical.bottom,
                                            decoration: InputDecoration(
                                                labelText: 'Location',
                                                hintText: 'Location',
                                                border: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors
                                                          .grey),
                                                  borderRadius: BorderRadius
                                                      .circular(8),
                                                ),
                                                suffixIcon: IconButton(onPressed: (){},icon: const Icon(Icons.search,color: Colors.black,),)
                                            )),
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width*0.6,
                                        height: 38,
                                        child: TextFormField(
                                            onTap: () {
                                              _selectDate(context);
                                            },
                                            readOnly: true,
                                            controller: TextEditingController(
                                              text: _selectedDate != null
                                                  ? "${_selectedDate!.toLocal()}".split(' ')[0]
                                                  : '',
                                            ),
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors
                                                        .grey),
                                                borderRadius: BorderRadius
                                                    .circular(8),
                                              ),
                                              hintText: 'Date',
                                              labelText: 'Date',
                                            )),
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width*0.6,
                                        height: 38,
                                        child: TextFormField(
                                          onTap: () {
                                            showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                            ).then((TimeOfDay? value) {
                                              if (value != null) {
                                                setState(() {
                                                  time.text = value.format(context);
                                                });
                                              }
                                            });
                                          },
                                          readOnly: true,
                                          controller: time,
                                          decoration: InputDecoration(
                                            hintText: 'Time',
                                            labelText: 'Time',
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors
                                                      .grey),
                                              borderRadius: BorderRadius
                                                  .circular(8),
                                            ),
                                          ),
                                        ),
                                      ),

                                      TextButton(onPressed: saveDataToFirestore3, child: const Text('Update'))
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          );});
                  }, child: const Text('Edit match')),
                  TextButton(onPressed:(){
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                              alignment: Alignment.center,
                              title: const Text('Delete Event?'),
                              actions: [
                                Row(
                                  mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton(
                                      child: const Text('No'),
                                      onPressed: () {
                                        Navigator.pop(context); // Dismiss the dialog
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('yes'),
                                      onPressed: () {
                                        deletematch(widget.match.matchId);
                                        Navigator.pop(context); // Dismiss the dialog
                                      },
                                    ),
                                  ],
                                )
                              ]);
                        }
                    );
                  }, child: const Text("Delete")),
                ],
              ),
            ),
          );
        });

      } , child: const Text('More options'),),
    );
  }
}
class Updateevents extends StatefulWidget {
  String matchId;
  void Function()set;
  Updateevents({super.key,required this.matchId,required this.set});

  @override
  State<Updateevents> createState() => _UpdateeventsState();
}

class _UpdateeventsState extends State<Updateevents> {
  TextEditingController location = TextEditingController();
  DateTime? _selectedDate;
  TextEditingController time = TextEditingController();
  TextEditingController title = TextEditingController();
  void saveDataToFirestore3() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Events')
          .where('eventId', isEqualTo:widget.matchId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var documentSnapshot = querySnapshot.docs[0];
        var oldData = documentSnapshot.data() as Map<String, dynamic>;

        Map<String, dynamic> newData = {};
        if (time.text.isNotEmpty && time.text != oldData['time']) {
          newData['time'] = time.text;
        }

        if (_selectedDate.toString().isNotEmpty && _selectedDate != oldData['scheduledDate']) {
          newData['scheduledDate'] = _selectedDate;
        }
        if (location.text.isNotEmpty && location.text != oldData['location']) {
          newData['location'] = location.text;
        }
        if (title.text.isNotEmpty && title.text != oldData['title']) {
          newData['title'] = title.text;
        }
        if (newData.isNotEmpty) {
          await documentSnapshot.reference.update(newData);
          Navigator.pop(context);
          print('Data saved successfully');
        } else {
          print('No changes to update');
        }
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error saving data: $e');
    }
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.utc(2050),

    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
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
  void deleteevent(String matchId){
    showToastMessage('Deleting event...');
    widget.set();
    FirebaseFirestore.instance
        .collection('Events')
        .doc(matchId)
        .get()
        .then((doc) {
      doc.reference.delete();
    });
    showToastMessage('Event Deleted');
  }
  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      height: 35,
      child: TextButton(
        onPressed: (){
          showDialog(context: context, builder: (context){
            return AlertDialog(
              content: SizedBox(
                height: 100,
                child: Column(
                  children: [
                    TextButton(onPressed: (){
                      showModalBottomSheet(
                          isScrollControlled: true,
                          isDismissible: true,
                          backgroundColor: Colors.transparent,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10))),
                          context: context,
                          builder: (BuildContext context) {
                            return Align(
                              alignment: const Alignment(0.0,0.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  color: Colors.white,
                                  height: 270,
                                  width: MediaQuery.of(context).size.width*0.85,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Text('Edit Event',style: TextStyle(fontWeight: FontWeight.bold),),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width*0.6,
                                          height: 38,
                                          child: TextFormField(
                                              controller: title,
                                              textAlignVertical: TextAlignVertical.bottom,
                                              decoration: InputDecoration(
                                                labelText: 'Tittle',
                                                hintText: 'Tittle',
                                                border: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors
                                                          .grey),
                                                  borderRadius: BorderRadius
                                                      .circular(8),
                                                ),

                                              )),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width*0.6,
                                          height: 38,
                                          child: TextFormField(
                                              controller: location,
                                              textAlignVertical: TextAlignVertical.bottom,
                                              decoration: InputDecoration(
                                                  labelText: 'Location',
                                                  hintText: 'Location',
                                                  border: OutlineInputBorder(
                                                    borderSide: const BorderSide(
                                                        color: Colors
                                                            .grey),
                                                    borderRadius: BorderRadius
                                                        .circular(8),
                                                  ),
                                                  suffixIcon: IconButton(onPressed: (){},icon: const Icon(Icons.search,color: Colors.black,),)
                                              )),
                                        ),

                                        SizedBox(
                                          width: MediaQuery.of(context).size.width*0.6,
                                          height: 38,
                                          child: TextFormField(
                                              onTap: () {
                                                _selectDate(context);
                                              },
                                              readOnly: true,
                                              controller: TextEditingController(
                                                text: _selectedDate != null
                                                    ? "${_selectedDate!.toLocal()}".split(' ')[0]
                                                    : '',
                                              ),
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors
                                                          .grey),
                                                  borderRadius: BorderRadius
                                                      .circular(8),
                                                ),
                                                hintText: 'Date',
                                                labelText: 'Date',
                                              )),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width*0.6,
                                          height: 38,
                                          child: TextFormField(
                                            onTap: () {
                                              showTimePicker(
                                                context: context,
                                                initialTime: TimeOfDay.now(),
                                              ).then((TimeOfDay? value) {
                                                if (value != null) {
                                                  setState(() {
                                                    time.text = value.format(context);
                                                  });
                                                }
                                              });
                                            },
                                            readOnly: true,
                                            controller: time,
                                            decoration: InputDecoration(
                                              hintText: 'Time',
                                              labelText: 'Time',
                                              border: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors
                                                        .grey),
                                                borderRadius: BorderRadius
                                                    .circular(8),
                                              ),
                                            ),
                                          ),
                                        ),

                                        TextButton(onPressed: saveDataToFirestore3, child: const Text('Update'))
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                            );});
                    } , child: const Text('Edit Event'),),
                    TextButton(onPressed: (){
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                                alignment: Alignment.center,
                                title: const Text('Delete Event?'),
                                actions: [
                                  Row(
                                    mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton(
                                        child: const Text('No'),
                                        onPressed: () {
                                          Navigator.pop(context); // Dismiss the dialog
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('yes'),
                                        onPressed: () {
                                          deleteevent(widget.matchId);
                                          Navigator.pop(context); // Dismiss the dialog
                                        },
                                      ),
                                    ],
                                  )
                                ]);
                          }
                      );
                    }, child: const Text("Delete")),
                  ],
                ),
              ),
            );
          });
        },
        child: const Text("More options")
      ),
    );
  }
}



class Filter extends StatefulWidget {
  void Function(DateTime? from,
      DateTime? to) getdata;
  String choice;
  Filter({super.key,required this.getdata,required this.choice});

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  DateTime? _selectedDate;
  DateTime? _selectedDate1;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.utc(2050),

    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  Future<void> _selectDate1(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate1 ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.utc(2050),

    );

    if (picked != null && picked != _selectedDate1) {
      setState(() {
        _selectedDate1 = picked;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 1,
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back)),
        backgroundColor: Colors.white,
        title: const Text('Filter',style: TextStyle(color: Colors.black),),),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height:MediaQuery.of(context).size.width ,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(widget.choice,style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
            ),

            const Text("From:"),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width*0.6,
              height: 38,
              child: TextFormField(
                  onTap: () {
                    _selectDate(context);
                  },
                  readOnly: true,
                  controller: TextEditingController(
                    text: _selectedDate != null
                        ? "${_selectedDate!.toLocal()}".split(' ')[0]
                        : '',
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors
                              .grey),
                      borderRadius: BorderRadius
                          .circular(8),
                    ),
                    hintText: 'fromDate',
                    labelText: 'fromDate',
                  )),
            ),
            const SizedBox(
              height: 5,
            ),

            const Text("To:"),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width*0.6,
              height: 38,
              child: TextFormField(
                  onTap: () {
                    _selectDate1(context);
                  },
                  readOnly: true,
                  controller: TextEditingController(
                    text: _selectedDate1 != null
                        ? "${_selectedDate1!.toLocal()}".split(' ')[0]
                        : '',
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors
                              .grey),
                      borderRadius: BorderRadius
                          .circular(8),
                    ),
                    hintText: 'toDate',
                    labelText: 'toDate',
                  )),
            ),
            const SizedBox(height: 5,),
            OutlinedButton(onPressed: (){
              widget.getdata(_selectedDate,_selectedDate1);
              Navigator.pop(context);

            }, child: const Text('  filter  ')),
          ],
        ),
      ),
    );
  }
}


class MatchInsights extends StatefulWidget {
  final MatchM match;
  MatchInsights({super.key, required this.match});

  @override
  State<MatchInsights> createState() => _MatchInsightsState();
}

class _MatchInsightsState extends State<MatchInsights> {
  late DataPoints dataPoints;
  bool isLoading = true;
FirebaseFirestore firestore=FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    getData();
    getCurrencyData();
  }

  String country="Kenya";
  String currency="USD";
void getCurrencyData()async{
  List<Map<String,dynamic>> countryData=[];
    DocumentSnapshot documentSnapshot= await firestore.collection("exchangeRates").doc('USD').get();
    if(documentSnapshot.exists){
      var data= documentSnapshot.data() as Map<String,dynamic>;
      setState(() {
        countryData=List.from(data['countryData']);
        Map<String, dynamic> foundCountry = countryData.firstWhere(
              (element) => element['country'] == country,
          orElse: () => {},
        );
        String c = foundCountry['currency'] ??"USD";
        exrate=data[c];
        currency=foundCountry['currency'] ??"USD";
      });
    }
}
  void getData() async {
    try {
      dataPoints = await DataFetcher().matchData("Matches", widget.match.matchId);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("$e"),
        ),
      );
    }
  }

double cpm=0.25;
  double exrate=1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Match Insights",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: isLoading||dataPoints==null
            ? Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(4.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1,color: Colors.grey)
                  ),
                  child: Column(
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                          Column(
                            children: [
                              Text('Date of the Match',style:TextStyle(fontWeight: FontWeight.bold)),
                              Text("${widget.match.createdat}")
                            ],
                          ),
                          VerticalDivider(color: Colors.black,width: 40,thickness: 1,),
                          Column(
                            children: [
                              Text("Time",style:TextStyle(fontWeight: FontWeight.bold)),
                              Text("${widget.match.starttime}")
                            ],
                          ),
                        ],),
                      ),
                      Divider(color: Colors.black,height:3,thickness: 1,),
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                          Column(
                            children: [
                              Text('Duration (minutes)',style:TextStyle(fontWeight: FontWeight.bold)),
                              Text("${dataPoints.likesData.last.minute}")
                            ],
                          ),
                          VerticalDivider(color: Colors.black,width: 40,thickness: 1,),
                          Column(
                            children: [
                              Text('Location',style:TextStyle(fontWeight: FontWeight.bold)),
                              Text("${widget.match.location}")
                            ],
                          ),
                        ],),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("Likes against Duration(minutes)",style:TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 600,
                  child: buildGraph(dataPoints, 'Likes', 'Duration (minutes)'),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("Views against Duration(minutes)",style:TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 600,
                  child: buildGraph1(dataPoints, 'Views', 'Duration (minutes)'),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("Watch Hours against Duration(minutes)",style:TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 600,
                  child: buildGraph2(dataPoints, 'Watch Hours', 'Duration (minutes)'),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("Donation (amount USD) against Duration(minutes)",style:TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                    height: 600,
                    child: buildGraph3(dataPoints, 'amount (USD)', 'Duration (minutes)')),
                Payment(dataPoints),
                SizedBox(height: 40,),
              ],
            ),
          ),
        ));
  }
  Widget Payment(DataPoints dataMap){
    int views = dataMap.viewsData.fold(0, (sum, element) => sum + element.views);
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SizedBox(height: 10,),
          Text("Earnings",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
          SizedBox(height: 10,),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border.all(width: 1,color: Colors.grey)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Column(
                          children: [
                            Text("CPM",style: TextStyle(fontWeight: FontWeight.bold),),
                            SizedBox(height: 5,),
                            Text("charge per 1000 views",style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("USD $cpm")
                          ],
                        ),
                      ),
                      VerticalDivider(color: Colors.black,width: 40,thickness: 1,),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Column(
                          children: [
                            Text("Country",style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 5,),
                            Text("$country")
                          ],
                        ),
                      ),
                    ],),
                ),
                Divider(color: Colors.black,height:3,thickness: 1,),
                Text("Cash-out Amount",style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height: 5,),
                Text("${currency} ${views*cpm*exrate/1000}"),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget buildGraph(DataPoints dataMap, String y, String x) {
    final dataPoints = <LineChartBarData>[];
    int highestValue1 = dataMap.likesData.reduce((a, b) => a.minute > b.minute ? a : b).minute;
    List<FlSpot> spots = dataMap.likesData.map((usage) => FlSpot(usage.minute.toDouble(), usage.likes.toDouble())).toList();
    final barChartGroupData = LineChartBarData(
      color: Colors.blueAccent,
      isStrokeJoinRound: true,
      spots: spots,
      dotData: const FlDotData(
        show: true,
      ),
    );
    dataPoints.add(barChartGroupData);
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: LineChart(
            LineChartData(
              maxY: spots.isNotEmpty ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) : 0,
              minY: 0,
              maxX: highestValue1<=10?highestValue1.toDouble():(((highestValue1 + 9) ~/ 10) * 10).toDouble(),
              minX: 0,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  axisNameSize: 16,
                  axisNameWidget: Text(
                    y,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, titleMeta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  axisNameSize: 16,
                  axisNameWidget: Text(
                    x,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 25,
                    getTitlesWidget: (value, titleMeta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: dataPoints,
            ),
          ),
        ),
        SizedBox(height: 20,),
        TextGraphLikesData(dataMap,y,x )
      ],
    );
  }
  Widget TextGraphLikesData(DataPoints dataMap,String y,String x ){
    int likes = dataMap.likesData.fold(0, (sum, element) => sum + element.likes);
    int  duration = dataMap.likesData.last.minute;
    double average= likes/duration;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Graph Insights",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
          SizedBox(height: 5,),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border.all(width: 1,color: Colors.grey)
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(y,style:TextStyle(fontWeight: FontWeight.bold)),
                        Text("$likes"),
                        SizedBox(height: 1,),
                      ],
                    ),
                  ),
                  VerticalDivider(color: Colors.black,width: 40,thickness: 1,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text("Avg $y per minute",style:TextStyle(fontWeight: FontWeight.bold)),
                        Text("$average"),
                        SizedBox(height: 1,),
                      ],
                    ),
                  ),
                ],),
            ),
          ),
        ],
      ),
    );
  }

  Widget TextGraphViewsData(DataPoints dataMap,String y,String x ){
    int views = dataMap.viewsData.fold(0, (sum, element) => sum + element.views);
    int  duration = dataMap.viewsData.last.minute;
    double average= views/duration;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Graph Insights",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
          SizedBox(height: 5,),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border.all(width: 1,color: Colors.grey)
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(y,style:TextStyle(fontWeight: FontWeight.bold)),
                        Text("$views"),
                        SizedBox(height: 1,),
                      ],
                    ),
                  ),
                  VerticalDivider(color: Colors.black,width: 40,thickness: 1,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text("Avg $y per minute",style:TextStyle(fontWeight: FontWeight.bold)),
                        Text("$average"),
                        SizedBox(height: 1,),
                      ],
                    ),
                  ),
                ],),
            ),
          ),
        ],
      ),
    );
  }
  Widget TextGraphDonationsData(DataPoints dataMap,String y,String x ){
    double amount = dataMap.donationsData.fold(0, (sum, element) => sum + element.amount);
    int  duration = dataMap.viewsData.last.minute;
    double average= amount/duration;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Graph Insights",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
          SizedBox(height: 5,),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border.all(width: 1,color: Colors.grey)
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(y,style:TextStyle(fontWeight: FontWeight.bold)),
                        Text("$amount"),
                        SizedBox(height: 1,),
                      ],
                    ),
                  ),
                  VerticalDivider(color: Colors.black,width: 40,thickness: 1,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text("Avg $y per minute",style:TextStyle(fontWeight: FontWeight.bold)),
                        Text("$average"),
                        SizedBox(height: 1,),
                      ],
                    ),
                  ),
                ],),
            ),
          ),
        ],
      ),
    );
  }

  Widget TextGraphWatchHoursData(DataPoints dataMap,String y,String x ){
    double watchhours = dataMap.viewsData.fold(0, (sum, element) => sum + element.watchhours);
    int views = dataMap.viewsData.fold(0, (sum, element) => sum + element.views);
    int  duration = dataMap.viewsData.last.minute;
    double average= watchhours/duration;
    double averagewatchhours= watchhours/views;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Text("Graph Insights",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
          SizedBox(height: 5,),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border.all(width: 1,color: Colors.grey)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IntrinsicHeight(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(y,style:TextStyle(fontWeight: FontWeight.bold)),
                              Text("$watchhours"),
                              SizedBox(height: 1,),
                            ],
                          ),
                        ),
                        VerticalDivider(color: Colors.black,width: 40,thickness: 1,),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text("Avg $y per minute",style:TextStyle(fontWeight: FontWeight.bold)),
                              Text("$average"),
                              SizedBox(height: 1,),
                            ],
                          ),
                        ),
                      ]),
                ),
                Divider(color: Colors.black,height:3,thickness: 1,),
                Text("Avg $y per view",style:TextStyle(fontWeight: FontWeight.bold)),
                Text("$averagewatchhours"),
                SizedBox(height: 5,),
              ],),
          ),
        ],
      ),
    );
  }
  Widget buildGraph1(DataPoints dataMap, String y, String x) {
    final dataPoints = <LineChartBarData>[];
    int highestValue1 = dataMap.likesData.reduce((a, b) => a.minute > b.minute ? a : b).minute;
    List<FlSpot> spots = dataMap.viewsData.map((usage) => FlSpot(usage.minute.toDouble(), usage.views.toDouble())).toList();
    final barChartGroupData = LineChartBarData(
      color: Colors.blueAccent,
      isStrokeJoinRound: true,
      spots: spots,
      dotData: const FlDotData(
        show: true,
      ),
    );
    dataPoints.add(barChartGroupData);
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: LineChart(
            LineChartData(
              maxY: spots.isNotEmpty ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) : 0,
              minY: 0,
              maxX: highestValue1<=10?highestValue1.toDouble():(((highestValue1 + 9) ~/ 10) * 10).toDouble(),
              minX: 0,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  axisNameSize: 16,
                  axisNameWidget: Text(
                    y,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, titleMeta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  axisNameSize: 16,
                  axisNameWidget: Text(
                    x,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 25,
                    getTitlesWidget: (value, titleMeta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: dataPoints,
            ),
          ),
        ),
        SizedBox(height: 20,),
        TextGraphViewsData(dataMap,y,x )
      ],
    );
  }
  Widget buildGraph3(DataPoints dataMap, String y, String x) {
    final dataPoints = <LineChartBarData>[];
    int highestValue1 = dataMap.likesData.reduce((a, b) => a.minute > b.minute ? a : b).minute;
    List<FlSpot> spots = dataMap.donationsData.map((usage) => FlSpot(usage.minute.toDouble(), usage.amount.toDouble())).toList();
    final barChartGroupData = LineChartBarData(
      color: Colors.blueAccent,
      isStrokeJoinRound: true,
      spots: spots,
      dotData: const FlDotData(
        show: true,
      ),
    );
    dataPoints.add(barChartGroupData);
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: LineChart(
            LineChartData(
              maxY: spots.isNotEmpty ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) : 0,
              minY: 0,
              maxX: highestValue1<=10?highestValue1.toDouble():(((highestValue1 + 9) ~/ 10) * 10).toDouble(),
              minX: 0,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  axisNameSize: 16,
                  axisNameWidget: Text(
                    y,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, titleMeta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  axisNameSize: 16,
                  axisNameWidget: Text(
                    x,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 25,
                    getTitlesWidget: (value, titleMeta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: dataPoints,
            ),
          ),
        ),
        SizedBox(height: 20,),
        TextGraphDonationsData(dataMap, y, x),
      ],
    );
  }
  Widget buildGraph2(DataPoints dataMap, String y, String x) {
    final dataPoints = <LineChartBarData>[];
    int highestValue1 = dataMap.likesData.reduce((a, b) => a.minute > b.minute ? a : b).minute;
    List<FlSpot> spots = dataMap.viewsData.map((usage) => FlSpot(usage.minute.toDouble(), usage.watchhours.toDouble())).toList();
    final barChartGroupData = LineChartBarData(
      color: Colors.blueAccent,
      isStrokeJoinRound: true,
      spots: spots,
      dotData: const FlDotData(
        show: true,
      ),
    );
    dataPoints.add(barChartGroupData);
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: LineChart(
            LineChartData(
              maxY: spots.isNotEmpty ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) : 0,
              minY: 0,
              maxX: highestValue1<=10?highestValue1.toDouble():(((highestValue1 + 9) ~/ 10) * 10).toDouble(),
              minX: 0,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  axisNameSize: 16,
                  axisNameWidget: Text(
                    y,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, titleMeta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  axisNameSize: 16,
                  axisNameWidget: Text(
                    x,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 25,
                    getTitlesWidget: (value, titleMeta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: dataPoints,
            ),
          ),
        ),
        SizedBox(height: 20,),
        TextGraphWatchHoursData(dataMap,y,x )
      ],
    );
  }
}

class Mt1 extends StatelessWidget {
  List<ViewData> data;
  Mt1({super.key,required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Testing"),),
      body: Builder(
        builder: (context){
      List<FlSpot> spots = data.map((usage) => FlSpot(usage.minute.toDouble(), usage.watchhours.toDouble())).toList();
      final barChartGroupData = LineChartBarData(
        spots: spots,
        isCurved: true,
        color: Colors.blue,
        barWidth: 4,
        isStrokeCapRound: true,
        belowBarData: BarAreaData(
          show: true,
          color: Colors.blue.withOpacity(0.3),
        ),
      );
      return LineChart(
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
          maxX: spots.isNotEmpty ? spots.last.x : 0,
          minY: 0,
          maxY: spots.isNotEmpty ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) : 0,
          lineBarsData: [barChartGroupData],
        ),
      );

        },
      )
    );
  }
}

class EventStats extends StatefulWidget {
  EventM match;
  EventStats({super.key,required this.match});

  @override
  State<EventStats> createState() => _EventStatsState();
}

class _EventStatsState extends State<EventStats> {
  late DataPoints dataPoints;
  bool isLoading = true;
  FirebaseFirestore firestore=FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    getData();
    getCurrencyData();
  }

  String country="Kenya";
  String currency="USD";
  void getCurrencyData()async{
    List<Map<String,dynamic>> countryData=[];
    DocumentSnapshot documentSnapshot= await firestore.collection("exchangeRates").doc('USD').get();
    if(documentSnapshot.exists){
      var data= documentSnapshot.data() as Map<String,dynamic>;
      setState(() {
        countryData=List.from(data['countryData']);
        Map<String, dynamic> foundCountry = countryData.firstWhere(
              (element) => element['country'] == country,
          orElse: () => {},
        );
        String c = foundCountry['currency'] ??"USD";
        exrate=data[c];
        currency=foundCountry['currency'] ??"USD";
      });
    }
  }
 void getData() async {
   try {
     dataPoints = await DataFetcher().matchData("Events", widget.match.eventId);
     setState(() {
       isLoading = false;
     });
   } catch (e) {
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         content: Text("$e"),
       ),
     );
   }
 }
  double cpm=0.25;
  double exrate=1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text("Event Insights",style: TextStyle(color: Colors.black),),),
        body: isLoading||dataPoints==null
            ? Center(child: CircularProgressIndicator()): SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1,color: Colors.grey)
                  ),
                  child: Column(
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text('Date of the Events',style:TextStyle(fontWeight: FontWeight.bold)),
                                Text("${widget.match.createdat}")
                              ],
                            ),
                            VerticalDivider(color: Colors.black,width: 40,thickness: 1,),
                            Column(
                              children: [
                                Text("Time",style:TextStyle(fontWeight: FontWeight.bold)),
                                Text("${widget.match.starttime}")
                              ],
                            ),
                          ],),
                      ),
                      Divider(color: Colors.black,height:3,thickness: 1,),
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text('Duration (minutes)',style:TextStyle(fontWeight: FontWeight.bold)),
                                Text("${dataPoints.likesData.last.minute}")
                              ],
                            ),
                            VerticalDivider(color: Colors.black,width: 40,thickness: 1,),
                            Column(
                              children: [
                                Text('Location',style:TextStyle(fontWeight: FontWeight.bold)),
                                Text("${widget.match.location}")
                              ],
                            ),
                          ],),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("Likes against Duration(minutes)",style:TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 600,
                  child: buildGraph(dataPoints, 'Likes', 'Duration (minutes)'),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("Views against Duration(minutes)",style:TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 600,
                  child: buildGraph1(dataPoints, 'Views', 'Duration (minutes)'),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("Watch Hours against Duration(minutes)",style:TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 600,
                  child: buildGraph2(dataPoints, 'Watch Hours', 'Duration (minutes)'),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("Donation (amount USD) against Duration(minutes)",style:TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 600,
                    child: buildGraph3(dataPoints, 'amount (USD)', 'Duration (minutes)')),
                Payment(dataPoints),
                SizedBox(height: 40,),
              ],
            ),
          ),
        ),
    );
  }
  Widget Payment(DataPoints dataMap){
    int views = dataMap.viewsData.fold(0, (sum, element) => sum + element.views);
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SizedBox(height: 10,),
          Text("Earnings",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
          SizedBox(height: 10,),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border.all(width: 1,color: Colors.grey)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Column(
                          children: [
                            Text("CPM",style: TextStyle(fontWeight: FontWeight.bold),),
                            SizedBox(height: 5,),
                            Text("charge per 1000 views",style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("USD $cpm")
                          ],
                        ),
                      ),
                      VerticalDivider(color: Colors.black,width: 40,thickness: 1,),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Column(
                          children: [
                            Text("Country",style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 5,),
                            Text("$country")
                          ],
                        ),
                      ),
                    ],),
                ),
                Divider(color: Colors.black,height:3,thickness: 1,),
                Text("Cash-out Amount",style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height: 5,),
                Text("${currency} ${views*cpm*exrate/1000}"),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget buildGraph(DataPoints dataMap, String y, String x) {
    final dataPoints = <LineChartBarData>[];
    int highestValue1 = dataMap.likesData.reduce((a, b) => a.minute > b.minute ? a : b).minute;
    List<FlSpot> spots = dataMap.likesData.map((usage) => FlSpot(usage.minute.toDouble(), usage.likes.toDouble())).toList();
    final barChartGroupData = LineChartBarData(
      color: Colors.blueAccent,
      isStrokeJoinRound: true,
      spots: spots,
      dotData: const FlDotData(
        show: true,
      ),
    );
    dataPoints.add(barChartGroupData);
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: LineChart(
            LineChartData(
              maxY: spots.isNotEmpty ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) : 0,
              minY: 0,
              maxX: highestValue1<=10?highestValue1.toDouble():(((highestValue1 + 9) ~/ 10) * 10).toDouble(),
              minX: 0,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  axisNameSize: 16,
                  axisNameWidget: Text(
                    y,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, titleMeta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  axisNameSize: 16,
                  axisNameWidget: Text(
                    x,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 25,
                    getTitlesWidget: (value, titleMeta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: dataPoints,
            ),
          ),
        ),
        SizedBox(height: 20,),
        TextGraphLikesData(dataMap,y,x )
      ],
    );
  }
  Widget TextGraphLikesData(DataPoints dataMap,String y,String x ){
    int likes = dataMap.likesData.fold(0, (sum, element) => sum + element.likes);
    int  duration = dataMap.likesData.last.minute;
    double average= likes/duration;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Graph Insights",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
          SizedBox(height: 5,),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border.all(width: 1,color: Colors.grey)
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(y,style:TextStyle(fontWeight: FontWeight.bold)),
                        Text("$likes"),
                        SizedBox(height: 1,),
                      ],
                    ),
                  ),
                  VerticalDivider(color: Colors.black,width: 40,thickness: 1,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text("Avg $y per minute",style:TextStyle(fontWeight: FontWeight.bold)),
                        Text("$average"),
                        SizedBox(height: 1,),
                      ],
                    ),
                  ),
                ],),
            ),
          ),
        ],
      ),
    );
  }

  Widget TextGraphViewsData(DataPoints dataMap,String y,String x ){
    int views = dataMap.viewsData.fold(0, (sum, element) => sum + element.views);
    int  duration = dataMap.viewsData.last.minute;
    double average= views/duration;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Graph Insights",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
          SizedBox(height: 5,),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border.all(width: 1,color: Colors.grey)
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(y,style:TextStyle(fontWeight: FontWeight.bold)),
                        Text("$views"),
                        SizedBox(height: 1,),
                      ],
                    ),
                  ),
                  VerticalDivider(color: Colors.black,width: 40,thickness: 1,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text("Avg $y per minute",style:TextStyle(fontWeight: FontWeight.bold)),
                        Text("$average"),
                        SizedBox(height: 1,),
                      ],
                    ),
                  ),
                ],),
            ),
          ),
        ],
      ),
    );
  }
  Widget TextGraphDonationsData(DataPoints dataMap,String y,String x ){
    double amount = dataMap.donationsData.fold(0, (sum, element) => sum + element.amount);
    int  duration = dataMap.viewsData.last.minute;
    double average= amount/duration;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Graph Insights",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
          SizedBox(height: 5,),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border.all(width: 1,color: Colors.grey)
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(y,style:TextStyle(fontWeight: FontWeight.bold)),
                        Text("$amount"),
                        SizedBox(height: 1,),
                      ],
                    ),
                  ),
                  VerticalDivider(color: Colors.black,width: 40,thickness: 1,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text("Avg $y per minute",style:TextStyle(fontWeight: FontWeight.bold)),
                        Text("$average"),
                        SizedBox(height: 1,),
                      ],
                    ),
                  ),
                ],),
            ),
          ),
        ],
      ),
    );
  }

  Widget TextGraphWatchHoursData(DataPoints dataMap,String y,String x ){
    double watchhours = dataMap.viewsData.fold(0, (sum, element) => sum + element.watchhours);
    int views = dataMap.viewsData.fold(0, (sum, element) => sum + element.views);
    int  duration = dataMap.viewsData.last.minute;
    double average= watchhours/duration;
    double averagewatchhours= watchhours/views;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Text("Graph Insights",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
          SizedBox(height: 5,),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border.all(width: 1,color: Colors.grey)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IntrinsicHeight(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(y,style:TextStyle(fontWeight: FontWeight.bold)),
                              Text("$watchhours"),
                              SizedBox(height: 1,),
                            ],
                          ),
                        ),
                        VerticalDivider(color: Colors.black,width: 40,thickness: 1,),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text("Avg $y per minute",style:TextStyle(fontWeight: FontWeight.bold)),
                              Text("$average"),
                              SizedBox(height: 1,),
                            ],
                          ),
                        ),
                      ]),
                ),
                Divider(color: Colors.black,height:3,thickness: 1,),
                Text("Avg $y per view",style:TextStyle(fontWeight: FontWeight.bold)),
                Text("$averagewatchhours"),
                SizedBox(height: 5,),
              ],),
          ),
        ],
      ),
    );
  }
  Widget buildGraph1(DataPoints dataMap, String y, String x) {
    final dataPoints = <LineChartBarData>[];
    int highestValue1 = dataMap.likesData.reduce((a, b) => a.minute > b.minute ? a : b).minute;
    List<FlSpot> spots = dataMap.viewsData.map((usage) => FlSpot(usage.minute.toDouble(), usage.views.toDouble())).toList();
    final barChartGroupData = LineChartBarData(
      color: Colors.blueAccent,
      isStrokeJoinRound: true,
      spots: spots,
      dotData: const FlDotData(
        show: true,
      ),
    );
    dataPoints.add(barChartGroupData);
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: LineChart(
            LineChartData(
              maxY: spots.isNotEmpty ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) : 0,
              minY: 0,
              maxX: highestValue1<=10?highestValue1.toDouble():(((highestValue1 + 9) ~/ 10) * 10).toDouble(),
              minX: 0,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  axisNameSize: 16,
                  axisNameWidget: Text(
                    y,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, titleMeta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  axisNameSize: 16,
                  axisNameWidget: Text(
                    x,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 25,
                    getTitlesWidget: (value, titleMeta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: dataPoints,
            ),
          ),
        ),
        SizedBox(height: 20,),
        TextGraphViewsData(dataMap,y,x )
      ],
    );
  }
  Widget buildGraph3(DataPoints dataMap, String y, String x) {
    final dataPoints = <LineChartBarData>[];
    int highestValue1 = dataMap.likesData.reduce((a, b) => a.minute > b.minute ? a : b).minute;
    List<FlSpot> spots = dataMap.donationsData.map((usage) => FlSpot(usage.minute.toDouble(), usage.amount.toDouble())).toList();
    final barChartGroupData = LineChartBarData(
      color: Colors.blueAccent,
      isStrokeJoinRound: true,
      spots: spots,
      dotData: const FlDotData(
        show: true,
      ),
    );
    dataPoints.add(barChartGroupData);
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: LineChart(
            LineChartData(
              maxY: spots.isNotEmpty ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) : 0,
              minY: 0,
              maxX: highestValue1<=10?highestValue1.toDouble():(((highestValue1 + 9) ~/ 10) * 10).toDouble(),
              minX: 0,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  axisNameSize: 16,
                  axisNameWidget: Text(
                    y,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, titleMeta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  axisNameSize: 16,
                  axisNameWidget: Text(
                    x,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 25,
                    getTitlesWidget: (value, titleMeta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: dataPoints,
            ),
          ),
        ),
        SizedBox(height: 20,),
        TextGraphDonationsData(dataMap, y, x),
      ],
    );
  }
  Widget buildGraph2(DataPoints dataMap, String y, String x) {
    final dataPoints = <LineChartBarData>[];
    int highestValue1 = dataMap.likesData.reduce((a, b) => a.minute > b.minute ? a : b).minute;
    List<FlSpot> spots = dataMap.viewsData.map((usage) => FlSpot(usage.minute.toDouble(), usage.watchhours.toDouble())).toList();
    final barChartGroupData = LineChartBarData(
      color: Colors.blueAccent,
      isStrokeJoinRound: true,
      spots: spots,
      dotData: const FlDotData(
        show: true,
      ),
    );
    dataPoints.add(barChartGroupData);
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: LineChart(
            LineChartData(
              maxY: spots.isNotEmpty ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) : 0,
              minY: 0,
              maxX: highestValue1<=10?highestValue1.toDouble():(((highestValue1 + 9) ~/ 10) * 10).toDouble(),
              minX: 0,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  axisNameSize: 16,
                  axisNameWidget: Text(
                    y,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, titleMeta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  axisNameSize: 16,
                  axisNameWidget: Text(
                    x,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 25,
                    getTitlesWidget: (value, titleMeta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: dataPoints,
            ),
          ),
        ),
        SizedBox(height: 20,),
        TextGraphWatchHoursData(dataMap,y,x )
      ],
    );
  }
}



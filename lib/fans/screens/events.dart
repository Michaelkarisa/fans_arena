import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:fans_arena/fans/screens/debate.dart';
import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:fans_arena/fans/screens/search.dart';
import 'package:fans_arena/joint/components/Played.dart';
import 'package:fans_arena/joint/components/colors.dart';
import 'package:fans_arena/joint/components/upcomingevents.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../joint/components/Playing.dart';
import '../../joint/components/ongoing.dart';
import '../../joint/components/recently.dart';
import '../../joint/components/upcoming.dart';
import '../../main.dart';
import 'homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
class EventsF extends StatefulWidget {
  const EventsF({super.key});

  @override
  State<EventsF> createState() => _EventsFState();
}

class _EventsFState extends State<EventsF> with SingleTickerProviderStateMixin{
   late TabController _tabController;
  bool isselected = false;
  final bool _showCloseIcon = false;
Newsfeedservice news=Newsfeedservice();
ScrollController controller=ScrollController();
ScrollController controller1=ScrollController();
ScrollController controller2=ScrollController();
ScrollController controller3=ScrollController();
ScrollController controller4=ScrollController();
ScrollController controller5=ScrollController();
List<MatchM> matchesT=[];
List<MatchM> matchesU=[];
List<MatchM> matchesR=[];
   List<EventM> eventsT=[];
   List<EventM> eventsU=[];
   List<EventM> eventsR=[];
   late NetworkProvider connectivityProvider;
   String userId='new user';
  @override
  void initState() {
    super.initState();
    connectivityProvider = Provider.of<NetworkProvider>(context, listen: false);
    connectivityProvider.addListener(_connectivityChanged);
    connectivityProvider.connectivity();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid; // Assign the user ID to the userId variable
      });}
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        // Load more posts when scrolling to the end
      }
    });
    controller1.addListener(() {
      if (controller1.position.pixels == controller1.position.maxScrollExtent) {
        // Load more posts when scrolling to the end
      }
    });
    controller2.addListener(() {
      if (controller2.position.pixels == controller2.position.maxScrollExtent) {
         // Load more posts when scrolling to the end
      }
    });
    controller3.addListener(() {
      if (controller3.position.pixels == controller3.position.maxScrollExtent) {
         // Load more posts when scrolling to the end
      }
    });
    setState(() {});
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _tabController = TabController(length: 2, vsync: this, initialIndex: index);
    _tabController.addListener(_handleTabChange);
    _startTime=DateTime.now();
  }
 bool isLoading=true;
   Future<void> _connectivityChanged() async {
       if (connectivityProvider.isConnected) {
         if(mR&&loadingR){
           getmatchRData();
         }
         if(mT&&loadingT){
           getmatchTData();
         }
         if(mU&&loadingU){
           getmatchUData();
         }
         if(eR&&loadingeR){
           geteventRData();
         }
         if(eT&&loadingeT){
           geteventTData();
         }
         if(eU&&loadingeU){
           geteventUData();
         }
       } else {
         if(mR&&loadingR){
           getmatchRData();
         }
         if(mT&&loadingT){
           getmatchTData();
         }
         if(mU&&loadingU){
           getmatchUData();
         }
         if(eR&&loadingeR){
           geteventRData();
         }
         if(eT&&loadingeT){
           geteventTData();
         }
         if(eU&&loadingeU){
           geteventUData();
         }
       }
   }
bool nomatchesT=false;
   bool nomatchesU=false;
   bool nomatchesR=false;
   bool noeventsT=false;
   bool noeventsU=false;
   bool noeventsR=false;
   bool loadingT=true;
   bool loadingU=true;
   bool loadingR=true;
   bool loadingeT=true;
   bool loadingeU=true;
   bool loadingeR=true;
  Future<void> getmatchTData()async{
    setState(() {
      loadingT=true;
    });
    List<MatchM> m=await DataFetcher().getTmatches(userId);
    setState(() {
      if(m.isNotEmpty){
        loadingT=false;
        matchesT=m;
      }else{
        loadingT=false;
        nomatchesT=true;
      }
    });
  }
   Future<void> getmatchRData()async{
     setState(() {
       loadingR=true;
     });
     List<MatchM> m=await DataFetcher().getPmatches(userId);
     setState(() {
       if(m.isNotEmpty){
         loadingR=false;
         matchesR=m;
       }else{
         loadingR=false;
         nomatchesR=true;
       }
     });
   }
   Future<void> getmatchUData()async{
     setState(() {
       loadingU=true;
     });
     List<MatchM> m=await DataFetcher().getUmatches(userId);
     setState(() {
       if(m.isNotEmpty){
         loadingU=false;
         matchesU=m;
       }else{
         loadingU=false;
         nomatchesU=true;
       }
     });
   }
  Future<void> geteventTData()async{
     setState(() {
       loadingeT=true;
     });
     List<EventM> e=await DataFetcher().getTevents(userId);
     setState(() {
       if(e.isNotEmpty){
         loadingeT=false;
         eventsT=e;
       }else{
         loadingeT=false;
         noeventsT=true;
       }
     });
}
   Future<void> geteventRData()async{
  setState(() {
    loadingeR=true;
  });
  List<EventM> e=await DataFetcher().getPevents(userId);
  setState(() {
    if(e.isNotEmpty){
      loadingeR=false;
      eventsR=e;
    }else{
      loadingeR=false;
      noeventsR=true;
    }
  });
}
   Future<void> geteventUData()async{
  setState(() {
    loadingeU=true;
  });
  List<EventM> e =await DataFetcher().getUevents(userId);
  setState(() {
    if(e.isNotEmpty){
      eventsU=e;
      loadingeU=false;
    }else{
      loadingeU=false;
      noeventsU=true;
    }
  });
}
  bool mR=false;
  bool mT=true;
  bool mU=false;
   bool eR=false;
   bool eT=true;
   bool eU=false;
  void _handleTabChange() {
    setState(() {
      index = _tabController.index;
    });
    if(index==0){
      getmatchTData();
    }else{
      geteventTData();
    }
  }
  int index=0;
   late DateTime  _startTime;

   @override
   void dispose(){
     Engagement().engagement('EventsFans',_startTime,'');
     connectivityProvider.removeListener(_connectivityChanged);
     super.dispose();
   }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Text('Events',style: TextStyle(color: Textn),),
        backgroundColor: Appbare,
        actions: [
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const Betting()));
              },
              child: SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    'Betting',style: TextStyle(color: Textn),
                  ),
                ),
              ),
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.038),
          child: Material(
            color: Colors.white,
            child: TabBar(
              labelStyle: const TextStyle(fontSize: 18),
              labelColor: Colors.blue,
              controller: _tabController,
              unselectedLabelColor: Colors.grey[600],
              indicatorWeight: 1,
              indicatorColor: Colors.white,
              tabs: [
                Selected(label: 'Matches', isActive: index == 0,fsize: 18,),
                Selected(label: 'Events', isActive: index == 1,fsize: 18,),
              ],
            ),
          ),),
      ),

      body:  TabBarView(
        controller: _tabController,
        children: [
   RefreshIndicator(
     onRefresh: ()async{
       setState(() {
         if(index==0){
           mU=false;
           mT=true;
           mR=false;
           loadingU=true;
           loadingT=true;
           loadingR=true;
         }else{
           eU=false;
           eT=false;
           eR=false;
           loadingeU=true;
           loadingeT=true;
           loadingeR=true;
         }
       });
       await _connectivityChanged();
     },
     child: ListView.builder(
       scrollDirection: Axis.vertical,
    itemCount: 4,
    itemBuilder: (context, index) {
    switch (index) {
        case 0:
          return  Column(
          children: [
            ListTile(
              title: SizedBox(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(
                      child: Text("Today's Matches",
                        style: TextStyle(color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Container(
                          width: 23,
                          height: 23,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: Text('${matchesT.length}',
                              style: const TextStyle(color: Colors.white)),)),),

                  ],
                ),
              ),
              trailing: InkWell(
                  onTap: () {
                    setState(() {
                      mT = !mT;
                    });
                  },
                  child: Icon(
                    mT ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.black,)),
            ),
            mT
                ? FansMatchesT(
              matches: matchesT, loading: loadingT, nomatches: nomatchesT,)
                : const SizedBox.shrink(),
          ],
        );
      case 1:
        return   Column(
          children: [
            ListTile(
              title: SizedBox(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(
                      child: Text('Upcoming this week',
                        style: TextStyle(color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Container(
                          width: 23,
                          height: 23,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: Text('${matchesU.length}',
                              style: const TextStyle(color: Colors.white)),)),),

                  ],
                ),
              ),
              trailing: InkWell(
                  onTap: () {
                    setState(() {
                      mU = !mU;
                      if (matchesU.isEmpty&&mU) {
                        getmatchUData();
                      }
                    });
                  },
                  child: Icon(
                    mU ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.black,)),
            ),
            mU
                ? FansMatchesU(
              matches: matchesU, loading: loadingU, nomatches: nomatchesU,)
                : const SizedBox.shrink(),
          ],
        );
      case 2:
        return  Column(
          children: [
            ListTile(
              title: SizedBox(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(
                      child: Text('Recently',
                        style: TextStyle(color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Container(
                          width: 23,
                          height: 23,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: Text('${matchesR.length}',
                            style: const TextStyle(color: Colors.white),),)),),

                  ],
                ),
              ),
              trailing: InkWell(
                  onTap: () {
                    setState(() {
                      mR = !mR;
                    });
                    if (matchesR.isEmpty&&mR) {
                      getmatchRData();
                    }
                  },
                  child: Icon(
                    mR ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.black,)),
            ),
            mR
                ? FansMatchesR(
              matches: matchesR, loading: loadingR, nomatches: nomatchesR,)
                : const SizedBox.shrink(),
          ],
        );
      case 3:
        return  const SizedBox(
          height: 60,
        );
      default:
        return const SizedBox.shrink();
    } }),
       ),


          RefreshIndicator(
            onRefresh: ()async{
              await geteventTData();
              if(eR){
                await geteventRData();
              }else if(eR&&eU){
                await geteventRData();
                await geteventUData();
              }else if(eU){
                await geteventUData();
              }
            },
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: 4,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return Column(
                      children: [
                        ListTile(
                          title: SizedBox(
                            width: MediaQuery.of(context).size.width*0.25,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Center(
                                  child: Text("Today's Events",
                                    style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Container(
                                      width: 23,
                                      height: 23,
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(child: Text('${eventsT.length}',style: TextStyle(color: Colors.white)),)),),

                              ],
                            ),
                          ),
                          trailing: InkWell(
                              onTap: (){
                                setState(() {
                                  eT=!eT;
                                });
                              },
                              child: Icon(eT?Icons.keyboard_arrow_up:Icons.keyboard_arrow_down,color: Colors.black,)),
                        ),
                        eT?FansEventT(matches: eventsT, loading: loadingeT, noevents:noeventsT ,):const SizedBox.shrink(),
                      ],
                    );
                  case 1:
                    return Column(
                      children: [
                        ListTile(
                          title: SizedBox(
                            width: MediaQuery.of(context).size.width*0.25,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Center(
                                  child: Text('Upcoming this week',
                                    style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Container(
                                      width: 23,
                                      height: 23,
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(child: Text('${eventsU.length}',style: const TextStyle(color: Colors.white)),)),),

                              ],
                            ),
                          ),
                          trailing: InkWell(
                              onTap: (){
                                setState(() {
                                  eU=!eU;
                                });
                                if(eventsU.isEmpty&&eU){
                                  geteventUData();
                                }
                              },
                              child: Icon(eU?Icons.keyboard_arrow_up:Icons.keyboard_arrow_down,color: Colors.black,)),
                        ),
                        eU?FansEventU(matches: eventsU, loading: loadingeU, noevents: noeventsU,):const SizedBox.shrink(),
                      ],
                    );
                  case 2:
                    return Column(
                      children: [
                        ListTile(
                          title: SizedBox(
                            width: MediaQuery.of(context).size.width*0.25,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Center(
                                  child: Text('Recently',
                                    style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Container(
                                      width: 23,
                                      height: 23,
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(child: Text('${eventsR.length}',style: const TextStyle(color: Colors.white)),)),),

                              ],
                            ),
                          ),
                          trailing: InkWell(
                              onTap: (){
                                setState(() {
                                  eR=!eR;
                                });
                                if(eventsR.isEmpty&&eR){
                                  geteventRData();
                                }
                              },
                              child: Icon(eR?Icons.keyboard_arrow_up:Icons.keyboard_arrow_down,color: Colors.black,)),
                        ),
                        eR?FansEventR(matches: eventsR, loading: loadingeR, noevents: noeventsR,):const SizedBox.shrink(),
                      ],
                    );
                  case 3:
                    return const SizedBox(
                      height: 60,
                    );
                  default:
                    return const SizedBox.shrink();
                }},
            ),
          ),


        ],
      ),
    );
  }
}
class FansMatchesT extends StatefulWidget {
  List<MatchM> matches;
  bool loading;
  bool nomatches;
  FansMatchesT({super.key,required this.matches,
    required this.loading,required this.nomatches});

  @override
  State<FansMatchesT> createState() => _FansMatchesTState();
}

class _FansMatchesTState extends State<FansMatchesT> {
  @override
  Widget build(BuildContext context) {
  if(widget.loading&&widget.matches.isEmpty){
    return const CircularProgressIndicator();
  }else if(widget.matches.isNotEmpty){
    return Column(
      children: widget.matches.map((match){
        return OnLayout(matches: match);
      }).toList(),
    );
  }else if(widget.nomatches){
   return const Text('No matches') ;
  }else{
    return const Text('') ;
  }
  }
}
class FansMatchesU extends StatefulWidget {
  List<MatchM> matches;
  bool loading;
  bool nomatches;
  FansMatchesU({super.key,required this.matches,
    required this.loading,required this.nomatches});

  @override
  State<FansMatchesU> createState() => _FansMatchesUState();
}

class _FansMatchesUState extends State<FansMatchesU> {
  @override
  Widget build(BuildContext context) {
    if(widget.loading){
      return const CircularProgressIndicator();
    }else if(widget.matches.isNotEmpty){
      return Column(
        children: widget.matches.map((match){
          return UpLayout(matches: match);
        }).toList(),
      );
    }else if(widget.nomatches){
      return const Text('No matches') ;
    }else{
      return const Text('') ;
    }
  }
}

class FansMatchesR extends StatefulWidget {
  List<MatchM> matches;
  bool loading;
  bool nomatches;
  FansMatchesR({super.key,required this.matches,
    required this.loading,required this.nomatches});

  @override
  State<FansMatchesR> createState() => _FansMatchesRState();
}

class _FansMatchesRState extends State<FansMatchesR> {
  @override
  Widget build(BuildContext context) {
    if(widget.loading&&widget.matches.isEmpty){
      return const CircularProgressIndicator();
    }else if(widget.matches.isNotEmpty){
      return Column(
        children: widget.matches.map((match){
          return RLayout(matches: match);
        }).toList(),
      );
    }else if(widget.nomatches){
      return const Text('No matches') ;
    }else{
      return const Text('') ;
    }
  }
}
class FansEventT extends StatefulWidget {
  List<EventM> matches;
  bool loading;
  bool noevents;
  FansEventT({super.key,required this.matches,
    required this.loading,required this.noevents});

  @override
  State<FansEventT> createState() => _FansEventTState();
}

class _FansEventTState extends State<FansEventT> {
  @override
  Widget build(BuildContext context) {
    if(widget.loading&&widget.matches.isEmpty){
      return const CircularProgressIndicator();
    }else if(widget.matches.isNotEmpty){
      return Column(
        children: widget.matches.map((match){
          return PLayout(matches: match);
        }).toList(),
      );
    }else if(widget.noevents){
      return const Text('No events') ;
    }else{
      return const Text('') ;
    }
  }
}
class FansEventU extends StatefulWidget {
  List<EventM> matches;
  bool loading;
  bool noevents;
  FansEventU({super.key,required this.matches,
    required this.loading,required this.noevents});

  @override
  State<FansEventU> createState() => _FansEventUState();
}

class _FansEventUState extends State<FansEventU> {
  @override
  Widget build(BuildContext context) {
    if(widget.loading&&widget.matches.isEmpty){
      return const CircularProgressIndicator();
    }else if(widget.matches.isNotEmpty){
      return Column(
        children: widget.matches.map((match){
          return UpELayout(matches: match);
        }).toList(),
      );
    }else if(widget.noevents){
      return const Text('No events') ;
    }else{
      return const Text('') ;
    }
  }
}

class FansEventR extends StatefulWidget {
  List<EventM> matches;
  bool loading;
  bool noevents;
  FansEventR({super.key,required this.matches,
    required this.loading,required this.noevents});

  @override
  State<FansEventR> createState() => _FansEventRState();
}

class _FansEventRState extends State<FansEventR> {
  @override
  Widget build(BuildContext context) {
    if(widget.loading&&widget.matches.isEmpty){
      return const CircularProgressIndicator();
    }else if(widget.matches.isNotEmpty){
      return Column(
        children: widget.matches.map((match){
          return PdLayout(matches: match);
        }).toList(),
      );
    }else if(widget.noevents){
      return const Text('No events') ;
    }else{
      return const Text('') ;
    }
  }
}



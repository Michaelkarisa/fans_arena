import 'package:fans_arena/clubs/screens/filmbtn.dart';
import 'package:fans_arena/clubs/screens/filmbutton.dart';
import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:fans_arena/fans/screens/search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fans/data/newsfeedmodel.dart';
import '../../fans/screens/debate.dart';
import '../../fans/screens/homescreen.dart';
import '../../main.dart';
import '../../reusablewidgets/cirularavatar.dart';
import 'package:flutter/services.dart';
import 'eventsclubs.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
class Allmatches extends StatefulWidget {
  const Allmatches({super.key});

  @override
  State<Allmatches> createState() => _AllmatchesState();

}

class _AllmatchesState extends State<Allmatches>  with SingleTickerProviderStateMixin{
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String status='0';
  String userId='';
  List<MatchM> posts = [];
  List<EventM> events = [];
  Set<String>matchIds={};
  Set<String>eventIds={};
  late MatchM lastmatch;
  late EventM lastevent;
  Newsfeedservice news =Newsfeedservice();
  late NetworkProvider connectivityProvider;
  @override
  void initState() {
    super.initState();
    connectivityProvider = Provider.of<NetworkProvider>(context, listen: false);
    connectivityProvider.addListener(_connectivityChanged);
    connectivityProvider.connectivity();
    _startTime=DateTime.now();
    _getCurrentUser1();
    _tabController = TabController(length: 2, vsync: this, initialIndex: index);
    _tabController.addListener(_handleTabChange);
    news = Newsfeedservice();
  }
  Future<void> _connectivityChanged() async {
    if(isLoading||isLoading1){
      if (connectivityProvider.isConnected) {
        getData();
      } else {
        getData();
      }}
  }
  late DateTime _startTime;
  bool isLoading=true;
  bool isLoading1=true;
  bool nomatches=false;
  bool noevents=false;
  Future<void> getData() async{
    if(index==0) {
      setState(() {
        isLoading = true;
        isLoading1 = true;
        posts.clear();
        events.clear();
      });
      try{
      List<MatchM> data = await DataFetcher().getweeksmatches(FirebaseAuth.instance.currentUser!.uid,);
      for (final d in data) {
        await Future.delayed(const Duration(milliseconds: 300));
        if(!matchIds.contains(d.matchId)) {
          setState(() {
            posts.add(d);
            matchIds.add(d.matchId);
          });}
      }
      setState(() {
        if (data.isEmpty) {
          isLoading = false;
          nomatches = true;
        } else {
          isLoading = false;
          lastmatch = data.last;
        }
      });}catch(e){
        dialoge(e.toString());
        if(e=='Exception: Failed to load matches'){
        List<MatchM> data = await Newsfeedservice().getmatches();
        for (final d in data) {
          await Future.delayed(const Duration(milliseconds: 300));
          if(!matchIds.contains(d.matchId)) {
          setState(() {
            posts.add(d);
            matchIds.add(d.matchId);
          });}
        }
        setState(() {
          if (data.isEmpty) {
            isLoading = false;
            nomatches = true;
          } else {
            isLoading = false;
            lastmatch = data.last;
          }
        });
      }}
    }else{
      try {
        List<EventM> data1 = await DataFetcher().getweeksevents(
            FirebaseAuth.instance.currentUser!.uid);
        for (final d in data1) {
          await Future.delayed(const Duration(milliseconds: 300));
          if(!eventIds.contains(d.eventId)) {
            setState(() {
              events.add(d);
              eventIds.add(d.eventId);
            });}
        }
        setState(() {
          if (data1.isEmpty) {
            isLoading1 = false;
            noevents = true;
            fetched = true;
          } else {
            lastevent = data1.last;
            isLoading1 = false;
            fetched = true;
          }
        });
      }catch(e){
        dialoge(e.toString());
         if(e=='Exception: Failed to load events'){
        List<EventM> data1 = await Newsfeedservice().getevents();
        for (final d in data1) {
          await Future.delayed(const Duration(milliseconds: 300));
          if(!eventIds.contains(d.eventId)) {
          setState(() {
            events.add(d);
            eventIds.add(d.eventId);
          });}
        }
        setState(() {
          if (data1.isEmpty) {
            isLoading1 = false;
            noevents = true;
            fetched = true;
          } else {
            lastevent = data1.last;
            isLoading1 = false;
            fetched = true;
          }
        });}
      }
    }
  }


  Future<void> _getCurrentUser1() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid; // Assign the user ID to the userId variable
      });

    }
  }
  bool fetched=false;
  late TabController _tabController;
  void _handleTabChange()async {
    setState(() {
      index = _tabController.index;
    });
    if(index>0&&!fetched){
  getData();
    }
  }
  void dialoge(String e){
    showDialog(
        context: context,
        builder: (context) {
          return  AlertDialog(
            content: Text(e),
          );
        });
  }
  int index=0;
  double radius=18;


  @override
  void dispose(){
    Engagement().engagement('ClubsThisWeeksMatches',_startTime,'');
    connectivityProvider.removeListener(_connectivityChanged);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('This weeks events',style: TextStyle(color: Colors.black),),
          backgroundColor: Colors.white,
          elevation: 1,
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
      
        body:SizedBox(
          height: MediaQuery.of(context).size.height,
          width:MediaQuery.of(context).size.width,
          child: TabBarView(
                      controller: _tabController,
                      children: [
                        RefreshIndicator(
                          triggerMode: RefreshIndicatorTriggerMode.anywhere,
                          onRefresh:()async{
                            setState(() {
                              isLoading = true;
                              posts.clear();
                            });
                            await _connectivityChanged();
                          },
                          child:ALM(matches:posts,nomatches: nomatches,isLoading: isLoading,),
                        ),
                        RefreshIndicator(
                          triggerMode: RefreshIndicatorTriggerMode.anywhere,
                          onRefresh:()async{
                            setState(() {
                              isLoading1 = true;
                              events.clear();
                            });
                            await _connectivityChanged();
                          },
                          child:ALE(events: events,noevents: noevents,isLoading: isLoading1,)
                        ),

                      ],
                    ),
        ),
      ),
    );

  }
}

class ALM extends StatefulWidget {
  bool isLoading;
  List<MatchM>matches;
  bool nomatches;
   ALM({super.key,required this.matches,required this.isLoading,required this.nomatches});

  @override
  State<ALM> createState() => _ALMState();
}

class _ALMState extends State<ALM> {
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
    }else {
      return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: widget.matches.length+1,
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            if(index==widget.matches.length){
              if(widget.isLoading) {
                return  Column(
                  children: [
                    MatchesShimmer(s:"Delete",s1:'Film'),
                    const SizedBox(height: 60,)
                  ],
                );
              }else if(widget.nomatches){
                return const SizedBox(
                  height: 40,
                  child: Center(
                    child: Text('No more matches'),
                  ),
                );
              }else{
                return const SizedBox.shrink();
              }
            }else {
              return AllMLayout(matches: widget.matches[index],set: () {
                setState(() {
                  widget.matches.removeAt(index);
                });
              },);
            }});
    }
  }
}

class ALE extends StatefulWidget {
  bool isLoading;
  List<EventM>events;
  bool noevents;
  ALE({super.key,required this.events,required this.isLoading,required this.noevents});

  @override
  State<ALE> createState() => _ALEState();
}

class _ALEState extends State<ALE> {
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
    }else {
      return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: widget.events.length+1,
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            if(index==widget.events.length){
              if(widget.isLoading) {
                return  Column(
                  children: [
                    EventsShimmer(s:'Delete',s1:'Film'),
                    const SizedBox(height: 60,)
                  ],
                );
              }else if(widget.noevents){
                return const Center(
                  child: Text('No more events'),
                );
              }else{
                return const SizedBox.shrink();
              }
            }else {
              return AllELayout(events: widget.events[index], set: () {
                setState(() {
                  widget.events.removeAt(index);
                });
              },);
            }});
    }
  }
}


class AllELayout extends StatefulWidget {
  EventM events;
  void Function()set;
   AllELayout({super.key,required this.events,required this.set});

  @override
  State<AllELayout> createState() => _AllELayoutState();
}

class _AllELayoutState extends State<AllELayout> {
  double radius=24;
  ScrollController controlerr=ScrollController();

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
      showToastMessage('Event Deleted');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10,left: 10,top: 5),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: MediaQuery.of(context).size.width*0.95,
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
              padding: const EdgeInsets.only(left: 5,right: 5,top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.events.title.isNotEmpty? FittedBox(
                    fit:BoxFit.scaleDown,
                    child: Container(
                        constraints: BoxConstraints(
                          maxWidth:MediaQuery.of(context).size.width*0.7,
                          maxHeight:50 ,
                          minWidth: 0,
                          minHeight:0,
                        ),
                        child: Text(
                          maxLines:2,
                          overflow:TextOverflow.ellipsis,
                          widget.events.title,style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)),
                  ):const SizedBox(height: 0,width: 0,),
                  Padding(
                    padding: const EdgeInsets.only(left: 10,right: 10),
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.85,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],

                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 6,left: 6, right: 6 ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomAvatar(radius: radius, imageurl: widget.events.user.url),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child:  CustomName(
                                    username: widget.events.user.name,
                                    maxsize: 140,
                                    style:const TextStyle(color: Colors.black,fontSize: 16),),
                                ),

                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width*0.5,
                            height: 40,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(widget.events.createdat),
                                Text(widget.events.starttime),
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
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
                                              deleteevent(widget.events.eventId);
                                              Navigator.pop(context); // Dismiss the dialog
                                            },
                                          ),
                                        ],
                                      )
                                    ]);
                              }
                          );
                        } , child: const Text('Delete'),),
                        Container(
                          height: 28,
                          width: MediaQuery.of(context).size.width*0.35,
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 3, right: 2),
                                child: Icon(Icons.location_on_outlined,color: Colors.black,),
                              ),
                              SizedBox(
                                width: 120,
                                  height: 20,
                                  child: OverflowBox(
                                  child: Text(
                                   overflow: TextOverflow.ellipsis,
                                    maxLines:1,
                                    widget.events.location,style: const TextStyle(color: Colors.black,fontSize: 15),))),
                            ],
                          ),
                        ),
                        FilmBtn1(event: widget.events,),
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


class AllMLayout extends StatefulWidget {
  MatchM matches;
  void Function()set;
   AllMLayout({super.key,required this.matches,required this.set});

  @override
  State<AllMLayout> createState() => _AllMLayoutState();
}

class _AllMLayoutState extends State<AllMLayout> {
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
        showToastMessage('Match Deleted');
    });
  }
  double radius=24;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10,left: 10,top: 5),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: MediaQuery.of(context).size.width*0.95,
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
              padding: const EdgeInsets.only(left: 5,right: 5,top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.matches.league.userId.isNotEmpty? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomAvatar(imageurl:widget.matches.league.url, radius: 18),
                      const SizedBox(width: 5,),
                      CustomName(
                        username: widget.matches.league.name,
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
                                    CustomAvatar( radius: radius, imageurl:widget.matches.club1.url),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10,right: 1),
                                      child: Center(child: Text('${widget.matches.score1}',style: const TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold,fontSize: 26),)),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5,top: 5),
                                  child: CustomName(
                                    username: widget.matches.club1.name,
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
                                  widget.matches
                                      .status == '0' ? Column(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceEvenly,
                                    children: [
                                      Text(widget.matches
                                          .createdat),
                                      Text(widget.matches
                                          .starttime),
                                    ],
                                  ):Time(matchId: widget.matches.matchId, club1Id: widget.matches.club1.userId, )

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
                                      child: Center(child: Text('${widget.matches.score2}',style: const TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold,fontSize: 26),)),
                                    ),
                                    CustomAvatar( radius: radius, imageurl:widget.matches.club2.url),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5,top:5),
                                  child: CustomName(
                                    username: widget.matches.club2.name,
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(onPressed: (){
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                    alignment: Alignment.center,
                                    title: const Text('Delete match?'),
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
                                              deletematch(widget.matches.matchId);
                                              Navigator.pop(context); // Dismiss the dialog
                                            },
                                          ),
                                        ],
                                      )
                                    ]);
                              }
                          );
                        } , child: const Text('Delete'),),
                        Container(
                          height: 28,
                          width: MediaQuery.of(context).size.width*0.35,
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 3, right: 2),
                                child: Icon(Icons.location_on_outlined,color: Colors.black,),
                              ),
                              SizedBox(
                                  width: 120,
                                  height: 20,
                                  child: OverflowBox(
                                      child: Text(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines:1,
                                        widget.matches.location,style: const TextStyle(color: Colors.black,fontSize: 15),))),
                            ],
                          ),
                        ),
                        FilmBtn(matches: widget.matches,),
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

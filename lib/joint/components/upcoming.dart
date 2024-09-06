import 'package:fans_arena/clubs/components/clubeventpost.dart';
import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../clubs/screens/accountclubviewer.dart';
import '../../clubs/screens/eventsclubs.dart';
import '../../fans/data/notificationsmodel.dart';
import '../../fans/screens/accountfanviewer.dart';
import '../../professionals/screens/accountprofilepviewer.dart';
import '../../reusablewidgets/cirularavatar.dart';

class Notifyup extends StatefulWidget {
  String matchId;
  Notifyup({super.key, required this.matchId});

  @override
  State<Notifyup> createState() => _NotifyupState();
}

class _NotifyupState extends State<Notifyup> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String username = '';

  @override
  void initState() {
    super.initState();
  }
  Future<void> fetchTimestampAndStartTimer() async {
    DocumentSnapshot timestampSnapshot = await FirebaseFirestore.instance
        .collection('Matches')
        .doc(widget.matchId)
        .get();

    if (timestampSnapshot.exists) {
      Timestamp timestampFromFirebase = timestampSnapshot['scheduledDate'] as Timestamp;
      DateTime startTime = timestampFromFirebase.toDate();
      setState(() {
        LocalNotificationManager().scheduledNotification(
            title: 'Michael Karisa',
            body: 'yeah Im the best', scheduledDate:startTime
        );
      });


    }
  }
  @override
  Widget build(BuildContext context) {
    return  IconButton( padding: EdgeInsets.zero,
        onPressed: fetchTimestampAndStartTimer, icon: const Icon(Icons.alarm,color: Colors.black,size: 25,));
  }
}

class UpLayout extends StatefulWidget {
  MatchM matches;
  UpLayout({super.key,required this.matches});

  @override
  State<UpLayout> createState() => _UpLayoutState();
}

class _UpLayoutState extends State<UpLayout> {
  double radius=24;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
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
                                InkWell(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context){
                                          if(widget.matches.club1.collectionName=='Club'){
                                            return AccountclubViewer(user: widget.matches.club1, index: 0);
                                          }else if(widget.matches.club1.collectionName=='Professional'){
                                            return AccountprofilePviewer(user: widget.matches.club1, index: 0);
                                          }else{
                                            return Accountfanviewer(user:widget.matches.club1, index: 0);
                                          }
                                        }
                                    ),);
                                  },
                                  child: Column(
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
                                      Text(widget.matches.createdat),
                                      Text(widget.matches.starttime),
                                    ],
                                  ),
                                ),

                                InkWell(
                                  onTap: (){
                                    Navigator.push(context,  MaterialPageRoute(
                                        builder: (context){
                                          if(widget.matches.club2.collectionName=='Club'){
                                            return AccountclubViewer(user: widget.matches.club2, index: 0);
                                          }else if(widget.matches.club2.collectionName=='Professional'){
                                            return AccountprofilePviewer(user: widget.matches.club2, index: 0);
                                          }else{
                                            return Accountfanviewer(user:widget.matches.club2, index: 0);
                                          }
                                        }
                                    ),);
                                  },
                                  child: Column(
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
                            SizedBox(width:MediaQuery.of(context).size.width*0.2,child: Notifyup(matchId: widget.matches.matchId)),
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
                            UpDebate(matches:widget.matches),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

      ],
    );
  }
}

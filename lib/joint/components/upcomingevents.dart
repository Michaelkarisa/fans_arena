import 'package:fans_arena/fans/data/notificationsmodel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../clubs/screens/accountclubviewer.dart';
import '../../clubs/screens/eventsclubs.dart';
import '../../fans/screens/accountfanviewer.dart';
import '../../fans/screens/newsfeed.dart';
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
        .collection('Events')
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


class UpELayout extends StatefulWidget {
  EventM matches;
  UpELayout({super.key,required this.matches});

  @override
  State<UpELayout> createState() => _UpELayoutState();
}

class _UpELayoutState extends State<UpELayout> {
  double radius=24;
  @override
  Widget build(BuildContext context) {
    return  Padding(
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
                  widget.matches.title.isNotEmpty? FittedBox(
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
                          widget.matches.title,style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)),
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
                            child: InkWell(
                              onTap: (){
                                Navigator.push(context,      MaterialPageRoute(
                                    builder: (context){
                                      if(widget.matches.user.collectionName=='Club'){
                                        return AccountclubViewer(user: widget.matches.user, index: 0);
                                      }else if(widget.matches.user.collectionName=='Professional'){
                                        return AccountprofilePviewer(user: widget.matches.user, index: 0);
                                      }else{
                                        return Accountfanviewer(user: widget.matches.user, index: 0);
                                      }
                                    }
                                ),);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomAvatar( radius: radius, imageurl:widget.matches.user.url),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: CustomName(
                                      username: widget.matches.user.name,
                                      maxsize: 140,
                                      style:const TextStyle(color: Colors.black,fontSize: 16),),
                                  ),

                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width*0.5,
                            height: 40,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(widget.matches.createdat),
                                Text(widget.matches.starttime),
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
                        SizedBox(width:35,child: Notifyup(matchId: widget.matches.eventId)),
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

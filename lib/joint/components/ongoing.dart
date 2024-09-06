import 'package:fans_arena/fans/screens/debate.dart';
import 'package:fans_arena/fans/screens/matchwatch.dart';
import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:flutter/material.dart';
import '../../clubs/screens/accountclubviewer.dart';
import '../../clubs/screens/eventsclubs.dart';
import '../../fans/screens/accountfanviewer.dart';
import '../../professionals/screens/accountprofilepviewer.dart';
import '../../reusablewidgets/cirularavatar.dart';


class OnLayout extends StatefulWidget {
  MatchM matches;
   OnLayout({super.key,required this.matches});

  @override
  State<OnLayout> createState() => _OnLayoutState();
}

class _OnLayoutState extends State<OnLayout> {
  double radius=24;
  @override
  Widget build(BuildContext context) {
    return  Padding(
            padding: const EdgeInsets.only(right: 10,left: 10,top: 5),
            child:FittedBox(
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
                                          child:  CustomName(
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
                                widget.matches
                                    .status != '0'||widget.matches.duration!=0 ?Time(matchId: widget.matches.matchId, club1Id: widget.matches.club1.userId, ): Column(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly,
                                  children: [
                                    Text(widget.matches
                                        .createdat),
                                    Text(widget.matches
                                        .starttime),
                                  ],
                                ),

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
                                          child:CustomName(
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
                              TextButton(onPressed: (){
                                Navigator.push(context,
                                  MaterialPageRoute(builder: (context)=> Matchwatch(match:widget.matches),
                                  ),
                                );
                              } , child: const Text('Watch'),),
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
                              TextButton(onPressed: (){
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context)=>Debate(matches: widget.matches,)));
                              }, child: const Text('Debate'))
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



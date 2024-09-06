import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../clubs/components/clubeventpost.dart';
import '../../clubs/screens/accountclubviewer.dart';
import '../../clubs/screens/eventsclubs.dart';
import '../../fans/screens/accountfanviewer.dart';
import '../../fans/screens/debate.dart';
import '../../fans/screens/newsfeed.dart';
import '../../reusablewidgets/cirularavatar.dart';
import '../screens/accountprofilepviewer.dart';

class Matchess extends StatefulWidget {
  String match1Id;
  String match2Id;
  String leagueId;
  String year;
  Matchess({super.key,
    required this.year,
    required this.match1Id,
    required this.match2Id,
    required this.leagueId,
  });

  @override
  State<Matchess> createState() => _MatchessState();
}

class _MatchessState extends State<Matchess> {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
bool isloading=true;

  @override
  void initState() {
    super.initState();
     retrieveMatch();
     setState(() {
     match=MatchM(
         startime: Timestamp.now(),
         stoptime: Timestamp.now(),
         duration: 0,
         matchId: '',
         timestamp:Timestamp.now(),
         score1: 0,
         score2: 0,
         location: '',
         status: '',
         starttime: '',
         createdat: '',
         tittle: '',
         leaguematchId: '',
         match1Id: '',
         status1: '',
         authorId:'',
         club1: Person(name:'',
           url: '',
           collectionName: '',
           userId: '',),
         club2: Person(name:'',
           url: '',
           collectionName: '',
           userId: '',),
         league: Person(name:'',
           url: '',
           collectionName: '',
           userId: '',),);
     match1=MatchM(
       startime: Timestamp.now(),
       stoptime: Timestamp.now(),
       duration: 0,
       matchId: '',
       timestamp:Timestamp.now(),
       score1: 0,
       score2: 0,
       location: '',
       status: '',
       starttime: '',
       createdat: '',
       tittle: '',
       leaguematchId: '',
       match1Id: '',
       status1: '',
       authorId:'',
       club1: Person(name:'',
         url: '',
         collectionName: '',
         userId: '',),
       club2: Person(name:'',
         url: '',
         collectionName: '',
         userId: '',),
       league: Person(name:'',
         url: '',
         collectionName: '',
         userId: '',),);
     });
  }
  late MatchM match;
  late MatchM match1;
  bool isloading1=true;
  void retrieveMatch() async {
    try{
      if(widget.match1Id.isNotEmpty) {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection(
            'Matches').doc(widget.match1Id).get();
        match = await Newsfeedservice().getmatch(doc);
        setState(() {
          isloading = false;
        });
      }else {
        setState(() {
          isloading = false;
        });
      }
      if(widget.match2Id.isNotEmpty) {
        DocumentSnapshot doc1 = await FirebaseFirestore.instance.collection(
            'Matches').doc(widget.match2Id).get();
        match1 = await Newsfeedservice().getmatch(doc1);
        setState(() {
          isloading1 = false;
        });
      }else {
        setState(() {
          isloading1 = false;
        });
      }
    } catch (e) {
      showDialog(context: context, builder: (context){
        return AlertDialog(
          content: Text("$e"),
        );
      });
    }
  }

  double radius=24;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
          },icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,),),
        title: const Text('Matches',style: TextStyle(color: Colors.black),),
      ),
      body: SizedBox(
          width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(5.0),
              child: Text('Home Match',style: TextStyle(fontWeight: FontWeight.bold)),
            ),
           Builder(builder: (context){
             if(isloading){
               return const Center(
                 child: CircularProgressIndicator(),);
             }else if(widget.match1Id.isNotEmpty){
               return Padding(
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
                                       InkWell(
                                         onTap: (){
                                           Navigator.push(context, MaterialPageRoute(
                                               builder: (context){
                                                 if(match.club1.collectionName=='Club'){
                                                   return AccountclubViewer(user: match.club1, index: 0);
                                                 }else if(match.club1.collectionName=='Professional'){
                                                   return AccountprofilePviewer(user: match.club1, index: 0);
                                                 }else{
                                                   return Accountfanviewer(user: match.club1, index: 0);
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
                                                 CustomAvatar( radius: radius, imageurl:match.club1.url),
                                                 Padding(
                                                   padding: const EdgeInsets.only(left: 10,right: 1),
                                                   child: Center(child: Text('${match.score1}',style: const TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold,fontSize: 26),)),
                                                 ),
                                               ],
                                             ),
                                             Padding(
                                               padding: const EdgeInsets.only(left: 5,top: 5),
                                               child:  CustomName(
                                                 username: match.club1.name,
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
                                       InkWell(
                                         onTap: (){
                                           Navigator.push(context,  MaterialPageRoute(
                                               builder: (context){
                                                 if(match.club2.collectionName=='Club'){
                                                   return AccountclubViewer(user: match.club2, index: 0);
                                                 }else if(match.club2.collectionName=='Professional'){
                                                   return AccountprofilePviewer(user: match.club2, index: 0);
                                                 }else{
                                                   return Accountfanviewer(user:match.club2, index: 0);
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
                                                   child: Center(child: Text('${match.score2}',style: const TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold,fontSize: 26),)),
                                                 ),
                                                 CustomAvatar( radius: radius, imageurl:match.club2.url),
                                               ],
                                             ),
                                             Padding(
                                               padding: const EdgeInsets.only(left: 5,top:5),
                                               child:CustomName(
                                                 username: match.club2.name,
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
                                   Watch(match:match,),
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
                                                   match.location,style: const TextStyle(color: Colors.black,fontSize: 15),))),
                                       ],
                                     ),
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
             }else{
               return const Center(child: Text("Home Match not Available"));
             }
           }),
            const Padding(
              padding: EdgeInsets.all(5.0),
              child: Text('Away Match',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Builder(builder: (context){
              if(isloading1){
                return const Center(child: CircularProgressIndicator(),);
              }else if(widget.match2Id.isNotEmpty){
                return Padding(
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
                              match1.league.userId.isNotEmpty? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomAvatar(imageurl:match1.league.url, radius: 18),
                                  const SizedBox(width: 5,),
                                  CustomName(
                                    username: match1.league.name,
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
                                                  if(match1.club1.collectionName=='Club'){
                                                    return AccountclubViewer(user: match1.club1, index: 0);
                                                  }else if(match1.club1.collectionName=='Professional'){
                                                    return AccountprofilePviewer(user: match1.club1, index: 0);
                                                  }else{
                                                    return Accountfanviewer(user: match1.club1, index: 0);
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
                                                  CustomAvatar( radius: radius, imageurl:match1.club1.url),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 10,right: 1),
                                                    child: Center(child: Text('${match1.score1}',style: const TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold,fontSize: 26),)),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 5,top: 5),
                                                child:  CustomName(
                                                  username: match1.club1.name,
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
                                              match1.status != '0'||match1.duration!=0 ?Time(matchId: match1.matchId, club1Id: match1.club1.userId, ): Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Text(match1.createdat),
                                                  Text(match1.starttime),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: (){
                                            Navigator.push(context,  MaterialPageRoute(
                                                builder: (context){
                                                  if(match1.club2.collectionName=='Club'){
                                                    return AccountclubViewer(user: match1.club2, index: 0);
                                                  }else if(match1.club2.collectionName=='Professional'){
                                                    return AccountprofilePviewer(user: match1.club2, index: 0);
                                                  }else{
                                                    return Accountfanviewer(user:match1.club2, index: 0);
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
                                                    child: Center(child: Text('${match1.score2}',style: const TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold,fontSize: 26),)),
                                                  ),
                                                  CustomAvatar( radius: radius, imageurl:match1.club2.url),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 5,top:5),
                                                child:CustomName(
                                                  username: match1.club2.name,
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
                                    Watch(match:match1,),
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
                                                    match1.location,style: const TextStyle(color: Colors.black,fontSize: 15),))),
                                        ],
                                      ),
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
              }else{
                return const Center(child: Text("Away Match not Available"));
              }
            }),
          ],
        ),
      ),
    );
  }
}

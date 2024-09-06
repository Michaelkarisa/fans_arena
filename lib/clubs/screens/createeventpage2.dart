import 'package:fans_arena/joint/components/recently.dart';
import 'package:flutter/material.dart';
import 'package:fans_arena/reusablewidgets/cirularavatar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fans/data/newsfeedmodel.dart';
import '../../fans/screens/newsfeed.dart';
import 'eventsclubs.dart';
class CreateEventPage2 extends StatefulWidget {
  String  matchId;
   CreateEventPage2({super.key,required this.matchId,});

  @override
  State<CreateEventPage2> createState() => _CreateEventPage2State();
}

class _CreateEventPage2State extends State<CreateEventPage2> {
  TextEditingController league = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String url='https://assets.mixkit.co/videos/preview/mixkit-group-of-friends-partying-happily-4640-large.mp4';
  String club1name='';
  String imageurl1='';
  String imageurl2='';
  String club2name='';
  String leaguename='';
  String leagueimageurl='';
  String message='The match has not yet Started';
  String location='';
  Timestamp date=Timestamp.now();
  String time='';
  String userId = '';
  String pausetime='';
  String additionalinfo='';
  String formattedTime1 = '';
  String starttime='';
  String stoptime='';
  String club1='';
  String club2='';
  String leagueId='';
  String leaguematchId='';
  String match1Id='';
  String authorId='';
  @override
  void initState() {
    super.initState();
   retrieveUsername();
   if(widget.matchId.isEmpty){
     dialoge("MatchId is empty");
   }else{
     dialoge(widget.matchId);
   }
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
    });
  }
  late MatchM match;
  bool isloading=true;
  List<String>years=[];
  Future<void> retrieveUsername1() async {
    QuerySnapshot querysnapshot = await FirebaseFirestore.instance
        .collection('Leagues')
        .doc(match.league.userId)
        .collection('year')
        .orderBy('timestamp',descending: true)
        .get();

    if (querysnapshot.docs.isNotEmpty) {
      List<QueryDocumentSnapshot>documents=querysnapshot.docs;
      for(final document in documents){
        years.add(document.id);
      }
    }
  }
  void retrieveUsername() async {
    try{
      match=await DataFetcher().getMatch(widget.matchId);
      retrieveUsername1();
    } catch (e) {
      dialoge('Error retrieving username: $e');
    }
  }

  void postmatch()async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: MediaQuery.of(context).size.height*0.02222),
                const Text('Creating match...'),
              ],
            ),
          ),
        );
      },
    );
    final matchesCollection =  FirebaseFirestore.instance.collection('Matches');
   String matchId = matchesCollection.doc().id;
    try {
      // Upload the image to Firebase Storage and get the URL

      // Check if the image upload was successful
      // Generate a unique post ID
      Timestamp createdAt = Timestamp.now(); // Get the current timestamp
      await matchesCollection
          .doc(matchId)
          .set({
        'matchId': matchId,
        'club1Id': match.club1.userId,
        'score1':0,
        'club2Id': match.club2.userId,
        'score2':0,
        'location': match.location,
        'matchUrl': url,
        'authorId': FirebaseAuth.instance.currentUser!.uid,
        'activeuser':0,
        'createdAt': createdAt,
        'leagueId':match.league.userId,
        'scheduledDate':match.timestamp,
        'time':match.starttime,
        'state1':'0',
        'state2':'0',
        'message':message,
        'starttime': starttime,
        'pausetime':pausetime,
        'resumetime':pausetime,
        'duration':0,
        'stoptime': stoptime,
        'additionalinfo':additionalinfo,
        'leaguematchId':match.leaguematchId,
        'title':'',
        'match1Id':match.matchId,
        // Add more fields as needed
      });
        saveDataToFirestore(matchId);
        if(leagueId.isNotEmpty) {
          saveDataToFirestore1(matchId);
        }
        await Future.delayed(const Duration(milliseconds: 2500));
        back();
        await Future.delayed(const Duration(milliseconds: 1000));
       dialoge('Match created');
       await Future.delayed(const Duration(seconds: 4),(){});
        back();
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 1500));
     back();
      await Future.delayed(const Duration(milliseconds: 1000));
  dialoge(e.toString());
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
  void back(){
    Navigator.of(context,rootNavigator: true).pop();
  }
  Future<void> saveDataToFirestore(String matchId) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('Matches')
          .where('matchId', isEqualTo:match.matchId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var documentSnapshot = querySnapshot.docs[0];
        var oldData = documentSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> newData = {};
        if (matchId.isNotEmpty && matchId != oldData['match1Id']) {
          newData['match1Id'] = matchId;
        }
        if (newData.isNotEmpty) {
          await documentSnapshot.reference.update(newData);
        } else {
          dialoge('No changes to update');
        }
      } else {
        dialoge('No matching document found.');
      }
    } catch (e) {
      dialoge(e.toString());
    }
  }
  Future<void> saveDataToFirestore1(String matchId) async {
    try {
      CollectionReference collection = FirebaseFirestore.instance
          .collection('Leagues')
          .doc(leagueId)
          .collection('year')
          .doc(years.first)
          .collection('leaguematches');

      // Get all documents from the subcollection
      QuerySnapshot querySnapshot = await collection.get();

      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        List<dynamic> clubsteam = documentSnapshot['matches'];

        // Find the index of the array element with matching 'teamId'
        int indexToUpdate = -1;
        for (int i = 0; i < clubsteam.length; i++) {
          if (clubsteam[i]['matchId'] == leaguematchId) {
            indexToUpdate = i;
            break;
          }
        }

        if (indexToUpdate != -1) {
          // Update the 'role' field for the array element
          if (club1==FirebaseAuth.instance.currentUser!.uid&&matchId.isNotEmpty && matchId != clubsteam[indexToUpdate]['match1Id']) {
            clubsteam[indexToUpdate]['match1Id'] = matchId;
          }
          if (club2==FirebaseAuth.instance.currentUser!.uid&&matchId.isNotEmpty && matchId != clubsteam[indexToUpdate]['match2Id']) {
            clubsteam[indexToUpdate]['match2Id'] = matchId;
          }
          // Update the Firestore document with the modified 'clubsteam' array
          await documentSnapshot.reference.update({'matches': clubsteam});
          break; // Exit the loop once the update is done
        }
      }
    } catch (e) {
      dialoge('Error updating role: $e');
    }
  }
  double radius= 18;
  double fsize= 14;
  @override
  Widget build(BuildContext context) {
   return SafeArea(
     child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,),
            onPressed: () {
              Navigator.of(context).pop();
            },//to next page},
          ),
          title: const Text('Create event',style: TextStyle(color: Colors.black),),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 370,
                    height: 140,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Home',style:TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 50,
                              width: 250,
                              child: Row(
                                children: [
                                  CustomAvatar( radius: radius, imageurl:match.club1.url),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child:CustomName(
                                      username: match.club1.name,
                                      maxsize: 150,
                                      style:const TextStyle(color: Colors.black,fontSize: 16),),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>LineUpA(match:match,)));
                            }, child: const Text('Lineup'))
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 370,
                    height: 80,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5,right: 5,top: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('Match',style:TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 45,
                              width: 360,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomAvatar( radius: radius, imageurl:match.club1.url),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: CustomName(
                                      username:match.club1.name,
                                      maxsize: 120,
                                      style:const TextStyle(color: Colors.black,fontSize: 16),)
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5,right: 5),
                                    child: Container(
                                      width: 25,
                                      height: 30,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius
                                              .circular(5),
                                          border: Border.all(
                                              width: 1,
                                              color: Colors.black
                                          )
                                      ),
                                      child: const Center(child: Text('VS')),
                                    ),
                                  ),
                                  CustomAvatar( radius: radius, imageurl:match.club2.url),
                                  Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: CustomName(
                                        username:match.club2.name,
                                        maxsize: 120,
                                        style:const TextStyle(color: Colors.black,fontSize: 16),)
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
                    width: 370,
                    height: 140,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Away',style:TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 50,
                              width: 250,
                              child: Row(
                                children: [
                                  CustomAvatar( radius: radius, imageurl:match.club2.url),
                                  Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: CustomName(
                                        username:match.club2.name,
                                        maxsize: 120,
                                        style: TextStyle(color: Colors.black,fontSize: fsize),)
                                  ),
                                ],
                              ),
                            ),
                            TextButton(onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>LineUpB(match: match,)));
                              }, child: const Text('Lineup'))
                          ],
                        ),
                      ),
                    ),
                  ),

                 leagueId.isNotEmpty? SizedBox(
                    width: 370,
                    height: 100,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('League',style:TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 50,
                              width: 250,
                              child: match.league.userId.isNotEmpty? Row(
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  ):const SizedBox(height: 0,width: 0,),
                  SizedBox(
                    width: 250,
                    height: 200,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text('Other neccesary information',style:TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(
                              width: 250,
                              height: 30,
                              child: Text('Location: $location')),
                          SizedBox(
                              width: 250,
                              height: 30,
                              child: Text('Date: $formattedTime1' )),
                          SizedBox(
                              width: 250,
                              height: 30,
                              child: Text('Time: $time')
                          ),

                        ],
                      ),
                    ),
                  ),

                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 30),
                      side: const BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    onPressed: postmatch
                    ,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1),
                      child: Text(
                        "Post match",
                        style: TextStyle(color: Colors.black),
                      ),
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
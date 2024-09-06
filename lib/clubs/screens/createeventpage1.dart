import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fans/screens/messages.dart';
import '../../fans/screens/notifications.dart';
import 'createeventpage2.dart';
class CreateEventPage1 extends StatefulWidget {
  String leagueId;
  String leaguematchId;
  CreateEventPage1({super.key,
    required this.leaguematchId,
    required this.leagueId,});

  @override
  State<CreateEventPage1> createState() => _CreateEventPage1State();
}

class _CreateEventPage1State extends State<CreateEventPage1> {
  TextEditingController league = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String url='https://assets.mixkit.co/videos/preview/mixkit-group-of-friends-partying-happily-4640-large.mp4';
  String score1='0';
  String score2='0';
  String club1name='';
  String imageurl1='';
  String imageurl2='';
  String club2name='';
  String leaguename='';
  String leagueimageurl='';
  String state1='0';
  String state2='0';
  String message='The match has not yet Started';
 String location='';
late Timestamp date;
 String time='';
  String userId = '';
  String pausetime='';
  String additionalinfo='';
  String formattedTime1 = '';
  String matchId = '';
  String starttime='';
  String stoptime='';
  String club1='';
  String club2='';
  String matchid='';
  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    retrieveUsername1();
  }
String match1Id='';
  String match2Id='';
  void _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid; // Assign the user ID to the userId variable
      });
      retrieveUserData3();

    }
  }


  void retrieveUserData2() async {
    try {
      QuerySnapshot querySnapshotC = await firestore
          .collection('Clubs')
          .where('Clubid', isEqualTo: club1)
          .limit(1)
          .get();

      if (querySnapshotC.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotC.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          club1name = data['Clubname'];
          imageurl1=data['profileimage'];
          // other fields from the Fans collection
        });
      } else {
        dialoge('No matching document found.');
      }
    } catch (e) {
      dialoge('Error retrieving user data: $e');
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
  void retrieveUserData4() async {
    try {
      QuerySnapshot querySnapshotC = await firestore
          .collection('Clubs')
          .where('Clubid', isEqualTo: club2)
          .limit(1)
          .get();

      if (querySnapshotC.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotC.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          club2name=data['Clubname'];
          imageurl2=data['profileimage'];
          // other fields from the Fans collection
        });
      } else {
        dialoge('No matching document found.');
      }
    } catch (e) {
      dialoge('Error retrieving user data: $e');
    }
  }
  void retrieveUserData3() async {
    try {
      QuerySnapshot querySnapshotC = await firestore
          .collection('Leagues')
          .where('leagueId', isEqualTo:widget.leagueId)
          .limit(1)
          .get();

      if (querySnapshotC.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotC.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          leaguename=data['leaguename'];
          leagueimageurl=data['profileimage'];
          // other fields from the Fans collection
        });
      } else {
        dialoge('No matching document found.');
      }
    } catch (e) {
      dialoge('Error retrieving user data: $e');
    }
  }
  List<String>years=[];
  Future<void> retrieveUsername1() async {
    QuerySnapshot querysnapshot = await FirebaseFirestore.instance
        .collection('Leagues')
        .doc(widget.leagueId)
        .collection('year')
        .orderBy('timestamp',descending: true)
        .get();

    if (querysnapshot.docs.isNotEmpty) {
      List<QueryDocumentSnapshot>documents=querysnapshot.docs;
      for(final document in documents){
        years.add(document.id);
      }
      retrieveUserData();
    }
  }
  Timestamp toDate=Timestamp.now();
  void retrieveUserData() async {
    try {
      CollectionReference collection = FirebaseFirestore.instance
          .collection('Leagues')
          .doc(widget.leagueId)
          .collection('year')
          .doc(years.first)
          .collection('leaguematches');
      QuerySnapshot querySnapshot = await collection.get();
      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        List<dynamic> clubsteam = documentSnapshot['matches'];

        int indexToUpdate = -1;
        for (int i = 0; i < clubsteam.length; i++) {
          if (clubsteam[i]['matchId'] == widget.leaguematchId) {
            indexToUpdate = i;
            break;
          }
        }

        if (indexToUpdate != -1) {
          // Retrieve the data without updating variables
          setState(() {
            toDate = clubsteam[indexToUpdate]['scheduledDate'];
            DateTime createdDateTime1 = toDate.toDate();
            formattedTime1 = DateFormat('d MMM').format(createdDateTime1);
            location = clubsteam[indexToUpdate]['location'];
            club1 = clubsteam[indexToUpdate]['club1Id'];
            club2 = clubsteam[indexToUpdate]['club2Id'];
            time = clubsteam[indexToUpdate]['time'];
            date = clubsteam[indexToUpdate]['scheduledDate'];
            match1Id= clubsteam[indexToUpdate]['match1Id']??'';
            match2Id= clubsteam[indexToUpdate]['match2Id']??'';
          });
          // You can choose to do something with the retrieved data here
          // For now, let's just print it
          break; // Exit the loop once the data is retrieved
        }
      }
    } catch (e) {
    dialoge('Error retrieving data: $e');
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
    String club = club1==userId?club2:club1;
    DateTime selectedDate = toDate.toDate();
    final today=DateTime(selectedDate.year,selectedDate.month,selectedDate.day);
    final matchesCollection =  FirebaseFirestore.instance.collection('Matches');
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Matches').where('authorId',isEqualTo: club).where('scheduledDate',isEqualTo:Timestamp.fromDate(today)).get();
      QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance.collection('Matches').where('authorId',isEqualTo: userId).where('scheduledDate',isEqualTo:Timestamp.fromDate(today)).get();

      // Upload the image to Firebase Storage and get the URL
        if(querySnapshot1.docs.isEmpty){
          if(querySnapshot.docs.isNotEmpty){
            String clb1='';
            String clb2='';
            var documentSnapshot = querySnapshot.docs[0];
            var data = documentSnapshot.data() as Map<String, dynamic>;
            setState(() {
              matchid=documentSnapshot.id;
              clb1=data['club1Id'];
              clb2=data['club2Id'];
            }); // Check if the image upload was successful
            back();
            await Future.delayed(const Duration(milliseconds: 1000));
            dialog(club1: clb1, club2: clb2);
          }else {
            // Check if the image upload was successful
            matchId = matchesCollection
                .doc()
                .id; // Generate a unique post ID
            Timestamp createdAt = Timestamp.now(); // Get the current timestamp
            await matchesCollection
                .doc(matchId)
                .set({
              'matchId': matchId,
              'club1Id': club1,
              'score1': 0,
              'club2Id': club2,
              'score2': 0,
              'location': location,
              'matchUrl': url,
              'authorId': userId,
              'activeuser': 0,
              'createdAt': createdAt,
              'leagueId': widget.leagueId,
              'scheduledDate': date,
              'time': time,
              'state1': state1,
              'state2': state2,
              'message': message,
              'starttime': starttime,
              'pausetime': pausetime,
              'resumetime': pausetime,
              'duration': 0,
              'stoptime': stoptime,
              'additionalinfo': additionalinfo,
              'leaguematchId': widget.leaguematchId,
              'title': '',
              'match1Id': club2 == userId ? match2Id : match1Id,

              // Add more fields as needed
            });
            await saveDataToFirestore1();
          }
        }else{
          back();
          await Future.delayed(const Duration(milliseconds: 1000));
          dialog1();
        }
     }catch (e) {
      back();
      await Future.delayed(const Duration(milliseconds: 1000));
      dialoge("$e Error in posting match ");
    }
  }
  dialog({required String club1,required String club2})async{
    showDialog(context: context, builder:(context){
      return AlertDialog(
        content: const Text(' The club you selected has a match on this day. Do you want to see the match?'),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: ()async{
                navigate(club1, club2);
              }, child: const Text('View match')),
              TextButton(onPressed: (){Navigator.pop(context);}, child: const Text('dismiss')),
            ],
          )
        ],
      );
    });
  }
  void navigate(String club1,String club2){
    Navigator.push(context, MaterialPageRoute(builder: (context){
      if(club1==FirebaseAuth.instance.currentUser!.uid||club2==FirebaseAuth.instance.currentUser!.uid) {
        return CreateEventPage2(
          matchId: matchid,);
      }else{
        return ViewMatch(matchId: matchid, club1Id: club1, club2Id: club2);
      }
    }
    ));
  }
  void dialog1(){
    showDialog(
        context: context,
        builder: (context) {
          return  AlertDialog(
            alignment: Alignment.center,
            content: const Text('You already have a match for the selected  date. You cannot create more than one match for the same date.'),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(onPressed: (){Navigator.pop(context);}, child: const Text('dismiss')),
                ],
              ),
            ],
          );
        });
  }

  Future<void> saveDataToFirestore1() async {
    try {
      CollectionReference collection = FirebaseFirestore.instance
          .collection('Leagues')
          .doc(widget.leagueId)
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
          if (clubsteam[i]['matchId'] == widget.leaguematchId) {
            indexToUpdate = i;
            break;
          }
        }

        if (indexToUpdate != -1) {
          // Update the 'role' field for the array element
          if (club1==userId&&matchId.isNotEmpty && matchId != clubsteam[indexToUpdate]['match1Id']) {
            clubsteam[indexToUpdate]['match1Id'] = matchId;
          }
          if (club2==userId&&matchId.isNotEmpty && matchId != clubsteam[indexToUpdate]['match2Id']) {
            clubsteam[indexToUpdate]['match2Id'] = matchId;
          }
          // Update the Firestore document with the modified 'clubsteam' array
          await documentSnapshot.reference.update({'matches': clubsteam});
          back();
          await Future.delayed(const Duration(milliseconds: 1000));
          dialoge('Match created');
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
                    height: 100,
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
                                  CustomAvatarM(userId: club1, radius: radius,),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: CustomNameM(userId: club1, style: TextStyle(fontSize: fsize), maxsize: 150,),),

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
                                  CustomAvatarM(userId: club1, radius: radius,),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: CustomNameM(userId: club1, style: TextStyle(fontSize: fsize), maxsize: 120,),
                                    ),
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
                                  CustomAvatarM(userId: club2, radius: radius,),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: CustomNameM(userId: club2, style: TextStyle(fontSize: fsize), maxsize: 120,),),
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
                    height: 100,
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
                                  CustomAvatarM(userId: club2, radius: radius,),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: CustomNameM(userId: club2, style: TextStyle(fontSize: fsize), maxsize: 150,),
                                  )
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
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.black,
                                    child: CachedNetworkImage(
                                      alignment: Alignment.center,
                                      imageUrl:
                                      leagueimageurl,
                                      imageBuilder: (context,
                                          imageProvider) =>
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundImage: imageProvider,
                                          ),

                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: SizedBox(
                                        width: 150,
                                        height: 20,
                                        child: OverflowBox(
                                            child: Text(
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                leaguename))),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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

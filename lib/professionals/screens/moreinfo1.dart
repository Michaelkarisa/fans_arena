import 'package:fans_arena/fans/screens/leagueviewer.dart';
import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:fans_arena/reusablewidgets/cirularavatar.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fans/screens/messages.dart';

class MoreInfo1 extends StatefulWidget {
  String userId;
 MoreInfo1({super.key,required this.userId});

  @override
  State<MoreInfo1> createState() => _MoreInfo1State();
}

class _MoreInfo1State extends State<MoreInfo1> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String leagueId='';
  String imageurl = '';
  String leaguename = '';
  String clubId='';
  String identity='';
  String role='';
  bool create=false;
  bool profe=false;
  bool info=false;
  late LeagueC league;
  @override
  void initState() {
    super.initState();
    retrieveUsername();
    retrieveUsername1();
  }
  String year='';
 Future<void> retrieveUsername3() async {
    league=await DataFetcher().getLeague(leagueId);
        setState(() {
          year=league.leagues.first;
        });
      }

  bool isloading=true;
  Future<void> retrieveUsername() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Leagues')
          .where('authorId', isEqualTo: widget.userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var documentSnapshot = querySnapshot.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          leagueId = data['leagueId'];
          imageurl = data['profileimage'];
          leaguename = data['leaguename'];
          create=true;
          info=true;
          isloading=false;
        });
        await retrieveUsername3();
      } else {
        setState(() {
          create = false;
          info=false;
        });
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving leaguedata: $e');
    }
  }

  Future<void> retrieveUsername1() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Professionals')
          .doc(widget.userId)
          .collection('club')
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        var documentSnapshot = querySnapshot.docs[0].id;
        setState(() {
          clubId=documentSnapshot;
          isloading=false;
        });
        await retrieveUserData(clubId:documentSnapshot);
      } else {
        setState(() {
          info=false;
        });
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving leaguedata: $e');
    }
  }

  Future<void> retrieveUserData({required String clubId}) async {
    try {
      CollectionReference collection = FirebaseFirestore.instance
          .collection('Clubs')
          .doc(clubId)
          .collection('clubsteam');
      QuerySnapshot querySnapshot = await collection.get();
      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        List<dynamic> clubsteam = documentSnapshot['clubsteam'];
        int indexToUpdate = -1;
        for (int i = 0; i < clubsteam.length; i++) {
          if (clubsteam[i]['teamId'] == widget.userId) {
            indexToUpdate = i;
            break;
          }
        }
        if (indexToUpdate != -1) {
          setState(() {
            role = clubsteam[indexToUpdate]['role'];
            identity=clubsteam[indexToUpdate]['identity'];
          });
          break;
        }
      }
    } catch (e) {
      showDialog(context: context, builder: (context){
        return AlertDialog(
          content: Text('$e'),
        );
      });
      print('Error retrieving data: $e');
    }
  }
  double radius=18;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('More info', style: TextStyle(color: Colors.black),),
          elevation: 1,
          backgroundColor: Colors.white,
        ),
        body:isloading||league==null?const Center(child: CircularProgressIndicator()): SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height:MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  info?const SizedBox(height: 0,):const SizedBox(
                    child:   Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text("No more info about user's extra activities",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                    ),
                  ),
                  create?Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text('League user is managing',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomAvatar(radius: radius, imageurl: league.imageurl),
                          InkWell(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LeagueLayout(league:league,year: year,),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: SizedBox(
                                  width: MediaQuery.of(context).size.width*0.4,
                                  height: 20,
                                  child: OverflowBox(
                                      child: Text( maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        league.leaguename,style: const TextStyle(color:Colors.black),))),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ):const SizedBox(height: 0,),
                  clubId.isNotEmpty?Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Club engaged into',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                         CustomUsernameD0Avatar(radius: radius, userId:clubId,
                           style:const TextStyle(color: Colors.black,fontSize: 16),
                           maxsize: 140,
                           height: 30,
                           width: 175,)
                        ],
                      ),
                      const SizedBox(width: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              const Text('Role: ',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                              Text(role),
                            ],
                          ),
                          identity.isNotEmpty?Row(
                            children: [
                              const Text('Identity: ',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                              Text(identity),
                            ],
                          ):const SizedBox(height: 0,),
                        ],
                      )
                    ],
                  ):const SizedBox(height: 0,)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}

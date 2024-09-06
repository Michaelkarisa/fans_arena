import 'package:fans_arena/clubs/screens/createeventpage2.dart';
import 'package:fans_arena/fans/data/usermodel.dart';
import 'package:fans_arena/fans/screens/notifications.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../appid.dart';
import '../../reusablewidgets/cirularavatar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'clubteamtable.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  TextEditingController club1 = TextEditingController();
  TextEditingController time = TextEditingController();
  TextEditingController club2  = TextEditingController();
  TextEditingController league = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController eventtittle  = TextEditingController();
  DateTime? _selectedDate;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
String url='https://assets.mixkit.co/videos/preview/mixkit-group-of-friends-partying-happily-4640-large.mp4';
String score1='0';
String score2='0';
String club1Id='';
String club2Id='';
String imageurl='';
String club1name='Home club';
  String club2name='Away club';
String imageurl1='';
  String imageurl2='';
String clubname='loading name';
String leaguename='loading name';
String leagueimageurl='';
String state1='0';
String state2='0';
String starttime='';
String stoptime='';
String message='The match has not yet Started';
  String message1='The Event has not yet Started';
bool ischoosen=false;
bool ischoosen1=false;
  bool isAway=false;
  String username = 'loading name';
  String userId = '';
  String pausetime = '';
  String clubId='';
String additionalinfo='';
String matchid='';

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }
  void _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      retrieveUsername();
    }
  }

  void _getCurrentUser1() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        club1Id = user.uid;
      });
    }
  }
  void _getCurrentUser2() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        club2Id = user.uid;
      });
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
  void retrieveUsername() async {
    try {
      DocumentSnapshot documentSnapshot = await firestore
          .collection('Clubs')
          .doc(userId)
          .get();

      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          username = data['Clubname'];
          imageurl=data['profileimage'];

        });
      } else {
        dialoge('No matching document found.');
      }
    } catch (e) {
      dialoge('Error retrieving username: $e');
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
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.utc(2050),
    );
    if (picked != null && picked != _selectedDate) {
      final pickedDateWithoutTime = DateTime(picked.year, picked.month, picked.day);
      setState(() {
        _selectedDate = pickedDateWithoutTime;
      });
    }
  }

  void retrieveUserData2() async {
    try {
      QuerySnapshot querySnapshotC = await firestore
          .collection('Clubs')
          .where('Clubname', isEqualTo: club2.text)
          .limit(1)
          .get();

      if (querySnapshotC.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotC.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          club2Id = data['Clubid'];
          club2name=data['Clubname'];
          imageurl2=data['profileimage'];
        });
      } else {
        dialoge('no such clubname');
      }
    } catch (e) {
      dialoge('Error retrieving user data: $e');
    }
  }
  void retrieveUserData4() async {
    try {
      QuerySnapshot querySnapshotC = await firestore
          .collection('Clubs')
          .where('Clubname', isEqualTo: club1.text)
          .limit(1)
          .get();

      if (querySnapshotC.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotC.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {

          club1Id = data['Clubid'];
          club1name=data['Clubname'];
          imageurl1=data['profileimage'];
        });
      } else {
        dialoge('no such clubname');
      }
    } catch (e) {
      dialoge('Error retrieving user data: $e');
    }
  }

  String message13='added you to their new match';
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
    String club = club1Id==userId?club2Id:club1Id;
    Timestamp createdAt = Timestamp.now();
    final today=DateTime(_selectedDate!.year,_selectedDate!.month,_selectedDate!.day);
    final matchesCollection =  FirebaseFirestore.instance.collection('Matches');

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Matches').where('authorId',isEqualTo: club).where('scheduledDate',isEqualTo:Timestamp.fromDate(today)).get();
      showToastMessage("checked if other club has a match on selected date");
      QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance.collection('Matches').where('authorId',isEqualTo: userId).where('scheduledDate',isEqualTo:Timestamp.fromDate(today)).get();
      showToastMessage("checked if your club has match on selected date");
          if (club1Id!=club2Id&&club1Id.isNotEmpty&&club2Id.isNotEmpty&&location.text.isNotEmpty&&time.text.isNotEmpty&&_selectedDate.toString().isNotEmpty) {
        if(querySnapshot1.docs.isEmpty){
          showToastMessage("you have no match");
      if(querySnapshot.docs.isNotEmpty){
        showToastMessage("other club has a match");
        String clb1='';
        String clb2='';
        var documentSnapshot = querySnapshot.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          matchid=documentSnapshot.id;
          clb1=data['club1Id'];
          clb2=data['club2Id'];
        });
        await Future.delayed(const Duration(milliseconds: 1500));
       back();
        await Future.delayed(const Duration(milliseconds: 1000));
        dialog(club1: clb1, club2: clb2);
      }else{
        showToastMessage("creating match...");
        String matchId = matchesCollection
            .doc()
            .id;
       await matchesCollection
            .doc(matchId)
            .set({
          'matchId': matchId,
          'club1Id': club1Id,
          'score1': 0,
          'club2Id': club2Id,
          'score2': 0,
          'location': location.text,
          'matchUrl': url,
          'authorId': userId,
          'match1Id': '',
          'activeuser':0,
          'createdAt': createdAt,
          'scheduledDate': _selectedDate,
          'time': time.text,
          'state1': state1,
          'state2': state2,
          'message': message,
          'starttime': starttime,
          'pausetime':pausetime,
          'resumetime':pausetime,
          'duration':0,
          'stoptime': stoptime,
          'additionalinfo': additionalinfo,
          'leagueId':'',
          'leaguematchId':'',
          'title':'',
        });
        showToastMessage("Match created");
          await Future.delayed(const Duration(milliseconds: 2500));
          back();
          await Future.delayed(const Duration(milliseconds: 1000));
          dialoge('Match created');
        }}else{
          await Future.delayed(const Duration(milliseconds: 1500));
          back();
          await Future.delayed(const Duration(milliseconds: 1000));
         dialog1();
        }
      }else{
        await Future.delayed(const Duration(milliseconds: 1500));
       back();
        await Future.delayed(const Duration(milliseconds: 1000));
        dialog2('Match');
      } }catch (e) {
      await Future.delayed(const Duration(milliseconds: 1500));
      back();
      await Future.delayed(const Duration(milliseconds: 1000));
      dialoge("$e Error in posting match ");
    }
  }
  bool isloading=true;

  dialog({required String club1,required String club2})async{
    showDialog(context: context, builder:(context){
      return AlertDialog(
        content: Column(
          children: [
            const Text(' The club you selected has a match on this day. Do you want to see the match?'),
            Text(matchid)
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: (){
                Navigator.pop(context);
                navigate(club1, club2);
           }, child: const Text('View match')),
              TextButton(onPressed: (){Navigator.pop(context);}, child: const Text('dismis')),
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
                  TextButton(onPressed: (){Navigator.pop(context);}, child: const Text('dismis')),
                ],
              ),
            ],
          );
        });
  }
  void dialog2(String m){
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              alignment: Alignment.center,
              title:  Text("Error in posting $m"),
              content: SizedBox(
                height: 80,
                child: m=='Event'?const Column(
                  children: [
                    Text('1. Make sure location, date, time, home and away are not empty'),
                    Text("2. Make sure home and away clubs are not the same"),
                  ],
                ):const Text('1. Make sure location, date, time are not empty'),
              ),
              actions: [
                Row(
                  mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: const Text('ok'),
                      onPressed: () {
                        Navigator.pop(context); // Dismiss the dialog
                      },
                    ),
                  ],
                )
              ]);
        }
    );
  }
  void postmatch1()async{
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
                const Text('Creating event...'),
              ],
            ),
          ),
        );
      },
    );
    final matchesCollection = FirebaseFirestore.instance.collection('Events');
    try {
      if (location.text.isNotEmpty&&time.text.isNotEmpty&&_selectedDate.toString().isNotEmpty) {
        String matchId = matchesCollection
            .doc()
            .id;
        Timestamp createdAt = Timestamp.now();
       await matchesCollection
            .doc(matchId)
            .set({
          'eventId': matchId,
          'title':eventtittle.text,
          'location': location.text,
          'eventUrl': url,
          'authorId': userId,
          'activeuser':0,
          'createdAt': createdAt,
          'scheduledDate': _selectedDate,
          'time': time.text,
          'state1': state1,
          'state2': state2,
          'message': message1,
          'starttime': starttime,
          'duration':0,
          'pausetime':pausetime,
          'stoptime': stoptime,
          'resumetime':pausetime,
          'additionalinfo': additionalinfo,
        });
          await Future.delayed(const Duration(milliseconds: 2500));
          back();
          await Future.delayed(const Duration(milliseconds: 1000));
          dialoge('Event created');
      }else{
        await Future.delayed(const Duration(milliseconds: 1500));
        back();
        await Future.delayed(const Duration(milliseconds: 1000));
       dialog2("Event");
      } }catch (e) {
      dialoge(e.toString());
    }
  }
  bool ismatch=true;
  void matchh(){
    setState(() {
      ismatch=true;
    });
  }
  void freestyle(){
    setState(() {
      ismatch=false;
    });
  }
  void homee(){
    setState(() {
      ischoosen=true;
      ischoosen1=false;
      club2.clear();
      isAway=true;
      _getCurrentUser1();
    });
  }
  void away(){
    setState(() {
      club1.clear();
      ischoosen=false;
      ischoosen1=true;
      isAway=false;
      _getCurrentUser2();
    });
  }
  void away1(){
    setState(() {
      retrieveUserData2();
    });
  }

void homee1(){
  setState(() {
    retrieveUserData4();
  });
}
  Future<Map<String, dynamic>> fetchCurrentAddress() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final String geocodeApiUrl = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapsApi';
      final response = await http.get(Uri.parse(geocodeApiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final addressComponents = data['results'][0]['address_components'] as List;
          List<String> addressDetails = addressComponents.map((component) {
            return component['long_name'] as String;
          }).toList();
          String country = addressComponents.firstWhere(
                  (component) => (component['types'] as List).contains('country'),
              orElse: () => {'long_name': 'Unknown'}
          )['long_name'];
          final String placesApiUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
          final responsePlaces = await http.get(
              Uri.parse('$placesApiUrl?location=${position.latitude},${position.longitude}&radius=2000&key=$mapsApi')
          );
          List<String> nearbyPlaces = [];
          if (responsePlaces.statusCode == 200) {
            final placesData = json.decode(responsePlaces.body);
            if (placesData['results'] != null && placesData['results'].isNotEmpty) {
              nearbyPlaces.addAll(placesData['results'].map<String>((place) {
                return '${place['name']}';
              }).toList());
            } else {
              nearbyPlaces.add('No nearby places found');
            }
          } else {
            nearbyPlaces.add('Error: ${responsePlaces.statusCode}');
          }
          return {
            'addressDetails': addressDetails,
            'country': country,
            'nearbyPlaces': nearbyPlaces
          };
        } else {
          return {
            'addressDetails': ['No address found'],
            'country': 'Unknown',
            'nearbyPlaces': ['No nearby places found']
          };
        }
      } else {
        throw Exception('Failed to fetch address');
      }
    } catch (e) {
      return {
        'addressDetails': ['Error: $e'],
        'country': 'Unknown',
        'nearbyPlaces': ['Error: $e']
      };
    }
  }

  void daa(String userId1){
    setState(() {
      userId1=club1Id;
    });
}
  bool isLoading=false;
  SearchService2 search=SearchService2();
  String _searchQuery = '';
  double radius=18;
  double radius1=16;
  List<String> locations=[];
  bool isEnabled=false;
  String country='';
  String Country="Add Country";
  int ind=0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text('Create event',style: TextStyle(color: Colors.black),),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            height: 34,
                            width: MediaQuery.of(context).size.width*0.25,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 30),
                                side: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              onPressed:matchh,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 1),
                                child: ismatch?const Text(
                                  "Match",
                                  style: TextStyle(color: Colors.blue),
                                ):const Text(
                                  "Match",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 34,
                            width: MediaQuery.of(context).size.width*0.25,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 30),
                                side: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              onPressed:freestyle,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 1),
                                child: ismatch?const Text(
                                  "Event",
                                  style: TextStyle(color: Colors.black),
                                ):const Text(
                                  "Event",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ismatch?Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width*0.935,
                        height: 150,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Text('Your club',style:TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(
                                  height: 34,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        height: 34,
                                        width: MediaQuery.of(context).size.width*0.25,
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size(0, 30),
                                            side: const BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          onPressed:homee,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 1),
                                            child: ischoosen?const Text(
                                              "home",
                                              style: TextStyle(color: Colors.blue),
                                            ):const Text(
                                              "home",
                                              style: TextStyle(color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 34,
                                        width: MediaQuery.of(context).size.width*0.25,
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size(0, 30),
                                            side: const BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          onPressed:away,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 1),
                                            child: ischoosen1?const Text(
                                              "Away",
                                              style: TextStyle(color: Colors.blue),
                                            ):const Text(
                                              "Away",
                                              style: TextStyle(color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width*0.935,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.black,
                                        child: CachedNetworkImage(
                                          alignment: Alignment.center,
                                          imageUrl:
                                         imageurl,
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
                                            width: MediaQuery.of(context).size.width*0.325,
                                            height: 20,
                                            child: OverflowBox(
                                                child: Text(
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    username))),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width*0.935,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5,right: 5,top: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text('Match',style:TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    height: 45,
                                    width: MediaQuery.of(context).size.width*0.88,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CustomNameAvatar(userId:club1Id,cloadingname:"club 1...." , style: const TextStyle(color: Colors.black), radius: radius, maxsize: MediaQuery.of(context).size.width*0.3,),
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
                                        CustomNameAvatar(userId:club2Id,cloadingname:"club 2....", style: const TextStyle(color: Colors.black), radius: radius, maxsize: MediaQuery.of(context).size.width*0.3,),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width*0.935,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8,right: 8),
                              child: Column(
                                children: [
                                  const Text('Other club',style:TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    height: 35,
                                    width: MediaQuery.of(context).size.width*0.7,
                                    child: isAway?Row(
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width*0.5,
                                          child: TextFormField(
                                              scrollPadding: const EdgeInsets.only(left: 10),
                                              controller: club2,
                                              onChanged: (value){
                                                setState(() {
                                                  _searchQuery = value;
                                                });
                                              },
                                              textAlignVertical: TextAlignVertical.center,
                                              decoration: InputDecoration(
                                                contentPadding: const EdgeInsets.only(left: 10),
                                                  hintText: 'input away clubs name',
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5),
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              minimumSize: const Size(0, 30),
                                              side: const BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            onPressed:away1,
                                            child: const Text(
                                              "search",
                                              style: TextStyle(color: Colors.black),
                                            ),
                                          ),
                                        )
                                      ],
                                    ):Row(
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width*0.5,
                                          child: TextFormField(
                                              controller: club1,
                                              scrollPadding: const EdgeInsets.only(left: 10),
                                              textAlignVertical: TextAlignVertical.center,
                                              onChanged: (value){
                                                setState(() {
                                                  _searchQuery = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                contentPadding: const EdgeInsets.only(left: 10),
                                                  hintText: 'input home clubs name',
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5),
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              minimumSize: const Size(0, 30),
                                              side: const BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            onPressed: homee1,
                                            child: const Text(
                                              "search",
                                              style: TextStyle(color: Colors.black),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width*0.9,
                                      child:  StreamBuilder<Set<UserModelC>>(
                                        stream: search.getUser(_searchQuery),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const Center(child: SizedBox(
                                              height: 30,
                                                width: 30,
                                                child: CircularProgressIndicator()));
                                          }
                                          Set<UserModelC> userList1 = snapshot.data!;
                                          List<UserModelC> userList = userList1.where((user)=>user.userId!=FirebaseAuth.instance.currentUser!.uid).toList();
                                          return ListView.builder(
                                            itemCount: userList.length,
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            scrollDirection: Axis.vertical,
                                            itemBuilder: (context, index) {
                                              UserModelC user = userList[index];
                                              return SizedBox(
                                                height: 48,
                                                child: ListTile(
                                                    leading: Row(
                                                      children: [
                                                        CustomAvatar(radius: radius1, imageurl:user.url,),
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 5),
                                                          child: FittedBox(
                                                            fit: BoxFit.scaleDown,
                                                            child: Container(
                                                                constraints:  BoxConstraints(
                                                                  minWidth: 10.0,
                                                                  maxWidth: MediaQuery.of(context).size.width*0.3,
                                                                ),
                                                                height: 20,
                                                                child: Text(
                                                                  user.clubname,
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: const TextStyle(fontSize: 14),
                                                                )),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    trailing:isAway?OutlinedButton(
                                                      style: OutlinedButton.styleFrom(
                                                        minimumSize: const Size(0, 30),
                                                        side: const BorderSide(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      onPressed:()=>
                                                          setState(() {
                                                            club2Id=user.userId;
                                                          }),
                                                      child: const Text(
                                                        "set A",
                                                        style: TextStyle(color: Colors.black),
                                                      ),
                                                    )
                                                        :OutlinedButton(
                                                      style: OutlinedButton.styleFrom(
                                                        minimumSize: const Size(0, 30),
                                                        side: const BorderSide(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      onPressed:()=>
                                                          setState(() {
                                                            club1Id=user.userId;
                                                          }),
                                                      child: const Text(
                                                        "set H",
                                                        style: TextStyle(color: Colors.black),
                                                      ),
                                                    )

                                                ),

                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ):Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 38,
                          width: MediaQuery.of(context).size.width*0.65,
                          child: TextFormField(
                              controller: eventtittle,
                              textAlignVertical: TextAlignVertical.bottom,
                              decoration: InputDecoration(
                                hintText: 'Event tittle',
                                labelText: 'Event tittle',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              )
                          ),),

                      ],
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width*0.935,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('Other necessary information'),
                            SizedBox(
                              width: MediaQuery.of(context).size.width*0.935,
                              child: Column(
                                children: [
                                  Container(
                                      height: 30,
                                      width: MediaQuery.of(context).size.width*0.315,
                                      decoration: BoxDecoration(
                                          color: Colors.green[200],
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                              width: 1.5,
                                              color: Colors.blue[300]!
                                          )
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(Country,style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                                            IconButton(
                                                padding: EdgeInsets.zero,
                                                onPressed: (){
                                                  setState(() {
                                                    isEnabled=!isEnabled;
                                                    if(isEnabled){
                                                      location.text =
                                                      "${locations[ind]}, ${country}";
                                                    }else{
                                                      location.text=locations[ind];
                                                    }
                                                  });
                                                },icon:Icon(
                                              isEnabled ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                              color:isEnabled? Colors.purple:Colors.black54,
                                            )),
                                          ],
                                        ),
                                      )),
                                  const SizedBox(height: 10.0),
                                  locations.isEmpty?Text("Refresh to add locations"):SizedBox(
                                    height: 40,
                                    child: ListView.builder(
                                        itemCount: locations.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context,index){
                                          return  InkWell(
                                            onTap:(){
                                              setState(() {
                                                ind=index;
                                                if(isEnabled) {
                                                  location.text =
                                                  "${locations[index]}, ${country}";
                                                }else{
                                                  location.text=locations[index];
                                                }
                                              });
                                            },
                                            child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal:20),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Container(
                                                    height: 28,
                                                    decoration:  BoxDecoration(
                                                      color: Colors.grey[500],
                                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10),bottomLeft: Radius.circular(10),topRight: Radius.circular(10),bottomRight: Radius.circular(10)),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        SizedBox(
                                                            width: 30,
                                                            child: Icon(Icons.location_on_outlined,color: Colors.black54,)),
                                                        Padding(
                                                          padding: const EdgeInsets.only(right: 10,left: 2),
                                                          child: Text(
                                                            locations[index],style: const TextStyle(color: Colors.black,fontSize: 15),),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )),
                                          );
                                        }),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.location_on_outlined),
                                      SizedBox(width: 15,),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width*0.65,
                                        child: TextFormField(
                                          scrollPhysics: const ScrollPhysics(),
                                          expands: false,
                                          maxLines: 4,
                                          minLines: 1,
                                          controller: location,
                                          decoration:  InputDecoration(
                                              contentPadding: EdgeInsets.symmetric(horizontal: 5,vertical: 1),
                                              fillColor: Colors.grey[200],
                                              labelText: 'Location',
                                              filled: true,
                                              border: InputBorder.none
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10,),
                                      isLoading?CircularProgressIndicator():IconButton(onPressed: ()async{
                                        setState(() {
                                          isLoading=true;
                                        });
                                        try {
                                          final addressData = await fetchCurrentAddress();
                                          final List<String> addressDetails = List<String>.from(addressData['addressDetails']);
                                          final List<String> nearbyPlaces = List<String>.from(addressData['nearbyPlaces']);
                                          String c = addressData['country'];
                                          if (addressDetails.isNotEmpty) {
                                            addressDetails.remove(c);
                                            if (addressDetails.isNotEmpty) {
                                              addressDetails.removeAt(0);
                                            }
                                          }
                                          locations = [...addressDetails, ...nearbyPlaces];
                                          setState(() {
                                            country = c;
                                            isLoading = false;
                                            isEnabled=false;
                                          });
                                        } catch (e) {

                                        }
                                      }, icon: Icon(Icons.refresh))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width:MediaQuery.of(context).size.width*0.9,
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_month),
                                  TextFormField(
                                      maxLines: 1,
                                      minLines: 1,
                                      scrollPadding: EdgeInsets.zero,
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
                                          contentPadding: EdgeInsets.symmetric(horizontal: 5,vertical: 1),
                                          fillColor: Colors.grey[200],
                                          filled: true,
                                          border: InputBorder.none,
                                          hintText: 'Date'
                                      )),
                                ],
                              ),
                            ),
                            SizedBox(
                              width:MediaQuery.of(context).size.width*0.9,
                              child: Row(
                                children: [
                                  Icon(Icons.watch_later_outlined),
                                  TextFormField(
                                    maxLines: 1,
                                    minLines: 1,
                                    scrollPadding: EdgeInsets.zero,
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
                                    decoration:  InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 5,vertical: 1),
                                      fillColor: Colors.grey[200],
                                      filled: true,
                                      border: InputBorder.none,
                                      hintText: 'Time',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            ismatch? OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 30),
                                side: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              onPressed: postmatch,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 1),
                                child: Text(
                                  "Post match",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ): OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 30),
                                side: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              onPressed: postmatch1,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 1),
                                child: Text(
                                  "Post Event",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
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

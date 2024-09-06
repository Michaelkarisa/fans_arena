import 'package:fans_arena/fans/data/notificationsmodel.dart';
import 'package:fans_arena/fans/data/usermodel.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../clubs/screens/clubteamtable.dart';
import '../../reusablewidgets/cirularavatar.dart';
import '../../appid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class CreateeventPageProfe extends StatefulWidget {
  const CreateeventPageProfe({super.key});

  @override
  State<CreateeventPageProfe> createState() => _CreateeventPageProfeState();
}

class _CreateeventPageProfeState extends State<CreateeventPageProfe> {
  TextEditingController account2 = TextEditingController();
  TextEditingController time = TextEditingController();
  TextEditingController eventittle  = TextEditingController();
  TextEditingController league = TextEditingController();
  TextEditingController location = TextEditingController();
  DateTime? _selectedDate;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String url='https://assets.mixkit.co/videos/preview/mixkit-group-of-friends-partying-happily-4640-large.mp4';
  String score1='0';
  String score2='0';
  String club1Id='';
  String club2Id='';
  String imageurl='';
  String club1name='Account A';
  String club2name='Account B';
  String imageurl1='';
  String imageurl2='';
  String clubname='';
  String leaguename='';
  String leagueimageurl='';
  String state1='0';
  String state2='0';
  String starttime='';
  String stoptime='';
  String message='The Contest has not yet Started';
  String message1='The Event has not yet Started';
  bool isContest=true;
  bool ischosen=false;
  bool ischosen1=false;
  String username = '';
  String type = '0';
  String userIde = '';
  String type1 = '1';
  String additionalinfo='';
  String pausetime='';
  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }
  @override
  void dispose(){
    super.dispose();
  }
  void _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userIde = user.uid;
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
        club1Id = user.uid;
      });
    }
  }
  void retrieveUsername() async {
    try {
      DocumentSnapshot documentSnapshot = await firestore
          .collection('Professionals')
          .doc(userIde)
          .get();

      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          username = data['Stagename'];
          imageurl=data['profileimage'];

        });
      } else {
        dialoge('no matching document');
      }
    } catch (e) {
      dialoge('Error retrieving user data: $e');
    }
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
          .collection('Professionals')
          .where('Stagename', isEqualTo: account2.text)
          .limit(1)
          .get();

      if (querySnapshotC.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotC.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          club2Id = data['profeid'];
          club2name=data['Stagename'];
          imageurl2=data['profileimage'];
        });
      } else {
        dialoge('no such Stagename');
      }
    } catch (e) {
      dialoge('Error retrieving user data: $e');
    }
  }
  void retrieveUserData4() async {
    try {
      QuerySnapshot querySnapshotC = await firestore
          .collection('Professionals')
          .where('Stagename', isEqualTo: account2.text)
          .limit(1)
          .get();

      if (querySnapshotC.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotC.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          club1Id = data['profeid'];
          club1name=data['Stagename'];
          imageurl1=data['profileimage'];
        });
      } else {
        dialoge('no such Stagename');
      }
    } catch (e) {
      dialoge('Error retrieving user data: $e');
    }
  }

  String message13='added you on their new match';
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
                const Text('Creating contest...'),
              ],
            ),
          ),
        );
      },
    );
    final matchesCollection = FirebaseFirestore.instance.collection('Matches');
    try {
      if (club1Id!=club2Id&&club2Id.isNotEmpty&&location.text.isNotEmpty&&time.text.isNotEmpty&&_selectedDate.toString().isNotEmpty) {
        String matchId = matchesCollection
            .doc()
            .id;
        Timestamp createdAt = Timestamp.now();
        await matchesCollection
            .doc(matchId)
            .set({
          'matchId': matchId,
          'club1Id': club1Id,
          'title':eventittle.text,
          'score1': 0,
          'club2Id': club2Id,
          'score2': 0,
          'location': location.text,
          'matchUrl': url,
          'authorId': userIde,
          'activeuser':0,
          'createdAt': createdAt,
          'scheduledDate': _selectedDate,
          'time': time.text,
          'state1': state1,
          'state2': state2,
          'message': message,
          'starttime': starttime,
          'duration':0,
          'pausetime':pausetime,
          'resumetime':pausetime,
          'stoptime': stoptime,
          'additionalinfo': additionalinfo,
          'leagueId':'',
          'leaguematchId':'',
          'match1Id': '',
        });
          if(userIde!=club1Id){
            Sendnotification(from: userIde, to: club1Id, message: message13, content:matchId).sendnotification();
          }else if(userIde!=club2Id){
            Sendnotification(from: userIde, to: club2Id, message: message13, content:matchId).sendnotification();
          }
        await Future.delayed(const Duration(milliseconds: 2500));
        back();
        await Future.delayed(const Duration(milliseconds: 1000));
         dialoge('Contest added');
      }else{
        await Future.delayed(const Duration(milliseconds: 2500));
      back();
        await Future.delayed(const Duration(milliseconds: 1000));
        dialog2('Contest');
      } }catch (e) {
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

  void dialog1(){
    showDialog(
        context: context,
        builder: (context) {
          return  AlertDialog(
            alignment: Alignment.center,
            content: const Text('You already have a contest for the selected  date. You cannot create more than one match for the same date.'),
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
              content:  SizedBox(
                height: 80,
                child: Column(
                  children: [
                    const Text('1. Make sure location, date and time are not empty'),
                    m=="Event" ?const Text("2. Make sure contestants are not the same or empty"):const SizedBox.shrink(),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: const Text('ok'),
                      onPressed: () {
                        Navigator.pop(context);
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
          'title':eventittle.text,
          'location': location.text,
          'eventUrl': url,
          'authorId': userIde,
          'activeuser':0,
          'createdAt': createdAt,
          'scheduledDate': _selectedDate,
          'time': time.text,
          'state1': state1,
          'state2': state2,
          'message': message1,
          'starttime': starttime,
          'pausetime':pausetime,
          'resumetime':pausetime,
          'duration':0,
          'stoptime': stoptime,
          'additionalinfo': additionalinfo,
        });
        await Future.delayed(const Duration(milliseconds: 2500));
        back();
        await Future.delayed(const Duration(milliseconds: 1000));
          dialoge('Event added');
      }else{
        await Future.delayed(const Duration(milliseconds: 2500));
        back();
        await Future.delayed(const Duration(milliseconds: 1000));
        dialog2('Event');
      } }catch (e) {
      dialoge('Error retrieving user data: $e');
    }
  }
  void homee(){
    setState(() {
      imageurl1=imageurl;
      club1name=username;
      ischosen=true;
      ischosen1=false;
      isContest=true;
      _getCurrentUser1();
    });
  }
  void away(){
    setState(() {
      imageurl1=imageurl;
      club1name=username;
      isContest=false;
      ischosen1=true;
      ischosen=false;
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
  bool isLoading=false;
  bool icir=false;
  SearchService1 search=SearchService1();
  String _searchQuery1 = '';
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.935,
                    height: 120,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('Your Account',style:TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 35,
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
                                      onPressed:homee
                                      ,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 1),
                                        child: ischosen?const Text(
                                          "Contest",
                                          style: TextStyle(color: Colors.blue),
                                        ):const Text(
                                          "Contest",
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
                                      onPressed:away
                                      ,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 1),
                                        child: ischosen1?const Text(
                                          "Event",
                                          style: TextStyle(color: Colors.blue),
                                        ):const Text(
                                          "Event",
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
         isContest? Column(children: [
        SizedBox(
          width: MediaQuery.of(context).size.width*0.935,
      height: 80,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(left: 5,right: 5,top: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text('Contest',style:TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(
                height: 45,
                width: MediaQuery.of(context).size.width*0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomNameAvatar(userId:club1Id,cloadingname:"contestant 1....", style: const TextStyle(color: Colors.black), radius: radius, maxsize: 120,),
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
                    CustomNameAvatar(userId:club2Id,cloadingname:"contestant 2....", style: const TextStyle(color: Colors.black), radius: radius, maxsize: 120,),

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
         width: MediaQuery.of(context).size.width*0.625,
         child: TextFormField(
             scrollPadding: const EdgeInsets.only(left: 10),
             controller: eventittle,
             textAlignVertical: TextAlignVertical.center,
             decoration: InputDecoration(
               contentPadding: const EdgeInsets.only(left: 10),
               hintText: 'Event title',
               border: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(8),
               ),
             )
         ),),
        FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: MediaQuery.of(context).size.width*0.935,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.only(left: 8,right: 8),
            child: Column(
              children: [
                const Text('Other Account',style:TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(
                    width: MediaQuery.of(context).size.width*0.5,
                    height: 35,
                  child: Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width*0.5,
                        child: TextFormField(
                            scrollPadding: const EdgeInsets.only(left: 10),
                            controller: account2,
                            onChanged: (value){
                              setState(() {
                                _searchQuery1=value;
                              });
                            },
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(left: 10),
                              hintText: 'input other account name',
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
                  )
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width*0.935,
                    child:  StreamBuilder<Set<UserModelP>>(
                      stream: search.getUser(_searchQuery1),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return  const Center(
                            child: SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator()),
                          );
                        }
                        Set<UserModelP> userList1 = snapshot.data!;
                        List<UserModelP> userList =List.from(userList1);
                        return ListView.builder(
                          itemCount: userList.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            UserModelP user = userList[index];
                            return SizedBox(
                              height: 48,
                              child: ListTile(
                                  leading: Row(
                                    children: [
                                      CustomAvatar(radius: radius1, imageurl: user.url,),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Container(
                                              constraints: BoxConstraints(
                                                minWidth: 10.0,
                                                maxWidth:MediaQuery.of(context).size.width*0.3,
                                              ),
                                              height: 20,
                                              child: Text(
                                                user.stagename,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 14),
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing:OutlinedButton(
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
                                      "set",
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
      ),),

         ],):SizedBox(
           width: MediaQuery.of(context).size.width*0.625,
       height: 35,
       child: TextFormField(
           scrollPadding: const EdgeInsets.only(left: 10),
           controller: eventittle,
           textAlignVertical: TextAlignVertical.center,
           decoration: InputDecoration(
             contentPadding: const EdgeInsets.only(left: 10),
             hintText: 'Event title',
             border: OutlineInputBorder(
               borderRadius: BorderRadius.circular(8),
             ),
           )
       ),),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width*0.935,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('Other necessary information',style:TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(
                              width: MediaQuery.of(context).size.width*0.935,
                              child: Column(
                                children: [
                                  Container(
                                      height: 30,
                                      width: MediaQuery.of(context).size.width*0.325,
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
                                        width: MediaQuery.of(context).size.width*0.635,
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


                          ],
                        ),
                      ),
                    ),
                  ),

                  isContest?OutlinedButton(
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
                        "Post Contest",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ):OutlinedButton(
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
      ),
    );
  }
}


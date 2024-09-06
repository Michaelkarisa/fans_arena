import 'package:fans_arena/clubs/screens/eventsclubs.dart';
import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../clubs/screens/clubteamtable.dart';
import '../../fans/data/notificationsmodel.dart';
import '../../reusablewidgets/cirularavatar.dart';
import 'package:uuid/uuid.dart';
import '../../appid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class CreateeventPageleague extends StatefulWidget {
  String year;
  LeagueC league;
  CreateeventPageleague({super.key,required this.year,required this.league});

  @override
  State<CreateeventPageleague> createState() => _CreateeventPageleagueState();
}

class _CreateeventPageleagueState extends State<CreateeventPageleague> {
  TextEditingController club1 = TextEditingController();
  TextEditingController time = TextEditingController();
  TextEditingController club2  = TextEditingController();
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
  String club1name='Home club';
  String imageurl1='';
  String club2name='Away club';
  String leaguename='';
  String leagueimageurl='';
  String state='';
  String state2='0';
  String message='The match has not yet Started';
  bool ischoosen=false;
  bool ischoosen1=false;
  bool isAway=false;
  String username = '';
  String userId = '';
  String match1Id = '';
  String match2Id = '';
  String clubId='';
  String leagueId='';
  String additionalinfo='';
  @override
  void initState() {
    super.initState();
    getFnData();
    getClubData();
  }
  void getFnData()async{
    DocumentSnapshot snapshot= await FirebaseFirestore.instance
        .collection('Leagues')
        .doc(widget.league.leagueId)
        .collection('year')
        .doc(widget.year)
        .get();
    var document= snapshot.data() as Map<String,dynamic>;
    List<Map<String, dynamic>> allLikes = [];
    final List<dynamic> likesArray = document['leagueTable'];
    allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
    setState(() {
      tableColumns=allLikes;
    });
  }
  Set<String>docIds={};
  void getClubData()async{
    QuerySnapshot snapshot= await FirebaseFirestore.instance
        .collection('Leagues')
        .doc(widget.league.leagueId)
        .collection('year')
        .doc(widget.year)
        .collection('clubs')
        .get();
    final List<QueryDocumentSnapshot> likeDocuments = snapshot.docs;
    List<Map<String, dynamic>> allLikes = [];
    for (final document in likeDocuments) {
      docIds.add(document.id);
      final List<dynamic> likesArray = document['clubs'];
      allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
    }
    setState(() {
      dRows=allLikes;
    });
  }

  List<Map<String, dynamic>> tableColumns = [];
  List<Map<String, dynamic>> dRows = [];
  @override
  void dispose(){

    super.dispose();
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
  String message7='created a match for you';


  String generateUniqueNotificationId() {
    final String uniqueId = const Uuid().v4();
    return uniqueId;
  }

  Future<void> postmatch() async {
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
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection('Leagues')
        .doc(leagueId)
        .collection('year')
        .doc(widget.year)
        .collection('leaguematches');
    String leaguematchId = generateUniqueNotificationId();
    if (club1Id!=club2Id&&club1Id.isNotEmpty&&club2Id.isNotEmpty&&location.text.isNotEmpty&&time.text.isNotEmpty&&_selectedDate.toString().isNotEmpty) {
      final Timestamp createdAt = Timestamp.now();
      final like = {
        'matchId': leaguematchId,
        'club1Id': club1Id,
        'score1': 0,
        'club2Id': club2Id,
        'leagueId':widget.league.leagueId,
        'score2': 0,
        'location': location.text,
        'authorId': widget.league.author.userId,
        'createdAt': createdAt,
        'scheduledDate': _selectedDate,
        'time': time.text,
        'status': state,
        'match1Id': match1Id,
        'match2Id': match2Id,
      };
      final QuerySnapshot querySnapshot = await likesCollection.get();
      final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
      if (documents.isNotEmpty) {
        final DocumentSnapshot latestDoc = documents.first;
        List<dynamic> likesArray = latestDoc['matches'];
        if (likesArray.length < 1000) {
          likesArray.add(like);
          await latestDoc.reference.update({'matches': likesArray});
        } else {
          await likesCollection.add({'matches': [like]});
        }
      } else {
        await likesCollection.add({'matches': [like]});
      }
      await NotifyFirebase().sendleaguesmatchcreated(widget.league.leagueId, leaguematchId, club1Id, club2Id);
      await Sendnotification(from: widget.league.leagueId, to: club1Id, message: message7, content:leaguematchId).sendnotification();
      await Sendnotification(from: widget.league.leagueId, to: club2Id, message: message7, content:leaguematchId).sendnotification();
      await Future.delayed(const Duration(milliseconds: 2500));
     back();
      await Future.delayed(const Duration(milliseconds: 1000));
      dialoge('Match added');
    }else{
      await Future.delayed(const Duration(milliseconds: 2500));
      back();
      await Future.delayed(const Duration(milliseconds: 1000));
      dialog2('Match');

    }
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
                child: Column(
                  children: [
                    const Text('1. Make sure location, date, time, home and away are not empty'),
                    m=='Event'? const Text("2. Make sure home and away clubs are not the same"):const SizedBox.shrink(),
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
                        Navigator.pop(context); // Dismiss the dialog
                      },
                    ),
                  ],
                )
              ]);
        }
    );
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

  bool icir=false;
  double radius=18;
  double radius1=16;
  List<String> locations=[];
  bool isEnabled=false;
  String country='';
  String Country="Add Country";
  int ind=0;
  bool isLoading=false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text('Create a Match',style: TextStyle(color: Colors.black),),
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
                    width:MediaQuery.of(context).size.width,
                    height: 80,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8,right: 8,top: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('League',style:TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 45,
                              width: 250,
                              child: Row(
                                children: [
                                  CustomAvatar(imageurl: widget.league.imageurl, radius: 18),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: CustomName(username: widget.league.leaguename, maxsize:150, style: TextStyle(color: Colors.black)),
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
                    width:MediaQuery.of(context).size.width,
                    height: 80,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5,right: 5,top: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('Match',style:TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 45,
                              width:MediaQuery.of(context).size.width,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomNameAvatar(userId:club1Id,cloadingname:widget.league.accountType=="Clubs"?"club 1....":'contestant 1....', style: const TextStyle(color: Colors.black), radius: radius, maxsize: 120,),
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
                                  CustomNameAvatar(userId:club2Id,cloadingname:widget.league.accountType=="Clubs"?"club 2....":'contestant 2....', style: const TextStyle(color: Colors.black), radius: radius, maxsize: 120,),
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
                      width:MediaQuery.of(context).size.width,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 3,right: 3,bottom: 5),
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  Text(widget.league.accountType=="Clubs"?"Select Home club":'Select Contestant 1',style:const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: SizedBox(
                                          width:MediaQuery.of(context).size.width*0.5,
                                          child:dRows.isEmpty?SizedBox(
                                              height: 45,
                                              child: Center(child: Text("No Members"))):ListView.builder(
                                              itemCount: dRows.length,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.vertical,
                                              itemBuilder: (context, index) {
                                                String userId=dRows[index][tableColumns[1]['fn']];
                                                return SizedBox(
                                                    height: 45,
                                                    child: ListTile(
                                                        leading: CustomNameAvatar(userId: userId, style: TextStyle(color: Colors.black), radius: radius, maxsize: 120),
                                                        trailing: OutlinedButton(
                                                          style: OutlinedButton.styleFrom(
                                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                                            minimumSize: const Size(
                                                                0, 30),
                                                            side: const BorderSide(
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                          onPressed: () =>
                                                              setState(() {
                                                                club1Id = userId;
                                                              }),
                                                          child: const Text(
                                                            "set H",
                                                            style: TextStyle(
                                                                color: Colors.black),
                                                          ),
                                                        )
                                                    )
                                                );
                                              }))),
                                ],),
                              Column(
                                children: [
                                   Text(widget.league.accountType=="Clubs"?"Select Away club":'Select Contestant 2',style:const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2,),
                                  FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: SizedBox(
                                          width:MediaQuery.of(context).size.width*0.5,
                                          child:dRows.isEmpty?SizedBox(
                                              height: 45,
                                              child: Center(child: Text("No Members"))): ListView.builder(
                                              itemCount: dRows.length,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.vertical,
                                              itemBuilder: (context, index) {
                                                String userId=dRows[index][tableColumns[1]['fn']];
                                                return SizedBox(
                                                    height: 45,
                                                    child: ListTile(
                                                        leading: CustomNameAvatar(userId: userId, style: TextStyle(color: Colors.black), radius: radius, maxsize: 120),
                                                        trailing: OutlinedButton(
                                                          style: OutlinedButton.styleFrom(
                                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                                            minimumSize: const Size(
                                                                0, 30),
                                                            side: const BorderSide(
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                          onPressed: () =>
                                                              setState(() {
                                                                club2Id = userId;
                                                              }),
                                                          child: const Text(
                                                            "set A",
                                                            style: TextStyle(
                                                                color: Colors.black),
                                                          ),
                                                        )
                                                    )
                                                );
                                              }))),],),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width:MediaQuery.of(context).size.width,
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

                          ],
                        ),
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
                    onPressed: postmatch,
                    child:  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Text(widget.league.accountType=="Clubs"?
                        "Post match":'Post Contest',
                        style: const TextStyle(color: Colors.black),
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

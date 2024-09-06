import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:fans_arena/professionals/screens/editprofileleagues.dart';
import 'package:fans_arena/reusablewidgets/cirularavatar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../fans/data/newsfeedmodel.dart';
import '../../fans/screens/homescreen.dart';
import 'package:intl/intl.dart';
import '../../fans/screens/leagueviewer.dart';

class LeaguesP extends StatefulWidget {
  const LeaguesP({super.key});

  @override
  State<LeaguesP> createState() => _LeaguesPState();
}

class _LeaguesPState extends State<LeaguesP> {
 bool isloading=true;
 late LeagueC league;
  @override
  void initState() {
    super.initState();
    _startTime=DateTime.now();
    setState(() {
    league=LeagueC(
      leagues: [],
      leagueId:'',
      genre: '',
      imageurl: '',
      author: Person(
          name: '',
          url: '',
          collectionName: '',
          userId:''
      ),
      leaguename: '',
      location:'',
      timestamp: Timestamp.now(),
      accountType: '',
    );
    });
    userData();
  }
  late DateTime _startTime;

  @override
  void dispose(){
    Engagement().engagement('LeagueP',_startTime,'');
    super.dispose();
  }
  String hours = '';
  String minutes = '';
  String t = ''; // AM/PM
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String userId='';
  String leagueId='';
  String imageurl = '';
  String leaguename = 'loading name';
  bool create=false;
  late DateTime date;
  String year='';
  void userData()async{
      league= await DataFetcher().getmyLeague(FirebaseAuth.instance.currentUser!.uid);
      if(league.leagueId.isNotEmpty){
        setState(() {
          isloading=false;
          date=league.timestamp.toDate();
        });
      if(league.leagues.isNotEmpty){
        final month1=month(date);
        setState(() {
          years=league.leagues;
            hours = DateFormat('HH').format(date);
            minutes = DateFormat('mm').format(date);
            t = DateFormat('a').format(date); // AM/PM
            date1='${date.day} $month1 ${date.year} at $hours:$minutes $t';
        });
      }} else{
      setState(() {
        create=true;
      });
      dialog();
    }
  }

  void dialog(){
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              alignment: Alignment.center,
              title: const Text("You Haven't created a league yet"),
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
  String month(DateTime date){
    if(date.month==DateTime.january){
      return 'january';
    }else if(date.month==DateTime.february){
      return 'February';
    }else if(date.month==DateTime.march){
      return 'March';
    }else if(date.month==DateTime.april){
      return 'April';
    }else if(date.month==DateTime.may){
      return 'May';
    }else if(date.month==DateTime.june){
      return 'June';
    }else if(date.month==DateTime.july){
      return 'July';
    }else if(date.month==DateTime.august){
      return 'August';
    }else if(date.month==DateTime.september){
      return 'September';
    }else if(date.month==DateTime.october){
      return 'October';
    }else if(date.month==DateTime.november){
      return 'November';
    }else if(date.month==DateTime.december){
      return 'December';
    }else{
      return'';
    }}
  String date1='';
  List<String>years=[];


  Future<void> deleteSeason(String season) async {
    try {
      // Reference to the Firestore collection
      CollectionReference collectionReference = FirebaseFirestore.instance.collection('Leagues').doc(leagueId).collection('year');
      // Deleting the document with the specified ID
      await collectionReference.doc(season).delete().then((_){
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                content: Text('Season deleted'),
              );
            });
      });
    } catch (e) {
      print('Error deleting document: $e');
      // Handle the error as needed
    }

  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Manage League',style: TextStyle(color: Colors.black),),
          elevation: 1,
        ),
        body:NestedScrollView(
      headerSliverBuilder: (context, _) {
      return [
      SliverList(
          delegate: SliverChildListDelegate(
          [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomAvatar(radius: 40, imageurl: league.imageurl),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(league.leaguename,style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                        'Created on: $date1',style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width*0.3,
                        child:TextButton(onPressed: (){
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context)=>  EditprofileL(leagueId: league.leagueId,),
                            ),
                          );
                        },child:create? const Center(child: Text('Create League')):const Center(child: Text('League Profile')),),


                      ),
                    ),
                  ],
                ),
              ),
            )
          ]
          ))


      ];
      },
      body: Column(
          children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 3),
                  child: Text('Seasons',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18),),
                ),
                Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(
                          width: 1,
                          color: Colors.grey
                      ),
                      shape: BoxShape.circle
                  ),
                  child: IconButton(
                    iconSize: 18,
                    constraints:const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ) ,
                    padding: EdgeInsets.zero,
                      onPressed: (){
                    showModalBottomSheet(
                        isScrollControlled: true,
                        isDismissible: true,
                        backgroundColor: Colors.transparent,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10))),
                        context: context,
                        builder: (BuildContext context) {
                          return Align(
                            alignment: const Alignment(0.0,0.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CreateS(leagueId: league.leagueId, get:userData,),
                            ),

                          );});
                  }, icon: const Icon(Icons.add,)),
                ),
              ],
            ),
          ),
             isloading?const CircularProgressIndicator():
             Column(
              children: league.leagues.map<Widget>((item) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: InkWell(
                    onLongPress: (){
                      showDialog(context: context, builder: (context){
                        return AlertDialog(
                          title: const Text('Delete season'),
                          content: const Text('Do you want to delete season'),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(onPressed:(){
                                  Navigator.of(context,rootNavigator: true).pop();
                                }, child: const Text('cancel')),
                                TextButton(onPressed:(){
                                  deleteSeason(item);
                                }, child: const Text('delete'))
                              ],
                            )
                          ],
                        );
                      });
                    },
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>LeagueLayout(year: item, league: league,)));
                    },
                    child: Container(
                      height: 40,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            width: 1,
                            color: Colors.grey
                          )
                        ),
                        child: Center(child: Text(item,style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,)))),
                  ),
                );
      }
            ).toList(),)
          ],
        ),)
      ),
    );
  }
}

class CreateS extends StatefulWidget {
  String leagueId;
  void Function() get;
   CreateS({super.key,required this.leagueId,required this.get});

  @override
  State<CreateS> createState() => _CreateSState();
}

class _CreateSState extends State<CreateS> {
  DateTime? _selectedDate;
  DateTime? _selectedDate1;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.utc(2050),

    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  Future<void> _selectDate1(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate1 ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.utc(2050),

    );

    if (picked != null && picked != _selectedDate1) {
      setState(() {
        _selectedDate1 = picked;
      });
    }
  }
  void addSeason() async {
    final leaguesCollection = FirebaseFirestore.instance
        .collection('Leagues')
        .doc(widget.leagueId)
        .collection('year');
    try {
      // Upload the image to Firebase Storage and get the URL
      DateTime now=DateTime.now();
      String season = long?now.year.toString():'${now.year.toString()}-${now.month.toString()}';
      // Check if the image upload was successful
      setState(() {
      if(_selectedDate?.year==_selectedDate1?.year&&long){
          season='${_selectedDate?.year.toString()}';
      }else if(_selectedDate!.year<_selectedDate1!.year&&long){
          season='${_selectedDate?.year.toString()}-${_selectedDate1?.year.toString()}';
      }else if(_selectedDate!.year<_selectedDate1!.year&&!long){
          season='${_selectedDate?.year.toString()} ${month(_selectedDate!)}-${_selectedDate1?.year.toString()} ${month(_selectedDate1!)}';
      }else if(_selectedDate!.year==_selectedDate1!.year&&!long){
          season='${_selectedDate?.year.toString()} ${month(_selectedDate!)}-${_selectedDate1?.year.toString()} ${month(_selectedDate1!)}';
      }
      });
       // Generate a unique post ID
      Timestamp createdAt = Timestamp.now(); // Get the current timestamp
      leaguesCollection
          .doc(season)
          .set({
        'timestamp': createdAt,
        'year':now.year,
        'month':now.month,
        'fromDate': _selectedDate,
        'toDate': _selectedDate1,
        // Add more fields as needed
      })
          .then((_) {
            widget.get;
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                content: Text('Season Created'),
              );
            });
        print('Match data added to Firestore.');
      })
          .catchError((error) {
        print('Error adding post data to Firestore: $error');
      });
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }
  String month(DateTime date){
    if(date.month==DateTime.january){
      return 'jan';
    }else if(date.month==DateTime.february){
      return 'Feb';
    }else if(date.month==DateTime.march){
      return 'Mar';
    }else if(date.month==DateTime.april){
      return 'Apr';
    }else if(date.month==DateTime.may){
      return 'May';
    }else if(date.month==DateTime.june){
      return 'Jun';
    }else if(date.month==DateTime.july){
      return 'Jul';
    }else if(date.month==DateTime.august){
      return 'Aug';
    }else if(date.month==DateTime.september){
      return 'Sep';
    }else if(date.month==DateTime.october){
      return 'Oct';
    }else if(date.month==DateTime.november){
      return 'Nov';
    }else if(date.month==DateTime.december){
      return 'Dec';
    }else{
      return'';
    }}
  bool long =false;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 270,
      width: MediaQuery.of(context).size.width*0.85,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('create season',style: TextStyle(fontWeight: FontWeight.bold),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 30),
                    side: const BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  onPressed:()=>
                      setState(() {
                        long=true;
                      }),
                  child: Text(
                    "Long season",
                    style: TextStyle(color:long?Colors.blue: Colors.black),
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 30),
                    side: const BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  onPressed:()=>
                      setState(() {
                        long=false;
                      }),
                  child: Text(
                    "Short season",
                    style: TextStyle(color: long?Colors.black: Colors.blue),
                  ),
                )
              ],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width*0.6,
              height: 38,
              child: TextFormField(
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
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors
                              .grey),
                      borderRadius: BorderRadius
                          .circular(8),
                    ),
                    hintText: 'fromDate',
                    labelText: 'fromDate',
                  )),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width*0.6,
              height: 38,
              child: TextFormField(
                  onTap: () {
                    _selectDate1(context);
                  },
                  readOnly: true,
                  controller: TextEditingController(
                    text: _selectedDate1 != null
                        ? "${_selectedDate1!.toLocal()}".split(' ')[0]
                        : '',
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors
                              .grey),
                      borderRadius: BorderRadius
                          .circular(8),
                    ),
                    hintText: 'toDate',
                    labelText: 'toDate',
                  )),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(onPressed:(){
                  Navigator.pop(context);
                }, child: const Text('dismis')),
                TextButton(onPressed: addSeason, child: const Text('Add season')),
              ],
            )
          ],
        ),
      ),
    );
  }
}


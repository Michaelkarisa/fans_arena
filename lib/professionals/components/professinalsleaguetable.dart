import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../clubs/data/lineup.dart';
import '../../clubs/screens/accountclubviewer.dart';
import '../../clubs/screens/clubteamtable.dart';
import '../../fans/data/newsfeedmodel.dart';
import '../../fans/screens/accountfanviewer.dart';
import '../screens/accountprofilepviewer.dart';
class ProfessionalsLeaguetable extends StatefulWidget {
  String leagueId;
  String year;
  ProfessionalsLeaguetable({super.key,required this.leagueId,required this.year});

  @override
  State<ProfessionalsLeaguetable> createState() => _ProfessionalsLeaguetableState();
}

class _ProfessionalsLeaguetableState extends State<ProfessionalsLeaguetable> {

  TextEditingController name1=TextEditingController();
  TextEditingController name2=TextEditingController();
  TextEditingController name3=TextEditingController();
  TextEditingController name4=TextEditingController();
  TextEditingController name5=TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String scorename1='goals';
  String scorename2='points';
  String scorename3='wins';
  String scorename4='loses';
  String scorename5='draws';
  void retrieveUsername() async {
    try {
      DocumentSnapshot documentSnapshot = await firestore
          .collection('Leagues')
          .doc(widget.leagueId)
          .get();

      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          scorename1 = data['scorename1'];
          scorename2 = data['scorename2'];
          scorename3 = data['scorename3'];
          scorename4 = data['scorename4'];
          scorename5 = data['scorename5'];
        });

      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving username: $e');
    }


  }
  Future<void> saveDataToFirestore() async {
    try {
      DocumentSnapshot documentSnapshot = await firestore
          .collection('Leagues')
          .doc(widget.leagueId)
          .get();

      if (documentSnapshot.exists) {
        var oldData = documentSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> newData = {};
        if (name1.text.isNotEmpty && name1.text != oldData['scorename1']) {
          newData['scorename1'] = name1.text;
        }
        if (name2.text.isNotEmpty && name2.text != oldData['scorename2']) {
          newData['scorename2'] = name2.text;
        }
        if (name3.text.isNotEmpty && name3.text != oldData['scorename3']) {
          newData['scorename3'] = name3.text;
        }
        if (name4.text.isNotEmpty && name4.text != oldData['scorename4']) {
          newData['scorename4'] = name4.text;
        }
        if (name5.text.isNotEmpty && name5.text != oldData['scorename5']) {
          newData['scorename5'] = name5.text;
        }
        if (newData.isNotEmpty) {
          await documentSnapshot.reference.update(newData);
          retrieveUsername();
          print('Data saved successfully');
        } else {
          print('No changes to update');
        }
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error saving data: $e');
    }
  }
  @override
  void didUpdateWidget(covariant ProfessionalsLeaguetable oldWidget) {
    if (widget.leagueId.isEmpty) {
      retrieveUsername();
    }
    if(oldWidget.leagueId!=widget.leagueId){
      retrieveUsername();
    }
    super.didUpdateWidget(oldWidget);
  }
  @override
  void initState() {
    super.initState();
    retrieveUsername();

  }
  double radius = 16;
  bool ascending=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title:const Text("League Table",style: TextStyle(color: Colors.black),),),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream:FirebaseFirestore.instance
                    .collection('Leagues')
                    .doc(widget.leagueId)
                    .collection('year')
                    .doc(widget.year)
                    .collection('clubs')
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator()); // Display a loading indicator while fetching data
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No Members')); // Handle case where there are no likes
                  } else {
                    final List<QueryDocumentSnapshot> likeDocuments = snapshot.data!.docs;
                    List<Map<String, dynamic>> allLikes = [];
                    // Extract and combine all like objects into a single list
                    for (final document in likeDocuments) {
                      final List<dynamic> likesArray = document['clubs'];
                      // Explicitly cast likesArray to Iterable<Map<String, dynamic>>
                      allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
                    }
                    if(ascending){
                      allLikes .sort((a, b) {
                        int adate = int.tryParse(a['points'])??0;
                        int bdate = int.tryParse(b['points'])??0;
                        return adate.compareTo(bdate);
                      });
                    }else{
                      allLikes .sort((a, b) {
                        int adate = int.tryParse(a['points'])??0;
                        int bdate = int.tryParse(b['points'])??0;
                        return bdate.compareTo(adate);
                      });}
                    int i =6;
                    return Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            horizontalMargin: 5.0,
                            columnSpacing: MediaQuery.of(context).size.width*0.001,
                            sortColumnIndex: i, // Set the column index to sort by (change it as needed)
                            sortAscending: ascending,
                            columns: [
                              const DataColumn(
                                label: SizedBox(width: 40,height:20,child: Center(child: Text('Rank'))),
                                tooltip: 'Rank',
                              ),

                              const DataColumn(
                                label: Text('Club'),
                                tooltip: 'Club',
                              ),

                              DataColumn(
                                label: InkWell(onTap: (){
                                  setState(() {
                                    name1.text=scorename1;
                                  });
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                            alignment: Alignment.center,
                                            title: const Text('Edit scorename'),
                                            content:SizedBox(
                                              height: 35,
                                              child: TextFormField(
                                                scrollPadding: EdgeInsets.zero,
                                                textAlignVertical: TextAlignVertical.center,
                                                controller:name1,
                                                decoration: InputDecoration(
                                                    contentPadding: const EdgeInsets.only(left: 10),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    hintStyle: const TextStyle(color: Colors.black)
                                                ),
                                              ),
                                            ) ,
                                            actions: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  TextButton(
                                                    child: const Text('dismis'),
                                                    onPressed: () {
                                                      Navigator.pop(context); // Dismiss the dialog
                                                    },
                                                  ),
                                                  TextButton(
                                                    onPressed: saveDataToFirestore,
                                                    child: const Text('post'),
                                                  )
                                                ],
                                              ),

                                            ]);
                                      }
                                  );
                                },
                                  child: Row(
                                    children: [
                                      SizedBox(width: 38,height:20,child: Center(child: OverflowBox(child:
                                      Text(scorename1.isNotEmpty?scorename1:'goals',overflow: TextOverflow.ellipsis,
                                        maxLines: 1,)))),
                                      const Icon(Icons.edit,size: 18,),
                                    ],
                                  ),
                                ),
                                numeric: false,
                                tooltip: scorename1,
                              ),
                              DataColumn(
                                label: InkWell(
                                  onTap: (){
                                    setState(() {
                                      name3.text=scorename3;
                                    });
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                              alignment: Alignment.center,
                                              title: const Text('Edit Scorename'),
                                              content:SizedBox(
                                                height: 35,
                                                child: TextFormField(
                                                  textAlignVertical: TextAlignVertical.center,
                                                  scrollPadding: EdgeInsets.zero,
                                                  controller: name3,
                                                  decoration: InputDecoration(
                                                      contentPadding: const EdgeInsets.only(left: 10),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      hintStyle: const TextStyle(color: Colors.black)
                                                  ),
                                                ),
                                              ) ,
                                              actions: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    TextButton(
                                                      child: const Text('dismis'),
                                                      onPressed: () {
                                                        Navigator.pop(context); // Dismiss the dialog
                                                      },
                                                    ),
                                                    TextButton(
                                                      onPressed: saveDataToFirestore,
                                                      child: const Text('post'),
                                                    )
                                                  ],
                                                ),

                                              ]);
                                        }
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(width: 38,height:20,child: Center(child: OverflowBox(child:
                                      Text(scorename3.isNotEmpty?scorename3:'wins',overflow: TextOverflow.ellipsis,
                                        maxLines: 1,)))),
                                      const Icon(Icons.edit,size: 18,),
                                    ],
                                  ),
                                ),
                                numeric: false,
                                tooltip: scorename3,
                              ),
                              DataColumn(
                                label: InkWell(
                                  onTap: (){
                                    setState(() {
                                      name5.text=scorename5;
                                    });
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                              alignment: Alignment.center,
                                              title: const Text('Edit Scorename'),
                                              content:SizedBox(
                                                height: 35,
                                                child: TextFormField(
                                                  scrollPadding: EdgeInsets.zero,
                                                  textAlignVertical: TextAlignVertical.center,
                                                  controller: name5,
                                                  decoration: InputDecoration(
                                                      contentPadding: const EdgeInsets.only(left: 10),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      hintStyle: const TextStyle(color: Colors.black)
                                                  ),
                                                ),
                                              ) ,
                                              actions: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    TextButton(
                                                      child: const Text('dismis'),
                                                      onPressed: () {
                                                        Navigator.pop(context); // Dismiss the dialog
                                                      },
                                                    ),
                                                    TextButton(
                                                      onPressed: saveDataToFirestore,
                                                      child: const Text('post'),
                                                    )
                                                  ],
                                                ),

                                              ]);
                                        }
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(width: 38,height:20,child: Center(child: OverflowBox(
                                        child: Text(scorename5.isNotEmpty?scorename5:'draws',overflow: TextOverflow.ellipsis,
                                          maxLines: 1,),
                                      ))),
                                      const Icon(Icons.edit,size: 18,),
                                    ],
                                  ),
                                ),
                                numeric: false,
                                tooltip: scorename5,
                              ),
                              DataColumn(
                                label: InkWell(
                                  onTap: (){
                                    setState(() {
                                      name4.text=scorename4;
                                    });
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                              alignment: Alignment.center,
                                              title: const Text('Edit Scorename'),
                                              content:SizedBox(
                                                height: 35,
                                                child: TextFormField(
                                                  scrollPadding: EdgeInsets.zero,
                                                  textAlignVertical: TextAlignVertical.center,
                                                  controller: name4,
                                                  decoration: InputDecoration(
                                                      contentPadding: const EdgeInsets.only(left: 10),
                                                      hintText: scorename4,
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      hintStyle: const TextStyle(color: Colors.black)
                                                  ),
                                                ),
                                              ) ,
                                              actions: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    TextButton(
                                                      child: const Text('dismis'),
                                                      onPressed: () {
                                                        Navigator.pop(context); // Dismiss the dialog
                                                      },
                                                    ),
                                                    TextButton(
                                                      onPressed: saveDataToFirestore,
                                                      child: const Text('post'),
                                                    )
                                                  ],
                                                ),

                                              ]);
                                        }
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(width:38,height:20,child: Center(child: OverflowBox(
                                        child: Text(scorename4.isNotEmpty?scorename4:'loses',overflow: TextOverflow.ellipsis,
                                          maxLines: 1,),
                                      ))),
                                      const Icon(Icons.edit,size: 18,),
                                    ],
                                  ),
                                ),
                                numeric: false,
                                tooltip: scorename4,
                              ),
                              DataColumn(
                                label: InkWell(
                                  onTap: (){
                                    setState(() {
                                      name2.text=scorename2;
                                    });
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                              alignment: Alignment.center,
                                              title: const Text('Edit Scorename'),
                                              content:SizedBox(
                                                height: 35,
                                                child: TextFormField(
                                                  scrollPadding: EdgeInsets.zero,
                                                  textAlignVertical: TextAlignVertical.center,
                                                  controller: name2,
                                                  decoration: InputDecoration(
                                                      contentPadding: const EdgeInsets.only(left: 10),
                                                      hintText: scorename2,
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      hintStyle: const TextStyle(color: Colors.black)
                                                  ),
                                                ),
                                              ) ,
                                              actions: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    TextButton(
                                                      child: const Text('dismis'),
                                                      onPressed: () {
                                                        Navigator.pop(context); // Dismiss the dialog
                                                      },
                                                    ),
                                                    TextButton(
                                                      onPressed: saveDataToFirestore,
                                                      child: const Text('post'),
                                                    )
                                                  ],
                                                ),

                                              ]);
                                        }
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(width: 38,height:20,child: Center(child: OverflowBox(
                                        child: Text(scorename2.isNotEmpty?scorename2:'points',overflow: TextOverflow.ellipsis,
                                          maxLines: 1,),
                                      ))),
                                      const Icon(Icons.edit,size: 18,),
                                    ],
                                  ),
                                ),
                                numeric: false,
                                tooltip: scorename2,
                                onSort: (int index, bool scending){
                                  setState(() {
                                    ascending=!ascending;
                                    scending=!scending;
                                  });
                                },
                              ),
                              const DataColumn(
                                label: SizedBox(width: 42,height:20,child: Center(child: Text('Status'))),
                                tooltip: 'Status',
                              ),
                              // Add more DataColumn widgets for additional fields
                            ],
                            rows: allLikes.asMap().entries.map((entry) {
                              int index = entry.key;
                              Map<String, dynamic> data = entry.value;
                              return DataRow(cells: [
                                DataCell(Center(child: Text('${index +1}'))),
                                DataCell(InkWell(
                                  onTap: (){
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Alert(userId: data['clubId'].toString(), leagueId: widget.leagueId,year:widget.year);
                                        }
                                    );
                                  },
                                  child: CustomNameAvatar(userId: data['clubId'],radius: radius, style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.normal,
                                  ), maxsize: 70,),
                                )),
                                DataCell(InkWell(
                                    onTap:(){
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Alert1(clubId: data['clubId'].toString(), leagueId:  widget.leagueId,year:widget.year, score: data['goals'].toString(), scorename1: scorename1,);
                                          }
                                      );
                                    },
                                    child: Center(child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(data['goals'].toString()),
                                        const Icon(Icons.edit,size: 15,)
                                      ],
                                    )))),
                                DataCell(InkWell(
                                    onTap:(){
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Alert3(clubId: data['clubId'].toString(),year:widget.year, leagueId:  widget.leagueId, wins:data['wins'].toString(), scorename3: scorename3,);
                                          }
                                      );
                                    },
                                    child: Center(child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(data['wins'].toString()),
                                        const Icon(Icons.edit,size: 15,)
                                      ],
                                    )))),
                                DataCell(InkWell(
                                    onTap:(){
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Alert5(clubId: data['clubId'].toString(),year:widget.year, leagueId:  widget.leagueId, draws:data['draws'].toString(), scorename5: scorename5,);
                                          }
                                      );
                                    },
                                    child: Center(child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(data['draws'].toString()),
                                        const Icon(Icons.edit,size: 15,)
                                      ],
                                    )))),
                                DataCell(InkWell(
                                    onTap:(){
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Alert4(clubId: data['clubId'].toString(),year:widget.year, leagueId:  widget.leagueId, loses: data['loses'].toString(), scorename4: scorename4,);
                                          }
                                      );
                                    },
                                    child: Center(child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(data['loses'].toString()),
                                        const Icon(Icons.edit,size: 15,)
                                      ],
                                    )))),

                                DataCell(InkWell(
                                    onTap: (){
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Alert2(clubId: data['clubId'].toString(),year:widget.year, leagueId:  widget.leagueId, points: data['points'].toString(), scorename2: scorename2,);
                                          }
                                      );
                                    },
                                    child: Center(child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(data['points'].toString()),
                                        const Icon(Icons.edit,size: 15,)
                                      ],
                                    )))),
                                DataCell(Status0(status: data['status'].toString(),))
                                // Add more DataCell widgets for additional fields
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.07,)
            ],
          ),
        ),
      ),


    );
  }
}



class Alert extends StatefulWidget {
  String leagueId;
  String userId;
  String year;
  Alert({super.key,required this.leagueId, required this.userId,required this.year});

  @override
  State<Alert> createState() => _AlertState();
}

class _AlertState extends State<Alert> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  void initstate(){
    super.initState();
    getData();
  }
  String url='';
  String name="loading....";
  String collectionName='';
  String location="";
  void getData()async{
    UsersData? appUsage = await DatabaseHelper2Users.instance.getUser(widget.userId);
    if (appUsage != null) {
      setState(() {
        url=appUsage.user.url;
        name =appUsage.user.name;
        collectionName=appUsage.user.collectionName;
        location=appUsage.user.location;
      });
      if(url.isEmpty){
        await getUserData();
        await DatabaseHelper2Users.instance.insertAppUsage(UsersData(
            user: Person(
              name: name,
              userId: widget.userId,
              location: location,
              collectionName: collectionName,
              url: url,
            )
        ));
      }
    }else{
      await getUserData();
      await DatabaseHelper2Users.instance.insertAppUsage(UsersData(
          user: Person(
            name: name,
            userId: widget.userId,
            location: location,
            collectionName: collectionName,
            url: url,
          )
      ));
    }
  }
  Future<void>getUserData()async{
    try {
      QuerySnapshot querySnapshotA = await firestore
          .collection('Fans')
          .where('Fanid', isEqualTo: widget.userId)
          .limit(1)
          .get();
      QuerySnapshot querySnapshotB = await firestore
          .collection('Professionals')
          .where('profeid', isEqualTo: widget.userId)
          .limit(1)
          .get();
      QuerySnapshot querySnapshotC = await firestore
          .collection('Clubs')
          .where('Clubid', isEqualTo: widget.userId)
          .limit(1)
          .get();

      if (querySnapshotA.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotA.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Fan';
          name = data['username'];
          url= data['profileimage'];
          location=data['location'];
          // other fields from the Fans collection
        });
      } else if (querySnapshotB.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotB.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Professional';
          name = data['Stagename'];
          url= data['profileimage'];
          location=data['Location'];
          // other fields from the Professionals collection
        });
      } else if (querySnapshotC.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotC.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Club';
          name = data['Clubname'];
          url= data['profileimage'];
          location=data['Location'];
        });
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }
  Future<void> Deleteteammemeber() async {
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection('Leagues')
        .doc(widget.leagueId)
        .collection('year')
        .doc(widget.year)
        .collection('clubs');

    // Query the Likes subcollection to find the document
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    for (final document in documents) {
      final List<dynamic> likesArray = document['clubs'];
      // Find the index of the like object with the specified userId
      final index = likesArray.indexWhere((like) => like['clubId'] == widget.userId);
      if (index != -1) {
        // Remove the like object from the array
        likesArray.removeAt(index);
        // Update the document with the modified likes array
        await document.reference.update({'clubs': likesArray});
        return; // Exit the loop once the like is deleted
      }
    }
    // If the loop completes and the like is not found, it means the like doesn't exist.
    print('match not found.');
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        alignment: Alignment.center,
        title: const Text('Remove League member'),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context); // Dismiss the dialog
                },

              ),
              TextButton(onPressed: (){
                Navigator.push(context,  MaterialPageRoute(
                    builder: (context){
                      if(collectionName=='Club'){
                        return AccountclubViewer(user: Person(name: name, url: url, collectionName: collectionName, userId: widget.userId), index: 0);
                      }else if(collectionName=='Professional'){
                        return AccountprofilePviewer(user:Person(name: name, url: url, collectionName: collectionName, userId: widget.userId), index: 0);
                      }else{
                        return Accountfanviewer(user:Person(name: name, url: url, collectionName: collectionName, userId: widget.userId), index: 0);
                      }
                    }
                ),);
              }, child: Text('view club')),
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  Deleteteammemeber();
                  Navigator.pop(context); // Dismiss the dialog
                },
              )
            ],
          ),

        ]);
  }
}

class Alert1 extends StatefulWidget {
  String score;
  String leagueId;
  String clubId;
  String scorename1;
  String year;
  Alert1({super.key,required this.year, required this.leagueId,required this.clubId, required this.score, required this.scorename1});

  @override
  State<Alert1> createState() => _Alert1State();
}

class _Alert1State extends State<Alert1> {
  TextEditingController score=TextEditingController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    setState(() {
      score.text=widget.score;
    });
  }

  void updateDrawInArray() async {
    try {
      CollectionReference collection = FirebaseFirestore.instance
          .collection('Leagues')
          .doc(widget.leagueId)
          .collection('year')
          .doc(widget.year)
          .collection('clubs');

      // Get all documents from the subcollection
      QuerySnapshot querySnapshot = await collection.get();

      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        List<dynamic> clubsteam = documentSnapshot['clubs'];

        // Find the index of the array element with matching 'teamId'
        int indexToUpdate = -1;
        for (int i = 0; i < clubsteam.length; i++) {
          if (clubsteam[i]['clubId'] == widget.clubId) {
            indexToUpdate = i;
            break;
          }
        }

        if (indexToUpdate != -1) {
          // Update the 'role' field for the array element
          if(score.text.isNotEmpty) {
            clubsteam[indexToUpdate]['goals'] = score.text;
          }
          // Update the Firestore document with the modified 'clubsteam' array
          await documentSnapshot.reference.update({'clubs': clubsteam});
          Navigator.of(context,rootNavigator: true).pop();

          print('Role updated successfully');
          break; // Exit the loop once the update is done
        }
      }
    } catch (e) {
      print('Error updating role: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        alignment: Alignment.center,
        title:widget.scorename1.isEmpty?const Text('Edit goals'): Text('Edit ${widget.scorename1}'),
        content:SizedBox(
          height: 35,
          child: TextFormField(
            textAlignVertical: TextAlignVertical.center,
            scrollPadding: EdgeInsets.zero,
            controller: score,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintStyle: const TextStyle(color: Colors.black)
            ),
          ),
        ) ,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: const Text('dismis'),
                onPressed: () {
                  Navigator.pop(context); // Dismiss the dialog
                },
              ),
              TextButton(
                onPressed: updateDrawInArray,
                child: const Text('Update'),
              )
            ],
          ),

        ]);
  }
}
class Alert2 extends StatefulWidget {
  String leagueId;
  String clubId;
  String points;
  String scorename2;
  String year;
  Alert2({super.key,required this.year, required this.leagueId,required this.clubId, required this.points, required this.scorename2});

  @override
  State<Alert2> createState() => _Alert2State();
}

class _Alert2State extends State<Alert2> {
  TextEditingController points=TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    setState(() {
      points.text=widget.points;
    });
  }

  void updateDrawInArray() async {
    try {
      CollectionReference collection = FirebaseFirestore.instance
          .collection('Leagues')
          .doc(widget.leagueId)
          .collection('year')
          .doc(widget.year)
          .collection('clubs');

      // Get all documents from the subcollection
      QuerySnapshot querySnapshot = await collection.get();

      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        List<dynamic> clubsteam = documentSnapshot['clubs'];

        // Find the index of the array element with matching 'teamId'
        int indexToUpdate = -1;
        for (int i = 0; i < clubsteam.length; i++) {
          if (clubsteam[i]['clubId'] == widget.clubId) {
            indexToUpdate = i;
            break;
          }
        }

        if (indexToUpdate != -1) {
          // Update the 'role' field for the array element
          if(points.text.isNotEmpty) {
            clubsteam[indexToUpdate]['points'] = points.text;
          }
          // Update the Firestore document with the modified 'clubsteam' array
          await documentSnapshot.reference.update({'clubs': clubsteam});
          Navigator.of(context,rootNavigator: true).pop();

          print('Role updated successfully');
          break; // Exit the loop once the update is done
        }
      }
    } catch (e) {
      print('Error updating role: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        alignment: Alignment.center,
        title:widget.scorename2.isEmpty?const Text('Edit points'): Text('Edit ${widget.scorename2}'),
        content:SizedBox(
          height: 35,
          child: TextFormField(
            textAlignVertical: TextAlignVertical.center,
            scrollPadding: EdgeInsets.zero,
            controller: points,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintStyle: const TextStyle(color: Colors.black)
            ),
          ),
        ) ,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: const Text('dismis'),
                onPressed: () {
                  Navigator.pop(context); // Dismiss the dialog
                },
              ),
              TextButton(
                onPressed: updateDrawInArray,
                child: const Text('Update'),
              )
            ],
          ),

        ]);
  }
}
class Alert3 extends StatefulWidget {
  String leagueId;
  String clubId;
  String wins;
  String scorename3;
  String year;
  Alert3({super.key,required this.year, required this.leagueId,required this.clubId, required this.wins, required this.scorename3});

  @override
  State<Alert3> createState() => _Alert3State();
}

class _Alert3State extends State<Alert3> {
  TextEditingController wins=TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    setState(() {
      wins.text=widget.wins;
    });
  }

  void updateDrawInArray() async {
    try {
      CollectionReference collection = FirebaseFirestore.instance
          .collection('Leagues')
          .doc(widget.leagueId)
          .collection('year')
          .doc(widget.year)
          .collection('clubs');

      // Get all documents from the subcollection
      QuerySnapshot querySnapshot = await collection.get();

      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        List<dynamic> clubsteam = documentSnapshot['clubs'];

        // Find the index of the array element with matching 'teamId'
        int indexToUpdate = -1;
        for (int i = 0; i < clubsteam.length; i++) {
          if (clubsteam[i]['clubId'] == widget.clubId) {
            indexToUpdate = i;
            break;
          }
        }

        if (indexToUpdate != -1) {
          // Update the 'role' field for the array element
          if(wins.text.isNotEmpty) {
            clubsteam[indexToUpdate]['wins'] = wins.text;
          }
          // Update the Firestore document with the modified 'clubsteam' array
          await documentSnapshot.reference.update({'clubs': clubsteam});
          Navigator.of(context,rootNavigator: true).pop();

          print('Role updated successfully');
          break; // Exit the loop once the update is done
        }
      }
    } catch (e) {
      print('Error updating role: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        alignment: Alignment.center,
        title:widget.scorename3.isEmpty?const Text('Edit wins'): Text('Edit ${widget.scorename3}'),
        content:SizedBox(
          height: 35,
          child: TextFormField(
            textAlignVertical: TextAlignVertical.center,
            scrollPadding: EdgeInsets.zero,
            controller: wins,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintStyle: const TextStyle(color: Colors.black)
            ),
          ),
        ) ,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: const Text('dismis'),
                onPressed: () {
                  Navigator.pop(context); // Dismiss the dialog
                },
              ),
              TextButton(
                onPressed: updateDrawInArray,
                child: const Text('Update'),
              )
            ],
          ),

        ]);
  }
}
class Alert4 extends StatefulWidget {
  String leagueId;
  String clubId;
  String loses;
  String scorename4;
  String year;
  Alert4({super.key,required this.year, required this.leagueId,required this.clubId, required this.loses, required this.scorename4});

  @override
  State<Alert4> createState() => _Alert4State();
}

class _Alert4State extends State<Alert4> {
  TextEditingController loses=TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    setState(() {
      loses.text=widget.loses;
    });
  }

  void updateDrawInArray() async {
    try {
      CollectionReference collection = FirebaseFirestore.instance
          .collection('Leagues')
          .doc(widget.leagueId)
          .collection('year')
          .doc(widget.year)
          .collection('clubs');

      // Get all documents from the subcollection
      QuerySnapshot querySnapshot = await collection.get();

      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        List<dynamic> clubsteam = documentSnapshot['clubs'];

        // Find the index of the array element with matching 'teamId'
        int indexToUpdate = -1;
        for (int i = 0; i < clubsteam.length; i++) {
          if (clubsteam[i]['clubId'] == widget.clubId) {
            indexToUpdate = i;
            break;
          }
        }

        if (indexToUpdate != -1) {
          // Update the 'role' field for the array element
          if(loses.text.isNotEmpty) {
            clubsteam[indexToUpdate]['loses'] = loses.text;
          }
          // Update the Firestore document with the modified 'clubsteam' array
          await documentSnapshot.reference.update({'clubs': clubsteam});
          Navigator.of(context,rootNavigator: true).pop();

          print('Role updated successfully');
          break; // Exit the loop once the update is done
        }
      }
    } catch (e) {
      print('Error updating role: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        alignment: Alignment.center,
        title:widget.scorename4.isEmpty?const Text('Edit loses'): Text('Edit ${widget.scorename4}'),
        content:SizedBox(
          height: 35,
          child: TextFormField(
            scrollPadding: EdgeInsets.zero,
            textAlignVertical: TextAlignVertical.center,
            controller: loses,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintStyle: const TextStyle(color: Colors.black)
            ),
          ),
        ) ,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: const Text('dismis'),
                onPressed: () {
                  Navigator.pop(context); // Dismiss the dialog
                },
              ),
              TextButton(
                onPressed: updateDrawInArray,
                child: const Text('Update'),
              )
            ],
          ),

        ]);
  }
}
class Alert5 extends StatefulWidget {
  String leagueId;
  String clubId;
  String draws;
  String scorename5;
  String year;
  Alert5({super.key,
    required this.leagueId,
    required this.clubId,
    required this.draws,
    required this.scorename5,required this.year});

  @override
  State<Alert5> createState() => _Alert5State();
}

class _Alert5State extends State<Alert5> {
  TextEditingController loses=TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    setState(() {
      loses.text=widget.draws;
    });
  }
  void updateDrawInArray() async {
    try {
      CollectionReference collection = FirebaseFirestore.instance
          .collection('Leagues')
          .doc(widget.leagueId)
          .collection('year')
          .doc(widget.year)
          .collection('clubs');

      // Get all documents from the subcollection
      QuerySnapshot querySnapshot = await collection.get();

      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        List<dynamic> clubsteam = documentSnapshot['clubs'];

        // Find the index of the array element with matching 'teamId'
        int indexToUpdate = -1;
        for (int i = 0; i < clubsteam.length; i++) {
          if (clubsteam[i]['clubId'] == widget.clubId) {
            indexToUpdate = i;
            break;
          }
        }

        if (indexToUpdate != -1) {
          // Update the 'role' field for the array element
          if(loses.text.isNotEmpty) {
            clubsteam[indexToUpdate]['draws'] = loses.text;
          }
          // Update the Firestore document with the modified 'clubsteam' array
          await documentSnapshot.reference.update({'clubs': clubsteam});
          Navigator.of(context,rootNavigator: true).pop();

          print('Role updated successfully');
          break; // Exit the loop once the update is done
        }
      }
    } catch (e) {
      print('Error updating role: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        alignment: Alignment.center,
        title:widget.scorename5.isEmpty?const Text('Edit draws'): Text('Edit ${widget.scorename5}'),
        content:SizedBox(
          height: 35,
          child: TextFormField(
            scrollPadding: EdgeInsets.zero,
            textAlignVertical: TextAlignVertical.center,
            controller: loses,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintStyle: const TextStyle(color: Colors.black)
            ),
          ),
        ) ,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: const Text('dismis'),
                onPressed: () {
                  Navigator.pop(context); // Dismiss the dialog
                },
              ),
              TextButton(
                onPressed: updateDrawInArray,
                child: const Text('Update'),
              )
            ],
          ),

        ]);
  }
}
class Status0 extends StatefulWidget {
  String status;
  Status0({super.key,required this.status});

  @override
  State<Status0> createState() => _Status0State();
}

class _Status0State extends State<Status0> {
  bool isaccepted = false;
  String state = '1';
  String state1 = '0';
  @override
  Widget build(BuildContext context) {
    if (widget.status == state) {
      return const Icon(Icons.check_circle_outline, color: Colors.blue,);
    } else if (widget.status == state1) {
      return const Text('declined');
    } else {
      return const Text('pending');
    }
  }
}
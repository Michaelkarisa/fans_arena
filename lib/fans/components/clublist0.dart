import 'package:fans_arena/clubs/screens/accountclubviewer.dart';
import 'package:fans_arena/fans/data/notificationsmodel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fans_arena/fans/data/usermodel.dart';
import '../../reusablewidgets/cirularavatar.dart';
import '../bloc/usernamedisplay.dart';
import '../data/newsfeedmodel.dart';
class ClubList extends StatefulWidget {
  String leagueId;
  String year;
  String leaguename;
   ClubList({super.key,
     required this.leagueId,
     required this.year,
     required this.leaguename});
  @override
  State<ClubList> createState() => _ClubListState();
}
class _ClubListState extends State<ClubList> {
  @override
  void initState() {
    super.initState();
    getFnData();
    getClubData();
  }
  void getFnData()async{
    DocumentSnapshot snapshot= await FirebaseFirestore.instance
        .collection('Leagues')
        .doc(widget.leagueId)
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
        .doc(widget.leagueId)
        .collection('year')
        .doc(widget.year)
        .collection('clubs')
        .get();
    final List<QueryDocumentSnapshot> likeDocuments = snapshot.docs;
    List<Map<String, dynamic>> allLikes = [];
    // Extract and combine all like objects into a single list
    for (final document in likeDocuments) {
      docIds.add(document.id);
      final List<dynamic> likesArray = document['clubs'];
      // Explicitly cast likesArray to Iterable<Map<String, dynamic>>
      allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
    }
    setState(() {
      dRows=allLikes;
    });
  }

  List<Map<String, dynamic>> tableColumns = [];
  List<Map<String, dynamic>> dRows = [];
  SearchService4 search2=SearchService4();
  String _searchQuery = '';
  final TextEditingController _controller = TextEditingController();
  bool _showCloseIcon = false;
  double radius=23;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 35,),
          onPressed: () {
            Navigator.of(context).pop();
          }, //to next page},
        ),
        title: const Text('Add Clubs', style: TextStyle(color: Colors.black),),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            SizedBox(
                height:37,
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.71,
                child: TextFormField(
                  scrollPadding: const EdgeInsets.only(left: 10),
                  textAlign: TextAlign.justify,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: Colors.black,
                  controller: _controller,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery=value;
                      _showCloseIcon = value.isNotEmpty;
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(width: 1, color: Colors.black),
                    ),
                    focusedBorder:  OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(width: 1, color: Colors.black),
                    ),
                    filled: true,
                    hintStyle: const TextStyle(color: Colors.black,
                      fontSize: 14, fontWeight: FontWeight.normal,),
                    fillColor: Colors.white70,
                    suffixIcon: _showCloseIcon ? IconButton(
                      icon: const Icon(Icons.close,color: Colors.black,),
                      onPressed: () {
                        setState(() {
                          _controller.clear();
                          _showCloseIcon = false;
                          _searchQuery='';
                        });
                      },
                    ) : null,
                    hintText: 'Search',
                  ),
                )),
            Expanded(
              child:  StreamBuilder<Set<UserModelC>>(
                stream: search2.getUser(_searchQuery),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator()),
                    );
                  }
                  Set<UserModelC> userList1 = snapshot.data!;
                  List<UserModelC> userList = userList1.toList();
                  return ListView.builder(
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
                      UserModelC user = userList[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: ListTile(
                            leading: CustomAvatar(radius: radius, imageurl:user.url),
                            title:  InkWell(
                                onTap: () {
                                  Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AccountclubViewer(user:Person(
                                                name: user.clubname,
                                                userId:user.userId,
                                                url: user.url,
                                                collectionName:"Club"
                                            ),index: 0,)
                                    ),
                                  );
                                },
                                child:UsernameDO(
                                  username:user.clubname,
                                  collectionName:'Club',
                                  width: 160,
                                  height: 38,
                                  maxSize: 140,
                                ),
                            ),
                            trailing: SizedBox(
                                height: 30,
                                width: 120,
                                child: Addbtn1(userId:user.userId, leagueId: widget.leagueId ,year:widget.year,tableColumns: tableColumns, dRows: dRows, leaguename: widget.leaguename,),)
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class ClubList1 extends StatefulWidget {
  String leagueId;
  String year;
 String leaguename;
  ClubList1({super.key,
    required this.leagueId,
    required this.year,
    required this.leaguename
   });

  @override
  State<ClubList1> createState() => _ClubList1State();
}

class _ClubList1State extends State<ClubList1> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    getFnData();
    getClubData();
  }
  void getFnData()async{
    DocumentSnapshot snapshot= await FirebaseFirestore.instance
        .collection('Leagues')
        .doc(widget.leagueId)
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
        .doc(widget.leagueId)
        .collection('year')
        .doc(widget.year)
        .collection('clubs')
        .get();
    final List<QueryDocumentSnapshot> likeDocuments = snapshot.docs;
    List<Map<String, dynamic>> allLikes = [];
    // Extract and combine all like objects into a single list
    for (final document in likeDocuments) {
      docIds.add(document.id);
      final List<dynamic> likesArray = document['clubs'];
      // Explicitly cast likesArray to Iterable<Map<String, dynamic>>
      allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
    }
    setState(() {
      dRows=allLikes;
    });
  }

  List<Map<String, dynamic>> tableColumns = [];
  List<Map<String, dynamic>> dRows = [];
  SearchService5 search2=SearchService5();
  String _searchQuery = '';
  final TextEditingController _controller = TextEditingController();
  bool _showCloseIcon = false;
  double radius=23;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 35,),
          onPressed: () {
            Navigator.of(context).pop();
          }, //to next page},
        ),
        title: const Text('Add Professionals', style: TextStyle(color: Colors.black),),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            SizedBox(
                height:37,
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.71,
                child: TextFormField(
                  scrollPadding: const EdgeInsets.only(left: 10),
                  textAlign: TextAlign.justify,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: Colors.black,
                  controller: _controller,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery=value;
                      _showCloseIcon = value.isNotEmpty;
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(width: 1, color: Colors.black),
                    ),
                    focusedBorder:  OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(width: 1, color: Colors.black),
                    ),
                    filled: true,
                    hintStyle: const TextStyle(color: Colors.black,
                      fontSize: 14, fontWeight: FontWeight.normal,),
                    fillColor: Colors.white70,
                    suffixIcon: _showCloseIcon ? IconButton(
                      icon: const Icon(Icons.close,color: Colors.black,),
                      onPressed: () {
                        setState(() {
                          _controller.clear();
                          _showCloseIcon = false;
                          _searchQuery='';
                        });
                      },
                    ) : null,
                    hintText: 'Search',
                  ),
                )),
            Expanded(
              child:  StreamBuilder<Set<UserModelP>>(
                stream: search2.getUser(_searchQuery),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator()),
                    );
                  }
                  Set<UserModelP> userList1 = snapshot.data!;
                  List<UserModelP> userList = userList1.toList();
                  return ListView.builder(
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
                      UserModelP user = userList[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: ListTile(
                            leading: CustomAvatar(radius: radius, imageurl:user.url),
                            title:  InkWell(
                              onTap: () {
                                Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AccountclubViewer(user:Person(
                                              name: user.stagename,
                                              userId:user.userId,
                                              url: user.url,
                                              collectionName:"Professional"
                                          ),index: 0,)
                                  ),
                                );
                              },
                              child:UsernameDO(
                                username:user.stagename,
                                collectionName:'Professional',
                                width: 160,
                                height: 38,
                                maxSize: 140,
                              ),
                            ),
                            trailing: SizedBox(
                              height: 30,
                              width: 120,
                              child: Addbtn1(userId:user.userId, leagueId: widget.leagueId ,year:widget.year, tableColumns: tableColumns, dRows: dRows, leaguename: widget.leaguename,),)
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class Addbtn1 extends StatefulWidget {
  String leagueId;
  String userId;
  String year;
  String leaguename;
  List<Map<String,dynamic>>tableColumns;
  List<Map<String,dynamic>>dRows;
  Addbtn1({super.key,
    required this.userId,
    required this.leagueId,
    required this.year,
    required this.tableColumns,
    required this.dRows,required this.leaguename});

  @override
  State<Addbtn1> createState() => _Addbtn1State();
}

class _Addbtn1State extends State<Addbtn1> {

  bool isadded=false;
  @override
  void initState() {
    super.initState();
    _checkUseristeam();
    setState(() {
      if(widget.tableColumns.isEmpty) {
        widget.tableColumns=[
          {'fn':'Rank'},
          {'fn':'Club'},];
      }
    });
  }
  String message10='added you to the league team';
  void _checkUseristeam(){
    bool added=widget.dRows.any((element) => element[widget.tableColumns[1]['fn']]==widget.userId);
    setState(() {
      isadded = added;
    });
  }
DateTime now=DateTime.now();
  Future<void> deleteTeamMemeber() async {
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection('Leagues')
        .doc(widget.leagueId)
        .collection('year')
        .doc(widget.year)
        .collection('clubs');

    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    for (final document in documents) {
      final List<dynamic> likesArray = document['clubs'];
      final index = likesArray.indexWhere((like) => like[widget.tableColumns[1]['fn']] == widget.userId);
      if (index != -1) {
        likesArray.removeAt(index);
        await document.reference.update({'clubs': likesArray});
        setState(() {
          isadded=false;
        });
        Navigator.of(context, rootNavigator: true).pop();
        return;
      }
    }
  }
  List<Map<String, dynamic>> dRows = [];

  Future<void> addClub() async {
    String message="${widget.leaguename} ${message10}";
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection('Leagues')
        .doc(widget.leagueId)
        .collection('year')
        .doc(widget.year)
        .collection('clubs');
    setState(() {
      if (widget.userId.isNotEmpty) {
        Map<String, dynamic> data = {};
        for (var d in widget.tableColumns) {
          int i = widget.tableColumns.indexOf(d);
          if (i == 1) {
            data[d['fn']] = widget.userId;
          } else if (i > 1) {
            data[d['fn']] = '0';
          } else {
            data[d['fn']] = '';
          }
        }
        dRows.add(data);
        String newColumnName = "createdAt";
        String newColumnName1 = "status";
        if (newColumnName.isNotEmpty) {
          for (var d in dRows) {
            d[newColumnName] = Timestamp.now();
            d[newColumnName1] = "";
          }
        }
      }
    });
if(widget.tableColumns.isEmpty) {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  await firestore.collection('Leagues').doc(widget.leagueId).collection(
      'year').doc(widget.year).update({
    'leagueTable': widget.tableColumns,
  });
}
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    if (documents.isNotEmpty) {
      final DocumentSnapshot latestDoc = documents.first;
      List<dynamic> likesArray = latestDoc['clubs'];
      if (likesArray.length < 500) {
        likesArray.addAll(dRows);
        await latestDoc.reference.update({'clubs': likesArray});
        setState(() {
          isadded=true;
          widget.dRows.addAll(dRows);
        });
        NotifyFirebase().sendInvitationNotification(widget.leagueId, widget.userId, message);
        await Sendnotification(from:widget.leagueId, to: widget.userId, message: message10, content: '').sendnotification();
      } else {
        await likesCollection.add({'clubs': dRows});
        setState(() {
          isadded=true;
          widget.dRows.addAll(dRows);
        });
        NotifyFirebase().sendInvitationNotification(widget.leagueId, widget.userId, message);
        await Sendnotification(from:widget.leagueId, to: widget.userId, message: message10, content: '').sendnotification();
      }
    } else {
      await likesCollection.add({'clubs': dRows});
      setState(() {
        isadded=true;
        widget.dRows.addAll(dRows);
      });
      NotifyFirebase().sendInvitationNotification(widget.leagueId, widget.userId, message);
      await Sendnotification(from:widget.leagueId, to: widget.userId, message: message10, content: '').sendnotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: isadded?OutlinedButton(
        style: OutlinedButton.styleFrom(

            minimumSize: const Size(0, 30),
            side: const BorderSide(
              color: Colors.grey,
            )),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    title: const Text('Remove League member'),
                    content: const Text('Do you want to remove member?'),
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
                            TextButton(
                              onPressed: deleteTeamMemeber,
                              child: const Text('Yes'),)
                          ]),]
                );
              }
          );
        },
        child: const Text(
          'Added', style: TextStyle(color: Colors.black),),
      ):OutlinedButton(
        style: OutlinedButton.styleFrom(

            minimumSize: const Size(0, 30),
            side: const BorderSide(
              color: Colors.grey,
            )),
        onPressed: addClub,
        child: const Text(
          'Add', style: TextStyle(color: Colors.black),),
      ),
    );
  }
}
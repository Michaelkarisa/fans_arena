import 'package:fans_arena/appid.dart';
import 'package:fans_arena/fans/data/notificationsmodel.dart';
import 'package:fans_arena/fans/data/usermodel.dart';
import 'package:fans_arena/professionals/screens/accountprofilepviewer.dart';
import 'package:fans_arena/reusablewidgets/cirularavatar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../fans/bloc/usernamedisplay.dart';
import '../../fans/data/newsfeedmodel.dart';

class HeaderWidgetclubsteams extends StatefulWidget {
  const HeaderWidgetclubsteams({super.key});
  @override
  State<HeaderWidgetclubsteams> createState() => _HeaderWidgetclubsteamsState();
}
class _HeaderWidgetclubsteamsState extends State<HeaderWidgetclubsteams> {
  final TextEditingController _controller = TextEditingController();
  bool _showCloseIcon = false;
  @override
  void initState() {
    super.initState();
    getAllData();
  }

  Set<String>docIds={};

  late Stream<QuerySnapshot> stream;
  void getAllData()async{
    try {
      stream = FirebaseFirestore.instance
          .collection('Clubs')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('clubsteam')
          .snapshots();
      stream.listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final List<QueryDocumentSnapshot> docs = snapshot.docs;
          List<Map<String, dynamic>> allLikes = [];
          List<Map<String, dynamic>> allLikes1 = [];
          for (final doc in docs) {
            docIds.add(doc.id);
            final List<Map<String,dynamic>> chats = List<Map<String,dynamic>>.from(doc['clubsteam']);
            final List<Map<String,dynamic>> chats1 = List<Map<String,dynamic>>.from(doc['clubsTeamTable']);
            allLikes.addAll(chats);
            allLikes1.addAll(chats1);
          }
          setState(() {
            dRows=allLikes;
            tableColumns=allLikes1;
          });
        } else {
        }
      });
    } catch (e) {
    }
  }
  List<Map<String, dynamic>> tableColumns = [];
  List<Map<String, dynamic>> dRows = [];

  String y='';
  SearchService5 search=SearchService5();
  String _searchQuery = '';
  double radius=18;
  @override
  Widget build(BuildContext context) {
    return
      Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: 235,
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: SizedBox(
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
                          _showCloseIcon = value.isNotEmpty;
                          _searchQuery=value;
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
                              _searchQuery=y;
                            });
                          },
                        ) : null,
                        hintText: 'Search',
                      ),
                    )),
              ),
            ),
            StreamBuilder<Set<UserModelP>>(
              stream: search.getUser(_searchQuery),
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
                List<UserModelP> userList=userList1.toList();
                return Expanded(
                  child: ListView.builder(
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
                      UserModelP user = userList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: SizedBox(
                          height: 40,
                          child: ListTile(
                              onTap: () {
                                Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AccountprofilePviewer(user:Person(
                                              name: user.stagename,
                                              userId:user.userId,
                                              url: user.url,
                                              collectionName:"Professional"
                                          ),index: 0,)
                                  ),
                                );
                              },
                              leading: CustomAvatar(radius: radius, imageurl: user.url),
                              title:UsernameDO(
                                username:user.stagename,
                                collectionName:'Professional',
                                width: 160,
                                height: 38,
                                maxSize: 140,
                              ),
                              trailing: SizedBox(
                                  width: 90,
                                  child: Addbtn(userId: user.userId,tableColumns:tableColumns,dRows: dRows,))
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),

      );
  }

}



class Addbtn extends StatefulWidget {
  String userId;
  List<Map<String,dynamic>>tableColumns;
  List<Map<String,dynamic>>dRows;
  Addbtn({super.key,
    required this.userId,
    required this.tableColumns,
    required this.dRows,});

  @override
  State<Addbtn> createState() => _AddbtnState();
}

class _AddbtnState extends State<Addbtn> {
  bool isadded=false;
  @override
  void initState() {
    super.initState();
    _checkUseristeam();
    setState(() {
      if(widget.tableColumns.isEmpty) {
        widget.tableColumns=[
          {'fn':'L'},
          {'fn':'Team'},];
      }
    });
  }
  void _checkUseristeam(){
    bool added=widget.dRows.any((element) => element[widget.tableColumns[1]['fn']]==widget.userId);
    setState(() {
      isadded = added; // Update _isLiked based on query result
    });
  }
  DateTime now=DateTime.now();
  Future<void> deleteTeamMemeber() async {
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection('Clubs')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('clubsteam');
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    for (final document in documents) {
      final List<dynamic> likesArray = document['clubsteam'];
      final index = likesArray.indexWhere((like) => like[widget.tableColumns[1]['fn']] == widget.userId);
      if (index != -1) {
        likesArray.removeAt(index);
        await document.reference.update({'clubsteam': likesArray});
        setState(() {
          isadded=false;
        });
        Navigator.of(context, rootNavigator: true).pop();
        return;
      }
    }
  }


  String message9="added you as a Club's team";

  List<Map<String, dynamic>> dRows = [];
  Future<void> addClub() async {
    String message="${username} ${message9}";
    try {
      final CollectionReference likesCollection = FirebaseFirestore.instance
          .collection('Clubs')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('clubsteam');

      setState(() {
        if (widget.userId.isNotEmpty) {
          Map<String, dynamic> data = {};
          for (var d in widget.tableColumns) {
            int i = widget.tableColumns.indexOf(d);
            if (i == 1) {
              data[d['fn']] = widget.userId;
            } else if (i > 1) {
              data[d['fn']] = '';
            } else {
              data[d['fn']] = '';
            }
          }
          dRows.add(data);
          String newColumnName = "addedAt";
          String newColumnName1 = "status";
          if (newColumnName.isNotEmpty) {
            for (var d in dRows) {
              d[newColumnName] = Timestamp.now();
              d[newColumnName1] = "";
            }
          }
        }
      });
      final QuerySnapshot querySnapshot = await likesCollection.get();
      final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
      if (documents.isNotEmpty) {
        final DocumentSnapshot latestDoc = documents.first;
        List<dynamic> likesArray = latestDoc['clubsteam'];
        if (likesArray.length < 500) {
          likesArray.addAll(dRows);
          await latestDoc.reference.update({'clubsteam': likesArray,});
          setState(() {
            isadded = true;
            widget.dRows.addAll(dRows);
          });
          NotifyFirebase().sendInvitationNotification(FirebaseAuth.instance.currentUser!.uid, widget.userId, message);
          await Sendnotification(from: FirebaseAuth.instance.currentUser!.uid,
              to: widget.userId,
              message: message9,
              content: '').sendnotification();
        } else {
          await likesCollection.add({'clubsteam': dRows, 'clubsTeamTable': widget.tableColumns});
          setState(() {
            isadded = true;
            widget.dRows.addAll(dRows);
          });
          NotifyFirebase().sendInvitationNotification(FirebaseAuth.instance.currentUser!.uid, widget.userId, message);
          await Sendnotification(from: FirebaseAuth.instance.currentUser!.uid,
              to: widget.userId,
              message: message9,
              content: '').sendnotification();

        }
      } else {
        await likesCollection.add({'clubsteam': dRows, 'clubsTeamTable': widget.tableColumns});
        setState(() {
          isadded = true;
          widget.dRows.addAll(dRows);
        });
        NotifyFirebase().sendInvitationNotification(FirebaseAuth.instance.currentUser!.uid, widget.userId, message);
        await Sendnotification(from: FirebaseAuth.instance.currentUser!.uid,
            to: widget.userId,
            message: message9,
            content: '').sendnotification();
      }
    }catch(error){
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
            content: Text('error: $error'),);});
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
                    title: const Text('Remove member'),
                    content: const Text('Do you want to remove member?'),
                    actions: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

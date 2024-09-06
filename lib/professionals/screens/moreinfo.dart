import 'package:fans_arena/professionals/screens/accountprofilepviewer.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../clubs/screens/clubteamtable.dart';
import '../../fans/bloc/accountchecker6.dart';
import '../../fans/data/newsfeedmodel.dart';
import '../../fans/data/notificationsmodel.dart';
import '../../fans/data/usermodel.dart';
import '../../fans/screens/messages.dart';
import '../../joint/components/colors.dart';
import '../../reusablewidgets/cirularavatar.dart';

class MoreInfo extends StatefulWidget {
  const MoreInfo({super.key});

  @override
  State<MoreInfo> createState() => _MoreInfoState();
}

class _MoreInfoState extends State<MoreInfo> {
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
  @override
  void initState() {
    super.initState();
    fetch();
    retrieveUsername();
    retrieveUsername1();
  }
  bool isloading=true;
  Future<void> retrieveUsername() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Leagues')
          .where('authorId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
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
      } else {
        setState(() {
          create = false;
          info=false;
        });
      }
    } catch (e) {
      print('Error retrieving leaguedata: $e');
    }
  }

  Future<void> retrieveUsername1() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Professionals')
          .doc(FirebaseAuth.instance.currentUser!.uid)
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

  List<Map<String,dynamic>>items1=[];
  List<Map<String, dynamic>> dataList2 = [];
  Future<void> fetch() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot documentSnapshot = await firestore.collection('Professionals')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final data = documentSnapshot.data() as Map<String, dynamic>?;
    if (data != null) {
      dataList2 = List<Map<String, dynamic>>.from(data['interests']);
    }
  }

  Future<void>PostToFirestore()async{
    await firestore.collection('Professionals')
        .doc(FirebaseAuth.instance.currentUser!.uid).update({
      'interests': FieldValue.arrayUnion(items1),
    });
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
          if (clubsteam[i]['teamId'] == FirebaseAuth.instance.currentUser!.uid) {
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
  final bool _showCloseIcon = false;
  final TextEditingController interest = TextEditingController();

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
        body:isloading?const Center(child: CircularProgressIndicator()): SingleChildScrollView(
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
                      child: Text('No more info about your extra activities',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                    ),
                  ),
                  create?Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text("League you're managing",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomAvatar(radius: radius, imageurl: imageurl),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: SizedBox(
                                width: MediaQuery.of(context).size.width*0.4,
                                height: 20,
                                child: OverflowBox(
                                    child: Text( maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      leaguename,style: const TextStyle(color:Colors.black),))),
                          ),
                        ],
                      ),
                    ],
                  ):const SizedBox(height: 0,),
                  clubId.isNotEmpty?SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Club engaged into',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomUsernameD0Avatar(userId: clubId,
                                style:const TextStyle(fontSize: 13),
                                radius: radius,
                                maxsize: 150,
                                height: 25,
                                width: 185),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                const Text('Role: ',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                                Text(role),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Row(
                                children: [
                                  const Text('Identity: ',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                                  identity.isNotEmpty?Text(identity):const Text('-'),
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ):const SizedBox(height: 0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('TrustedAccounts'),
                      IconButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>const AddTrustedA()));
                      }, icon: const Icon(Icons.add))
                    ],
                  ),

                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: FutureBuilder<QuerySnapshot>(
                        future:FirebaseFirestore.instance
                            .collection('Professionals')
                            .doc(FirebaseAuth.instance.currentUser!.uid).collection('trustedaccounts').get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('Members not yet added'));
                          } else {
                            final List<QueryDocumentSnapshot> likeDocuments = snapshot.data!.docs;
                            List<Map<String, dynamic>> allLikes = [];
                            for (final document in likeDocuments) {
                              final List<dynamic> likesArray = document['accounts'];
                              allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
                            }
                            return ListView.builder(
                              itemCount: allLikes.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                final data=allLikes[index];
                                return InkWell(
                                  onTap: () {

                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Container(
                                      width: 100,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ListTile(
                                        leading:CustomNameAvatar(userId: data['userId'],radius: radius, style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.normal,
                                        ), maxsize: 120,),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
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
    );
  }

}

class AddTrustedA extends StatefulWidget {
  const AddTrustedA({super.key});

  @override
  State<AddTrustedA> createState() => _AddTrustedAState();
}

class _AddTrustedAState extends State<AddTrustedA> {
  final TextEditingController _controller = TextEditingController();
  int index=0;
  String y='';
  SearchService search=SearchService();
  SearchService5 search1=SearchService5();
  SearchService4 search2=SearchService4();
  String _searchQuery = '';
  double radius=23;
  bool _showCloseIcon = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 8,bottom: 8,right: 30),
            child: SizedBox(
              height: 39,
              width:MediaQuery.of(context).size.width * 0.75,
              child: TextFormField(
                scrollPadding: const EdgeInsets.only(left: 10),
                textAlign: TextAlign.justify,
                textAlignVertical: TextAlignVertical.center,
                cursorColor: Colors.black,
                controller: _controller,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
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
                    fontSize: 20, fontWeight: FontWeight.normal,),
                  fillColor: Colors.white70,
                  suffixIcon: _showCloseIcon ? IconButton(
                    icon: const Icon(Icons.close,color: Colors.black,),
                    onPressed: () {
                      setState(() {
                        _searchQuery=y;
                        _controller.clear();
                        _showCloseIcon = false;
                      });
                    },
                  ) : null,
                  hintText: 'Search',
                ),
              ),
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Appbare,),
      body: StreamBuilder<Set<UserModelP>>(
        stream: search1.getUser(_searchQuery),
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
          List<UserModelP> userList =List.from(userList1);
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
                                  AccountprofilePviewer(
                                      user:Person(
                                          userId: user.userId,
                                          name: user.stagename,
                                          url: user.url,
                                          collectionName:'Professional'
                                      ),index:0)
                          ),
                        );
                      },
                      child:     Padding(
                        padding: const EdgeInsets
                            .only(left: 5),
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 10.0,
                            maxWidth: 160.0,
                          ),
                          color: Colors.transparent,
                          height: 38.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                color: Colors.transparent,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 10.0,
                                      maxWidth: 140.0,
                                    ),
                                    child: Text(
                                      user.stagename,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child:  SizedBox(
                                      height: 20,
                                      width: 20,
                                      child:  Accountchecker6(user:Person(
                                          userId: user.userId,
                                          name: user.stagename,
                                          url: user.url,
                                          collectionName:'Professional'
                                      ),)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    trailing: SizedBox(
                        height: 30,
                        child:AddButton(userId: user.userId,)
                    ),
                  )
              );
            },
          );
        },
      ),
    );
  }
}
class AddButton extends StatefulWidget {
  final String userId;
  const AddButton({super.key,required this.userId});

  @override
  State<AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<AddButton> {
  bool isadded=false;
  @override
  void initState() {
    super.initState();
    _checkUseristeam(widget.userId);
  }
  String message16='added you as a trusted account';
  void _checkUseristeam(String userId) async {
    bool added=await isUserIdLikedInAllDocuments(userId);
    setState(() {
      isadded = added;
    });
  }

  Future<void> Deleteteammemeber() async {
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection('Professionals')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('trustedaccounts');
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    for (final document in documents) {
      final List<dynamic> likesArray = document['accounts'];
      final index = likesArray.indexWhere((like) => like['userId'] == widget.userId);
      if (index != -1) {
        likesArray.removeAt(index);
        await document.reference.update({'accounts': likesArray});
        setState(() {
          isadded=false;
        });
        Navigator.of(context, rootNavigator: true).pop();
        return;
      }
    }
    print('match not found.');
  }

  Future<void> addclub() async {
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection('Professionals')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('trustedaccounts');
    final bool userLiked = await isUserIdLikedInAllDocuments(widget.userId);
    if (userLiked) {
      return;
    }
    final Timestamp createdAt = Timestamp.now();
    final like = {
      'userId': widget.userId,
      'createdAt': createdAt,};
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    if (documents.isNotEmpty) {
      final DocumentSnapshot latestDoc = documents.first;
      List<dynamic> likesArray = latestDoc['accounts'];
      if (likesArray.length < 500) {
        likesArray.add(like);
        await latestDoc.reference.update({'accounts': likesArray});
        setState(() {
          isadded=true;
        });
        await Sendnotification(from:FirebaseAuth.instance.currentUser!.uid, to: widget.userId, message: message16, content: '').sendnotification();
      } else {
        await likesCollection.add({'accounts': [like]});
        setState(() {
          isadded=true;
        });
      }
    } else {
      await likesCollection.add({'accounts': [like]});
      setState(() {
        isadded=true;
      });
    }
  }

  Future<bool> isUserIdLikedInAllDocuments(String userId) async {
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection('Professionals')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('trustedaccounts');
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    for (final document in documents) {
      final List<dynamic> likesArray = document['accounts'];
      if (likesArray.any((like) => like['userId'] == userId)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return  isadded?OutlinedButton(
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
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            onPressed: Deleteteammemeber,
                            child: const Text('Yes'),)
                        ]),]
              );
            }
        );
      },
      child: const Text(
        'Added',
        style: TextStyle(color: Colors.black),),
    ):OutlinedButton(
      style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 30),
          side: const BorderSide(
            color: Colors.grey,
          )),
      onPressed: addclub,
      child: const Text(
        'Add', style: TextStyle(color: Colors.black),),
    );
  }
}

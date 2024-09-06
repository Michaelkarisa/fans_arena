import 'package:fans_arena/fans/components/tabbar.dart';
import 'package:fans_arena/fans/screens/accountfanviewer.dart';
import 'package:fans_arena/professionals/screens/accountprofilepviewer.dart';
import 'package:fans_arena/reusablewidgets/cirularavatar.dart';
import 'package:flutter/material.dart';
import '../../fans/data/newsfeedmodel.dart';
import '../../fans/data/usermodel.dart';
import '../../fans/screens/search.dart';
import '../components/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class Choosefriends extends StatefulWidget {
  const Choosefriends({super.key});

  @override
  State<Choosefriends> createState() => _ChoosefriendsState();
}

class _ChoosefriendsState extends State<Choosefriends>with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    setState(() {});
    _tabController = TabController(length: 2, vsync: this, initialIndex: index);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    setState(() {
      index = _tabController.index;
    });
  }
  int index=0;
  bool _showCloseIcon = false;
  String y='';
  SearchService search=SearchService();
  String _searchQuery = '';
  double radius=20;
  bool issearch=false;
  SearchService5 search1=SearchService5();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,),
            onPressed: () {
              Navigator.of(context).pop();
            },//to next page},
          ),
          title: issearch? Padding(
            padding: const EdgeInsets.only(top: 5,bottom: 3,right: 10),
            child: SizedBox(
              height: 40,
              width:MediaQuery.of(context).size.width * 0.8,
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
                        _controller.clear();
                        _searchQuery=y;
                        _showCloseIcon = false;
                      });
                    },
                  ) : null,
                  hintText: 'Search',
                ),
              ),
            ),
          ):Center(child: Text('Choose Friends', style: TextStyle(color: Textn),)),
          backgroundColor: Appbare,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(onPressed: (){
                setState(() {
                  issearch=!issearch;
                });
              }, icon: Icon(issearch?Icons.arrow_drop_down:Icons.search_rounded,size: 25,color: Colors.black,)),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.044),
            child: SizedBox(
              height: MediaQuery.of(context).size.height*0.025,
              child: TabBar(
                labelStyle: const TextStyle(fontSize: 15),
                labelColor: Colors.blue,
                controller: _tabController,
                unselectedLabelColor: Colors.grey[600],
                indicatorWeight: 1,
                indicatorColor: Colors.white,
                tabs: [
                  Selected(label: 'Fans', isActive: index == 0,fsize: 15,),
                  Selected(label: 'Professionals', isActive: index == 1,fsize: 15,),
                ],
              ),
            ),
          ),
        ),

        body: TabBarView(
          controller: _tabController,
          children: [
            StreamBuilder<Set<UserModelF>>(
              stream: search.getUser(_searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState==ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator()),
                  );
                }
                Set<UserModelF> userList1 = snapshot.data!;
                List<UserModelF> userList =List.from(userList1);
                userList.removeWhere((element) => element.userId==FirebaseAuth.instance.currentUser!.uid);
                return ListView.builder(
                  itemCount: userList.length+1,
                  itemBuilder: (context, index) {
                    if (index==userList.length) {
                      return SizedBox(
                        height: 60,
                      );
                      //members already exists
                    }else{
                      UserModelF user = userList[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: ListTile(
                          leading:CustomAvatar(radius: radius, imageurl:user.url),
                          title:  InkWell(
                            onTap: () {
                              Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Accountfanviewer(user:Person(
                                            userId: user.userId,
                                            name: user.username,
                                            url: user.url,
                                            collectionName:'Fan'
                                        ),index:0)
                                ),
                              );
                            },
                            child:    Padding(
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
                                            user.username,
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
                                    // Adjust the spacing between the OverflowBox and Aligned container
                                  ],
                                ),
                              ),
                            ),
                          ),

                        ),
                      );
                    }},
                );
              },
            ),
            StreamBuilder<Set<UserModelP>>(
              stream: search1.getUser(_searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState==ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator()),
                  );
                }
                Set<UserModelP> userList1 = snapshot.data!;
                List<UserModelP> userList =List.from(userList1);
                userList.removeWhere((element) => element.userId==FirebaseAuth.instance.currentUser!.uid);
                return ListView.builder(
                    itemCount: userList.length+1,
                    itemBuilder: (context, index) {
                      if (index==userList.length) {
                        return SizedBox(
                          height: 60,
                        );
                        //members already exists
                      }else{
                        UserModelP user = userList[index];
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: ListTile(
                            leading:CustomAvatar(radius: radius, imageurl: user.url),
                            title:  InkWell(
                              onTap: () {
                                Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AccountprofilePviewer(user:Person(
                                              userId: user.userId,
                                              name: user.stagename,
                                              url: user.url,
                                              collectionName:'Professional'
                                          ),index: 0,)
                                  ),
                                );
                              },
                              child:    Padding(
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
                                      // Adjust the spacing between the OverflowBox and Aligned container
                                      Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Align(
                                          alignment: AlignmentDirectional.centerStart,
                                          child:  SizedBox(
                                              height: 20,
                                              width: 20,
                                              child:  Container(
                                                width:20 ,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color: Colors.blueGrey,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: const Center(child: Text('P',style: TextStyle(color: Colors.white),)),)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          ),
                        );
                      }}
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Choosefriends1 extends StatefulWidget {
  const Choosefriends1({super.key});

  @override
  State<Choosefriends1> createState() => _Choosefriends1State();
}

class _Choosefriends1State extends State<Choosefriends1> with SingleTickerProviderStateMixin{
  final TextEditingController _controller = TextEditingController();
  bool _showCloseIcon = false;
  String y='';
  SearchService search=SearchService();
  SearchService5 search1=SearchService5();
  String _searchQuery = '';
  double radius=20;
  bool issearch=false;
  String? selectedTeamId;
  Set<int> selectedIndexes = <int>{};
  Set<int> selectedIndexes1 = <int>{};
  List<String> selectedUserIds = [];
  String url='';
  String name='';
  TextEditingController groupname=TextEditingController();
  @override
  void initState() {
    super.initState();
    setState(() {});
    _tabController = TabController(length: 2, vsync: this, initialIndex: index);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    setState(() {
      index = _tabController.index;
    });
  }
  int index=0;
  Future<void> creategroup() async {
    final CollectionReference likesCollection = FirebaseFirestore.instance.collection('Groups');

    // Check if the user has already liked the post
    final List<Map<String, dynamic>> membersWithTimestamps = [];
    final Timestamp timestamp = Timestamp.now();
    final like = {'userId': FirebaseAuth.instance.currentUser!.uid, 'timestamp': timestamp};

    for (var userId in selectedUserIds) {
      membersWithTimestamps.add({
        'userId': userId,
        'timestamp': timestamp,
      });
    }
    membersWithTimestamps.add(like);
    // Create a new group document with a generated ID
    final DocumentReference newGroupDocRef = await likesCollection.add({
      'admins': [like],
      'profileimage': url,
      'members': FieldValue.arrayUnion(membersWithTimestamps),
      'createdAt': timestamp,
      'groupname': groupname.text,
    });

    // Set the groupId to be the same as the document's ID
    final groupId = newGroupDocRef.id;

    // Update the groupId field in the group document
    await newGroupDocRef.update({'groupId': groupId});
  }

  Future<bool> isUserIdLikedInAllDocuments(String userId) async {
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection('Groups');

    // Query the Likes subcollection to retrieve all documents
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    for (final document in documents) {
      final List<dynamic> likesArray = document['admins'];

      // Check if the userId is in the likes array
      if (likesArray.any((like) => like['userId'] == userId)) {
        // If userId is found in any document, return true
        return true;
      }
    }
    // If the loop completes without finding the userId in any document, return false
    return false;
  }
  late TabController _tabController;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,),
            onPressed: () {
              Navigator.of(context).pop();
            },//to next page},
          ),
          title: issearch? Padding(
            padding: const EdgeInsets.only(top: 5,bottom: 3,right: 10),
            child: SizedBox(
              height: 40,
              width:MediaQuery.of(context).size.width * 0.8,
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
                        _controller.clear();
                        _searchQuery=y;
                        _showCloseIcon = false;
                      });
                    },
                  ) : null,
                  hintText: 'Search',
                ),
              ),
            ),
          ):Center(child: Text('Choose Friends', style: TextStyle(color: Textn),)),
          backgroundColor: Appbare,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(onPressed: (){
                setState(() {
                  issearch=!issearch;
                });
              }, icon: Icon(issearch?Icons.arrow_drop_down:Icons.search_rounded,size: 25,color: Colors.black,)),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.044),
            child: SizedBox(
              height: MediaQuery.of(context).size.height*0.025,
              child: TabBar(
                labelStyle: const TextStyle(fontSize: 15),
                labelColor: Colors.blue,
                controller: _tabController,
                unselectedLabelColor: Colors.grey[600],
                indicatorWeight: 1,
                indicatorColor: Colors.white,
                tabs: [
                  Selected(label: 'Fans', isActive: index == 0,fsize: 15,),
                  Selected(label: 'Professionals', isActive: index == 1,fsize: 15,),
                ],
              ),
            ),
          ),
        ),

        body: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              children: [
                StreamBuilder<Set<UserModelF>>(
                  stream: search.getUser(_searchQuery),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState==ConnectionState.waiting) {
                      return const Center(
                        child: SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator()),
                      );
                    }
                    Set<UserModelF> userList1 = snapshot.data!;
                    List<UserModelF> userList =List.from(userList1);
                    userList.removeWhere((element) => element.userId==FirebaseAuth.instance.currentUser!.uid);
                    return ListView.builder(
                      itemCount: userList.length+1,
                      itemBuilder: (context, index) {
                        if (index==userList.length) {
                          return SizedBox(
                            height: 60,
                          );
                          //members already exists
                        }else {
                          UserModelF user = userList[index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: ListTile(
                              leading: CustomAvatar(radius: radius, imageurl: user.url),
                              title: InkWell(
                                onTap: () {
                                  Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Accountfanviewer(user:Person(
                                                userId: user.userId,
                                                name: user.username,
                                                url: user.url,
                                                collectionName:'Fan'
                                            ), index: 0,)
                                    ),
                                  );
                                },
                                child:   Padding(
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
                                                user.username,
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
                                        // Adjust the spacing between the OverflowBox and Aligned container
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              trailing: SizedBox(
                                height: 40,
                                width: 40,
                                child: Checkbox(
                                  value: selectedIndexes.contains(index),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedIndexes.add(index);
                                        selectedTeamId = user.userId;
                                        selectedUserIds.add(user.userId);
                                      } else {
                                        selectedIndexes.remove(index);
                                        selectedUserIds.remove(user.userId);
                                      }
                                    });
                                  },
                                ),


                              ),
                            ),
                          );
                        } },
                    );
                  },
                ),
                StreamBuilder<Set<UserModelP>>(
                  stream: search1.getUser(_searchQuery),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState==ConnectionState.waiting) {
                      return const Center(
                        child: SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator()),
                      );
                    }
                    Set<UserModelP> userList1 = snapshot.data!;
                    List<UserModelP> userList =List.from(userList1);
                    userList.removeWhere((element) => element.userId==FirebaseAuth.instance.currentUser!.uid);
                    return ListView.builder(
                      itemCount: userList.length+1,
                      itemBuilder: (context, index) {
                        if (index==userList.length) {
                          return SizedBox(
                            height: 60,
                          );
                          //members already exists
                        }else{
                          UserModelP user = userList[index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: ListTile(
                              leading:CustomAvatar(radius: radius, imageurl:user.url),
                              title:  InkWell(
                                onTap: () {
                                  Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AccountprofilePviewer(user:Person(
                                                userId: user.userId,
                                                name: user.stagename,
                                                url: user.url,
                                                collectionName:'Professional'
                                            ),index: 0,)
                                    ),
                                  );
                                },
                                child:    Padding(
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
                                        // Adjust the spacing between the OverflowBox and Aligned container
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5),
                                          child: Align(
                                            alignment: AlignmentDirectional.centerStart,
                                            child:  SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:  Container(
                                                  width:20 ,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: Colors.blueGrey,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: const Center(child: Text('P',style: TextStyle(color: Colors.white),)),)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              trailing: SizedBox(
                                height: 40,
                                width: 40,
                                child: Checkbox(
                                  value: selectedIndexes1.contains(index),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedIndexes1.add(index);
                                        selectedTeamId =user.userId;
                                        selectedUserIds.add(user.userId);
                                      } else {
                                        selectedIndexes1.remove(index);
                                        selectedUserIds.remove(user.userId);
                                      }
                                    });
                                  },
                                ),


                              ),
                            ),
                          );}
                      },
                    );
                  },
                ),
              ],
            ),

            Align(
              alignment: const Alignment(0.85, 0.9),
              child: Container(
                height: 40,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  shape: BoxShape.rectangle,
                ),

                child: FloatingActionButton(
                  foregroundColor: selectedUserIds.length > 2 ? Colors.teal : Colors.grey,
                  backgroundColor:selectedUserIds.length > 2 ? Colors.teal : Colors.grey,
                  onPressed: () {
                    if (selectedUserIds.length > 2) {
                      showDialog(context: context, builder: (context) {
                        return AlertDialog(
                          content: TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'group name'

                            ),
                            controller: groupname,
                          ),
                          actions: [
                            TextButton(onPressed: ()async{
                              await creategroup();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => Tabbar(index: 1,)),
                              );
                            }, child: const Text('done'))
                          ],
                        );
                      });

                    }else{
                      showDialog(context: context, builder: (context) {
                        String members='members';
                        String member='member';
                        String are='are';
                        String a='is';
                        int mno=3-selectedUserIds.length;
                        return AlertDialog(
                            title: const Text('Warning'),
                            content: Text('$mno additional ${mno==1?member:members} ${mno==1?a:are} required to create a group'));});
                    }
                  },
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0), // Adjust the value to control the button's oval shape
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Create group',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            )

          ],

        ),
      ),
    );
  }
}

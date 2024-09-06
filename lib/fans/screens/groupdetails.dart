import 'package:fans_arena/reusablewidgets/cirularavatar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../joint/components/colors.dart';
import '../bloc/usernamedisplay.dart';
import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../data/newsfeedmodel.dart';
import '../data/usermodel.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'accountfanviewer.dart';
import 'messages.dart';
class Groupdetails extends StatefulWidget {
  final String groupId;
  final String username;
  const Groupdetails({super.key,required this.groupId,required this.username});

  @override
  State<Groupdetails> createState() => _GroupdetailsState();
}

class _GroupdetailsState extends State<Groupdetails> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String groupname='';
  String url='';
  double radius=50;
  @override
  void initState(){
    super.initState();
    userData1();
  }
  late Stream<QuerySnapshot> _stream;
  void userData1() {
    _stream = firestore.collection('Groups').where('groupId',isEqualTo:widget.groupId).limit(1).snapshots();
    _stream.listen((snapshot) {
      List<QueryDocumentSnapshot> likeDocuments = snapshot.docs;
      // Extract and combine all like objects into a single list
      if(likeDocuments.isNotEmpty){
        for (final document in likeDocuments) {
          setState(() {
            groupname = document['groupname'];
            url = document['profileimage'];
          });
          // Explicitly cast likesArray to Iterable<Map<String, dynamic>>
        }}});}

  String imageurl = '';
  String userId='';


  Future<String> uploadImageToStorage(BuildContext context) async {
    File imageFile = File(imageurl);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('ProfileGroups')
          .child('images')
          .child('$fileName.jpg');

      final uploadTask = ref.putFile(imageFile);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16.0),
                Text('Uploading Image...'),
              ],
            ),
          );
        },
      );

      final snapshot = await uploadTask.whenComplete(() {});
      Navigator.of(context, rootNavigator: true).pop();// Close the progress dialog

      if (snapshot.state == firebase_storage.TaskState.success) {
        String imageURL = await ref.getDownloadURL();
        return imageURL;
      } else {
        print('Image upload task failed');
        return '';
      }
    } catch (e) {
      print('Error uploading image to storage: $e');
      return '';
    }
  }
  Future<void> uploadAndSaveImage() async {
    if (imageurl.isNotEmpty) {
      File imageFile = File(imageurl);

      if (imageFile.existsSync()) {
        String? imageUrl = await uploadImageToStorage(context);

        setState(() {
          imageurl = imageUrl;
        });
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                content: Text('Profile updated successfully'),
              );
            });

            }
    }
  }
  Future<void> saveDataToFirestore() async {

    await uploadAndSaveImage();
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('Groups')
          .where('groupId', isEqualTo: widget.groupId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var documentSnapshot = querySnapshot.docs[0];
        var oldData = documentSnapshot.data() as Map<String, dynamic>;

        Map<String, dynamic> newData = {};
        if (imageurl != oldData['profileimage']) {
          newData['profileimage'] = imageurl;
        }
        if (newData.isNotEmpty) {
          await documentSnapshot.reference.update(newData);
          imageurl='';
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
  Future<void> updategroupname() async {


    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('Groups')
          .where('groupId', isEqualTo: widget.groupId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var documentSnapshot = querySnapshot.docs[0];
        var oldData = documentSnapshot.data() as Map<String, dynamic>;

        Map<String, dynamic> newData = {};
        if (groupname1.text.isNotEmpty&&groupname1.text != oldData['groupname']) {
          newData['groupname'] = groupname1.text;
        }
        if (newData.isNotEmpty) {
          await documentSnapshot.reference.update(newData);
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
  TextEditingController groupname1=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.grey[400],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        elevation: 1,
        title: const Text("Group details",style: TextStyle(color: Colors.white),),
        leading: IconButton(
      icon: const Icon(Icons.arrow_back,color: Colors.white,size: 33,),
      onPressed: () {
        Navigator.of(context).pop();
      },//to next page},
        ),
      actions: [
        SizedBox(
      width: MediaQuery.of(context).size.width*0.3625,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

          PopupMenuButton<String>(
           position:PopupMenuPosition.under,
            onSelected: (value) {
              if(value=='1'){
                Navigator.push(context,
                  MaterialPageRoute(builder: (context)=> Addmembers(groupId: widget.groupId,),
                  ),
                );
              }else if(value=='2'){
                showDialog(context: context, builder: (context) {
                  groupname1.text=groupname;
                  return AlertDialog(
                    content: TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'group name'

                      ),
                      controller: groupname1,
                    ),
                    actions: [
                      TextButton(onPressed: ()async{
                        await updategroupname();
                      }, child: const Text('done'))
                    ],
                  );
                });
              }else if(value=='3'){
                Navigator.push(context,
                  MaterialPageRoute(builder: (context)=> Grouppermissions(groupId: widget.groupId,),
                  ),
                );
              }
              // Do something when a menu item is selected
              print('You selected "$value"');
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: '1',
                  child: Text('Add members'),
                ),
                const PopupMenuItem<String>(
                  value: '2',
                  child: Text('Change groupname'),
                ),
                const PopupMenuItem<String>(
                  value: '3',
                  child: Text('Group permissions'),
                ),
              ];
            },
          ),

        ],
      ),
        ),
      ],
      ),
        body: CustomScrollView(
          scrollDirection:Axis.vertical,
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          children: [
                            widget.username.isEmpty?CustomAvatar(imageurl: url, radius: radius):CustomAvatarM(userId:widget.username.isEmpty?widget.groupId:'', radius: radius,),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: InkWell(
                                  onTap: ()async{
                                    FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(type: FileType.image);
                                    if (result != null && result.files.isNotEmpty) {
                                      File imageFile = File(result.files.single.path!);
                                      setState(() {
                                        imageurl = imageFile.path;
                                      });
                                    }
                                  },
                                  child: const Icon(Icons.edit,color: Colors.white,size: 26,),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      imageurl.isNotEmpty?TextButton(onPressed: (){saveDataToFirestore();}, child: const Text('update image')):
                      const SizedBox(height: 0,),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                            color: Colors.transparent,
                            constraints: const BoxConstraints(
                                maxWidth: 160,
                                minWidth: 10
                            ),
                            height: 25,
                            child: Text(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                             widget.username.isEmpty? groupname:widget.username,style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),)),
                      ),
                      TextButton(onPressed: (){
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context)=> Addmembers(groupId: widget.groupId,),
                          ),
                        );
                      }, child: const Text('Add members')),
                    ],
                  ),
                ),

              ]),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(
                  height: 25,
                    width: MediaQuery.of(context).size.width,
                    child: const Center(child: Text('Members',style: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.bold),))),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Groups')
                        .where('groupId',isEqualTo: widget.groupId)
                        .limit(1)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator()); // Display a loading indicator while fetching data
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text(
                            'No members')); // Handle case where there are no likes
                      } else {
                        final List<QueryDocumentSnapshot> likeDocuments = snapshot
                            .data!.docs;
                        Set<Map<String, dynamic>> allLikes = {};
                        List<Map<String, dynamic>> allLikes1 = [];
                        // Extract and combine all like objects into a single list
                        for (final document in likeDocuments) {
                          final List<dynamic> likesArray = document['members'];
                          final List<dynamic> likesArray1 = document['admins'];
                          // Explicitly cast likesArray to Iterable<Map<String, dynamic>>
                          allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
                          allLikes1.addAll(likesArray1.cast<Map<String, dynamic>>());
                        }return ListView.builder(
                            itemCount: allLikes.length,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final u = allLikes.toList();
                              final user = u[index];
                              final ind=allLikes1.indexWhere((like) => like['userId'] == user['userId']);
                              return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: ListTile(
                                    leading:CustomUsernameD0Avatar(userId:user['userId'] ,
                                        style:const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                        radius: 23, maxsize: 165, height: 20, width: 200),
                                    trailing: ind!=-1?const Text('Admin'):const SizedBox(height: 0,width: 0,),
                                  )

                              );});
                      }})
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
class Addmembers extends StatefulWidget {
  String groupId;
   Addmembers({super.key,required this.groupId});

  @override
  State<Addmembers> createState() => _AddmembersState();
}

class _AddmembersState extends State<Addmembers> {

  @override
  void initState(){
    super.initState();
    retrieveAllChats();
  }
  late Stream<QuerySnapshot> _stream3;

  Future<void> retrieveAllChats() async {
    _stream3 = firestore
        .collection('Groups')
        .where('groupId',isEqualTo: widget.groupId)
        .snapshots();

    _stream3.listen((snapshot) async {
      List<QueryDocumentSnapshot>documents=snapshot.docs;
      if (documents.isNotEmpty) {
        for(final document in documents){
          List<dynamic> data=document['members'];
          allLikes.addAll(data.cast<Map<String, dynamic>>());
        }
      }
    });
  }
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _controller = TextEditingController();
  bool _showCloseIcon = false;
  String y='';
  SearchService search=SearchService();
  String _searchQuery = '';
  double radius=20;
  bool issearch=false;
  String? selectedTeamId;
  Set<int> selectedIndexes = <int>{};
  List<String> selectedUserIds = [];
  String url='';
  String name='';
  TextEditingController groupname=TextEditingController();
  Future<void> addmembers()async{
    //profile image
    // admins[userId,datejoined]
    //members[userId,datejoined]
    //createdat
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection('Groups');
    final messageCollection = FirebaseFirestore.instance.collection('Groups');
    // Check if the user has already liked the post
    final List<Map<String, dynamic>> membersWithTimestamps = [];
    final List<Map<String, dynamic>> membersWithTimestamps1 = [];
    final Timestamp timestamp = Timestamp.now();
    final like = {'userId': FirebaseAuth.instance.currentUser!.uid, 'timestamp': timestamp};
    for (var userId in selectedUserIds) {
      membersWithTimestamps.add({
        'userId': userId,
        'timestamp': timestamp,
      });
    }
    // Query the Likes subcollection to retrieve existing documents
     final QuerySnapshot querySnapshot = await likesCollection.where('groupId',isEqualTo: widget.groupId).limit(1).get();
     final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    if (documents.isNotEmpty) {
      // There are existing documents, get the latest one
      final DocumentSnapshot latestDoc = documents.first;
      List<dynamic> likesArray = latestDoc['members'];
      // Check if adding the like to the latest document exceeds the limit
      if (likesArray.length < 200) {
        for (final item in membersWithTimestamps) {
          final userId = item['userId'] as String;
          final index=likesArray.indexWhere((like) => like['userId'] == userId);
          if (index!=-1) {
           //members already exists
          }else{
            //member does not exist
            likesArray.add(item); 
          }
        }
        await latestDoc.reference.update({'members': likesArray});
      } else {
        showDialog(context: context, builder: (context){
          return const AlertDialog(
            title: Text('Warning'),
            content: Text('Maximun number of members reached'),
          );
        });
      }
    } else {
      // No previous documents, create a new one with the initial like
      membersWithTimestamps.add(like);
      await likesCollection.add({
        'admins': [like],
        'profileimage':url,
        'members': FieldValue.arrayUnion(membersWithTimestamps),
        'createdAt':timestamp,
        'groupId':messageCollection.doc().id,
        'groupname':groupname.text,
      });
    }
  }
  List<Map<String, dynamic>> allLikes = [];
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
                textAlign: TextAlign.justify,
                textAlignVertical: TextAlignVertical.bottom,
                cursorColor: Colors.black,
                controller: _controller,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _showCloseIcon = value.isNotEmpty;
                  });
                },
                decoration: InputDecoration(
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
        ),

        body: Stack(
          children: [
            StreamBuilder<Set<UserModelF>>(
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
                Set<UserModelF>? userList1 = snapshot.data;
                List<UserModelF>? userList = userList1?.toList();
                return ListView.builder(
                  itemCount: userList!.length+1,
                  itemBuilder: (context, index) {
                      if (index==userList.length) {
                        return SizedBox(
                          height: 50,
                        );
                        //members already exists
                      }else{
                        UserModelF? user = userList[index];
                        final ind=allLikes.indexWhere((like) => like['userId'] == user.userId);
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Accountfanviewer(user:Person(
                                        name: user.username,
                                        userId:user.userId,
                                        url: user.url,
                                        collectionName:"Fan"
                                    ),index: 0,)
                            ),
                          );
                        },
                        leading:CustomAvatar(radius: radius, imageurl:user.url),
                        title:  UsernameDO(
                          username:user.username,
                          collectionName:'Fan',
                          width: 160,
                          height: 38,
                          maxSize: 140,
                        ),
                        subtitle:ind!=-1?const Text('already added to the group'):const Text('') ,
                        trailing: SizedBox(
                          height: 40,
                          width: 40,
                          child: ind==-1?Checkbox(
                            value: selectedIndexes.contains(index),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedIndexes.add(index);
                                  selectedTeamId =user.userId;
                                  selectedUserIds.add(user.userId);
                                } else {
                                  selectedIndexes.remove(index);
                                  selectedUserIds.remove(user.userId);
                                }
                              });
                            },
                          ):const Text(''),


                        ),
                      ),
                    );
                  }},
                );
              },
            ),
            Align(
              alignment: const Alignment(0.85, 0.98),
              child: Container(
                height: 40,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  shape: BoxShape.rectangle,
                ),

                child: FloatingActionButton(
                  foregroundColor: selectedUserIds.isNotEmpty ? Colors.teal : Colors.grey,
                  backgroundColor:selectedUserIds.isNotEmpty ? Colors.teal : Colors.grey,
                  onPressed: () {
                   addmembers();
                  },
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0), // Adjust the value to control the button's oval shape
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Add members',
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
class Grouppermissions extends StatefulWidget {
  String groupId;
   Grouppermissions({super.key,required this.groupId});

  @override
  State<Grouppermissions> createState() => _GrouppermissionsState();
}

class _GrouppermissionsState extends State<Grouppermissions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text("Group Permissions",style: TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white,size: 33,),
          onPressed: () {
            Navigator.of(context).pop();
          },//to next page},
        ),

      ),
    );
  }
}

import 'package:fans_arena/fans/components/followerstabbar.dart';
import 'package:fans_arena/fans/screens/chatting.dart';
import 'package:fans_arena/fans/screens/moreinfofansv.dart';
import 'package:fans_arena/fans/screens/postsnumber.dart';
import 'package:fans_arena/fans/screens/professional.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../reusablewidgets/cirularavatar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/newsfeedmodel.dart';
class ProfileHeaderWidgetfanviewer extends StatefulWidget {
  String userId;
  ProfileHeaderWidgetfanviewer({super.key, required this.userId});

  @override
  State<ProfileHeaderWidgetfanviewer> createState() => _ProfileHeaderWidgetfanviewerState();
}

class _ProfileHeaderWidgetfanviewerState extends State<ProfileHeaderWidgetfanviewer> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String username1 = '';
  String favourite1 = '';
  String bio1 = '';
  String website1 = '';
  String imageurl = '';
  String email1 = '';

  void retrieveUserData() async {
    try {
      QuerySnapshot querySnapshotC = await firestore
          .collection('Fans')
          .where('Fanid', isEqualTo: widget.userId)
          .limit(1)
          .get();

      if (querySnapshotC.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotC.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          username1 = data['username']??'';
          email1 = data['email']??'';
          favourite1 = data['genre']??'';
          bio1 = data['bio']??'';
          imageurl = data['profileimage']??'';
          website1 = data['website']??'';

        });
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    retrieveUserData();
    _getCurrentUser();
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  String userId='';
  String collectionName='';
  bool isLoading=true;
  Future<void> _getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      collectionName = prefs.getString('cname')?? '';
      collectionName = prefs.getString('cname')?? '';
      userId=FirebaseAuth.instance.currentUser!.uid;
      isLoading=false;
    });
  }
  double radius=55;
  @override
  Widget build(BuildContext context) {
    return   FittedBox(
          fit: BoxFit.scaleDown,
          child: LayoutBuilder(
          builder: (context, constraints) {
      if (MediaQuery
            .of(context)
            .size
            .height < 650) {
    return  Padding(
      padding: const EdgeInsets.only(top: 6,left: 8),
      child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.23,
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.126,
                    child: InkWell(
                      onTap: (){
                        Navigator.push(context,MaterialPageRoute(builder: (context)=>ViewFile(urls:[{'url':'','url1':imageurl}])));
                      },
                        child: CustomAvatar( radius: radius, imageurl: imageurl,))
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: SizedBox(
                      width:MediaQuery.of(context).size.width*0.68,
                      height:MediaQuery.of(context).size.height*0.18,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width:MediaQuery.of(context).size.width*0.65,
                            height:MediaQuery.of(context).size.height*0.055,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.315,
                                  child:  LayoutBuilder(builder: (context, BuildContext) {
                                    if(isLoading){
                                      return OutlinedButton(
                                        style: OutlinedButton.styleFrom(

                                            minimumSize: const Size(0, 30),
                                            side: const BorderSide(
                                              color: Colors.grey,
                                            )),
                                        onPressed: () {
                                        },
                                        child: const Text("Message", style: TextStyle(color: Colors.black)),
                                      );
                                    }else if (collectionName == 'Fan') {
                                      return actions(context);
                                    } else if (collectionName == 'Professional') {
                                      return actions(context);
                                    } else if (collectionName == 'Club') {
                                      return  OutlinedButton(
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
                                                    alignment: Alignment.center,
                                                    title: const Text('Access denied'),
                                                    content: const Text('As a club you are an entity, individual messaging privilages are not enabled for such an account.'),
                                                    actions: [
                                                      TextButton(
                                                        child: const Text('Ok'),
                                                        onPressed: () {
                                                          Navigator.pop(context); // Dismiss the dialog
                                                        },
                                                      ),

                                                    ]);
                                              }
                                          );
                                        },
                                        child: const Text("Message", style: TextStyle(color: Colors.black)),
                                      );
                                    } else {
                                      return OutlinedButton(
                                        style: OutlinedButton.styleFrom(

                                            minimumSize: const Size(0, 30),
                                            side: const BorderSide(
                                              color: Colors.grey,
                                            )),
                                        onPressed: () {

                                        },
                                        child: const Text("Message", style: TextStyle(color: Colors.black)),
                                      );
                                    }
                                  }),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.28,
                                  child: actions4(context),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.65,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    const Text('Posts', style: TextStyle(fontSize: 16,
                                      fontWeight: FontWeight.bold,)),
                                    Postno(userId: widget.userId)
                                  ],
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(context,
                                      MaterialPageRoute(builder: (
                                          context) =>  Followerstab(userId: widget.userId,index: 0,),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      const Text('Followers', style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,)),
                                      ItemCount(collection: "Fans",subCollection: 'followers',docId: widget.userId,)
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(context,
                                      MaterialPageRoute(builder: (
                                          context) =>  Followerstab( userId: widget.userId,index: 1,),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      const Text('Following', style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,)),
                                      ItemCount(collection: "Fans",subCollection: 'following',docId: widget.userId,)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.65,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(context,
                                      MaterialPageRoute(builder: (
                                          context) =>  Followerstab(userId: widget.userId,index: 2,),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      const Text('Clubs', style: TextStyle(fontSize: 16,
                                        fontWeight: FontWeight.bold,)),
                                      ItemCount(collection: "Fans",subCollection: 'clubs',docId: widget.userId,)
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(context,
                                      MaterialPageRoute(builder: (
                                          context) =>  Followerstab(userId: widget.userId,index: 3,),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      const Text('Professional', style: TextStyle(fontSize: 16,
                                        fontWeight: FontWeight.bold,)),
                                      ItemCount(collection: "Fans",subCollection: 'professionals',docId: widget.userId,)
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    const Text('Favourite', style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold,)),
                                    favourite1.isEmpty?const Text('-',style: TextStyle(fontSize: 20),): Text(favourite1),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),


              FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      bio1.isNotEmpty?
                      Row(
                        children: [
                          const Text(
                            'Bio: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            bio1,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ):const SizedBox.shrink(),
                          email1.isNotEmpty?
                          Row(
                            children: [
                              const Text('Email: '),
                              Text(email1)
                            ],
                          ):const SizedBox.shrink(),
                          website1.isNotEmpty?
                          Row(
                            children: [
                              const Text('Website: '),
                              InkWell(
                                  onTap: (){
                                    _launchURL(website1);
                                  },
                                  child: Text(website1,style: const TextStyle(color: Colors.blue),)),
                            ],
                          ):const SizedBox.shrink()
                       ,
                    ],
                  ),
                ),
              ),

            ],
          ),
      ),
    );
    }else{
          return   SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4,top: 3),
                      child: SizedBox(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.28,
                        height: MediaQuery
                            .of(context)
                            .size
                            .height * 0.126,
                        child: InkWell(
                            onTap: (){
                              Navigator.push(context,MaterialPageRoute(builder: (context)=>ViewFile(urls:[{'url':'','url1':imageurl}])));
                            },
                            child: CustomAvatar(radius: radius, imageurl: imageurl,))
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SizedBox(
                          width:MediaQuery.of(context).size.width*0.68,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width:MediaQuery.of(context).size.width*0.67,
                                height:MediaQuery.of(context).size.height*0.045,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.315,
                                      child:  LayoutBuilder(builder: (context, BuildContext) {
                                        if(isLoading){
                                          return OutlinedButton(
                                            style: OutlinedButton.styleFrom(

                                                minimumSize: const Size(0, 30),
                                                side: const BorderSide(
                                                  color: Colors.grey,
                                                )),
                                            onPressed: () {

                                            },
                                            child: const Text("Message", style: TextStyle(color: Colors.black)),
                                          );
                                        }else if (collectionName == 'Fan') {
                                          return actions(context);
                                        } else if (collectionName == 'Professional') {
                                          return actions(context);
                                        } else if (collectionName == 'Club') {
                                          return  OutlinedButton(
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
                                                        alignment: Alignment.center,
                                                        title: const Text('Access denied'),
                                                        content: const Text('As a club you are an entity, individual messaging privilages are not enabled for such an account.'),
                                                        actions: [
                                                          TextButton(
                                                            child: const Text('Ok'),
                                                            onPressed: () {
                                                              Navigator.pop(context); // Dismiss the dialog
                                                            },
                                                          ),

                                                        ]);
                                                  }
                                              );
                                            },
                                            child: const Text("Message", style: TextStyle(color: Colors.black)),
                                          );
                                        } else {
                                          return OutlinedButton(
                                            style: OutlinedButton.styleFrom(

                                                minimumSize: const Size(0, 30),
                                                side: const BorderSide(
                                                  color: Colors.grey,
                                                )),
                                            onPressed: () {

                                            },
                                            child: const Text("Message", style: TextStyle(color: Colors.black)),
                                          );
                                        }
                                      }),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.3,
                                      child: actions4(context),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.65,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        const Text('Posts', style: TextStyle(fontSize: 16,
                                          fontWeight: FontWeight.bold,)),
                                        Postno(userId: widget.userId)
                                      ],
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(context,
                                          MaterialPageRoute(builder: (
                                              context) =>  Followerstab(userId: widget.userId,index: 0,),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          const Text('Followers', style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,)),
                                          ItemCount(collection: "Fans",subCollection: 'followers',docId: widget.userId,)
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(context,
                                          MaterialPageRoute(builder: (
                                              context) => Followerstab(userId: widget.userId,index: 1,),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          const Text('Following', style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,)),
                                          ItemCount(collection: "Fans",subCollection: 'following',docId: widget.userId,)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.65,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(context,
                                          MaterialPageRoute(builder: (
                                              context) =>  Followerstab(userId: widget.userId,index: 2,),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          const Text('Clubs', style: TextStyle(fontSize: 16,
                                            fontWeight: FontWeight.bold,)),
                                          ItemCount(collection: "Fans",subCollection: 'clubs',docId: widget.userId,)
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(context,
                                          MaterialPageRoute(builder: (
                                              context) => Followerstab(userId: widget.userId,index: 3,),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          const Text('Professional', style: TextStyle(fontSize: 16,
                                            fontWeight: FontWeight.bold,)),
                                          ItemCount(collection: "Fans",subCollection: 'professionals',docId: widget.userId,)
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        const Text('Favourite', style: TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.bold,)),
                                        favourite1.isEmpty?const Text('-',style: TextStyle(fontSize: 20),): Text(favourite1),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                   width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          bio1.isNotEmpty?
                          Row(
                            children: [
                              const Text(
                                'Bio: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                bio1,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ):const SizedBox.shrink(),
                              email1.isNotEmpty?
                              Row(
                                children: [
                                  const Text('Email: '),
                                  Text(email1)
                                ],
                              ):const SizedBox.shrink(),
                              website1.isNotEmpty?
                              Row(
                                children: [
                                  const Text('Website: '),
                                  InkWell(
                                      onTap: (){
                                        _launchURL(website1);
                                      },
                                      child: Text(website1,style: const TextStyle(color: Colors.blue),)),
                                ],
                              ):const SizedBox.shrink()
                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),
          );
    }
      }),
        );
  }

  Widget actions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                minimumSize: const Size(0, 30),
                side: const BorderSide(
                  color: Colors.grey,
                )),
            onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => Chatting(user:Person(
                    userId: widget.userId,
                    name: username1,
                    url: imageurl,
                    collectionName:'Fan'
                ), chatId: '',),
                ),
              );
            },
            child: const Text("Message", style: TextStyle(color: Colors.black)),
          ),
        ),
      ],
    );
  }

  Widget actions4(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                minimumSize: const Size(0, 30),
                side: const BorderSide(
                  color: Colors.grey,
                )),
            onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => Moreinfofansv(userId:widget.userId),
                ),
              );
            },
            child: const Text("More info", style: TextStyle(color: Colors.black)),
          ),
        ),
      ],
    );
  }
}
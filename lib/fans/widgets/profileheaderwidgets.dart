import 'package:fans_arena/fans/components/followerstabbar.dart';
import 'package:fans_arena/fans/screens/editprofilef.dart';
import 'package:fans_arena/fans/screens/moreinfofans.dart';
import 'package:fans_arena/fans/screens/postsnumber.dart';
import 'package:fans_arena/fans/screens/professional.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../reusablewidgets/cirularavatar.dart';

class ProfileHeaderWidget extends StatefulWidget {
  const ProfileHeaderWidget({super.key});

  @override
  _ProfileHeaderWidgetState createState() => _ProfileHeaderWidgetState();
}

class _ProfileHeaderWidgetState extends State<ProfileHeaderWidget> {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String username1 = '';
  String favourite1 = '';
  String bio1 = '';
  String website1 = '';
  String imageurl = '';
  String email1 = '';
  String userId='';


  Future<void> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    userData();
  }
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
  late Stream<DocumentSnapshot> _stream1;
  void userData() {
    _stream1 = firestore.collection('Fans').doc(FirebaseAuth.instance.currentUser!.uid).snapshots();
    _stream1.listen((snapshot) {
      final newValue = (snapshot.data() as Map<String, dynamic>)['username']??'';
      final newValue0 = (snapshot.data() as Map<String, dynamic>)['email']??'';
      final  newValue1 = (snapshot.data() as Map<String, dynamic>)['bio']??'';
      final newValue2 = (snapshot.data() as Map<String, dynamic>)['profileimage']??'';
      final newValue4 = (snapshot.data() as Map<String, dynamic>)['genre']??'';
      final newValue3 = (snapshot.data() as Map<String, dynamic>)['website']??'';
      setState(() {
        username1 = newValue;
        email1 = newValue0;
        bio1 = newValue1;
        imageurl = newValue2;
        website1 = newValue3;
        favourite1 = newValue4;
      });
    } );
  }


  double radius=55;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          if (MediaQuery
              .of(context)
              .size
              .height < 650) {
            return Padding(
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
                          width:MediaQuery.of(context).size.width*0.23,
                          height:MediaQuery.of(context).size.height*0.126,
                          child: Center(
                              child:CustomAvatar(radius: radius, imageurl: imageurl,)
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
                                    height:MediaQuery.of(context).size.height*0.055,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.31,
                                          child: actions(context),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.28,
                                          child: actions5(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: MediaQuery
                                      .of(context)
                                      .size
                                      .width * 0.65,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            const Text(
                                              'Posts',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Postno(userId: userId)
                                          ],
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>  Followerstab(userId: userId,index: 0,),
                                              ),
                                            );
                                          },
                                          child: Column(
                                            children: [
                                              const Text(
                                                'Followers',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              ItemCount(collection: "Fans",subCollection: 'followers',docId: userId,)
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>  Followerstab(userId: userId,index: 1,),
                                              ),
                                            );
                                          },
                                          child: Column(
                                            children: [
                                              const Text(
                                                'Following',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              ItemCount(collection: "Fans",subCollection: 'following',docId: userId,)
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.65,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Followerstab(userId: userId,index: 2,),
                                              ),
                                            );
                                          },
                                          child: Column(
                                            children: [
                                              const Text(
                                                'Clubs',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              ItemCount(collection: "Fans",subCollection: 'clubs',docId:userId,)
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Followerstab(userId: userId,index: 3,),
                                              ),
                                            );
                                          },
                                          child: Column(
                                            children: [
                                              const Text(
                                                'Professional',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              ItemCount(collection: "Fans",subCollection: 'professionals',docId: userId,)
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            const Text(
                                              'Favourite',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
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
                        width:MediaQuery.of(context).size.width ,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
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
                  ],
                ),
              ),
            );
          }else{
            return SizedBox(
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
                          width:MediaQuery.of(context).size.width*0.28,
                          height:MediaQuery.of(context).size.height*0.126,
                          child: Center(
                              child:CustomAvatar(radius: radius, imageurl: imageurl,)
                          ),
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
                                        child: actions(context),
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.28,
                                        child: actions5(context),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.65,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          const Text(
                                            'Posts',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Postno(userId: userId)
                                        ],
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Followerstab(userId: userId,index: 0,),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          children: [
                                            const Text(
                                              'Followers',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            ItemCount(collection: "Fans",subCollection: 'followers',docId:userId,)
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Followerstab(userId: userId,index: 1,),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          children: [
                                            const Text(
                                              'Following',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            ItemCount(collection: "Fans",subCollection: 'following',docId: userId,)
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.65,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Followerstab(userId: userId,index: 2,),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          children: [
                                            const Text(
                                              'Clubs',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            ItemCount(collection: "Fans",subCollection: 'clubs',docId: userId,)
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Followerstab(userId: userId,index: 3,),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          children: [
                                            const Text(
                                              'Professional',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            ItemCount(collection: "Fans",subCollection: 'professionals',docId:userId,)
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            'Favourite',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
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
                        padding: const EdgeInsets.only(left: 8,),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
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
        }
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
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditprofileF(),
                ),
              );
            },
            child: const Text(
              "Edit Profile",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
  Widget actions5(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              minimumSize: const Size(0, 30),
              side: const BorderSide(
                color: Colors.grey,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  Moreinfofans(userId:userId,),
                ),
              );
            },
            child: const Text(
              "More info",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
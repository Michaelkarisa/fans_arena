import 'package:fans_arena/clubs/components/fans.dart';
import 'package:fans_arena/clubs/components/matchesstreamed.dart';
import 'package:fans_arena/clubs/screens/clubteamtable.dart';
import 'package:fans_arena/clubs/screens/editprofilec.dart';
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:fans_arena/fans/screens/postsnumber.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../fans/screens/professional.dart';
import '../../reusablewidgets/cirularavatar.dart';
import 'package:url_launcher/url_launcher.dart';
class ProfileHeaderWidgetClubs extends StatefulWidget {
  const ProfileHeaderWidgetClubs({super.key});

  @override
  State<ProfileHeaderWidgetClubs> createState() => _ProfileHeaderWidgetClubsState();

}

class _ProfileHeaderWidgetClubsState extends State<ProfileHeaderWidgetClubs> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String username1 = '';
  String genre1 = '';
  String motto1 = '';
  String location1 = '';
  String website1 = '';
  String imageurl = '';
  String email1 = '';
  String userId = '';


  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    userData();
  }

  Future<void> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid; // Assign the user ID to the userId variable
      });
    }
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
    _stream1 = firestore.collection('Clubs').doc(FirebaseAuth.instance.currentUser!.uid).snapshots();
    _stream1.listen((snapshot) {
      final newValue = (snapshot.data() as Map<String, dynamic>)['Clubname']??'';
      final newValue0 = (snapshot.data() as Map<String, dynamic>)['email']??'';
      final  newValue1 = (snapshot.data() as Map<String, dynamic>)['Location']??'';
      final newValue2 = (snapshot.data() as Map<String, dynamic>)['profileimage']??'';
      final newValue3 = (snapshot.data() as Map<String, dynamic>)['website']??'';
      final newValue4 = (snapshot.data() as Map<String, dynamic>)['Motto']??'';
      final newValue5 = (snapshot.data() as Map<String, dynamic>)['genre']??'';
      setState(() {
        username1 = newValue;
        email1 = newValue0;
        location1 = newValue1;
        imageurl = newValue2;
        website1 = newValue3;
        motto1 = newValue4;
        genre1 = newValue5;
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
                            child: CustomAvatar(radius: radius, imageurl: imageurl,)
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10 ,),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SizedBox(
                              width:MediaQuery.of(context).size.width*0.68,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      height:MediaQuery.of(context).size.height*0.054,
                                      width:MediaQuery.of(context).size.width*0.65,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width:MediaQuery.of(context).size.width*0.3,
                                            child: actionss(context),
                                          ),
                                          SizedBox(
                                              width:MediaQuery.of(context).size.width*0.28,
                                              child: actions(context)),
                                        ],
                                      )),
                                  SizedBox(
                                    width:MediaQuery.of(context).size.width*0.66,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            const Text('Posts',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                                            Postno(userId: userId)
                                          ],
                                        ),
                                        InkWell(
                                            onTap: () {
                                              Navigator.push(context,
                                                MaterialPageRoute(builder: (
                                                    context) =>  Fans(userId: userId,),
                                                ),
                                              );
                                            },
                                            child: Column(
                                              children: [
                                                const Text('Fans',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                                                ItemCount(collection: "Clubs",subCollection: 'fans',docId: userId,)
                                              ],
                                            )),
                                        Column(
                                          children: [
                                            const Text('Matches Played',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                                            Matchesstreamedno(userId: userId,)
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width:MediaQuery.of(context).size.width*0.63,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Text('Genre',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
                                            Text(genre1),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Text('Location',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
                                            location1.isEmpty?const Text('-',style: TextStyle(fontSize: 20),): Text(location1),
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
                        width:MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children:  [
                                motto1.isNotEmpty? Row(
                                  children: [
                                    const Text('Motto: ',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,),),
                                    Text(motto1),
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
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );}else{
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
                      SizedBox(
                        width:MediaQuery.of(context).size.width*0.28,
                        height:MediaQuery.of(context).size.height*0.126,
                        child: Padding(
                            padding: const EdgeInsets.only(left:4,top: 2),
                            child: CustomAvatar(radius: radius, imageurl: imageurl,)
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10 ,),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width:MediaQuery.of(context).size.width*0.68,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    width:MediaQuery.of(context).size.width*0.68,
                                    height:MediaQuery.of(context).size.height*0.045,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width:MediaQuery.of(context).size.width*0.31,
                                          child: actionss(context),
                                        ),
                                        SizedBox(
                                            width:MediaQuery.of(context).size.width*0.32,
                                            child: actions(context)),
                                      ],
                                    )),
                                SizedBox(
                                  width:MediaQuery.of(context).size.width*0.65,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          const Text('Posts',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                                          Postno(userId: userId)
                                        ],
                                      ),
                                      InkWell(
                                          onTap: () {
                                            Navigator.push(context,
                                              MaterialPageRoute(builder: (
                                                  context) =>  Fans(userId: userId,),
                                              ),
                                            );
                                          },
                                          child: Column(
                                            children: [
                                              const Text('Fans',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                                              ItemCount(collection: "Clubs",subCollection: 'fans',docId: userId,)
                                            ],
                                          )),
                                      Column(
                                        children: [
                                          const Text('Matches Played',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                                          Matchesstreamedno(userId: userId,)
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width:MediaQuery.of(context).size.width*0.63,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const Text('Genre',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
                                          Text(genre1),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const Text('Location',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
                                          location1.isEmpty?const Text('-',style: TextStyle(fontSize: 20),): Text(location1),
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
                      width:MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child:   Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children:  [
                                motto1.isNotEmpty? Row(
                                  children: [
                                    const Text('Motto: ',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,),),
                                    Text(motto1),
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }

  Widget actions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                MaterialPageRoute(builder: (context)=>  Clubteamtable(userId: userId),
                ),
              );
            },
            child: const Text("Club's Team", style: TextStyle(color: Colors.black)),
          ),
        ),
      ],
    );
  }
  Widget actionss(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                minimumSize: const Size(0, 30),
                side: const BorderSide(
                  color: Colors.grey,
                )),
            onPressed: () { Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  EditprofileC(user: Person(
                    name: username1,
                    motto: motto1,
                    userId: userId,
                    url: imageurl,
                    collectionName: "Club"
                ),),
              ),
            );},
            child: const Text("Edit Profile", style: TextStyle(color: Colors.black)),
          ),
        ),

      ],
    );
  }}
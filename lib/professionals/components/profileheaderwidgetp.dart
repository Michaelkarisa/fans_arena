import 'package:fans_arena/fans/screens/postsnumber.dart';
import 'package:fans_arena/professionals/components/eventsstreamed.dart';
import 'package:fans_arena/professionals/components/profileHeaderWidgetprofeviewer.dart';
import 'package:fans_arena/professionals/screens/editprofilep.dart';
import 'package:fans_arena/professionals/screens/fans1.dart';
import 'package:fans_arena/professionals/screens/moreinfo.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../fans/screens/professional.dart';
import '../../reusablewidgets/cirularavatar.dart';
class ProfileHeaderWidgetprofe extends StatefulWidget {
  const ProfileHeaderWidgetprofe({super.key});

  @override
  State<ProfileHeaderWidgetprofe> createState() => _ProfileHeaderWidgetprofeState();
}

class _ProfileHeaderWidgetprofeState extends State<ProfileHeaderWidgetprofe> {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String username1 = '';
  String profession1 = '';
  String location1 = '';
  String quote1 = '';
  String website1 = '';
  String imageurl = '';
  String email1 = '';
  String userId = '';
  String linkedaccount = '';
  late Stream<DocumentSnapshot> _stream1;
  Future<void> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid; // Assign the user ID to the userId variable
      });
    }
  }
  void userData() {
    _stream1 = firestore.collection('Professionals').doc(FirebaseAuth.instance.currentUser!.uid).snapshots();
    _stream1.listen((snapshot) {

      final newValue = (snapshot.data() as Map<String, dynamic>)['Stagename']??'';
      final newValue4 = (snapshot.data() as Map<String, dynamic>)['profession']??'';
      final newValue5 = (snapshot.data() as Map<String, dynamic>)['quote']??'';
       final newValue0 = (snapshot.data() as Map<String, dynamic>)['email']??'';
      final  newValue1 = (snapshot.data() as Map<String, dynamic>)['Location']??'';
       final newValue2 = (snapshot.data() as Map<String, dynamic>)['profileimage']??'';
      final newValue3 = (snapshot.data() as Map<String, dynamic>)['website']??'';
      final newValue6 = (snapshot.data() as Map<String, dynamic>)['linkedaccount']??'';
      setState(() {
        username1 = newValue;
        email1 = newValue0;
        location1 = newValue1;
        imageurl = newValue2;
        website1 = newValue3;
        profession1 = newValue4;
        quote1 = newValue5;
        linkedaccount=newValue6;
      });
    } );
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
double radius=55;
  @override
  Widget build(BuildContext context) {
    return
        LayoutBuilder(
        builder: (context, constraints) {
      if (MediaQuery
          .of(context)
          .size
          .height < 650) {
    return    Padding(
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
                  child:CustomAvatar(radius: radius, imageurl: imageurl,)
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width:MediaQuery.of(context).size.width*0.68,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width*0.6,
                            height:MediaQuery.of(context).size.height*0.054,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox( width:MediaQuery.of(context).size.width*0.3,
                                  child: actionss(context),
                                ),
                                SizedBox( width:MediaQuery.of(context).size.width*0.3,
                                  child: actionss7(context),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width*0.64,
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
                                            context) =>  Fans1(userId: userId,),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        const Text('Fans',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                                        ItemCount(collection: "Professionals",subCollection: 'fans',docId: userId,)
                                      ],
                                    )),
                                Column(
                                  children: [
                                    const Text('Events Streamed',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                                    Eventstreamedno(userId: userId,)
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            width: MediaQuery.of(context).size.width*0.58,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text('Profession',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
                                    profession1.isEmpty?const Text('-',style: TextStyle(fontSize: 20),): Text(profession1),
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
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    linkedaccount.isNotEmpty?Linkedacc(userId: linkedaccount,):const SizedBox.shrink(),
                    Column(
                      children: [
                        quote1.isNotEmpty? Row(
                          children: [
                            const Text('Quote: ',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,),),
                            Text(quote1),
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
    );

    }else{
        return    SizedBox(
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
                    padding: const EdgeInsets.only(left:4,top: 3 ),
                    child: SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.28,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.126,
                      child: CustomAvatar(radius: radius, imageurl: imageurl,)
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width:MediaQuery.of(context).size.width*0.68,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width*0.67,
                              height:MediaQuery.of(context).size.height*0.044,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox( width:MediaQuery.of(context).size.width*0.31,
                                    child: actionss(context),
                                  ),
                                  SizedBox( width:MediaQuery.of(context).size.width*0.28,
                                    child: actionss7(context),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width*0.65,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      const Text('Posts',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                                      Postno(userId:userId)
                                    ],
                                  ),
                                  InkWell(
                                      onTap: () {
                                        Navigator.push(context,
                                          MaterialPageRoute(builder: (
                                              context) =>  Fans1(userId: userId,),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          const Text('Fans',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                                          ItemCount(collection: "Professionals",subCollection: 'fans',docId: userId,)
                                        ],
                                      )),
                                  Column(
                                    children: [
                                      const Text('Events Streamed',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                                      Eventstreamedno(userId: userId,)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width*0.58,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text('Profession',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
                                      profession1.isEmpty?const Text('-',style: TextStyle(fontSize: 20),): Text(profession1),
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
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        linkedaccount.isNotEmpty?Linkedacc(userId: linkedaccount,):const SizedBox.shrink(),
                        Column(
                          children: [
                            quote1.isNotEmpty? Row(
                              children: [
                                const Text('Quote: ',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,),),
                                Text(quote1),
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
              builder: (context) => const EditprofileP(),
            ),
          );},
          child: const Text("Edit profile", style: TextStyle(color: Colors.black)),
        ),
      ),

    ],
  );
}
  Widget actionss7(BuildContext context) {
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
                builder: (context) => const MoreInfo(),
              ),
            );},
            child: const Text("More info", style: TextStyle(color: Colors.black)),
          ),
        ),

      ],
    );
  }
}
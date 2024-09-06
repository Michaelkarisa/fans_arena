import 'package:fans_arena/fans/screens/chatting.dart';
import 'package:fans_arena/fans/screens/messages.dart';
import 'package:fans_arena/fans/screens/postsnumber.dart';
import 'package:fans_arena/professionals/components/eventsstreamed.dart';
import 'package:fans_arena/professionals/screens/fans1.dart';
import 'package:fans_arena/professionals/screens/moreinfo1.dart';
import 'package:fans_arena/reusablewidgets/cirularavatar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../fans/data/newsfeedmodel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../fans/screens/professional.dart';
class ProfileHeaderWidgetprofev extends StatefulWidget {
  String userId;
  ProfileHeaderWidgetprofev({super.key, required this.userId});

  @override
  State<ProfileHeaderWidgetprofev> createState() => _ProfileHeaderWidgetprofevState();
}

class _ProfileHeaderWidgetprofevState extends State<ProfileHeaderWidgetprofev> {
  String username1 = '';
  String profession1 = '';
  String location1 = '';
  String quote1 = '';
  String website1 = '';
  String imageurl = '';
  String email1 = '';
  String linkedaccount='';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  void retrieveUserData() async {
    try {
      QuerySnapshot querySnapshotC = await firestore
          .collection('Professionals')
          .where('profeid', isEqualTo: widget.userId)
          .limit(1)
          .get();

      if (querySnapshotC.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotC.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          username1 = data['Stagename']??'';
          email1 = data['email']??'';
          location1 = data['Location']??'';
          imageurl = data['profileimage']??'';
          website1 = data['website']??'';
          profession1 = data['profession']??'';
          quote1 = data['quote']??'';
          linkedaccount=data['linkedaccount']??'';
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

  @override
  void dispose() {

    super.dispose();
  }
  String userId='';
  String collectionName='';
  bool isLoading=true;
  Future<void> _getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      collectionName = prefs.getString('cname')?? '';
      userId=FirebaseAuth.instance.currentUser!.uid;
      isLoading=false;
    });
  }


  double radius=55;
  @override
  Widget build(BuildContext context) {
    return  LayoutBuilder(
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
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.23,
                            height: MediaQuery
                                .of(context)
                                .size
                                .height * 0.126,
                            child:InkWell(
                                onTap: (){
                                  Navigator.push(context,MaterialPageRoute(builder: (context)=>ViewFile(urls:[{'url':'','url1':imageurl}])));
                                },
                                child: CustomAvatar(radius: radius, imageurl: imageurl,))
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
                                    height:MediaQuery.of(context).size.height*0.05,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox( width:MediaQuery.of(context).size.width*0.3,
                                          child: LayoutBuilder(builder: (context, BuildContext) {
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
                                              return actionss(context);
                                            } else if (collectionName == 'Professional') {
                                              return actionss(context);
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
                                        SizedBox( width:MediaQuery.of(context).size.width*0.3,
                                          child: actionss7(context),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.64,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            const Text('Posts',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                                            Postno(userId: widget.userId)
                                          ],
                                        ),
                                        InkWell(
                                            onTap: () {
                                              Navigator.push(context,
                                                MaterialPageRoute(builder: (
                                                    context) =>  Fans1(userId: widget.userId,),
                                                ),
                                              );
                                            },
                                            child: Column(
                                              children: [
                                                const Text('Fans',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                                                ItemCount(collection: "Professionals",subCollection: 'fans',docId: widget.userId,)
                                              ],
                                            )),
                                        Column(
                                          children: [
                                            const Text('Events Streamed',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                                            Eventstreamedno(userId: widget.userId,)
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.58,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Profession',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
                              profession1.isEmpty?const Text('-',style: TextStyle(fontSize: 20),): Text(profession1),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Location',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),

                              location1.isEmpty?const Text('-',style: TextStyle(fontSize: 20),): Text(location1),
                            ],
                          ),
                        ],
                      ),
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
          }else {
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
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.28,
                            height: MediaQuery
                                .of(context)
                                .size
                                .height * 0.126,
                            child:InkWell(
                                onTap: (){
                                  Navigator.push(context,MaterialPageRoute(builder: (context)=>ViewFile(urls:[{'url':'','url1':imageurl}])));
                                },
                                child: CustomAvatar(radius: radius, imageurl: imageurl,))
                        ),//
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
                                  height:MediaQuery.of(context).size.height*0.045,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox( width:MediaQuery.of(context).size.width*0.31,
                                        child: LayoutBuilder(builder: (context, BuildContext) {
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
                                            return actionss(context);
                                          } else if (collectionName == 'Professional') {
                                            return actionss(context);
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
                                      SizedBox( width:MediaQuery.of(context).size.width*0.28,
                                        child: actionss7(context),
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
                                          const Text('Posts',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                                          Postno(userId: widget.userId)
                                        ],
                                      ),
                                      InkWell(
                                          onTap: () {
                                            Navigator.push(context,
                                              MaterialPageRoute(builder: (
                                                  context) =>  Fans1(userId: widget.userId,),
                                              ),
                                            );
                                          },
                                          child: Column(
                                            children: [
                                              const Text('Fans',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                                              ItemCount(collection: "Professionals",subCollection: 'fans',docId: widget.userId,)
                                            ],
                                          )),
                                      Column(
                                        children: [
                                          const Text('Events Streamed',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                                          Eventstreamedno(userId: widget.userId,)
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
            onPressed: () { Navigator.push(context,
              MaterialPageRoute(builder: (context)=> Chatting(user:Person(
                  userId: widget.userId,
                  name: username1,
                  url: imageurl,
                  collectionName:'Professional'
              ), chatId: '',),
              ),
            );},
            child: const Text("Message", style: TextStyle(color: Colors.black)),
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
            onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) =>  MoreInfo1(userId: widget.userId),
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

class Linkedacc extends StatefulWidget {
  String userId;
  Linkedacc({super.key, required this.userId});

  @override
  State<Linkedacc> createState() => _LinkedaccState();
}

class _LinkedaccState extends State<Linkedacc> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String imageurl='';
  double radius=15;
  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      height: MediaQuery.of(context).size.height * 0.035,
      child: Row(
        children: [
          const Text('Linked Account ',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,),),
          CustomUsernameD0Avatar(userId: widget.userId, click: true,style: const TextStyle(color: Colors.black,fontSize: 13), radius: radius, maxsize:160, height: 20, width: 175),
        ],
      ),
    );
  }
}

import 'package:fans_arena/clubs/components/fans.dart';
import 'package:fans_arena/clubs/components/matchesstreamed.dart';
import 'package:fans_arena/clubs/screens/clubsteamviewer.dart';
import 'package:fans_arena/clubs/screens/moreinfoclubs.dart';
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:fans_arena/fans/screens/postsnumber.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../fans/screens/chatting.dart';
import '../../fans/screens/professional.dart';
import '../../reusablewidgets/cirularavatar.dart';
class ProfileHeaderWidgetClubsv extends StatefulWidget {
  String userId;
  ProfileHeaderWidgetClubsv({super.key, required this.userId});

  @override
  State<ProfileHeaderWidgetClubsv> createState() => _ProfileHeaderWidgetClubsvState();
}

class _ProfileHeaderWidgetClubsvState extends State<ProfileHeaderWidgetClubsv> {
  String username1 = '';
  String genre1 = '';
  String motto1 = '';
  String location1 = '';
  String website1 = '';
  String imageurl = '';
  String email1 = '';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  void retrieveUserData() async {
    try {
      QuerySnapshot querySnapshotC = await firestore
          .collection('Clubs')
          .where('Clubid', isEqualTo: widget.userId)
          .limit(1)
          .get();

      if (querySnapshotC.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotC.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          username1 = data['Clubname']??'';
          email1 = data['email']??'';
          genre1 = data['genre']??'';
          motto1 = data['Motto']??'';
          location1 = data['Location']??'';
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
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
  @override
  void initState() {
    super.initState();
    retrieveUserData();
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
              padding: const EdgeInsets.only(top: 6, left: 8),
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
                            child: InkWell(
                                onTap: (){
                                  Navigator.push(context,MaterialPageRoute(builder: (context)=>ViewFile(urls:[{'url':'','url1':imageurl}])));
                                },
                                child: CustomAvatar(radius: radius, imageurl: imageurl,))
                        ),
                        //
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SizedBox(
                              width:MediaQuery.of(context).size.width*0.7,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      height:MediaQuery.of(context).size.height*0.055,
                                      width:MediaQuery.of(context).size.width*0.68,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                              width:MediaQuery.of(context).size.width*0.32,
                                              child: actions(context)),

                                          SizedBox(width:MediaQuery.of(context).size.width*0.28,
                                            child: actionss(context),
                                          ),

                                        ],
                                      )),
                                  SizedBox(
                                    width:MediaQuery.of(context).size.width*0.7,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                    context) =>  Fans(userId: widget.userId,),
                                                ),
                                              );
                                            },
                                            child: Column(
                                              children: [
                                                const Text('Fans',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                                                ItemCount(collection: "Clubs",subCollection: 'fans',docId: widget.userId,)
                                              ],
                                            )),
                                        Column(
                                          children: [
                                            const Text('Matches Played',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                                            Matchesstreamedno(userId: widget.userId,)
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width:MediaQuery.of(context).size.width*0.66,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children:  [
                                            const Text('Genre',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
                                            Text(genre1),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children:  [
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
                              children: [
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
              ),);
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
                      SizedBox(
                        width:MediaQuery.of(context).size.width*0.263,
                        height:MediaQuery.of(context).size.height*0.126,
                        child: Padding(
                            padding: const EdgeInsets.only(left:4,top: 3),
                            child:InkWell(
                                onTap: (){
                                  Navigator.push(context,MaterialPageRoute(builder: (context)=>ViewFile(urls:[{'url':'','url1':imageurl}])));
                                },
                                child: CustomAvatar(radius: radius, imageurl: imageurl,))
                        ),
                      ),
                      //
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width:MediaQuery.of(context).size.width*0.7,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    width:MediaQuery.of(context).size.width*0.67,
                                    height:MediaQuery.of(context).size.height*0.045,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                            width:MediaQuery.of(context).size.width*0.32,
                                            child: actions(context)),

                                        SizedBox(width:MediaQuery.of(context).size.width*0.29,
                                          child: actionss(context),
                                        ),

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
                                          Postno(userId: widget.userId)
                                        ],
                                      ),
                                      InkWell(
                                          onTap: () {
                                            Navigator.push(context,
                                              MaterialPageRoute(builder: (
                                                  context) =>  Fans(userId: widget.userId,),
                                              ),
                                            );
                                          },
                                          child: Column(
                                            children: [
                                              const Text('Fans',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                                              ItemCount(collection: "Clubs",subCollection: 'fans',docId: widget.userId,)
                                            ],
                                          )),
                                      Column(
                                        children: [
                                          const Text('Matches Played',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                                          Matchesstreamedno(userId: widget.userId,)
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width:MediaQuery.of(context).size.width*0.6,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children:  [
                                          const Text('Genre',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
                                          Text(genre1),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children:  [
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
                MaterialPageRoute(builder: (context)=>  Clubsteamviwer(userId: widget.userId,name:username1,image: imageurl,),
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
            onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context)=>  MoreInfoClubs(user: Person(
                    name: username1,
                    url: imageurl,
                    collectionName:"Club",
                    userId: widget.userId),),
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
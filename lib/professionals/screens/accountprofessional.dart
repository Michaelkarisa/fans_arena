import 'package:fans_arena/professionals/components/professionalspost.dart';
import 'package:fans_arena/professionals/components/professionalsvideo.dart';
import 'package:fans_arena/professionals/components/profileheaderwidgetp.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../appid.dart';
import '../../clubs/screens/settingsclub.dart';
import '../../fans/data/newsfeedmodel.dart';
import '../../fans/screens/accountpage.dart';
import '../../fans/screens/homescreen.dart';
class AccountprofileP extends StatefulWidget {
  const AccountprofileP({super.key});
  @override
  State<AccountprofileP> createState() => _AccountprofilePState();
}
class _AccountprofilePState extends State<AccountprofileP> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String email='';
ScrollController controller=ScrollController();
  late DateTime  _startTime;
  @override
  void initState() {
    super.initState();
    setState(() {
      user=Person(name:username, url: profileimage, collectionName: collectionNamefor, userId: FirebaseAuth.instance.currentUser!.uid);
    });
    _startTime=DateTime.now();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        setState(() {
          value=value+1;
        });
      }
    });
  }

  late Person user;
  int value=0;
  @override
  void dispose(){
    controller.dispose();
    Engagement().engagement('ProfessionalAccountProfile',_startTime,'');
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return
      SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
        if (MediaQuery
            .of(context)
            .size
            .height < 700) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              centerTitle: false,
              title: Container(
                constraints: const BoxConstraints(
                  minWidth: 10.0,
                  maxWidth: 150.0,
                ),
                color: Colors.white,
                height: 38.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        color: Colors.white,
                        constraints: const BoxConstraints(
                          minWidth: 10.0,
                          maxWidth: 120.0,
                        ),
                        child: Text(
                          username,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    // Adjust the spacing between the OverflowBox and Aligned container
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child:  Container(
                          width: MediaQuery.of(context).size.width * 0.045,
                          height: MediaQuery.of(context).size.height * 0.021,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(child: Text('P',style: TextStyle(color: Colors.white,fontSize: 15),)),),
                      ),
                    ),
                  ],
                ),
              ),
              elevation: 1,
              actions: [
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.2675,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.settings,
                          size: MediaQuery.sizeOf(context).height*0.038,
                          color: Colors.black,
                        ),
                        onPressed: (){
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context)=> SettingsClub(name: username,),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                )

              ],
            ),
            body:DefaultTabController(
              length: 2,
              child: NestedScrollView(
                controller: controller,
                headerSliverBuilder: (context, _) {
                  return [
                    const SliverToBoxAdapter(child: ProfileHeaderWidgetprofe(),
                    ),
                    SliverPersistentHeader(
                        floating: true,
                        pinned: true,
                        delegate: MyDelegate(
                          TabBar(
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.grey[400],
                            indicatorWeight: 1,
                            indicatorColor: Colors.black,
                            tabs: [
                              Tab(
                                icon: Icon(
                                  Icons.grid_on_sharp,
                                  color: Colors.black,
                                  size: MediaQuery.sizeOf(context).height*0.036,
                                ),
                              ),
                              Tab(
                                  icon: Icon(Icons.live_tv, size: MediaQuery.sizeOf(context).height*0.036,color: Colors.black,)
                              ),
                            ],
                          ),
                        ))
                  ];
                },
                body: TabBarView(
                  children: [
                    Professionalspost(user:user,controller: controller,),
                    Professionalsvideos(user:user,controller: controller,),
                  ],
                ),
              ),
            ),
          );
        }else{
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              centerTitle: false,
              title: Container(
                constraints: const BoxConstraints(
                  minWidth: 10.0,
                  maxWidth: 240.0,
                ),
                color: Colors.white,
                height: 38.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        color: Colors.white,
                        constraints: const BoxConstraints(
                          minWidth: 10.0,
                          maxWidth: 200.0,
                        ),
                        child: Text(
                          username,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    // Adjust the spacing between the OverflowBox and Aligned container
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child:  Container(
                          width: MediaQuery.of(context).size.width * 0.045,
                          height: MediaQuery.of(context).size.height * 0.021,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(child: Text('P',style: TextStyle(color: Colors.white,fontSize: 15),)),),
                      ),
                    ),
                  ],
                ),
              ),
              elevation: 1,
              actions: [
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.2875,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.black,
                        ),
                        onPressed: (){
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context)=> SettingsClub(name: username,),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                )

              ],
            ),
            body:DefaultTabController(
              length: 2,
              child: NestedScrollView(
                controller: controller,
                headerSliverBuilder: (context, _) {
                  return [

                    const SliverToBoxAdapter(child: ProfileHeaderWidgetprofe(),
                    ),
                    SliverPersistentHeader(
                        floating: true,
                        pinned: true,
                        delegate: MyDelegate(
                          TabBar(
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.grey[400],
                            indicatorWeight: 1,
                            indicatorColor: Colors.black,
                            tabs: [
                              Tab(
                                icon: Icon(
                                  Icons.grid_on_sharp,
                                  color: Colors.black,
                                  size: MediaQuery.sizeOf(context).height*0.036,
                                ),
                              ),
                              Tab(
                                  icon: Icon(Icons.live_tv, size: MediaQuery.sizeOf(context).height*0.036,color: Colors.black,)
                              ),
                            ],
                          ),
                        ))
                  ];
                },
                body: TabBarView(
                  children: [
                    Professionalspost(user:user,controller: controller,),
                    Professionalsvideos(user:user,controller: controller,),
                  ],
                ),
              ),
            ),
          );
        }
          }),
      );
  }
}


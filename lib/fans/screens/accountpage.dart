import 'package:fans_arena/appid.dart';
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:fans_arena/fans/widgets/profileheaderwidgets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../clubs/screens/settingsclub.dart';
import '../../professionals/components/professionalspost.dart';
import '../../professionals/components/professionalsvideo.dart';
import 'homescreen.dart';
class Accountprofile extends StatefulWidget {
  const Accountprofile({super.key});
  @override
  State<Accountprofile> createState() => _AccountprofileState();
}
class _AccountprofileState extends State<Accountprofile> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late DateTime  _startTime;
  int value=0;
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
  ScrollController controller=ScrollController();
@override
void dispose(){
  controller.dispose();
  Engagement().engagement('FansAccountProfile',_startTime,'');
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 1,
          backgroundColor: Colors.white,
          title: Text(
            ' $username',
            style:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>  SettingsClub(name: username,),
                  ),
                );
              },
            )
          ],
        ),
        body: DefaultTabController(
          length: 2,
          child: NestedScrollView(
            controller: controller,
            headerSliverBuilder: (context, _) {
              return [
                const SliverToBoxAdapter(child: ProfileHeaderWidget(),
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
                Professionalspost(user: user,controller: controller,),
                Professionalsvideos(user:user,controller: controller,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class MyDelegate extends SliverPersistentHeaderDelegate{
  MyDelegate(this.tabBar);
  final TabBar tabBar;
  @override
  Widget build(BuildContext context, double shrinkOffset,bool overlapsContent){
    return Container(
      color: Colors.white,
        child: tabBar);
  }
  @override
  double get maxExtent=> tabBar.preferredSize.height;

  @override
  double get minExtent=> tabBar.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate){
    return true;
  }
}
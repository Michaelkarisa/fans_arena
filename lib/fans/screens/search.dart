import 'package:fans_arena/clubs/screens/accountclubviewer.dart';
import 'package:fans_arena/fans/data/usermodel.dart';
import 'package:fans_arena/fans/screens/accountfanviewer.dart';
import 'package:fans_arena/joint/components/colors.dart';
import 'package:fans_arena/professionals/screens/accountprofilepviewer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../reusablewidgets/cirularavatar.dart';
import '../bloc/accountchecker11.dart';
import '../bloc/usernamedisplay.dart';
import '../data/newsfeedmodel.dart';
import 'homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search>with SingleTickerProviderStateMixin,AutomaticKeepAliveClientMixin  {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController error = TextEditingController();
  final TextEditingController error1 = TextEditingController();
  final TextEditingController error2 = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late TabController _tabController;
  bool isselected = false;
  bool _showCloseIcon = false;
  @override
  void initState() {
    super.initState();
    _startTime=DateTime.now();
    setState(() {});
    _tabController = TabController(length: 3, vsync: this, initialIndex: index);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    setState(() {
      index = _tabController.index;
    });
  }
  late DateTime _startTime;

  @override
  void dispose(){
    Engagement().engagement('Search',_startTime,'');
    super.dispose();
  }
  int index=0;
  String y='';
SearchService search=SearchService();
  SearchService5 search1=SearchService5();
  SearchService4 search2=SearchService4();
  String _searchQuery = '';
  double radius=23;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
         title: Center(
           child: Padding(
             padding: const EdgeInsets.only(top: 8,bottom: 8,right: 30),
             child: SizedBox(
               height: 39,
               width:MediaQuery.of(context).size.width * 0.75,
               child: TextFormField(
                 scrollPadding: const EdgeInsets.only(left: 10),
                 textAlign: TextAlign.left,
                 textAlignVertical: TextAlignVertical.center,
                 cursorColor: Colors.black,
                 controller: _controller,
                 textInputAction: TextInputAction.search,
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
                         _searchQuery=y;
                         _controller.clear();
                         _showCloseIcon = false;
                       });
                     },
                   ) : null,
                   hintText: 'Search',
                 ),
               ),
             ),
           ),
         ),
         automaticallyImplyLeading: false,
          backgroundColor: Appbare,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.044),
            child: Material(
              color: Colors.white,
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
                  Selected(label: 'Clubs', isActive: index == 2,fsize: 15,),
                ],
              ),
            ),),
        ),
        body: TabBarView(
            controller: _tabController,
      children: [
            StreamBuilder<Set<UserModelF>>(
        stream: search.getUser(_searchQuery),
        builder: (context, snapshot) {
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }else if(snapshot.hasError){
            return Center(child: Text("${snapshot.error}"),);
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Results'));
          }else{
            Set<UserModelF> userList1 = snapshot.data!;
          List<UserModelF> userList =List.from(userList1);
          userList.removeWhere((element) => element.userId==FirebaseAuth.instance.currentUser!.uid);
          return ListView.builder(
            itemCount: userList.length+1,
            itemBuilder: (context, index) {
              if(index==userList.length){
                return const SizedBox(height: 70,);
              }
              UserModelF user = userList[index];
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
                                    collectionName:"Fan",
                                  timestamp: user.timestamp
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
                    trailing: SizedBox(
                        width: 100,
                        child: Accountchecker11(user:Person(
                            name: user.username,
                            userId:user.userId,
                            url: user.url,
                            collectionName:"Fan",
                            timestamp: user.timestamp
                        ),),)
                ),
              );
            },
          );
        }},
            ),
        StreamBuilder<Set<UserModelP>>(
          stream: search1.getUser(_searchQuery),
          builder: (context, snapshot) {
            if(snapshot.connectionState==ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator());
            }else if(snapshot.hasError){
              return Center(child: Text("${snapshot.error}"),);
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No Results'));
            }else{
              Set<UserModelP> userList1 = snapshot.data!;
            List<UserModelP> userList =List.from(userList1);
            userList.removeWhere((element) => element.userId==FirebaseAuth.instance.currentUser!.uid);
            return ListView.builder(
        itemCount: userList.length+1,
        itemBuilder: (context, index) {
          if(index==userList.length){
            return const SizedBox(height: 70,);
          }
          UserModelP user = userList[index];
          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: ListTile(
                onTap: () {
                  Navigator.push(context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AccountprofilePviewer(user:Person(
                                name: user.stagename,
                                userId:user.userId,
                                url: user.url,
                                collectionName:"Professional",
                                timestamp: user.timestamp
                            ),index: 0,)
                    ),
                  );
                },
                leading: CustomAvatar(radius: radius, imageurl: user.url),
                title:   UsernameDO(
                  username:user.stagename,
                  collectionName:'Professional',
                  width: 160,
                  height: 38,
                  maxSize: 140,
                ),
                trailing: SizedBox(
                    width: 100,
                    child: Accountchecker11(user:Person(
                        name: user.stagename,
                        userId:user.userId,
                        url: user.url,
                        collectionName:"Professional",
                        timestamp: user.timestamp
                    ),),)
            ),
          );
        },
            );
          }},
        ),
        StreamBuilder<Set<UserModelC>>(
          stream: search2.getUser(_searchQuery),
          builder: (context, snapshot) {
             if(snapshot.connectionState==ConnectionState.waiting){
               return const Center(child: CircularProgressIndicator());
             }else if(snapshot.hasError){
              return Center(child: Text("${snapshot.error}"),);
             } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
               return const Center(child: Text('No Results'));
            }else{
               Set<UserModelC> userList1 = snapshot.data!;
            List<UserModelC> userList =List.from(userList1);
            userList.removeWhere((element) => element.userId==FirebaseAuth.instance.currentUser!.uid);
            return ListView.builder(
        itemCount: userList.length+1,
        itemBuilder: (context, index) {
          if(index==userList.length){
            return const SizedBox(height: 70,);
          }
          UserModelC user = userList[index];
          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: ListTile(
                onTap: () {
                  Navigator.push(context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AccountclubViewer(user:Person(
                                name: user.clubname,
                                userId:user.userId,
                                url: user.url,
                                collectionName:"Club",
                                timestamp: user.timestamp
                            ),index: 0,)
                    ),
                  );
                },
                leading: CustomAvatar(radius: radius, imageurl:user.url),
                title:   UsernameDO(
                  username:user.clubname,
                  collectionName:'Club',
                  width: 160,
                  height: 38,
                  maxSize: 140,
                ),
                trailing: SizedBox(
                    width: 100,
                    child: Accountchecker11(user:Person(
                        name: user.clubname,
                        userId:user.userId,
                        url: user.url,
                        collectionName:"Club",
                        timestamp: user.timestamp
                    ),),)
            ),
          );
        },
            );
          }},
        ),
      ]),
      ),
    );
  }
  @override
  bool get wantKeepAlive => true;
}
class Selected extends StatefulWidget {
  final String label;
  final double fsize;
  final bool isActive; // New parameter
  const Selected({
    super.key,
    required this.label,
    this.isActive = false,
    required this.fsize,
  });

  @override
  _SelectedState createState() => _SelectedState();
}

class _SelectedState extends State<Selected> {
  @override
  void initState() {
    super.initState();
    setState(() {
      isActive=widget.isActive;
      label=widget.label;
      fsize=widget.fsize;
    });
  }
  @override
  void didUpdateWidget(covariant Selected oldWidget) {
    if (oldWidget.isActive != widget.isActive||oldWidget.label != widget.label) {
      setState(() {
        isActive=widget.isActive;
        label=widget.label;
        fsize=widget.fsize;
      });
    }
    super.didUpdateWidget(oldWidget);
  }
  bool isActive=false;
  String label="";
  double fsize=0.0;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      width: MediaQuery.of(context).size.width * 0.34,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.grey[500],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black,
              fontSize: fsize,
            ),
          ),
        ),
      ),
    );
  }
}

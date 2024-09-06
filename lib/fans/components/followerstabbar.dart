import 'package:fans_arena/fans/components/Professionalslist.dart';
import 'package:fans_arena/fans/components/clublist2.dart';
import 'package:fans_arena/fans/components/followerslist.dart';
import 'package:fans_arena/fans/components/followinglist.dart';
import 'package:fans_arena/joint/components/colors.dart';
import 'package:flutter/material.dart';
import '../../clubs/screens/accountclubviewer.dart';
import '../../professionals/screens/accountprofilepviewer.dart';
import '../../reusablewidgets/cirularavatar.dart';
import '../bloc/accountchecker11.dart';
import '../bloc/usernamedisplay.dart';
import '../data/newsfeedmodel.dart';
import '../data/usermodel.dart';
import '../screens/accountfanviewer.dart';
class Followerstab extends StatefulWidget {
  String userId;
  int index;
  Followerstab({super.key, required this.userId,required this.index});

  @override
  State<Followerstab> createState() => _FollowerstabState();
}
late TabController _tabController;
class _FollowerstabState extends State<Followerstab> with SingleTickerProviderStateMixin,AutomaticKeepAliveClientMixin  {
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: widget.index);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  final TextEditingController _controller = TextEditingController();
  bool _showCloseIcon = false;
  String y='';
  String _searchQuery = '';
  double radius=23;
  SearchService0 search=SearchService0();
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,color: Colors.black,size: 35,),
            onPressed: () {
              Navigator.of(context).pop();
            },//to next page},
          ),
          title: Center(child: Text('', style: TextStyle(color: Textn),)),
          backgroundColor: Appbare,
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 10,bottom: 5,right: 30),
              child: SizedBox(
                height: 39,
                width:MediaQuery.of(context).size.width * 0.75,
                child: TextFormField(
                  scrollPadding: const EdgeInsets.only(left: 10),
                  textAlign: TextAlign.justify,
                  textAlignVertical: TextAlignVertical.center,
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  cursorColor: Colors.black,
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
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.03333),
            child: SizedBox(
              height: MediaQuery.of(context).size.height*0.03333,
              child: TabBar(
      labelPadding: const EdgeInsets.only(left: 0,right: 0),
                controller: _tabController,
                indicatorColor: Colors.black,
                tabs: const <Tab>[
                  Tab(child:Text('Followers', style: TextStyle(fontSize: 15,color: Colors.black),)
                  ),
                  Tab(child: Text('Following', style: TextStyle(fontSize: 15,color: Colors.black),),
      
                  ),
                  Tab(child: Text('Clubs', style: TextStyle(fontSize: 15,color: Colors.black),),
      
                  ),
                  Tab(child: Text('Professional', style: TextStyle(fontSize: 15,color: Colors.black),),
      
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _searchQuery.isEmpty? FollowersList(userId: widget.userId,):StreamBuilder<Set<UserModelF>>(
              stream: search.getUser(_searchQuery, widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No Results'));
                } else {
                  Set<UserModelF> userList = snapshot.data!;
                  return ListView.builder(
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
                      UserModelF user = userList.elementAt(index);
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Accountfanviewer(user:Person(
                                    name: user.username,
                                    userId:user.userId,
                                    url: user.url,
                                    collectionName:"Fan"
                                ), index: 0),
                              ),
                            );
                          },
                          leading: CustomAvatar(radius: radius, imageurl: user.url),
                          title: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 10.0,
                                maxWidth: 160.0,
                              ),
                              child: Text(
                                user.username,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          trailing: SizedBox(
                            width: 100,
                            child: Accountchecker11(user:Person(
                                name: user.username,
                                userId:user.userId,
                                url: user.url,
                                collectionName:"Fan"
                            ),),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),

            _searchQuery.isEmpty? Followinglist(userId: widget.userId, searchController:  _controller,): StreamBuilder<Set<UserModelF>>(
              stream: search.getUser(_searchQuery,widget.userId),
              builder: (context, snapshot) {
                Set<UserModelF> userList1 = snapshot.data!;
                if(snapshot.connectionState==ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator());
                }else if(snapshot.hasError){
                  return Center(child: Text("${snapshot.error}"),);
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No Results'));
                }else{
                  List<UserModelF> userList =List.from(userList1);
                  return ListView.builder(
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
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
                                            collectionName:"Fan"
                                        ),index: 0,)
                                ),
                              );
                            },
                            leading:CustomAvatar(radius: radius, imageurl:user.url),
                            title:  Padding(
                              padding: const EdgeInsets
                                  .only(left: 5),
                              child: Container(
                                constraints: const BoxConstraints(
                                  minWidth: 10.0,
                                  maxWidth: 160.0,
                                ),
                                color: Colors.transparent,
                                height: 38.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      color: Colors.transparent,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Container(
                                          constraints: const BoxConstraints(
                                            minWidth: 10.0,
                                            maxWidth: 140.0,
                                          ),
                                          child: Text(
                                            user.username,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Adjust the spacing between the OverflowBox and Aligned container
                                  ],
                                ),
                              ),
                            ),
                            trailing: SizedBox(
                              width: 100,
                              child: Accountchecker11(user:Person(
                                  name: user.username,
                                  userId:user.userId,
                                  url: user.url,
                                  collectionName:"Fan"
                              ),),)
                        ),
                      );
                    },
                  );
                }},
            ),
            _searchQuery.isEmpty? Clublist2(userId: widget.userId,):StreamBuilder<Set<UserModelC>>(
              stream: search.getUser2(_searchQuery,widget.userId),
              builder: (context, snapshot) {
                Set<UserModelC> userList1 = snapshot.data!;
                if(snapshot.connectionState==ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator());
                }else if(snapshot.hasError){
                  return Center(child: Text("${snapshot.error}"),);
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No Results'));
                }else{
                  List<UserModelC> userList =List.from(userList1);
                  return ListView.builder(
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
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
                                            collectionName:"Club"
                                        ),index: 0,)
                                ),
                              );
                            },
                            leading: CustomAvatar(radius: radius, imageurl: user.url),
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
                                  collectionName:"Club"
                              ),),)
                        ),
                      );
                    },
                  );
                }},
            ),
            _searchQuery.isEmpty? Professionallist(userId: widget.userId,): StreamBuilder<Set<UserModelP>>(
              stream: search.getUser1(_searchQuery,widget.userId),
              builder: (context, snapshot) {
                Set<UserModelP> userList1 = snapshot.data!;
                if(snapshot.connectionState==ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator());
                }else if(snapshot.hasError){
                  return Center(child: Text("${snapshot.error}"),);
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No Results'));
                }else{
                  List<UserModelP> userList =List.from(userList1);
                  return ListView.builder(
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
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
                                            collectionName:"Professional"
                                        ),index: 0,)
                                ),
                              );
                            },
                            leading: CustomAvatar(radius: radius, imageurl:user.url),
                            title:  UsernameDO(
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
                                  collectionName:"Professional"
                              ),),)
                        ),
                      );
                    },
                  );
                }},
            ),
      
          ],
        ),
      
      ),
    );
  }
  @override
  bool get wantKeepAlive => true;
}

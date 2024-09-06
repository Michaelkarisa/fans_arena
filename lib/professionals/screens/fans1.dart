import 'package:fans_arena/fans/bloc/accountchecker11.dart';
import 'package:fans_arena/fans/bloc/usernamedisplay.dart';
import 'package:flutter/material.dart';
import '../../fans/data/newsfeedmodel.dart';
import '../../fans/data/usermodel.dart';
import '../../fans/screens/accountfanviewer.dart';
import '../../fans/screens/newsfeed.dart';
import '../../reusablewidgets/cirularavatar.dart';
class Fans1 extends StatefulWidget {
  String userId;
  Fans1({super.key, required this.userId});

  @override
  State<Fans1> createState() => _Fans1State();
}


class _Fans1State extends State<Fans1> {

  final TextEditingController _controller = TextEditingController();
  bool _showCloseIcon = false;
  String y='';
  String _searchQuery = '';
  double radius=23;
  SearchService0 search=SearchService0();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Fans',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
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
                cursorColor: Colors.black,
                textInputAction: TextInputAction.search,
                controller: _controller,
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
      ),
      body: _searchQuery.isEmpty? FutureBuilder<List<Universalitem>>(
          future: DataFetcher().getanydata(docId: widget.userId,collection: 'Professionals',subcollection: 'fans'),
          builder: (context, snapshot){
            if(snapshot.hasError){
              return Text('${snapshot.error}');
            }else if(snapshot.hasData){
              List<Universalitem>data=snapshot.data!;
              return  ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  // Customize how you display each like object here
                  // For example, you might display userId and timestamp
                  final user = data[index].item;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: ListTile(
                        leading: CustomAvatar( radius: radius, imageurl: user.url),
                        title:  InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Accountfanviewer(user:user, index: 0),
                              ),
                            );
                          },
                          child:  UsernameDO(
                            username:user.name,
                            collectionName:user.collectionName,
                            width: 160,
                            height: 38,
                            maxSize: 140,
                          ),
                        ),
                        trailing: SizedBox(
                            width: 100,
                            child: Accountchecker11(user:user,))
                    ),
                  );
                },
              );}else{
              return const LFShimmer();
            }
          }):StreamBuilder<Set<UserModelF>>(
        stream: search.getUser(_searchQuery, widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LFShimmer();
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
                              userId: user.userId,
                              name: user.username,
                              url: user.url,
                              collectionName:'Fan'
                          ), index: 0),
                        ),
                      );
                    },
                    leading: CustomAvatar(radius: radius, imageurl: user.url),
                    title: UsernameDO(
                      username:user.username,
                      collectionName:'Fan',
                      width: 160,
                      height: 38,
                      maxSize: 140,
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Accountchecker11(user:Person(
                          userId: user.userId,
                          name: user.username,
                          url: user.url,
                          collectionName:'Fan'
                      ),),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

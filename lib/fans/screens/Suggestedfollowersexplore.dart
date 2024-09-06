import 'package:fans_arena/fans/bloc/accountchecker11.dart';
import 'package:fans_arena/fans/bloc/accountchecker9.dart';
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:fans_arena/reusablewidgets/cirularavatar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../bloc/accountchecker6.dart';
import 'package:firebase_auth/firebase_auth.dart';
class SuggestedExplore extends StatefulWidget {
  const SuggestedExplore({super.key});

  @override
  State<SuggestedExplore> createState() => _SuggestedExploreState();
}

class _SuggestedExploreState extends State<SuggestedExplore> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
late Users last;
  late Users last1;
  late Users last2;
  List<Users> user=[];
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  ScrollController controller=ScrollController();
Newsfeedservice news = Newsfeedservice();
  @override
  void initState() {
    super.initState();
    news=Newsfeedservice();
    retrieveUserData();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        retrieveUserData1(); // Load more posts when scrolling to the end
      }
    });
  }

 Future<void> retrieveUserData() async {
    setState((){
      user.clear();
    });
  List<Users> users= await news.retrieveUserData1();
  setState(() {
    user.addAll(users);
    user.removeWhere((element) => element.userId==FirebaseAuth.instance.currentUser!.uid);
    if(users.isNotEmpty){
      last= users.last;
    }
  });
  List<Users> users1= await news.retrieveUserData2();
  setState(() {
    user.addAll(users1);
    user.removeWhere((element) => element.userId==FirebaseAuth.instance.currentUser!.uid);
    if(users1.isNotEmpty){
      last1= users1.last;
    }
  });
  List<Users> users2= await news.retrieveUserData3();
  setState(() {
    user.addAll(users2);
    user.removeWhere((element) => element.userId==FirebaseAuth.instance.currentUser!.uid);
    if(users2.isNotEmpty){
     last2= users2.last;
    }
  });
  }

  void retrieveUserData1() async {
    List<Users> users= await news.retrieveUserDataM1(last: last);
    setState(() {
      user.addAll(users);
      user.removeWhere((element) => element.userId==FirebaseAuth.instance.currentUser!.uid);
      if(users.isNotEmpty){
        last= users.last;
      }
    });
    List<Users> users1= await news.retrieveUserDataM2(last: last1);
    setState(() {
      user.addAll(users1);
      user.removeWhere((element) => element.userId==FirebaseAuth.instance.currentUser!.uid);
      if(users1.isNotEmpty){
        last1= users1.last;
      }
    });
    List<Users> users2= await news.retrieveUserDataM3(last: last2);
    setState(() {
      user.addAll(users2);
      user.removeWhere((element) => element.userId==FirebaseAuth.instance.currentUser!.uid);
      if(users2.isNotEmpty){
        last2= users2.last;
      }
    });
  }

  double radius=22;
  double fsize=16;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,)),
        title: const Text('Suggested for you',style: TextStyle(color: Colors.black),),
      ),
      body: RefreshIndicator(
        onRefresh: ()async{
          await retrieveUserData();
        },
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            controller: controller,
            itemCount: user.length+1,
            itemBuilder: (ctx, index){
              if(index==user.length){
                return SizedBox(
                    height: 60,
                    child: Center(child: CircularProgressIndicator()));
              }
          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: ListTile(
                leading:CustomAvatar(radius: radius, imageurl: user[index].url),
                title:  InkWell(
                    onTap: () {
                      Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Accountchecker9(userId:user[index].userId,index: 0,iden:user[index].iden)
                        ),
                      );
                    },
                    child:  SizedBox(
                        width: 200,
                        child: Padding(
                          padding: const EdgeInsets
                              .only(left: 5),
                          child: SizedBox(
                            height: 25.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 10.0,
                                      maxWidth: 160.0,
                                    ),
                                    child: Text(
                                      user[index].name,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fsize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child:  Accountchecker6(user:Person(
                                        name: '',
                                        userId: '',
                                        url: '',
                                        collectionName: ''
                                      ),iden:user[index].iden)),
                                ),
                              ],
                            ),
                          ),
                        )),
                ),
                trailing: SizedBox(
                    width: 100,
                    child: Accountchecker11(user:Person(
                        name: user[index].name,
                        userId:user[index].userId,
                        url: user[index].url,
                        collectionName:user[index].collectionName
                    ),))
            ),
          );
        }),
      ),
    );
  }
}

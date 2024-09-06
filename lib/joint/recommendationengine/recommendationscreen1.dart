import 'package:fans_arena/fans/bloc/accountchecker11.dart';
import 'package:fans_arena/fans/screens/Suggestedfollowersexplore.dart';
import 'package:flutter/material.dart';
import '../../clubs/screens/accountclubviewer.dart';
import '../../fans/bloc/usernamedisplay.dart';
import '../../fans/data/newsfeedmodel.dart';
import '../../fans/screens/accountfanviewer.dart';
import '../../professionals/screens/accountprofilepviewer.dart';
import '../../reusablewidgets/cirularavatar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';
class RecommendationScreen1 extends StatefulWidget {
  List<Person>users;
  RecommendationScreen1({super.key,
    required this.users,});

  @override
  State<RecommendationScreen1> createState() => _RecommendationScreen1State();
}

class _RecommendationScreen1State extends State<RecommendationScreen1>  {
  @override
  void initState() {
    super.initState();
    setState(() {
      widget.users.removeWhere((element) => element.userId==FirebaseAuth.instance.currentUser!.uid);
    });
  }

  double radius=55;
  @override
  Widget build(BuildContext context) {
    return widget.users.isNotEmpty? SizedBox(
      height: 300,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              color: Colors.grey[200],
              width:MediaQuery.of(context).size.width,height: 35,child: Padding(
              padding: const EdgeInsets.only(left: 15,right: 15),
              child: Center(child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Clubs, professionals and fans around you',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
                  SizedBox(
                      height: 35,
                      child: TextButton(onPressed: (){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context)=>const SuggestedExplore()));
                      }, child: const Text('Explore',style: TextStyle(color: Colors.blue,),)))
                ],
              )),
            ),),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.users.length,
                itemBuilder: (ctx, index) {
                    final user = widget.users[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 4,right: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child:  Container(
                          height: 230,
                          width: 180,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1,
                                  color: Colors.grey
                              )
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 15,top: 5),
                                child: Align(
                                  alignment:Alignment.topRight,
                                  child: SizedBox(
                                    width:25,
                                    height: 20,
                                    child: InkWell(
                                      onTap: (){
                                        setState(() {
                                          widget.users.removeWhere((element)=>element.userId==user.userId);
                                        });
                                      },
                                      child: const Icon(Icons.close),
                                    ),
                                  ),),
                              ),
                              SizedBox(
                                height: 230,
                                width: 200,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context){
                                                if(user.collectionName=='Club'){
                                                  return AccountclubViewer(user: user, index: 0);
                                                }else if(user.collectionName=='Professional'){
                                                  return AccountprofilePviewer(user: user, index: 0);
                                                }else{
                                                  return Accountfanviewer(user:user, index: 0);
                                                }
                                              }
                                          ),
                                        );// Call the function with the 'context' and 'index' values
                                      },
                                      child: UsernameDO(
                                        username: user.name,
                                        collectionName: user.collectionName,
                                        width: 190,
                                        height: 38,
                                        maxSize: 155,
                                        aligncenter: true,
                                        style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                                      ),
                                    ),

                                    CustomAvatar(radius: radius, imageurl: user.url),
                                    FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Accountchecker11(user:user,)),

                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
              ),
            ),

          ],
        ),
      ),
    ):const SizedBox.shrink();
  }
}
class RecoShimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4,right: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child:  Container(
          height: 230,
          width: 180,
          decoration: BoxDecoration(
              border: Border.all(
                  width: 1,
                  color: Colors.grey
              )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 15,top: 5),
                child: Align(
                  alignment:Alignment.topRight,
                  child: SizedBox(
                    width:25,
                    height: 20,
                    child: InkWell(
                      onTap: (){
                      },
                      child: const Icon(Icons.close),
                    ),
                  ),),
              ),
              SizedBox(
                height: 230,
                width: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Container(
                      width: 160,
                      height: 25,
                      decoration:  BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[800]!,
                        highlightColor: Colors.grey[500]!,
                        period: const Duration(milliseconds: 800),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                              borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius:55,
                      backgroundColor: Colors.black,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[800]!,
                        highlightColor: Colors.grey[500]!,
                        period: const Duration(milliseconds: 800),
                        child: const CircleAvatar(
                            radius:55,
                            backgroundColor: Colors.black,
                      ),
                    )),
                    Container(
                      width: 100,
                      height: 25,
                      decoration:  BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Shimmer.fromColors(
                        baseColor: Colors.blue[800]!,
                        highlightColor: Colors.blue[500]!,
                        period: const Duration(milliseconds: 800),
                        child: Container(
                          decoration:  BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
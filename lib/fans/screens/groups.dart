import 'package:fans_arena/fans/screens/groupchatting.dart';
import 'package:fans_arena/fans/screens/messages.dart';
import 'package:fans_arena/joint/screens/choosefriends.dart';
import 'package:fans_arena/reusablewidgets/cirularavatar.dart';
import 'package:flutter/material.dart';

import 'chatting.dart';

class Groups extends StatefulWidget {
  List<String> userGroupIds;
  List<String> groupnames;
  List<String> profileimage;
   Groups({super.key,required this.userGroupIds,required this.groupnames,required this.profileimage});

  @override
  State<Groups> createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {


  bool deletemode=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView.builder(
      itemCount:widget.userGroupIds.length,
      itemBuilder: (BuildContext context, int index) {
        final groupId=widget.userGroupIds[index];
        String name="";
        String url="";
        if(widget.groupnames[index].isNotEmpty||widget.groupnames[index]!=null){
          name=widget.groupnames[index];
        }
        if(widget.profileimage[index].isNotEmpty||widget.profileimage[index]!=null){
         url=widget.profileimage[index];
        }

       return FittedBox(
           fit: BoxFit.scaleDown,
         child: Container(
           width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color:deletemode?Colors.white10:Colors.white54,
            ),
            margin: const EdgeInsets.all(4.0),
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Groupchatting(groupId: groupId, url: url??'', username: name??'',),
                  ),
                );//
                // Do something when the list tile is clicked.
              },
              child:Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  url.isNotEmpty?CustomAvatar(radius: 23, imageurl:url):CustomAvatarM(userId:groupId, radius: 23,),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width*0.85,
                          child: Row(
                            mainAxisAlignment:MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              name.isNotEmpty?Text(name,style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),):CustomNameM(maxsize: 165,userId:groupId,  style:const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                              LatestTime( chatId:groupId,collection:'Groups'),
                            ],
                          ),
                        ),
                        LatestText( chatId:groupId,collection:'Groups')
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


          Align(
            alignment: const Alignment(0.85,0.9),
            child:  ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: SizedBox(
                height: 50,
                width: 50,
              child: FloatingActionButton(
                backgroundColor: Colors.blue,
                onPressed: (){
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context)=> const Choosefriends1(),
                    ),
                  );
                },child: const Icon(Icons.add,color: Colors.white,),),
            ),
            )),
      ]),
    );
  }
}


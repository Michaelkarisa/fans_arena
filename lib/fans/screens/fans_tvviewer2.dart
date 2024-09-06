import 'package:fans_arena/fans/components/bottomnavigationbar.dart';
import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:fans_arena/joint/data/screens/widgets/optionsscreen1.dart';
import 'package:fans_arena/joint/screens/camera.dart';
import 'package:flutter/material.dart';
import '../data/newsfeedmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Fans_tvviewer2 extends StatefulWidget {
  Person user;
  FansTv post;
  List<FansTv> posts;
  Fans_tvviewer2({super.key,
    required this.user,
    required this.post,
    required this.posts});

  @override
  State<Fans_tvviewer2> createState() => _Fans_tvviewer2State();
}

class _Fans_tvviewer2State extends State<Fans_tvviewer2> {
  void getIndex()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('index', 2);

  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            OptionsScreen3(user:widget.user ,post:widget.post,posts: widget.posts,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:  [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,color: Colors.white,size: 35,),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },//to next page},
                  ),
                  const Text(
                    'Fans_Tv',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,color: Colors.white
                    ),
                  ),
                  InkWell(
                      onTap: (){
                        Bottomnavbar.setCamera(context);
                        Camera.setCamera(context);
                        getIndex();
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.camera_alt,size: 30,color: Colors.white,)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

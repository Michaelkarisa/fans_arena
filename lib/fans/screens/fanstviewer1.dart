import 'package:fans_arena/fans/components/bottomnavigationbar.dart';
import 'package:fans_arena/joint/data/screens/optionscreen_2.dart';
import 'package:fans_arena/joint/screens/camera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Fans_tvviewer1 extends StatefulWidget {
  String postId;
  Fans_tvviewer1({super.key, required this.postId});

  @override
  State<Fans_tvviewer1> createState() => _Fans_tvviewer1State();
}

class _Fans_tvviewer1State extends State<Fans_tvviewer1> {
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
            //We need swiper for every content
            OptionsScreen2(postId:widget.postId ,),
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

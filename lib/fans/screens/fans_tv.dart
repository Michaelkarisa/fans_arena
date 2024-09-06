import 'package:fans_arena/fans/components/bottomnavigationbar.dart';
import 'package:fans_arena/joint/data/screens/widgets/optionscreen2.dart';
import 'package:fans_arena/joint/screens/camera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Fans_tv extends StatefulWidget {
  const Fans_tv({super.key});

  @override
  State<Fans_tv> createState() => _Fans_tvState();
}

class _Fans_tvState extends State<Fans_tv> {
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
            const OptionsScreen1(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:  [
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

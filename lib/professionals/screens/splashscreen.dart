import 'package:fans_arena/fans/components/bottomnavigationbar.dart';
import 'package:flutter/material.dart';
class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    navigatehome();
  }

  navigatehome()async{
    await Future.delayed(const Duration(milliseconds: 1500),(){});
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context)=>Bottomnavbar()));
  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         MorbiusStrip(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(' Fans ',
              style: TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.teal),),
            Text('Arena ',
              style: TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.amber),),          ],)
        ],
      ),

    );
  }
}
class MorbiusStrip extends StatelessWidget {
  const MorbiusStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 280,
        width: 250,
        child: Stack(
          children: [
            Align(
              alignment: Alignment(0.0,0.0),
              child: Image.asset(
                "assets/mobius4.jpg",
                height: 250,
                width: 250,
              ),
            ),
            const Align(
                alignment: Alignment(0.0,0.0),
                child: Stack(
                  children: [
                    Align(alignment: Alignment(-0.1,-0.35),
                        child: Text('F',style:TextStyle(fontSize: 85,color: Colors.yellow,fontWeight: FontWeight.bold))),
                    Align(alignment: Alignment(0.15,-0.1),child: Text('A',style:TextStyle(fontSize: 42.5,color: Colors.orange,fontWeight: FontWeight.bold))),
                  ],
                ))
          ],
        ),
      ),
    );
  }

}
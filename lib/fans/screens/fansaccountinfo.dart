import 'package:flutter/material.dart';
class Fansaccountinfo extends StatefulWidget {
  const Fansaccountinfo({super.key});

  @override
  State<Fansaccountinfo> createState() => _FansaccountinfoState();
}

class _FansaccountinfoState extends State<Fansaccountinfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,),
        ),
        title: const Text('Information about Fans account',style: TextStyle(color: Colors.black),),
      ),
    body: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: const Column(
            children: [
              Text("What is a fan account?",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
              Text('A fan account is a digital form of a spectator. Its an account that will allow you to digitally cheer your favourite club and professionals when they are perfoming their events. '),
              Text("Why create a fan account?",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
              Text('If you have by chance a fourite home club"team" and you would like to cheer the club or show any form of support to the club when they are performing their events this will be the perfect account.'),
              Text("What is needed to create a fan account?",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
              Text('No heavy requirements are needed except having an email for the signup process.'),
              Text("What I should expect in a fan account?",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
              Text('A fan account will provide you with social engagement tools to watch events, comment, like, chat, and many more tools to spectate your favourite club or professional.'),
              Text("What happens to your content",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
              Text('The content you post is your responsibility to ensure there will be no misuse. '
                  'Fans Arena will not be responsible for content misuse or handling.'),
              Text("What added benefits comes with a fan account?",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
              Text('A fans account offers no bounds to your spectative enthusiasm. This allows you to show spectatular spectation at the comfort of your home.')
            ],
          ),
        ),
      ),
    ),
    );
  }
}

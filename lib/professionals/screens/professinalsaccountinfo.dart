import 'package:flutter/material.dart';
class Profesaccountinfo extends StatefulWidget {
  const Profesaccountinfo({super.key});

  @override
  State<Profesaccountinfo> createState() => _ProfesaccountinfoState();
}

class _ProfesaccountinfoState extends State<Profesaccountinfo> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,),
          ),
          title: const Text('Information about Professional account',style: TextStyle(color: Colors.black),),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Column(
                children: [
                  Text("What is a Professional account?",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                  Text ("A professional account is a individual account that is created and allows the individual to explore their various talents as an individual."
                      " As a professional you are identified as certain individual who wants to explore their talents."),
                  Text("Why create and use a Professional account?",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                  Text("If  you have various sports talents and you wish the world to see you explore them then its the right account for that."),
                  Text("What is needed to create a Professional account?",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                  Text('One of the requirements is for you to have an email. '),
                  Text("What I should expect in a Professional account?",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                  Text('A professional account will provide you with unique tools to film variuos events live to your enthusiatic fans. '
                      'The platform will also render you with social media engagement tools which include posting posts, stories, liking, commenting and so on.'
                      'That will come as an added bonus to the unique tools to film your events. The filming tools will allow you to use more than one phone to film the events. '
                      'This is unique to this platform. These tools will be beneficial to those who have talents that require a large field hence a large area of coverage which is impossible to cover with one phone, a good example is a football field.'),
                  Text("What happens to your content",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                  Text('You have full ownership to the content you create using the account. That means you can sue any account in the platform or any other platform if they use it without your consent. '
                      'It will be your responsiblity to regulate misuse of your content. Fans Arena will not be responsible for content misuse or handling. '),
                  Text("What added benefits comes with a professional account?",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                  Text('The Fans Arena platform will offer payment to professionals. The payment will soley depend on percentage exposure of your professional account and the content you air to your fans as events. '
                      'This will be in the form of views and watch hours. Once your cross the payment threshold money will be deposited to your account if not it will recure for the next month window.'
                      'For more information on the payment visit www.FansArena.com. ')
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
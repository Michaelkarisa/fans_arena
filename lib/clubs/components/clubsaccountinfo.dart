import 'package:flutter/material.dart';

class Clubsaccountinfo extends StatefulWidget {
  const Clubsaccountinfo({super.key});

  @override
  State<Clubsaccountinfo> createState() => _ClubsaccountinfoState();
}

class _ClubsaccountinfoState extends State<Clubsaccountinfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },icon: const Icon(Icons.arrow_back,color: Colors.black,),
        ),
        title: const Text('Information about Club account',style: TextStyle(color: Colors.black),),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: const Column(
              children: [
                Text("What is a club account?",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                Text ("A club account is a group account that is created and allows the group to explore their various talents as a group while also retaing their individuality."
                    " As a club you are identified as certain number of individuals who came together bounded by a common goal."),
                Text("Why create and use a club account?",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                Text("If you have friends or collegues with whom you all think that you have various sports talents and you wish the world to see you explore them then its the right account for that."),
                Text("What is needed to create a club account?",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                Text('One of the requirements is for you and every member to be in the club that they should create a professionals account. '
                    'The professionals account will allow you to retain your individuality. Second you need to create an email first for this account, I do not recommend using an email tied to an individual if by chance they will need to use it to signup into Fans Arena. '),
                Text('Retaining your individuality is a requirement which is beneficial for the club and you as a person.'),
                Text("What I should expect in a club account?",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                Text('A club account will provide you with unique tools to film various events live to your enthusiatic fans. '
                    'The platform will also render you with social media engagement tools which include posting on fansTv & newsfeed, stories, liking, commenting and so on.'
                    'That will come as an added bonus to the unique tools to film your events. The filming tools will allow you to use more than one phone to film the events. '
                    'This is unique to this platform. These tools will be beneficial to those who have talents that require a large field, hence a large area of coverage which is impossible to cover with one phone, a good example is a football field.'),
                Text("What happens to your content",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                Text('You have full ownership to the content you create using the account. That means you can sue any account in the platform or any other platform if they use it without your consent. '
                    'It will be your responsiblity to regulate misuse of your content. Fans Arena will not be responsible for content misuse or handling. '),
                Text("What added benefits comes with a club account?",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                Text('The Fans Arena platform will offer payment to clubs. The payment will soley depend on percentage exposure of your club account and the content you air to your fans as events. '
                    'This will be in the form of views and watch hours. Once you cross the payment threshold money will be deposited to your account if not it will recure for the next month window.'
                    'For more information on the payment visit www.FansArena.com. ')
              ],
            ),
          ),
        ),
      ),
    );
  }
}

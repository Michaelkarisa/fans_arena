import 'package:fans_arena/appid.dart';
import 'package:fans_arena/clubs/screens/allmatches.dart';
import 'package:fans_arena/fans/screens/homescreen.dart';
import 'package:fans_arena/joint/components/colors.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../reusablewidgets/mpesa.dart';
import 'revenueandstatistics.dart';
class EventsFilming extends StatefulWidget {
  const EventsFilming({super.key});
  @override
  State<EventsFilming> createState() => _EventsFilmingState();
}
class _EventsFilmingState extends State<EventsFilming> with TickerProviderStateMixin {
  late AnimationController _textBounceController;
  late Animation<Alignment> top;
  late Animation<Alignment> bottom;
  @override
  void initState() {
    super.initState();
    _startTime=DateTime.now();
    // Text Bounce Animation
    _textBounceController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    getCurrencyData();
  }
  late DateTime _startTime;

  @override
  void dispose(){
    Engagement().engagement('EventsFilming',_startTime,'');
    _textBounceController.dispose();
    super.dispose();
  }
  FirebaseFirestore firestore=FirebaseFirestore.instance;
  void getCurrencyData()async{
  String paymentId="";
  DocumentSnapshot documentSnapshot= await firestore.collection("Clubs").doc(FirebaseAuth.instance.currentUser!.uid).get();
  if(documentSnapshot.exists){
    var data= documentSnapshot.data() as Map<String,dynamic>;
    setState(() {
      paymentId=data['paymentId']??"";
    });
    if(paymentId.isNotEmpty||paymentId!=null){
    DocumentSnapshot documentSnapshot= await firestore.collection("Payments").doc(paymentId).get();
    if(documentSnapshot.exists){
      var data= documentSnapshot.data() as Map<String,dynamic>;
      setState(() {
     Map<String,dynamic>of=data['of'];
     if(of['plan']=="plan1"){
       use1=true;
     }else if(of['plan']=="plan2"){
       use2=true;
     }else if(of['plan']=="plan3"){
       use3=true;
     }else if(of['plan']=="plan4"){
       use4=true;
     }
      });
    }}}
  }
  TextEditingController t=TextEditingController();
bool use1=false;
  bool use2=false;
  bool use3=false;
  bool use4=false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          automaticallyImplyLeading: false,
          title: Text('Filming',style: TextStyle(color: Textn),),
          backgroundColor: Appbare,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Plans',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                ),
              ),
              SizedBox(
                width: 390,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Free',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                        const Text('One phone camera set up',style: TextStyle(fontWeight: FontWeight.bold),),
                        Text('This is free to use allows you to use one account phone, which allow you to cover your field while offering a limited coverage to your beloved fans.'),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: SizedBox(
                            width: 380,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 2),
                                ),
                                onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const Allmatches()), );
                                },
                                child:AnimatedBuilder(
                                  animation: _textBounceController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: 1 + _textBounceController.value * 0.2,
                                      child: const Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Text(
                                          'Use',
                                        ),
                                      ),
                                    );
                                  },
                                ),),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 390,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Plan 1',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                          const Text('Two phones camera set up',style: TextStyle(fontWeight: FontWeight.bold)),
                         Text('This plan entails using two account phones which will give you the possibility to cover big area of your field and offer a great view and experience for your beloved fans. The two phones must have the fans arena accounts. One of the phones must have a professional account as the assistant account. The admin account can be professional or club account.',),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: SizedBox(
                              width: 380,
                              child:use1?ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                  ),
                                  onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const Allmatches()), );
                                  },
                                  child: AnimatedBuilder(
                                    animation: _textBounceController,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: 1 + _textBounceController.value * 0.2,
                                        child: const Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text(
                                            'Use',
                                          ),
                                        ),
                                      );
                                    },
                                  )): ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                  ),
                                  onPressed: (){
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        isDismissible: false,
                                        backgroundColor: Colors.transparent,
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight:  Radius.circular(10))),
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Paywall(sdw: 140, sdm: 560, hdw: 280, hdm: 1120);
                                        }
                                    );
                                  },
                                  child:AnimatedBuilder(
                                    animation: _textBounceController,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: 1 + _textBounceController.value * 0.2,
                                        child: const Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text(
                                            'Subscribe',
                                          ),
                                        ),
                                      );
                                    },
                                  ),),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 390,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Plan 2',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                          const Text('Four phones camera set up',style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('This plan entails using four account phones which will give you the possibility to cover big area of your field and offer a great view and experience for your beloved fans. This is because the phones will allow you to only cover a small area of you field without need to switch location based on the movement of the ball(this is based on games that have a big field). The four phones must have the fans arena accounts. Three of the phones must have a professional account as the assisant account. The admin account can be professional or club account.'),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: SizedBox(
                              width: 380,
                              child:use2?ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                  ),
                                  onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const Allmatches()), );
                                  },
                                  child: AnimatedBuilder(
                                    animation: _textBounceController,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: 1 + _textBounceController.value * 0.2,
                                        child: const Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text(
                                            'Use',
                                          ),
                                        ),
                                      );
                                    },
                                  ),):  ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                  ),
                                  onPressed: (){
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        isDismissible: false,
                                        backgroundColor: Colors.transparent,
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight:  Radius.circular(10))),
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Paywall(sdw: 240, sdm: 960, hdw: 480, hdm: 1920);
                                        }
                                    );

                                  },
                                  child: AnimatedBuilder(
                                    animation: _textBounceController,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: 1 + _textBounceController.value * 0.2,
                                        child: const Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text(
                                            'Subscribe',
                                          ),
                                        ),
                                      );
                                    },
                                  ),),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 390,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Plan 3',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                          const Text('Six phones camera set up',style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('This plan entails using six account phones which will give you the possibility to cover big area of your field and offer a great view and experience for your beloved fans. This is because the phones will allow you to only cover a small area of you field without need to switch location based on the movement of the ball(this is based on games that have a big field). The six phones must have the fans arena accounts. Five of the phones must have a professional account as the assisant account. The admin account can be professional or club account.',),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: SizedBox(
                              width: 380,
                              child: use3?ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                  ),
                                  onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const Allmatches()), );
                                  },
                                  child: AnimatedBuilder(
                                    animation: _textBounceController,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: 1 + _textBounceController.value * 0.2,
                                        child: const Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text(
                                            'Use',
                                          ),
                                        ),
                                      );
                                    },
                                  ),): ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                  ),
                                  onPressed: (){
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        isDismissible: false,
                                        backgroundColor: Colors.transparent,
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight:  Radius.circular(10))),
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Paywall(sdw: 345, sdm: 1380, hdw: 690, hdm: 2760);
                                        }
                                    );
                                  },
                                  child: AnimatedBuilder(
                                    animation: _textBounceController,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: 1 + _textBounceController.value * 0.2,
                                        child: const Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text(
                                            'Subscribe',
                                          ),
                                        ),
                                      );
                                    },
                                  ),),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 390,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Plan Pro',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                          const Text('Upto twelve camera set up',style: TextStyle(fontWeight: FontWeight.bold)),
                         Text('This plan entails using upto twelve account phones which will give you the possibility to cover big area of your field and offer a great view and experience for your beloved fans. This is because the phones will allow you to only cover a small area of you field without need to switch location based on the movement of the ball(this is based on games that have a big field). The seven to twelve phones must have the fans arena accounts. six to eleven of the phones must have a professional account as the assisant account. The admin account can be professional or club account.',),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: SizedBox(
                              width: 380,
                              child: use4?ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                  ),
                                  onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const Allmatches()), );
                                  },
                                  child: AnimatedBuilder(
                                    animation: _textBounceController,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: 1 + _textBounceController.value * 0.2,
                                        child: const Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text(
                                            'Use',
                                          ),
                                        ),
                                      );
                                    },
                                  ),): ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                  ),
                                  onPressed: (){
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        isDismissible: false,
                                        backgroundColor: Colors.transparent,
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight:  Radius.circular(10))),
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Paywall(sdw: 650, sdm: 2600, hdw: 1300, hdm: 5200,);
                                        }
                                    );

                                  },
                                  child: AnimatedBuilder(
                                    animation: _textBounceController,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: 1 + _textBounceController.value * 0.2,
                                        child: const Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text(
                                            'Subscribe',
                                          ),
                                        ),
                                      );
                                    },
                                  ),),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: (){ Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>  const RevenueInsights(),
                  ),
                );},
                child:  SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Revenue & Insights',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 100,
              )
            ],
          ),
        ),

      ),
    );
  }
}

class Paywall extends StatefulWidget {
  int sdw;
 int sdm;
  int hdw;
  int hdm;
  Paywall({super.key,required this.sdw,required this.sdm,required this.hdw,required this.hdm});

  @override
  State<Paywall> createState() => _PaywallState();
}

class _PaywallState extends State<Paywall> {
  int money=0;
  @override
  Widget build(BuildContext context) {
    return  DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        builder: (context, controller) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child:ClipRRect(
              borderRadius: const BorderRadius.only(topLeft:Radius.circular(20),topRight: Radius.circular(20)),
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child:Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text("Select a Plan",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
                      const Text("Standard Definition",style: TextStyle(fontWeight: FontWeight.bold),),
                      InkWell(
                        onTap: (){
                          setState(() {
                            money=widget.sdw;
                          });
                        },
                        child: Container(
                          width: 390,
                          height: 80,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                width: 2,
                                color: money==widget.sdw?Colors.blue:Colors.grey,
                              )
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Weekly"),
                              Text("ksh.${widget.sdw}")
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          setState(() {
                            money=widget.sdm;
                          });
                        },
                        child: Container(
                          width: 390,
                          height: 80,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                width: 2,
                                color: money==widget.sdm?Colors.blue:Colors.grey,
                              )
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Monthly"),
                              Text("ksh.${widget.sdm}")
                            ],
                          ),
                        ),
                      ),
                      const Text("High Definition",style: TextStyle(fontWeight: FontWeight.bold),),
                      InkWell(
                        onTap: (){
                          setState(() {
                            money=widget.hdw;
                          });
                        },
                        child: Container(
                          width: 390,
                          height: 80,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                width: 2,
                                color: money==widget.hdw?Colors.blue:Colors.grey,
                              )
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Weekly"),
                              Text("ksh.${widget.hdw}")
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          setState(() {
                            money=widget.hdm;
                          });
                        },
                        child: Container(
                          width: 390,
                          height: 80,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                width: 2,
                                color: money==widget.hdm?Colors.blue:Colors.grey,
                              )
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Monthly"),
                              Text("ksh.${widget.hdm}")
                            ],
                          ),
                        ),
                      ),
                  MyButton(amount: money.toDouble()),
                    ],
                  ),
                ) ,
              ),
            )));
  }
}

class MyButton extends StatefulWidget {
  double amount;
  MyButton({super.key, required this.amount});
  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _textBounceController;
late Animation<Alignment> top;
late Animation<Alignment> bottom;
  @override
  void initState() {
    super.initState();
    Mpesa.setConsumerKey(mConsumerKey);
    Mpesa.setConsumerSecret(mConsumerSecret);
    // Gradient Animation
    _gradientController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    // Text Bounce Animation
    _textBounceController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    top= TweenSequence<Alignment>(
      [
        TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topLeft,end: Alignment.topRight), weight:1),
        TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topRight,end: Alignment.bottomRight), weight:1),
        TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.bottomRight,end: Alignment.bottomLeft), weight:1),
        TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.bottomLeft,end: Alignment.topLeft), weight:1),
      ],
    ).animate(_gradientController);
    bottom= TweenSequence<Alignment>(
      [
        TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.bottomRight,end: Alignment.bottomLeft), weight:1),
        TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.bottomLeft,end: Alignment.topLeft), weight:1),
        TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topLeft,end: Alignment.topRight), weight:1),
        TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topRight,end: Alignment.bottomRight), weight:1),
      ],
    ).animate(_gradientController);


  }

  String mPasskey = 'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919';
 String m="30a433f88cb895a15a6f3156def2fbf27cc9312c6200c256082615bf8b9a9507";
  Future<dynamic> startCheckout(
      {required String userPhone, required double amount}) async {
    showDialog(context: context, builder: (context){
      return AlertDialog(
        content:SizedBox(width:30,height:30,child: Column(
          children: [
            CircularProgressIndicator(),
          ],
        ))
      );
    });
    //handleDonationTransaction
    //userId,
    //authorId,
   // collection,
    try {
      //handleTransaction
      String baseUrl="https://us-central1-fans-arena.cloudfunctions.net";
     final transactionInitialisation =
      await Mpesa.initializeMpesaSTKPush(
          businessShortCode: "174379",
          transactionType: TransactionType.CustomerBuyGoodsOnline,
          amount: amount,
          partyA: userPhone,
          partyB: "174379",
          callBackURL: Uri.parse('$baseUrl/handleTransaction'),
          accountReference: "shoe",
          phoneNumber: userPhone,
          baseUri: Uri(scheme: "https", host: "sandbox.safaricom.co.ke"),
          transactionDesc: "purchase",
          passKey: mPasskey);

      print("TRANSACTION RESULT: $transactionInitialisation");

      //You can check sample parsing here -> https://github.com/keronei/Mobile-Demos/blob/mpesa-flutter-client-app/lib/main.dart

      /*Update your db with the init data received from initialization response,
      * Remaining bit will be sent via callback url*/
      return transactionInitialisation;
    } catch (e) {
      showDialog(context: context, builder: (context){
        return AlertDialog(
          content: Text('an error occurred:$e'),
        );
      });
      /*
      Other 'throws':
      1. Amount being less than 1.0
      2. Consumer Secret/Key not set
      3. Phone number is less than 9 characters
      4. Phone number not in international format(should start with 254 for KE)
       */
    }
  }

  final _textFieldController = TextEditingController();


  Future<String?> _showTextInputDialog(BuildContext context,double amount) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('M-Pesa Number'),
            content: TextField(
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: "07..."),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 50,),
              ElevatedButton(
                child: const Text('Proceed'),
                onPressed: () async {
                  String userPhone = _textFieldController.text;
                  if (userPhone.startsWith('0')) {
                    userPhone = '254${userPhone.substring(1)}';
                  }
                  var data=await startCheckout(userPhone: userPhone, amount: amount);
                  Navigator.of(context,rootNavigator:true).pop();
                  showDialog(context: context, builder: (context){
                    return AlertDialog(
                        content:Text("Done:$data")
                    );
                  });
                },
              ),
            ],
          );
        });
  }
  bool weekly=false;
  bool hd=false;
  int money=0;
  @override
  void dispose() {
    _gradientController.dispose();
    _textBounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async{
        var providedContact =
            await _showTextInputDialog(context,widget.amount);

        if (providedContact != null) {
          if (providedContact.isNotEmpty) {
            startCheckout(
                userPhone: providedContact,
                amount: money.toDouble());
          } else {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Empty Number!'),
                    content: const Text(
                        "You did not provide a number to be charged."),
                    actions: <Widget>[
                      ElevatedButton(
                        child: const Text("Cancel"),
                        onPressed: () =>
                            Navigator.pop(context),
                      ),
                    ],
                  );
                });
          }
        }
      },
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(3.0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              // If the button is pressed, return the overlay color.
              return Colors.blue.withOpacity(0.1);
            }
            // The default is transparent.
            return Colors.white;
          },
        ),
      ),
      child: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [
                  Color(0xFF00B4DB),
                  Color(0xFF0083B0),
                ],
                begin: top.value,
                end: bottom.value,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _textBounceController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1 + _textBounceController.value * 0.2,
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:fans_arena/clubs/screens/accountc.dart';
import 'package:fans_arena/clubs/screens/help.dart';
import 'package:fans_arena/clubs/screens/notify.dart';
import 'package:fans_arena/fans/data/notificationsmodel.dart';
import 'package:fans_arena/professionals/screens/account.dart';
import 'package:flutter/material.dart';
import '../../fans/screens/accountf.dart';
import '../../joint/screens/revenueandstatistics.dart';
import '../../professionals/screens/abouttheapp.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../professionals/screens/ads.dart';
class Settings{
  String set;
  Widget layout;
  Settings({required this.set,required this.layout});
}
class SettingsClub extends StatefulWidget {
  String name;
   SettingsClub({super.key,required this.name});

  @override
  State<SettingsClub> createState() => _SettingsClubState();
}
class _SettingsClubState extends State<SettingsClub> {

  void dialog(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: Alignment.center,
          title: const Text('Log out'),
          content:const Text('Do you want to log out?'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(onPressed: (){
                  _logout();
                }, child: const Text('log out')),
                TextButton(onPressed: (){
                  Navigator.pop(context);
                }, child: const Text('dismiss'))
              ],
            )
          ],
        );
      },
    );

  }

  Future<void> _logout() async {
    Navigator.of(context,rootNavigator: true).pop();
    await Future.delayed(const Duration(milliseconds: 10));
    double v=0.0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 const CircularProgressIndicator(),
                SizedBox(height: MediaQuery.of(context).size.height*0.02222),
                const Text('Logging out...'),
              ],
            ),
          ),
        );
      },
    );
    await Future.delayed(const Duration(milliseconds: 15));
    try {
   await NotifyFirebase().signOut(context);
    } catch (e) {
      // Logout failed
      String errorMessage = 'Failed to logout: $e';

      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Logout Failed'),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        ).then((_) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        });
      });

      print(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const SearchSettings()));
                    },
                    child: const Icon(Icons.search,color:Colors.black,size: 33,),
                  ),
                )
              ],
            )
          ],
          title: const Text('Settings',style: TextStyle(fontSize: 18,color: Colors.black),),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: InkWell(
                  onTap: (){
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) =>  const AccountClub(),
                      ),
                    );
                  },
                  child: Container(
                    height: 60,
                    color: Colors.grey[200],
                    width: MediaQuery.of(context).size.width,
                    child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Account'),
                        )),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: InkWell(
                  onTap: (){
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) =>  const Notify()
                      ),
                    );
                  },
                  child: Container(
                    height: 60,
                    color: Colors.grey[200],
                    width: MediaQuery.of(context).size.width,
                    child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Notifications'),
                        )),
                  ),
                ),
              ),
      
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: InkWell(
                  onTap: (){
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Ads(),
                      ),
                    );
                  },
                  child: Container(
                    height: 60,
                    color: Colors.grey[200],
                    width: MediaQuery.of(context).size.width,
                    child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Ads'),
                        )),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: InkWell(
                  onTap: (){
                    showModalBottomSheet(
                      isScrollControlled: true,
                      isDismissible: true,
                      backgroundColor: Colors.transparent,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight:  Radius.circular(10))),
                      context: context,
                      builder: (BuildContext context) {
                        return DraggableScrollableSheet(
                          expand: true,
                          initialChildSize: 0.32,
                          builder: (context, controller) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.5),
                            child: Container(
                              color: Colors.white,
                              child:Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Choose the platform to invite your friends from',style: TextStyle(fontWeight: FontWeight.bold),),
                                  Row(children: [
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height*0.08,
                                      width: MediaQuery.of(context).size.width*0.3,
      
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: InkWell(
                                          onTap: ()async{
                                            final message = "${widget.name} invited you to Fans Arena community(play store link/website link)";
      
                                            final whatsappUrl = "https://wa.me/?text=${Uri.encodeFull(message)}";
                                            await launch(whatsappUrl);
                                          },
                                          child: Image.asset("assets/images/whatsapplogo.png",fit: BoxFit.fitHeight,),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height*0.08,
                                      width: MediaQuery.of(context).size.width*0.3,
      
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: InkWell(
                                          onTap: ()async{
      
                                          },
                                          child: Image.asset("assets/images/instagram.jpeg",fit: BoxFit.fitHeight,),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height*0.08,
                                      width: MediaQuery.of(context).size.width*0.3,
      
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: InkWell(
                                          onTap: ()async{
      
                                          },
                                          child: Image.asset("assets/images/facebooklogo.png",fit: BoxFit.fitHeight,),
                                        ),
                                      ),
                                    )
                                  ],),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    height: 60,
                    color: Colors.grey[200],
                    width: MediaQuery.of(context).size.width,
                    child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Invite friends'),
                        )),
                  ),
                ),
              ),
      
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: InkWell(
                  onTap: (){
                    showModalBottomSheet(
                      isScrollControlled: true,
                      isDismissible: true,
                      backgroundColor: Colors.transparent,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight:  Radius.circular(10))),
                      context: context,
                      builder: (BuildContext context) {
                        return DraggableScrollableSheet(
                          expand: true,
                          initialChildSize: 0.32,
                          builder: (context, controller) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.5),
                            child: Container(
                              color: Colors.white,
                              child:const Column(children: [
      
                              ],),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    height: 60,
                    color: Colors.grey[200],
                    width: MediaQuery.of(context).size.width,
                    child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Theme'),
                        )),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: InkWell(
                  onTap:  () async {
                    dialog();
                  },
                  child: Container(
                    height: 60,
                    color: Colors.grey[200],
                    width: MediaQuery.of(context).size.width,
                    child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Log out'),
                        )),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: InkWell(
                  onTap: (){ Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Help(),
                    ),
                  );},
                  child: Container(
                    height: 60,
                    color: Colors.grey[200],
                    width: MediaQuery.of(context).size.width,
                    child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Help'),
                        )),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: InkWell(
                  onTap: (){
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const AboutTheApp(),
                      ),
                    );
                  },
                  child: Container(
                    height: 60,
                    color: Colors.grey[200],
                    width: MediaQuery.of(context).size.width,
                    child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('About'),
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchSettings extends StatefulWidget {
  const SearchSettings({super.key});

  @override
  State<SearchSettings> createState() => _SearchSettingsState();
}

class _SearchSettingsState extends State<SearchSettings> {
  TextEditingController _controller = TextEditingController();

  bool _showCloseIcon = false;
  List<Settings>settings1=[];
  List<Settings>settings=[
  Settings(
  set: 'Account',
  layout: AccountClub()),
  Settings(
  set: 'Account Insights',
  layout: AccountInsights()),
  Settings(
  set: 'Notifications',
  layout: Notify()),
  Settings(
  set: 'Ads',
  layout: Ads()),
  Settings(
  set: 'Invite friends',
  layout: SettingsClub(name: '',)),
  Settings(
  set: 'Log out',
  layout: SettingsClub(name:'' ,)),
  Settings(
  set: 'Help',
  layout: Help()),
  Settings(
  set: 'About',
  layout: AboutTheApp()),
  Settings(
  set: 'Time spent',
  layout: TimeSpent()),
  Settings(
  set: 'Interactions',
  layout: Interactions()),
  Settings(
  set: 'Archived',
  layout: Archived()),
  Settings(
  set: 'Password',
  layout: Passwordc()),
  Settings(
  set: 'Login Activity',
  layout: LoginActivity()),
  Settings(
  set: 'Saved login information',
  layout: SavedLoginInfo()),
  Settings(
  set: 'security check up',
  layout:SecurityCheckup()),
  Settings(
  set: 'Privacy policy',
  layout: PrivacyPolicy()),
  Settings(
  set: 'Terms of use',
  layout: TermsOfUse()),
  Settings(
  set: 'Updates',
  layout: Updates()),
  ];
  String matchedItem='';
  @override
  Widget build(BuildContext context) {
    return SafeArea(
    child: Scaffold(
    appBar: AppBar(
    elevation: 1,
  title:   Padding(
    padding: const EdgeInsets.only(top: 5),
    child: SizedBox(
      height: 37,
      width: MediaQuery.of(context).size.width*0.75,
      child: Padding(
        padding: const EdgeInsets.only(right: 30),
        child: TextFormField(
          textAlign: TextAlign.justify,
          textAlignVertical: TextAlignVertical.bottom,
          cursorColor: Colors.black,
          textInputAction: TextInputAction.search,
          controller: _controller,
          onChanged: (value) {
            setState(() {
              settings1 = settings.where((match) => match.set.toLowerCase().contains(value.toLowerCase())||
                  match.set.toUpperCase().contains(value.toUpperCase())).toList();
              _showCloseIcon = value.isNotEmpty;
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(width: 1, color: Colors.black),
            ),
            focusedBorder:  OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(width: 1, color: Colors.black),
            ),
            filled: true,
            hintStyle: const TextStyle(color: Colors.black,
              fontSize: 20, fontWeight: FontWeight.normal,),
            fillColor: Colors.white70,
            suffixIcon: _showCloseIcon ? IconButton(
              icon: const Icon(Icons.close,color: Colors.black,),
              onPressed: () {
                setState(() {
                  _controller.clear();
                  _showCloseIcon = false;
                });
              },
            ) : null,
            hintText: 'Search',
          ),
        ),
      ),
    ),
  ),
  backgroundColor: Colors.white,
  ),
    body: ListView.builder(
         itemCount: settings1.length,
        itemBuilder: (context,index){
      return  Padding(
        padding: const EdgeInsets.only(top: 5),
        child: InkWell(
          onTap:  () async {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>settings1[index].layout));
          },
          child: Container(
            height: 60,
            color: Colors.grey[200],
            width: MediaQuery.of(context).size.width,
            child:  Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(settings1[index].set),
                )),
          ),
        ),
      );
    }),
    )
    );
  }
}

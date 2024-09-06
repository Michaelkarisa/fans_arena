import 'package:fans_arena/clubs/screens/eventsclubs.dart';
import 'package:fans_arena/fans/bloc/accountchecker11.dart';
import 'package:fans_arena/fans/widgets/profileHeaderWidgetfanviewer.dart';
import 'package:fans_arena/professionals/components/professionalspost.dart';
import 'package:fans_arena/professionals/components/professionalsvideo.dart';
import 'package:fans_arena/reusablewidgets/cirularavatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/newsfeedmodel.dart';
import 'accountpage.dart';
import 'homescreen.dart';
import 'package:intl/intl.dart';
class Accountfanviewer extends StatefulWidget {
  Person user;
  int index;
  Accountfanviewer({super.key,required this.user,required this.index});

  @override
  State<Accountfanviewer> createState() => _AccountfanviewerState();
}

class _AccountfanviewerState extends State<Accountfanviewer>with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int value=0;
  late DateTime  _startTime;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this,initialIndex: widget.index);
    _startTime=DateTime.now();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        setState(() {
          value=value+1;
        });
      }
    });
  }

  ScrollController controller=ScrollController();
  @override
  void dispose(){
    controller.dispose();
    _tabController.dispose();
    Engagement().engagement('FansAccountProfileV',_startTime,widget.user.userId);
    super.dispose();
  }
  List<String> list=["Report","About this account","Copy profile URL"];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            widget.user.name,
            style:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          centerTitle: false,
          elevation: 1,
          actions: [
            SizedBox(
                width: MediaQuery.of(context).size.width*0.32,
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Accountchecker11(user: widget.user,),
                    IconButton(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        onPressed: (){
                          showModalBottomSheet(
                              isScrollControlled: true,
                              isDismissible: true,
                              backgroundColor: Colors.transparent,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight:  Radius.circular(10))),
                              context: context,
                              builder: (BuildContext context) {
                                return DraggableScrollableSheet(
                                    expand: true,
                                    initialChildSize: 0.2,
                                    maxChildSize: 0.2,
                                    minChildSize: 0.2,
                                    builder: (context, pController) => Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 2.5),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.only(topLeft:Radius.circular(20),topRight: Radius.circular(20)),
                                            color: Colors.grey[200],
                                          ),child: Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: ListView.builder(
                                              controller: pController,
                                              itemCount: list.length,
                                              itemBuilder: (context,index){
                                                return InkWell(
                                                  onTap: ()async{
                                                    if(index==0){
                                                      Navigator.pop(context);
                                                      await Future.delayed(Duration(seconds: 1));
                                                      showModalBottomSheet(
                                                          isScrollControlled: true,
                                                          isDismissible: true,
                                                          backgroundColor: Colors.transparent,
                                                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight:  Radius.circular(10))),
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return DraggableScrollableSheet(
                                                                expand: true,
                                                                initialChildSize: 0.4,
                                                                maxChildSize: 0.4,
                                                                minChildSize: 0.4,
                                                                builder: (context, pController) => Padding(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 2.5),
                                                                    child: Container(
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: const BorderRadius.only(topLeft:Radius.circular(20),topRight: Radius.circular(20)),
                                                                        color: Colors.grey[200],
                                                                      ),)));});
                                                    }else if(index==1){
                                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>AboutAccount(user:widget.user)));
                                                    }else{
                                                      Clipboard.setData(ClipboardData(text: widget.user.url));
                                                    }
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                                                    child: Text(list[index]),
                                                  ),
                                                );}),
                                        ),
                                        )));
                              });
                        }, icon: const Icon(Icons.more_vert,color: Colors.black,)),
                  ],
                )
            )
          ],
        ),
        body: NestedScrollView(
          controller: controller,
          headerSliverBuilder: (context, _) {
            return [
              SliverToBoxAdapter(child: ProfileHeaderWidgetfanviewer(userId: widget.user.userId,),
              ),
              SliverPersistentHeader(
                  floating: true,
                  pinned: true,
                  delegate: MyDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey[400],
                      indicatorWeight: 1,
                      indicatorColor: Colors.black,
                      tabs: [
                        Tab(
                          icon: Icon(
                            Icons.grid_on_sharp,
                            color: Colors.black,
                            size: MediaQuery.sizeOf(context).height*0.036,
                          ),
                        ),
                        Tab(
                            icon: Icon(Icons.live_tv, size: MediaQuery.sizeOf(context).height*0.036,color: Colors.black,)
                        ),
                      ],
                    ),
                  ))
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              Professionalspost(user: widget.user,controller: controller,),
              Professionalsvideos(user: widget.user,controller: controller,),
            ],
          ),
        ),
      ),
    );
  }
}

class AboutAccount extends StatefulWidget {
  Person user;
  AboutAccount({super.key,required this.user});

  @override
  State<AboutAccount> createState() => _AboutAccountState();
}

class _AboutAccountState extends State<AboutAccount> {

  @override
  Widget build(BuildContext context) {
    String date = DateFormat('d MMM y').format(widget.user.timestamp!.toDate());
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("About This Account"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomAvatar(imageurl: widget.user.url, radius: 45),
                    SizedBox(height: 10,),
                    CustomName(username: widget.user.name, maxsize: MediaQuery.of(context).size.width*0.6, style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                    SizedBox(height: 10,),
                  ],
                ),
              ),
              Text("Account Status: ${widget.user.collectionName}",style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.calendar_month,size: 55,color: Colors.black,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Account Creation Date",style:TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                      SizedBox(height: 5,),
                      Text(date)
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

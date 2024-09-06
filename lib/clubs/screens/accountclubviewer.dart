import 'package:fans_arena/clubs/components/profileheaderwidgetviewer.dart';
import 'package:fans_arena/fans/bloc/accountchecker11.dart';
import 'package:fans_arena/professionals/components/professionalspost.dart';
import 'package:fans_arena/professionals/components/professionalsvideo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../fans/data/newsfeedmodel.dart';
import '../../fans/screens/accountfanviewer.dart';
import '../../fans/screens/accountpage.dart';
import '../../fans/screens/homescreen.dart';
class AccountclubViewer extends StatefulWidget {
  Person user;
  int index;
  bool fromMatch;
  AccountclubViewer({super.key, required this.user,required this.index, this.fromMatch=false});

  @override
  State<AccountclubViewer> createState() => _AccountclubViewerState();
}
class _AccountclubViewerState extends State<AccountclubViewer> with SingleTickerProviderStateMixin  {
ScrollController controller=ScrollController();
late DateTime  _startTime;
int value=0;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this,initialIndex: widget.index);
    _startTime=DateTime.now();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        setState(() {
          value=value+1;
        });
      }
    });
  }
late TabController _tabController;

@override
void dispose(){
  controller.dispose();
  _tabController.dispose();
  if(widget.fromMatch) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }
  Engagement().engagement('ClubsAccountProfileV',_startTime,widget.user.userId);
  super.dispose();
}

List<String> list=["Report","About this account","Copy profile URL"];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: LayoutBuilder(
          builder: (context, orientation) {
        if (MediaQuery
            .of(context)
            .size
            .height < 700) {
          return
            Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                title: Container(
                  constraints:  BoxConstraints(
                    minWidth: 10.0,
                    maxWidth:  MediaQuery.of(context).size.width*0.39,
                  ),
                  color: Colors.white,
                  height: 38.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          constraints:  BoxConstraints(
                            minWidth: 10.0,
                            maxWidth: MediaQuery.of(context).size.width*0.3,
                          ),
                          child: Text(
                            widget.user.name,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child:  Container(
                            width: 20,
                            height:20,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(child: Text('C',style: TextStyle(color: Colors.white,fontSize: 15),)),),
                        ),
                      ),
                    ],
                  ),
                ),
                centerTitle: false,
                elevation: 1,
                actions: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.35,
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
                     SliverToBoxAdapter(child: ProfileHeaderWidgetClubsv(userId: widget.user.userId,),
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
            );
        }else{
          return
            Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                title: Container(
                  constraints: const BoxConstraints(
                    minWidth: 10.0,
                    maxWidth: 240.0,
                  ),
                  color: Colors.white,
                  height: 38.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 10.0,
                            maxWidth: 200.0,
                          ),
                          child: Text(
                            widget.user.name,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child:  Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(child: Text('C',style: TextStyle(color: Colors.white,fontSize: 15),)),),
                        ),
                      ),
                    ],
                  ),
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
                     SliverToBoxAdapter(child: ProfileHeaderWidgetClubsv(userId: widget.user.userId,),
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
            );
        }
        
        }),
      );
  }
}

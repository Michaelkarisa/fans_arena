import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:fans_arena/fans/screens/results.dart';
import 'package:flutter/material.dart';
import '../../joint/data/sportsapi/sportsapi.dart';
import '../../joint/data/sportsapi/sportsmodel.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LineupFixtures extends StatefulWidget {
  int id;
   LineupFixtures({super.key,required this.id});

  @override
  State<LineupFixtures> createState() => _LineupFixturesState();
}

class _LineupFixturesState extends State<LineupFixtures> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,),
            onPressed: () {
              Navigator.of(context).pop();
            },//to next page},
          ),
          elevation: 1,
          backgroundColor: Colors.white,
          title: const Text('Match Details',style: TextStyle(color: Colors.black),),
        ),
        body: FutureBuilder<List<Lineup>>(
          future: SportsApiF().getFixtureLineups(widget.id.toString()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.blue,));
            } else if (snapshot.hasData) {
              final matches = snapshot.data!;
              if (matches.isEmpty) {
                return const Center(child: Text("No match data available."));
              }

              return ListView.builder(
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  final data = matches[index];
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 5,),
                        Text(data.team.name,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                        const SizedBox(height: 5,),
                        CachedNetworkImage(
                          imageUrl:data.team.logourl,
                          progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                            child: SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(
                                value: downloadProgress.progress,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Center(child: Icon(Icons.error,color: Colors.white,size: 40,)),
                        ),
                        const SizedBox(height: 5,),
                        Text('Formation:${data.formation}'),
                        const SizedBox(height: 5,),
                        const Text('Coach details',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                        const SizedBox(height: 5,),
                        Text('Name:${data.coach.name}'),
                        const SizedBox(height: 5,),
                        CachedNetworkImage(
                          width: 70,height: 70,
                          imageUrl:data.coach.photo,
                          progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                            child: SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(
                                value: downloadProgress.progress,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Center(child: Icon(Icons.error,color: Colors.white,size: 40,)),
                        ),
                        const SizedBox(height: 5,),
                        const Text('Starter',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                        const SizedBox(height: 5,),
                        DataTable(
                          columnSpacing: MediaQuery.of(context).size.width * 0.05,
                          columns: const [
                            DataColumn(label: Text('  ')),
                          DataColumn(label: Text('Player name')),
                          DataColumn(label: Text('Player pos')),
                          DataColumn(label: Text('Player no.'))
                        ], rows: data.startXI.map((player) {
                          int no=data.startXI.indexOf(player)+1;
                          return DataRow(
                            cells: [
                              DataCell(Text(no.toString())),
                              DataCell(Text(player.name)),
                              DataCell(Center(child: Text(player.pos))),
                              DataCell(Center(child: Text(player.number.toString()))),
                            ],
                          );}).toList(),),
                          const SizedBox(height: 5,),
                          const Text('Substitute',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                          const SizedBox(height: 5),

                        DataTable(
                          columnSpacing: MediaQuery.of(context).size.width * 0.05,
                          columns: const [
                            DataColumn(label: Text('   ')),
                            DataColumn(label: Text('Player name')),
                            DataColumn(label: Text('Player pos')),
                            DataColumn(label: Text('Player no.'))
                          ], rows: data.substitutes.map((player){
                            int no=data.substitutes.indexOf(player)+1;
                            return DataRow(
                          cells: [
                            DataCell(Text(no.toString())),
                            DataCell(Text(player.name)),
                            DataCell(Center(child: Text(player.pos))),
                            DataCell(Center(child: Text(player.number.toString()))),
                          ],
                        );}).toList(),),
                          index==0? const Padding(
                            padding: EdgeInsets.only(top:15,bottom: 15 ),
                            child: Text('VS',style: TextStyle(fontSize: 45,fontWeight: FontWeight.bold),),
                          ):const SizedBox.shrink(),
                      ],
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {

              return Center(child: Text("An error occurred. ${snapshot.error}"));
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class Highlights1 extends StatefulWidget {
  String genre;
   Highlights1({super.key,required this.genre});

  @override
  State<Highlights1> createState() => _Highlights1State();
}

class _Highlights1State extends State<Highlights1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,),
          onPressed: () {
            Navigator.of(context).pop();
          },//to next page},
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        title: const Text('Match Fixtures',style: TextStyle(color: Colors.black),),
      ),
      body: FutureBuilder<List<News>>(
        future: DataFetcher().fetchNews(genre: widget.genre),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue,));
          } else if (snapshot.hasData) {
            final matches = snapshot.data!;
            if (matches.isEmpty) {
              return const Text("No match data available.");
            }

            return ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: NewsWidget(data: match,),
                );
              },
            );
          } else if (snapshot.hasError) {
            print("Error: ${snapshot.error}");
            return Text("An error occurred. ${snapshot.error}");
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          }
        },
      ),
    );
  }
}

class MatchFixture extends StatefulWidget {
  String genre;
   MatchFixture({super.key,required this.genre});

  @override
  State<MatchFixture> createState() => _MatchFixtureState();
}

class _MatchFixtureState extends State<MatchFixture> {

  int itemcount=0;
  @override
  void initState(){
    super.initState();
    controller.addListener(() {
      if(controller.position.pixels==controller.position.maxScrollExtent){
        if(matchWidgets.length>6&&itemcount<matchWidgets.length){
          setState(() {
            isloading=true;
          itemcount=itemcount+2;
          });
        }else{
          setState(() {
            isloading=true;
          itemcount=matchWidgets.length;
              });
        }
        setState(() {
        });
      }
    });
  }


  List<Soccermatch>matches0=[];
  List<BasketBall>matches1=[];
  List<VOLLEYBALL>matches2=[];
  List<RUGBY>matches3=[];
  List<HOCKEY>matches4=[];
  List<BASEBALL>matches5=[];
  List<HANDBALL>matches6=[];
  List<NFL>matches7=[];
  List<GameResponse>matches8=[];
  List<RaceData>matches9=[];
  ScrollController controller=ScrollController();

  bool isloading=true;
Future<void> getdata()async{
  String date = '${_selectedDate?.year}-${_selectedDate?.month.toString().padLeft(2, '0')}-${_selectedDate?.day.toString().padLeft(2, '0')}';

  String date1='${_selectedDate?.year}';
  setState(() {
     matches0.clear();
     matchWidgets.clear();
  });
   if(widget.genre=="Football"){
    List<Soccermatch>matches=await SportsApiF().getAllMatches1(date);
    setState(() {
      matches0.addAll(matches);
      matchWidgets = matches0.map((m) => SoccermatchWidget1(m)).toList();
    });
  }else if(widget.genre=="Basketball"){
     List<BasketBall>matches=await SportsApiF().getAllMatchesbas1(date);
     setState(() {
       matches1.addAll(matches);
       matchWidgets = matches1.map((m) => BasketballWidget1(m)).toList();
     });
  }else if(widget.genre=="Volleyball"){
     List<VOLLEYBALL>matches=await SportsApiF().getAllMatchesvol1(date);
     setState(() {
       matches2.addAll(matches);
       matchWidgets = matches2.map((m) => VolleyballW1(m)).toList();
     });
  }else if(widget.genre=="Formula one"){
     List<RaceData>matches=await SportsApiF().getAllMatchesf11(date1);
     setState(() {
       matches9.addAll(matches);
       matchWidgets = matches9.map((m) => F1Widget1(f1: m)).toList();
     });
  }else if(widget.genre=="Tennis"){

  }else if(widget.genre=="Cricket"){

  }else if(widget.genre=="Rugby"){
     List<RUGBY>matches=await SportsApiF().getAllMatchesrby1(date);
     setState(() {
       matches3.addAll(matches);
       matchWidgets = matches3.map((m) => RugbyW1(m)).toList();
     });
  }else if(widget.genre=="Cycling"){
     setState(() {
       matchWidgets = [Text('Not Available')];
     });
  }else if(widget.genre=="Marathon"){
     setState(() {
       matchWidgets = [Text('Not Available')];
     });
  }else if(widget.genre=="Swimming"){
     setState(() {
       matchWidgets = [Text('Not Available')];
     });
  }else if(widget.genre=="Golf"){
     setState(() {
       matchWidgets = [Text('Not Available')];
     });
  }else if(widget.genre=="Hockey"){
     List<HOCKEY>matches=await SportsApiF().getAllMatcheshky1(date);
     setState(() {
       matches4.addAll(matches);
       matchWidgets = matches4.map((m) => HockeyW1(m)).toList();
     });
  }else if(widget.genre=="Motorsport"){
     setState(() {
       matchWidgets = [Text('Not Available')];
     });
  }else if(widget.genre=="Horse racing"){
     setState(() {
       matchWidgets = [Text('Not Available')];
     });
  }else if(widget.genre=="Netball"){
     setState(() {
       matchWidgets = [Text('Not Available')];
     });
  }else if(widget.genre=="Wrestling"){
     setState(() {
       matchWidgets = [Text('Not Available')];
     });
  }else if(widget.genre=="Boxing"){
     setState(() {
       matchWidgets = [Text('Not Available')];
     });
  }else if(widget.genre=="Polo"){
     setState(() {
       matchWidgets = [Text('Not Available')];
     });
  }else if(widget.genre=="Rally"){
     setState(() {
       matchWidgets = [Text('Not Available')];
     });
  }else if(widget.genre=="Baseball"){
     List<BASEBALL>matches=await SportsApiF().getAllMatchesbsb1(date);
     setState(() {
       matches5.addAll(matches);
       matchWidgets = matches5.map((m) => BaseballWidget1(m)).toList();
     });
  }else if(widget.genre=="chess"){
     setState(() {
       matchWidgets = [Text('Not Available')];
     });
  }else if(widget.genre=="Handball"){
     List<HANDBALL>matches=await SportsApiF().getAllMatcheshb1(date);
     setState(() {
       matches6.addAll(matches);
       matchWidgets = matches6.map((m) => HandballWidget1(m)).toList();
     });
  }else if(widget.genre=="Badminton"){
     setState(() {
       matchWidgets = [Text('Not Available')];
     });
  }else if(widget.genre=="NFL"){
     List<NFL>matches=await SportsApiF().getAllMatchesab1(date);
     setState(() {
       matches7.addAll(matches);
       matchWidgets = matches7.map((m) => NflWidget1(m)).toList();
     });
  }else if(widget.genre=="NBA"){
     List<GameResponse>matches=await SportsApiF().fetchNBAData1(date);
     setState(() {
       matches8.addAll(matches);
       matchWidgets = matches8.map((m) => NBAW1(m)).toList();
     });
  }else{
     setState(() {
       matchWidgets = [Text('Unknown')];
     });
  }
   setState(() {
     isloading=false;
     if(matchWidgets.length<7) {
       itemcount = matchWidgets.length;
     }else{
       itemcount=7;
     }

   });
}
  DateTime? _selectedDate;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.utc(2050),

    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  List<Widget> matchWidgets = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,),
          onPressed: () {
            Navigator.of(context).pop();
          },//to next page},
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        title: const Text('Match Fixtures',style: TextStyle(color: Colors.black),),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  if(widget.genre=="Football"){
                    return SearchMatch(match: matches0);
                  }else if(widget.genre=="Basketball"){
                    return SearchMatch(match: matches0);
                  }else if(widget.genre=="Volleyball"){
                    return SearchMatch(match: matches0);
                  }else if(widget.genre=="Formula one"){
                    return SearchMatch(match: matches0);
                  }else if(widget.genre=="Tennis"){
                    return SearchMatch(match: matches0);
                  }else if(widget.genre=="Cricket"){
                    return SearchMatch(match: matches0);
                  }else if(widget.genre=="Rugby"){
                    return SearchMatch(match: matches0);
                  }else if(widget.genre=="Cycling"){
                    return SearchMatch(match: matches0);
                  }else if(widget.genre=="Marathon"){
                    return SearchMatch(match: matches0);
                  }else if(widget.genre=="Swimming"){
                    return SearchMatch(match: matches0);
                  }else if(widget.genre=="Golf"){
                    return SearchMatch(match: matches0);
                  }else if(widget.genre=="Hockey"){
                    return SearchMatchhky(matchhky: matches4);
                  }else if(widget.genre=="Motorsport"){
                    return SearchMatch(match: matches0);
                  }else if(widget.genre=="Horse racing"){
                    return SearchMatch(match: matches0);
                  }else if(widget.genre=="Netball"){
                    return SearchMatch(match: matches0);
                  }else if(widget.genre=="Wrestling"){
                    return SearchMatch(match: matches0);
                  }else if(widget.genre=="Boxing"){
                    return SearchMatch(match: matches0);
                  }else if(widget.genre=="Polo"){
                    return SearchMatch(match: matches0);
                  }else if(widget.genre=="Rally"){
                    return SearchMatch(match: matches0);
                  }else if(widget.genre=="Baseball"){
                    return SearchMatch(match: matches0);
                  }else if(widget.genre=="chess"){
                    return SearchMatch(match: matches0);
                  }else if(widget.genre=="Handball"){
                    return SearchMatch(match: matches0);
                  }else if(widget.genre=="Badminton"){
                    return SearchMatch(match: matches0);
                  }else if(widget.genre=="NFL"){
                    return SearchMatchnfl(matchnfl: matches7);
                  }else if(widget.genre=="NBA"){
                    return SearchMatch(match: matches0);
                  }else{
                    return SearchMatch(match: matches0);
                  }
                }));
              }, icon: const Icon(Icons.search))
            ],
          )
        ],
      ),
    body: NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
         SliverToBoxAdapter(child:Column(
          children: [
            const Text('Choose date'),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width*0.6,
              height: 38,
              child: TextFormField(
                  onTap: () {
                    _selectDate(context);
                  },
                  readOnly: true,
                  controller: TextEditingController(
                    text: _selectedDate != null
                        ? "${_selectedDate!.toLocal()}".split(' ')[0]
                        : '',
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors
                              .grey),
                      borderRadius: BorderRadius
                          .circular(8),
                    ),
                    hintText: 'Date',
                    labelText: 'Date',
                  )),
            ),
            const SizedBox(
              height: 5,
            ),
            OutlinedButton(onPressed: (){
              getdata();
            }, child:const Text('Get data') ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
        ),];
      },
      body: RefreshIndicator(
          onRefresh: ()async{
           await getdata();
          },
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            controller: controller,
            shrinkWrap: true,
            itemCount:itemcount+1,
            itemBuilder: (context, index) {
              if (index == itemcount) {
                if (isloading) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return const SizedBox.shrink();
                }
              } else {

                return matchWidgets[index];
              }
            },
          ),

      ),
    ),
    );
  }
}


class SearchMatch extends StatefulWidget {
  List<Soccermatch> match;
  SearchMatch({super.key,required this.match});

  @override
  State<SearchMatch> createState() => _SearchMatchState();
}

class _SearchMatchState extends State<SearchMatch> {

  List<String> clubs=[];
  List<Soccermatch> matches=[];
  @override
  void initState(){
    super.initState();
    for(final item in widget.match){
      clubs.add(item.away.name);
      clubs.add(item.home.name);
    }
  }
  String _searchQuery = '';
  bool _showCloseIcon = false;
  final TextEditingController _controller = TextEditingController();
  String y='';
  @override
  Widget build(BuildContext context) {
    return  SafeArea(
        child: Scaffold(
            appBar: AppBar(
                elevation: 1,
                title: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8,bottom: 8,right: 30),
                    child: SizedBox(
                      height: 39,
                      width:MediaQuery.of(context).size.width * 0.75,
                      child: TextFormField(
                        scrollPadding: const EdgeInsets.only(left: 10),
                        textAlign: TextAlign.left,
                        textAlignVertical: TextAlignVertical.center,
                        cursorColor: Colors.black,
                        controller: _controller,
                        textInputAction: TextInputAction.search,
                        onChanged: (value) {
                          setState(() {
                          matches = widget.match.where((match) =>
                          match.home.name.toLowerCase().contains(value.toLowerCase()) ||
                              match.away.name.toLowerCase().contains(value.toLowerCase())).toList();

                            _searchQuery = value;
                            _showCloseIcon = value.isNotEmpty;
                          });
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 10),
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
                                _searchQuery=y;
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
                )),
        body: ListView.builder(
        itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return SoccermatchWidget1(match);
          },
        ),

    ));
  }
}


class SearchMatchnfl extends StatefulWidget {
  List<NFL> matchnfl;
  SearchMatchnfl({super.key,required this.matchnfl});

  @override
  State<SearchMatchnfl> createState() => _SearchMatchnflState();
}

class _SearchMatchnflState extends State<SearchMatchnfl> {

  List<String> clubs=[];
  List<NFL> matches=[];
  @override
  void initState(){
    super.initState();
    for(final item in widget.matchnfl){
      clubs.add(item.away.name);
      clubs.add(item.home.name);
    }
  }
  String _searchQuery = '';
  bool _showCloseIcon = false;
  final TextEditingController _controller = TextEditingController();
  String y='';
  @override
  Widget build(BuildContext context) {
    return  SafeArea(
        child: Scaffold(
          appBar: AppBar(
              elevation: 1,
              title: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8,bottom: 8,right: 30),
                  child: SizedBox(
                    height: 39,
                    width:MediaQuery.of(context).size.width * 0.75,
                    child: TextFormField(
                      scrollPadding: const EdgeInsets.only(left: 10),
                      textAlign: TextAlign.left,
                      textAlignVertical: TextAlignVertical.center,
                      cursorColor: Colors.black,
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) {
                        setState(() {
                          matches = widget.matchnfl.where((match) =>
                          match.home.name.toLowerCase().contains(value.toLowerCase()) ||
                              match.away.name.toLowerCase().contains(value.toLowerCase())).toList();

                          _searchQuery = value;
                          _showCloseIcon = value.isNotEmpty;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 10),
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
                              _searchQuery=y;
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
              )),
          body: ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return NflWidget1(match);
            },
          ),

        ));
  }
}


class SearchMatchhky extends StatefulWidget {
  List<HOCKEY> matchhky;
  SearchMatchhky({super.key,required this.matchhky});

  @override
  State<SearchMatchhky> createState() => _SearchMatchhkyState();
}

class _SearchMatchhkyState extends State<SearchMatchhky> {

  List<String> clubs=[];
  List<HOCKEY> matches=[];
  @override
  void initState(){
    super.initState();
    for(final item in widget.matchhky){
      clubs.add(item.away.name);
      clubs.add(item.home.name);
    }
  }
  String _searchQuery = '';
  bool _showCloseIcon = false;
  final TextEditingController _controller = TextEditingController();
  String y='';
  @override
  Widget build(BuildContext context) {
    return  SafeArea(
        child: Scaffold(
          appBar: AppBar(
              elevation: 1,
              title: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8,bottom: 8,right: 30),
                  child: SizedBox(
                    height: 39,
                    width:MediaQuery.of(context).size.width * 0.75,
                    child: TextFormField(
                      scrollPadding: const EdgeInsets.only(left: 10),
                      textAlign: TextAlign.left,
                      textAlignVertical: TextAlignVertical.center,
                      cursorColor: Colors.black,
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) {
                        setState(() {
                          matches = widget.matchhky.where((match) =>
                          match.home.name.toLowerCase().contains(value.toLowerCase()) ||
                              match.away.name.toLowerCase().contains(value.toLowerCase())).toList();

                          _searchQuery = value;
                          _showCloseIcon = value.isNotEmpty;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 10),
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
                              _searchQuery=y;
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
              )),
          body: ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return HockeyW1(match);
            },
          ),

        ));
  }
}
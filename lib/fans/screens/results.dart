import 'package:fans_arena/joint/data/sportsapi/sportsmodel.dart';
import 'package:flutter/material.dart';
import '../../joint/data/sportsapi/sportsapi.dart';
import 'highlights.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'newsfeed.dart';
class Results extends StatefulWidget {
  String genre;
  Results({super.key,required this.genre});

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  final int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,),
          onPressed: () {
            Navigator.of(context).pop();
          },//to next page},
        ),
        elevation: 1,
        title: const Text('Sports News',style: TextStyle(color: Colors.black),),
      ),
      body: FutureBuilder<List<News>>(
        future: DataFetcher().fetchNews(genre: widget.genre),
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
                final match = matches[index];
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: NewsWidget1(data: match,),
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

    );
  }
}

class SoccermatchWidget extends StatelessWidget {
  final Football match;
  const SoccermatchWidget(this.match, {super.key});
  String convertUtcToEventTime(String utcTimestamp) {
    // Parse the UTC timestamp string into a DateTime object
    DateTime utcTime = DateTime.parse(utcTimestamp);

    // Convert the UTC time to local time
    DateTime localTime = utcTime.toLocal();

    // Format the local time using the desired format
    String formattedTime = DateFormat('HH:mm').format(localTime);

    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    String time=convertUtcToEventTime(match.fixture.dates);
    return InkWell(
      onTap: (){
        Navigator.push(context,
          MaterialPageRoute(builder: (context) =>  LineupFixtures(id:match.fixture.id,),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          match.league.id.toString().isNotEmpty||match.league!=null?Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 3),
              Text(match.league.name),
              const SizedBox(height: 3),
              CachedNetworkImage(
                height: 50,
                width: 50,
                imageUrl:match.league.logo,
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
           //   match.league.season!=null?Text(match.league.season,):const SizedBox.shrink(),
              const SizedBox(height: 8),
            ],
          ):const SizedBox.shrink(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             SizedBox(
               width: 106,
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                   const SizedBox(height: 30),
                   CachedNetworkImage(
                     height: 50,
                     width: 50,
                     imageUrl:match.home.logourl,
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
                   FittedBox(
                     fit: BoxFit.scaleDown,
                     child: Container(
                       constraints: const BoxConstraints(
                         minWidth: 10.0,
                         maxWidth: 106.0,
                       ),
                       child: Center(
                         child: Text(
                           maxLines:1,
                           ' ${match.home.name}',overflow: TextOverflow.ellipsis,
                           style: const TextStyle(fontSize: 14),
                         ),
                       ),
                     ),
                   ),
                 ],
               ),
             ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  match.fixture.status.short,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                match.fixture.status.short=="NS"? Text(time,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),):Text(
                  '${match.fixture.status.elapsedTime}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text("${match.goal.home} - ${match.goal.away}",style: const TextStyle(fontSize: 28),),
                const SizedBox(height: 30),
              ],
            ),
              SizedBox(
                width: 106,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    SizedBox(
                        height: 50,
                        width: 50,
                        child: CachedNetworkImage(
                          height: 50,
                          width: 50,
                          imageUrl:match.away.logourl,
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
                        )),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 10.0,
                          maxWidth: 106.0,
                        ),
                        child: Center(
                          child: Text(
                            maxLines:1,
                            match.away.name,overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }
}


class BasketballWidget extends StatelessWidget {
  final BasketBall match;
  const BasketballWidget(this.match, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          match.status.short,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          match.time,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        fit: BoxFit.cover,
                        height: 50,
                        width: 50,
                        imageUrl:match.home.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines:1,
                          ' ${match.home.name}',overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text("${match.scores.hscores.totalHome} - ${match.scores.ascores.totalAway}",style: const TextStyle(fontSize: 28),),
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        fit: BoxFit.cover,
                        height: 50,
                        width: 50,
                        imageUrl:match.away.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines:1,
                          match.away.name,overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ],
    );
  }
}



class NBAWc extends StatelessWidget {
  final Nba nba;
  const NBAWc(this.nba, {super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${nba.status.short}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            nba.status.clock,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 106,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 50,
                        width: 50,
                        child: CachedNetworkImage(
                          height: 50,
                          width: 50,
                          imageUrl:nba.teams.home.logo,
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
                        )),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 10.0,
                          maxWidth: 106.0,
                        ),
                        child: Center(
                          child: Text(
                            maxLines: 1,
                            ' ${nba.teams.home.name}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Text("${nba.scores.home.points} - ${nba.scores.visitors.points}",
                style: const TextStyle(fontSize: 28),),
              SizedBox(
                width: 106,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 50,
                        width: 50,
                        child: CachedNetworkImage(
                          height: 50,
                          width: 50,
                          imageUrl:nba.teams.visitors.logo,
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
                        )),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 10.0,
                          maxWidth: 106.0,
                        ),
                        child: Center(
                          child: Text(
                            maxLines: 1,
                            nba.teams.visitors.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ],
    );
  }
}

//Volleyball
class VolleyballW extends StatelessWidget {
  final Volleyball vol;
  const VolleyballW(this.vol, {super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          vol.status.short,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          vol.time,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child: CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.home.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          ' ${vol.home.name}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text("${vol.scores.home} - ${vol.scores.away}",
              style: const TextStyle(fontSize: 28),),
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.away.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          vol.away.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ],
    );
  }
}


//Rugby
class RugbyW extends StatelessWidget {
  final Rugby vol;
  const RugbyW(this.vol, {super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          vol.status.short,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          vol.time,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.home.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          ' ${vol.home.name}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text("${vol.scores.home} - ${vol.scores.away}",
              style: const TextStyle(fontSize: 28),),
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.away.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          vol.away.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ],
    );
  }
}


//Hockey
class HockeyW extends StatelessWidget {
  final Hockey vol;
  const HockeyW(this.vol, {super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          vol.status.short,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          vol.time,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.home.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          ' ${vol.home.name}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text("${vol.scores.home} - ${vol.scores.away}",
              style: const TextStyle(fontSize: 28),),
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child: CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.away.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          vol.away.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ],
    );
  }
}

//Handball
class HandballWidget extends StatelessWidget {
  final Handball vol;
  const HandballWidget(this.vol, {super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          vol.status.short,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          vol.time,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.home.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          ' ${vol.home.name}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text("${vol.goal.home} - ${vol.goal.away}",
              style: const TextStyle(fontSize: 28),),
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.away.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          vol.away.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ],
    );
  }
}

//Baseball
class BaseballWidget extends StatelessWidget {
  final Baseball vol;
  const BaseballWidget(this.vol, {super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          vol.status.short,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          vol.time,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.home.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          ' ${vol.home.name}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text("${vol.baseballScores.home.total} - ${vol.baseballScores.away.total}",
              style: const TextStyle(fontSize: 28),),
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.away.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          vol.away.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ],
    );
  }
}


//Nfl
class NflWidget extends StatelessWidget {
  final Nfl vol;
  const NflWidget(this.vol, {super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          vol.game.status.short,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          vol.game.date.time,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.home.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          ' ${vol.home.name}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text("${vol.scores.hscores.totalHome} - ${vol.scores.ascores.totalAway}",
              style: const TextStyle(fontSize: 28),),
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.away.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          vol.away.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ],
    );
  }
}

class F1Widget extends StatelessWidget {
  final Formula1 f1;
  const F1Widget({super.key,required this.f1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(f1.season.toString()),
        Text(f1.competition.name),
        SizedBox(
            height: 100,
            width: 100,
            child:  CachedNetworkImage(
              height: 100,
              width: 100,
              imageUrl:f1.circuit.image,
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
            )),
        Text(f1.competition.location.country),

      ],
    );
  }
}


class SoccermatchWidget1 extends StatelessWidget {
  final Soccermatch match;
  const SoccermatchWidget1(this.match, {super.key});
  String convertUtcToEventTime(String utcTimestamp) {
    // Parse the UTC timestamp string into a DateTime object
    DateTime utcTime = DateTime.parse(utcTimestamp);

    // Convert the UTC time to local time
    DateTime localTime = utcTime.toLocal();

    // Format the local time using the desired format
    String formattedTime = DateFormat('HH:mm').format(localTime);

    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    String time=convertUtcToEventTime(match.fixture.dates);
    return InkWell(
      onTap: (){
        Navigator.push(context,
          MaterialPageRoute(builder: (context) =>  LineupFixtures(id:match.fixture.id,),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Text(
            match.fixture.status.short,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          match.fixture.status.short=="NS"? Text(time,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),):Text(
            '${match.fixture.status.elapsedTime}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 106,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 50,
                        width: 50,
                        child:  CachedNetworkImage(
                          height: 50,
                          width: 50,
                          imageUrl:match.home.logourl,
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
                        )),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 10.0,
                          maxWidth: 106.0,
                        ),
                        child: Center(
                          child: Text(
                            maxLines:1,
                            ' ${match.home.name}',overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Text("${match.goal.home} - ${match.goal.away}",style: const TextStyle(fontSize: 28),),
              SizedBox(
                width: 106,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 50,
                        width: 50,
                        child: CachedNetworkImage(
                          height: 50,
                          width: 50,
                          imageUrl:match.away.logourl,
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
                        )),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 10.0,
                          maxWidth: 106.0,
                        ),
                        child: Center(
                          child: Text(
                            maxLines:1,
                            match.away.name,overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }
}


class BasketballWidget1 extends StatelessWidget {
  final BasketBall match;
  const BasketballWidget1(this.match, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          match.status.short,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          match.time,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        fit: BoxFit.cover,
                        height: 50,
                        width: 50,
                        imageUrl:match.home.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines:1,
                          ' ${match.home.name}',overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text("${match.scores.hscores.totalHome} - ${match.scores.ascores.totalAway}",style: const TextStyle(fontSize: 28),),
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        fit: BoxFit.cover,
                        height: 50,
                        width: 50,
                        imageUrl:match.away.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines:1,
                          match.away.name,overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ],
    );
  }
}



class NBAW1 extends StatelessWidget {
  final GameResponse nba;
  const NBAW1(this.nba, {super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${nba.status.short}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          nba.status.clock,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child: CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:nba.teams.home.logo,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          ' ${nba.teams.home.name}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text("${nba.scores.home.points} - ${nba.scores.visitors.points}",
              style: const TextStyle(fontSize: 28),),
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child: CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:nba.teams.visitors.logo,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          nba.teams.visitors.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ],
    );
  }
}

//Volleyball
class VolleyballW1 extends StatelessWidget {
  final VOLLEYBALL vol;
  const VolleyballW1(this.vol, {super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          vol.status.short,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          vol.time,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child: CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.home.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          ' ${vol.home.name}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text("${vol.scores.home} - ${vol.scores.away}",
              style: const TextStyle(fontSize: 28),),
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.away.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          vol.away.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ],
    );
  }
}


//Rugby
class RugbyW1 extends StatelessWidget {
  final RUGBY vol;
  const RugbyW1(this.vol, {super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          vol.status.short,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          vol.time,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.home.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          ' ${vol.home.name}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text("${vol.scores.home} - ${vol.scores.away}",
              style: const TextStyle(fontSize: 28),),
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.away.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          vol.away.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ],
    );
  }
}


//Hockey
class HockeyW1 extends StatelessWidget {
  final HOCKEY vol;
  const HockeyW1(this.vol, {super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          vol.status.short,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          vol.time,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.home.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          ' ${vol.home.name}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text("${vol.scores.home} - ${vol.scores.away}",
              style: const TextStyle(fontSize: 28),),
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child: CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.away.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          vol.away.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ],
    );
  }
}

//Handball
class HandballWidget1 extends StatelessWidget {
  final HANDBALL vol;
  const HandballWidget1(this.vol, {super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          vol.status.short,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          vol.time,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.home.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          ' ${vol.home.name}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text("${vol.goal.home} - ${vol.goal.away}",
              style: const TextStyle(fontSize: 28),),
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.away.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          vol.away.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ],
    );
  }
}

//Baseball
class BaseballWidget1 extends StatelessWidget {
  final BASEBALL vol;
  const BaseballWidget1(this.vol, {super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          vol.status.short,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          vol.time,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.home.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          ' ${vol.home.name}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text("${vol.baseballScores.home.total} - ${vol.baseballScores.away.total}",
              style: const TextStyle(fontSize: 28),),
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.away.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          vol.away.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ],
    );
  }
}


//Nfl
class NflWidget1 extends StatelessWidget {
  final NFL vol;
  const NflWidget1(this.vol, {super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          vol.game.status.short,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          vol.game.date.time,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.home.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          ' ${vol.home.name}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text("${vol.scores.hscores.totalHome} - ${vol.scores.ascores.totalAway}",
              style: const TextStyle(fontSize: 28),),
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child:  CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl:vol.away.logourl,
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
                      )),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 10.0,
                        maxWidth: 106.0,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          vol.away.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ],
    );
  }
}

class F1Widget1 extends StatelessWidget {
  final RaceData f1;
  const F1Widget1({super.key,required this.f1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(f1.season.toString()),
        Text(f1.competition.name),
        SizedBox(
            height: 100,
            width: 100,
            child:  CachedNetworkImage(
              height: 100,
              width: 100,
              imageUrl:f1.circuit.image,
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
            )),
        Text(f1.competition.location.country),

      ],
    );
  }
}

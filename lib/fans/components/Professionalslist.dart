import 'package:fans_arena/fans/bloc/accountchecker11.dart';
import 'package:fans_arena/fans/bloc/usernamedisplay.dart';
import 'package:flutter/material.dart';
import '../../professionals/screens/accountprofilepviewer.dart';
import '../../reusablewidgets/cirularavatar.dart';
import '../screens/newsfeed.dart';

class Professionallist extends StatefulWidget {
  String userId;
  Professionallist({super.key,required this.userId});

  @override
  State<Professionallist> createState() => _ProfessionallistState();
}
class _ProfessionallistState extends State<Professionallist> {
  String ex="Failed host lookup: 'us-central1-fans-arena.cloudfunctions.net'";
  double radius=23;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:   FutureBuilder<List<Universalitem>>(
            future: DataFetcher().getanydata(docId: widget.userId,collection: 'Fans',subcollection: 'professionals'),
            builder: (context, snapshot){
              if(snapshot.hasError){
                if(snapshot.error.toString()==ex){
                  return Center(child: Text('No Internet'));
                }else{
                  return Center(child: Text('${snapshot.error}'));
                }
              }else if(snapshot.hasData){
                List<Universalitem>data=snapshot.data!;
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final user = data[index].item;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: ListTile(
                          leading: CustomAvatar( radius: radius, imageurl: user.url),
                          title:  InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AccountprofilePviewer(user:user, index: 0),
                                ),
                              );
                            },
                            child:  UsernameDO(
                              username:user.name,
                              collectionName:user.collectionName,
                              width: 160,
                              height: 38,
                              maxSize: 140,
                            ),
                          ),
                          trailing: SizedBox(
                              width: 100,
                              child: Accountchecker11(user:user,))
                      ),
                    );
                  },
                );}else{
                return const LFShimmer();
              }
            })

    );
  }
}

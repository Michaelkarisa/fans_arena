import 'package:fans_arena/fans/screens/messages.dart';
import 'package:flutter/material.dart';
import 'package:fans_arena/fans/bloc/accountchecker9.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fans/bloc/usernamedisplay.dart';
import '../../fans/components/likebutton.dart';
import '../../reusablewidgets/cirularavatar.dart';
import 'package:intl/intl.dart';
class Storyviewers extends StatefulWidget {
  List<Map<String,dynamic>> data;
  Storyviewers({super.key,required this.data});
  @override
  State<Storyviewers> createState() => _StoryviewersState();
}
class _StoryviewersState extends State<Storyviewers> {
  @override
  Widget build(BuildContext context) {
    return  DraggableScrollableSheet(
      initialChildSize: 0.2,
      maxChildSize: 0.7,
      minChildSize: 0.2,
      builder:(_, controller)=> Padding(
        padding: const EdgeInsets.only(left: 5,right: 5),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(topLeft:Radius.circular(20),topRight: Radius.circular(20)),
            color: Colors.grey[200],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 8,
                width: 100,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Divider(thickness: 4,color: Colors.grey[700],)),
              ),
              Center(
                child: SizedBox(
                    height: 25,
                    width: 150,
                    child: LikesCountWidget(totalLikes: widget.data.length,)),
              ),
              Expanded(
                child:ListView.builder(
                  itemCount: widget.data.length,
                  controller: controller,
                  itemBuilder: (context, index) {
                    final like = widget.data[index];
                    Timestamp createdAt = like['timestamp'];
                    DateTime createdDateTime = createdAt.toDate();
                    DateTime now = DateTime.now();
                    Duration difference = now.difference(createdDateTime);
                    String formattedTime = '';
                    if (difference.inSeconds == 1) {
                      formattedTime = '${difference.inSeconds} second ago';
                    } else if (difference.inSeconds < 60) {
                      formattedTime = '${difference.inMinutes} seconds ago';
                    } else if (difference.inMinutes ==1) {
                      formattedTime = '${difference.inMinutes} minute ago';
                    } else if (difference.inMinutes < 60) {
                      formattedTime = '${difference.inMinutes} minutes ago';
                    } else if (difference.inHours == 1) {
                      formattedTime = '${difference.inHours} hour ago';
                    } else if (difference.inHours < 24) {
                      formattedTime = '${difference.inHours} hours ago';
                    } else if (difference.inDays == 1) {
                      formattedTime = '${difference.inDays} day ago';
                    } else if (difference.inDays < 7) {
                      formattedTime = '${difference.inDays} days ago';
                    } else if (difference.inDays == 7) {
                      formattedTime = '${difference.inDays ~/ 7} week ago';
                    } else {
                      formattedTime = DateFormat('d MMM').format(createdDateTime);
                    }
                    String hours = DateFormat('HH').format(createdDateTime);
                    String minutes = DateFormat('mm').format(createdDateTime);
                    String t = DateFormat('a').format(createdDateTime); // AM/PM
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: ListTile(
                          leading:CustomUsernameD0Avatar(userId: like['userId'],
                            style: const TextStyle(color: Colors.black,fontSize: 16),
                            radius: 14,
                            maxsize: 160,
                            height: 25,
                            width: 195,),
                          trailing:Text('$formattedTime at $hours:$minutes $t')
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
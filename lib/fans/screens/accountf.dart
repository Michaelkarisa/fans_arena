import 'package:fans_arena/appid.dart';
import 'package:fans_arena/joint/data/screens/feed_item.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../joint/components/Played.dart';
import '../../joint/components/recently.dart';
import '../data/newsfeedmodel.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fans_arena/fans/components/bottomnavigationbar.dart';
import 'package:fans_arena/joint/screens/camera.dart';
import 'newsfeed.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({super.key});

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  TextEditingController email= TextEditingController();
  TextEditingController gender= TextEditingController();
  TextEditingController DoB= TextEditingController();
  TextEditingController Phonenumber= TextEditingController();
  String username1 = '';
  String favourite1 = '';
  String bio1 = '';
  String website1 = '';
  String imageurl = '';
  String email1 = '';
  String userId='';
  @override
  void initState(){
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      retrieveUsername();
    }
  }
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  void retrieveUsername() async {
    try {
      DocumentSnapshot documentSnapshot = await firestore
          .collection('Fans')
          .doc(userId)
          .get();

      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          gender.text = data['gender'];
          email.text = data['email'];
          DoB.text = data['birthday'];
          Phonenumber.text = data['phonenumber'];
        });
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving username: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        },icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,)),
        title: const Text('Personal Information',style: TextStyle(color: Colors.black,),),),
      body: Column(
        children: [
          const Text("This won't be part of your public profile unless you deem so."),
          const SizedBox(height: 20,),
          const Text('Email address'),
          TextFormField(
              controller: email,
            decoration: const InputDecoration(
                suffixIcon: Icon(Icons.arrow_forward_ios,color: Colors.black,),
            labelText: 'Email address'
            ),
          ),
          const SizedBox(height: 20,),
          const Text('Phone number'),
          TextFormField(
          controller: Phonenumber,
            decoration: const InputDecoration(
                suffixIcon: Icon(Icons.arrow_forward_ios,color: Colors.black,),
             labelText:'Phone number'
            ),
          ),
          const SizedBox(height: 20,),
          const Text('Gender'),
          TextFormField(
           controller: gender,
            decoration: const InputDecoration(
                suffixIcon: Icon(Icons.arrow_forward_ios,color: Colors.black,),
            labelText: 'Gender'
            ),
          ),
          const SizedBox(height: 20,),
          const Text('Date of Birth'),
          TextFormField(
          controller: DoB,
            decoration: const InputDecoration(
                suffixIcon: Icon(Icons.arrow_forward_ios,color: Colors.black,),
           labelText: 'Date of Birth'
            ),
          ),
        ],
      ),
    );
  }
}


class Interactions extends StatefulWidget {
  const Interactions({super.key});

  @override
  State<Interactions> createState() => _InteractionsState();
}

class _InteractionsState extends State<Interactions> {
  List<Posts> posts = [];
  ScrollController controller = ScrollController();
  DataFetcher news = DataFetcher();
  late Posts lastPost;
  String userId='';
  @override
  void initState() {
    super.initState();
    setState(() {
      userId=FirebaseAuth.instance.currentUser!.uid;
    });
    getPosts();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        loadMore();
      }
    });
  }

  void getPosts() async {
    List<Posts> post = await news.getPostsForFollowedUsers(userId);
    setState(() {
      posts.addAll(post);
      if (post.isNotEmpty) {
        lastPost = post.last;
      }
    });
  }

  Future<void> loadMore() async {
    List<Posts> morePosts = await news.getmorePostsForFollowedUsers(userId, lastPost.postid);
    setState(() {
      posts.addAll(morePosts);
      if (morePosts.isNotEmpty) {
        lastPost = morePosts.last;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: const Text('Posts you interacted with',style: TextStyle(color: Colors.black),),),
      body: ListView.builder(
              scrollDirection: Axis.vertical,
              controller: controller,
              itemCount: posts.length+1,
              itemBuilder: (context, index) {
                if (index == posts.length) {
                  return const PostLShimer();
                }
                final post = posts[index];
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: PostLayout(post: post)),
                );

              },
            ),
    );
  }
}
class MatchesInteracted extends StatefulWidget {
  const MatchesInteracted({super.key});

  @override
  State<MatchesInteracted> createState() => _MatchesInteractedState();
}

class _MatchesInteractedState extends State<MatchesInteracted> {
  List<MatchM> posts = [];
  ScrollController controller = ScrollController();
  Newsfeedservice news = Newsfeedservice();
  late MatchM lastPost;
  String userId='';
  @override
  void initState() {
    super.initState();
    news = Newsfeedservice();
    setState(() {
      userId=FirebaseAuth.instance.currentUser!.uid;
    });
    getPosts();
    controller.addListener(() {
      if (controller.position.pixels >= controller.position.maxScrollExtent*0.5) {
       // loadMore();
      }
    });
  }

  void getPosts() async {
    List<MatchM> post = await DataFetcher().getmatcheswatched(userId);
    setState(() {
      posts.addAll(post);
      if (post.isNotEmpty) {
        lastPost = post.last;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: const Text('Matches you watched',style: TextStyle(color: Colors.black),),),
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        controller: controller,
        itemCount: posts.length+1,
        itemBuilder: (context, index) {
          if (index == posts.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final post = posts[index];
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: RLayout(matches: post)),
          );

        },
      ),
    );
  }
}
class EventsInteracted extends StatefulWidget {
  const EventsInteracted({super.key});

  @override
  State<EventsInteracted> createState() => _EventsInteractedState();
}

class _EventsInteractedState extends State<EventsInteracted> {
  List<EventM> posts = [];
  ScrollController controller = ScrollController();
  late EventM lastPost;
  @override
  void initState() {
    super.initState();
    getPosts();
    controller.addListener(() {
      if (controller.position.pixels >= controller.position.maxScrollExtent*0.5) {

      }
    });
  }

  void getPosts() async {
    List<EventM> post = await DataFetcher().geteventswatched(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      posts.addAll(post);
      if (post.isNotEmpty) {
        lastPost = post.last;
      }
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: const Text('Events you watched',style: TextStyle(color: Colors.black),),),
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        controller: controller,
        itemCount: posts.length+1,
        itemBuilder: (context, index) {
          if (index == posts.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final post = posts[index];
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: PdLayout(matches: post)),
          );

        },
      ),
    );
  }
}

class InteractionF extends StatefulWidget {
  const InteractionF({super.key});

  @override
  State<InteractionF> createState() => _InteractionFState();
}

class _InteractionFState extends State<InteractionF> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          title: const Text('Interactions',style: TextStyle(color: Colors.black),),),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: InkWell(
              onTap: (){ Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Interactions(),
                ),
              );},
              child: Container(
                height: 50,
                color: Colors.grey[200],
                width: MediaQuery.of(context).size.width,
                child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Posts you interacted with'),
                    )),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: InkWell(
              onTap: (){ Navigator.push(context,
                MaterialPageRoute(builder: (context) =>  const InteractionsFansTv(),
                ),
              );},
              child: Container(
                height: 50,
                color: Colors.grey[200],
                width: MediaQuery.of(context).size.width,
                child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('FansTvs you interacted with'),
                    )),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: InkWell(
              onTap: (){ Navigator.push(context,
                MaterialPageRoute(builder: (context) => const MatchesInteracted(),
                ),
              );},
              child: Container(
                height: 50,
                color: Colors.grey[200],
                width: MediaQuery.of(context).size.width,
                child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Matches you watched'),
                    )),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: InkWell(
              onTap: (){ Navigator.push(context,
                MaterialPageRoute(builder: (context) => const EventsInteracted(),
                ),
              );},
              child: Container(
                height: 50,
                color: Colors.grey[200],
                width: MediaQuery.of(context).size.width,
                child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Events you watched'),
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class Archived extends StatefulWidget {
  const Archived({super.key});

  @override
  State<Archived> createState() => _ArchivedState();
}

class _ArchivedState extends State<Archived> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: const Text('Saved Posts & Videos',style: TextStyle(color: Colors.black),),),
      body: const Column(
        children: [

        ],
      ),
    );
  }
}


class Location extends StatefulWidget {
  double latitude;
  double longitude;
  Location({super.key,required this.latitude,required this.longitude});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  String address='loading';
  @override
  void initState(){
    placemarkFromCoordinates(widget.latitude, widget.longitude)
        .then((placemarks) {
      if (placemarks.isNotEmpty) {
        setState(() {
          address="${placemarks[0].name}, ${placemarks[0].street}, ${placemarks[0].country}";
        });
      }});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(width:120,height: 20,child: Text(address));
  }
}



class SavedLoginInfo extends StatefulWidget {
  const SavedLoginInfo({super.key});

  @override
  State<SavedLoginInfo> createState() => _SavedLoginInfoState();
}

class _SavedLoginInfoState extends State<SavedLoginInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: const Text('Saved Login Information',style: TextStyle(color: Colors.black),),),
      body: StreamBuilder<QuerySnapshot>(
        stream:FirebaseFirestore.instance
            .collection('${collectionNamefor}s')
        .doc(FirebaseAuth.instance.currentUser?.uid).
    collection('locations')
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.hasError) {
    return Center(child: Text('Error: ${snapshot.error}'));
    } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
    return const Center(child: Text('No login data')); // Handle case where there are no likes
    } else {
    final List<QueryDocumentSnapshot> likeDocuments = snapshot.data!.docs;
    List<Map<String, dynamic>> allLikes = [];
    // Extract and combine all like objects into a single list
    for (final document in likeDocuments) {
    final List<dynamic> likesArray = document['location'];
    // Explicitly cast likesArray to Iterable<Map<String, dynamic>>
    allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
    }
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: allLikes.length,
        itemBuilder: (context,index){
      final data=allLikes[index];
      Timestamp newValue5 = data['timestamp'];
      DateTime createdDateTime5 = newValue5.toDate();
      String date = DateFormat('d MMM').format(createdDateTime5);
return Padding(
  padding: const EdgeInsets.all(8.0),
  child:   Column(
    children: [
      Text('Device Name: ${data['devicename']}'),
      Text('Date: $date'),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('location:'),
          Location(latitude: data['latitude'], longitude: data['latitude'],)
        ],
      ),
      Text('State: ${data['state']}'),
      Text('Os Version: ${data['osversion']}'),
      Text('Device Model: ${data['devicemodel']}'),
      Text('Manufacturer Name: ${data['manufacturername']}'),
    ],
  ),
);
    });
    }}),
    );
  }
}



class Password extends StatefulWidget {
  const Password({super.key});

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _currentPassword; // Make it nullable
  String? _newPassword; // Make it nullable
  void _changePassword() async {
    if(isStrongPassword5){
      if (_currentPassword == null || _newPassword == null) {
        print('Please enter both the current and new passwords.');
        return;
      }

      try {
        User? user = _auth.currentUser;

        if (user == null) {
          print('User not logged in.');
          return;
        }

        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPassword!,
        );
        await user.reauthenticateWithCredential(credential);

        await user.updatePassword(_newPassword!);

        print('Password changed successfully.');
      } catch (e) {
        print('Failed to change password: $e');
      }}
  }
  bool _obscureText = true;
  bool _obscureText1 = true;
  bool isStrongPassword = false;
  bool isStrongPassword1 = false;
  bool isStrongPassword2 = false;
  bool isStrongPassword3 = false;
  bool isStrongPassword4 = false;
  bool isStrongPassword5 = false;
  TextEditingController password=TextEditingController();
  TextEditingController passwor1=TextEditingController();
  void checkPasswordStrength(String value) {
    setState(() {
      // Define your password strength criteria here
      isStrongPassword = value.length >= 8;
      isStrongPassword1 = value.contains(RegExp(r'[a-z]'));
      isStrongPassword2 =value.contains(RegExp(r'[A-Z]'));
      isStrongPassword3 = value.contains(RegExp(r'[0-9]'));
      isStrongPassword4 = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      isStrongPassword5 =
          value.length >= 8 &&
              value.contains(RegExp(r'[a-z]')) &&
              value.contains(RegExp(r'[A-Z]')) &&
              value.contains(RegExp(r'[0-9]')) &&
              value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }
  int characternum=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: const Text('Password',style: TextStyle(color: Colors.black),),),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top:5,bottom: 8),
                  child: Text('Change Password',style: TextStyle(fontSize: 19,color: Colors.black,fontWeight: FontWeight.bold),),
                ),
                TextFormField(
                  obscureText: _obscureText,
                  controller: passwor1,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText1 ? Icons.visibility_off : Icons.visibility, color: Colors.black,),
                        onPressed: () {
                          setState(() {
                            _obscureText1 = !_obscureText1;
                          });
                        },
                      ),
                      labelText: 'Current Password'),

                  onChanged: (value) {
                    setState(() {
                      _currentPassword = value;
                    });
                  },
                ),
                const SizedBox(height: 8.0),
                if (_newPassword != null)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: 300,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Password Checker',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                          Text(
                            isStrongPassword2
                                ? 'Password contains upper case letters'
                                : 'Password must contain upper case letters',
                            style: TextStyle(
                              color: isStrongPassword2 ? Colors.green : Colors.red,
                            ),
                          ),
                          Text(
                            isStrongPassword1
                                ? 'Password contains lower case letters'
                                : 'Password must contain lower case letters',
                            style: TextStyle(
                              color: isStrongPassword1 ? Colors.green : Colors.red,
                            ),
                          ),
                          Text(
                            isStrongPassword3
                                ? 'Password contains numeric values'
                                : 'Password must contain numeric values',
                            style: TextStyle(
                              color: isStrongPassword3 ? Colors.green : Colors.red,
                            ),
                          ),
                          Text(
                            isStrongPassword4
                                ? 'Password contains special characters'
                                : 'Password must contain special characters',
                            style: TextStyle(
                              color: isStrongPassword4 ? Colors.green : Colors.red,
                            ),
                          ),
                          Text(
                            isStrongPassword
                                ? 'Password contains $characternum characters'
                                : 'Password must contain atleast 8 characters',
                            style: TextStyle(
                              color: isStrongPassword ? Colors.green : Colors.red,
                            ),
                          ),
                          Text(
                            isStrongPassword5
                                ? 'Password is strong'
                                : 'Password is not strong enough',
                            style: TextStyle(
                              color: isStrongPassword5 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 5,),
                TextFormField(
                  controller: password,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.black,),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      labelText: 'New Password'),
                  onChanged: (value) {
                    setState(() {
                      _newPassword = value;
                      checkPasswordStrength(value);
                      characternum=value.length;

                    });
                  },
                ),

                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _changePassword,
                  child: const Text('Change Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class Language extends StatefulWidget {
  const Language({super.key});

  @override
  State<Language> createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  List<String> languages = ['English', 'Spanish', 'French', 'German'];
  String? selectedLanguage;
  List<bool> isEnabled;
  _LanguageState() : isEnabled = List.filled(4, true);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Language',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: List.generate(languages.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Container(
              height: 60,
              color: Colors.grey[200],
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(languages[index]),
                  Radio<String>(
                    value: languages[index],
                    groupValue: selectedLanguage,
                    onChanged: isEnabled[index]
                        ? (value) {
                      setState(() {
                        selectedLanguage = value;
                        isEnabled = List.filled(languages.length, false);
                        isEnabled[index] = true;
                      });
                    } : null,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}




class InteractionsFansTv extends StatefulWidget {
  const InteractionsFansTv( {super.key,});
  @override
  _InteractionsFansTvState createState() => _InteractionsFansTvState();
}

class _InteractionsFansTvState extends State<InteractionsFansTv> with SingleTickerProviderStateMixin {
  List<FansTv> posts = [];
  PageController controller = PageController();
  Newsfeedservice news = Newsfeedservice();
  late FansTv lastPost;
  bool isLoading=false;
  @override
  void initState() {
    super.initState();
    news = Newsfeedservice();
    getPosts(); // Fetch initial posts
  }

  void getPosts() async {
    setState(() {
      isLoading=true;
    });
    List<FansTv> post = await DataFetcher().getFansTv(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      posts.addAll(post);
      if (post.isNotEmpty) {
        isLoading=false;
        lastPost = post.last;
      }
    });
  }

  Future<void> loadMore(index) async {
    setState(() {
      currentIndex = index;
    });
    List<FansTv> morePosts = await DataFetcher().getmoreFansTv(FirebaseAuth.instance.currentUser!.uid,lastPost.postid);

    setState(() {
      posts.addAll(morePosts);
      if (morePosts.isNotEmpty) {
        lastPost = morePosts.last;
      }
    });
  }

  void deleteCache()async{
    for(final post in posts){
      final file=await checkCacheFor(post.url);
      if(file!=null){
        await DefaultCacheManager().removeFile(post.url);}
    }
  } Future<FileInfo?> checkCacheFor(String url) async {
    final FileInfo? value = await DefaultCacheManager().getFileFromCache(url);
    return value;
  }
  @override
  void dispose(){
    deleteCache();
    super.dispose();
  }

  int currentIndex = 0;

  double radius=23;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black,
                child: isLoading?const Center(child: CircularProgressIndicator(color: Colors.white,)): PageView.builder(
                    scrollDirection: Axis.vertical,
                    controller: controller,
                    itemCount: posts.length,
                    onPageChanged: loadMore,
                    itemBuilder: (ctx, index) {
                      return Container(
                          color: Colors.transparent,
                          height: MediaQuery.of(context).size.height,
                          child: FeedItem(ftv: posts[index],opt1: false,completed: () {
                            if(index<posts.length){
                              controller.nextPage(duration: const Duration(milliseconds:300 ), curve: Curves.easeIn);}
                          },index:index ,posts: posts,));
                    }
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:  [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,color: Colors.white,size: 35,),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },//to next page},
                    ),
                    const Text(
                      'Fans_Tv',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,color: Colors.white
                      ),
                    ),
                    InkWell(
                        onTap: (){
                          Bottomnavbar.setCamera(context);
                          Camera.setCamera(context);
                          Navigator.of(context).pop();
                        },
                        child: const Icon(Icons.camera_alt,size: 30,color: Colors.white,)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }}


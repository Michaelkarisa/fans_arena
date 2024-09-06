import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
class UserModelF{
  String userId;
  String username;
  String genre;
  String location;
  String website;
  String email;
  String bio;
  String url;
  Timestamp timestamp;
  UserModelF({
    required this.userId,
    required this.username,
    required this.location,
    required this.genre,
    required this.email,
    required this.bio,
    required this.website,
    required this.url,required this.timestamp});
}
//add field searchname with all lower case values.
class UserModelP{
  String userId;
  String stagename;
  String genre;
  String location;
  String website;
  String email;
  String profession;
  String quote;
  String url;
  Timestamp timestamp;
  UserModelP({
    required this.userId,
    required this.stagename,
    required this.location,
    required this.genre,
    required this.email,
    required this.profession,
    required this.website,
    required this.quote,
    required this.url,
    required this.timestamp});
}
class UserModelC{
  String userId;
  String clubname;
  String genre;
  String location;
  String website;
  String email;
  String motto;
  String url;
  Timestamp timestamp;
  UserModelC({
    required this.userId,
    required this.clubname,
    required this.location,
    required this.genre,
    required this.email,
    required this.motto,
    required this.website,
    required this.url,required this.timestamp});
}
class Userdata{
  List<UserModelF> _userListFromSnapshotF(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return UserModelF(
        userId: doc.id,
        username: doc['username'] ?? '',
        url: doc['profileimage']??'',
        email: doc['email'] ?? '',
        genre: doc['favourite'] ?? '',
        location: doc['location'] ?? '',
        bio: doc['bio'] ?? '',
        website:doc['website'] ?? '', timestamp: doc['createdAt'],

      );
    }).toList();
  }
  List<UserModelP> _userListFromSnapshotP(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return UserModelP(
        userId: doc.id,
        stagename: doc['Stagename'] ?? '',
        email: doc['email'] ?? '',
        profession: doc['profession'] ?? '',
        location: doc['Location'] ?? '',
        genre: doc['genre'] ?? '',
        website:doc['website'] ?? '',
        quote: doc['quote'] ?? '',
        url:doc['profileimage']??'',
        timestamp: doc['createdAt'],
      );
    }).toList();
  }
  List<UserModelC> _userListFromSnapshotC(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return UserModelC(
        userId: doc.id,
        clubname: doc['Clubname'] ?? '',
        email: doc['email'] ?? '',
        url:doc['profileimage']??'',
        location: doc['Location'] ?? '',
        genre: doc['Genre'] ?? '',
       motto: doc['Motto'] ?? '',
        website:doc['website'] ?? '',
        timestamp: doc['createdAt'],
      );
    }).toList();
  }
  late Stream<QuerySnapshot> _stream1;
 Future<List<UserModelP>> userDataP({required String userId})async{
   List<UserModelP> user=[];
    _stream1 = FirebaseFirestore.instance.collection('Professionals').where('profeid',isEqualTo:userId).snapshots();
    _stream1.listen((snapshot) {
      user.addAll(_userListFromSnapshotP(snapshot));
    });
   return user;
  }
  Future<List<UserModelF>> userDataF({required String userId})async{
    List<UserModelF> user=[];
    _stream1 = FirebaseFirestore.instance.collection('Fans').where('Fanid',isEqualTo:userId).snapshots();
    _stream1.listen((snapshot) {
      user.addAll(_userListFromSnapshotF(snapshot));
    });
    return user;
  }
  Future<List<UserModelC>> userDataC({required String userId})async{
    List<UserModelC> user=[];
    _stream1 = FirebaseFirestore.instance.collection('Clubs').where('Clubid',isEqualTo:userId).snapshots();
    _stream1.listen((snapshot) {
      user.addAll(_userListFromSnapshotC(snapshot));
    });
    return user;
  }
}

class SearchService {
 Set<UserModelF> _userListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return UserModelF(
        userId: doc.id,
        username: doc['username'] ?? '',
        email: '',
        url: doc['profileimage']??'',
        location: '',
        genre:'',
        bio:'',
        website:'',
        timestamp: doc['createdAt'],
      );
    }).toSet();
  }

 UserModelF _userFromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
   return UserModelF(
     userId: doc.id,
     username: doc['username'] ?? '',
     email: '',
     url: doc['profileimage']??'',
     location: '',
     genre:'',
     bio:'',
     website:'',
     timestamp: doc['createdAt'],
   );
 }

 Stream<Set<UserModelF>> getUser(String search) async* {
   String searchLower = search.toLowerCase();
   String searchUpper = search.toUpperCase();
   final lowerQuery = FirebaseFirestore.instance
       .collection('Fans')
       .orderBy('searchname')
       .where('searchname', isGreaterThanOrEqualTo: searchLower)
       .where('searchname', isLessThan: '$searchLower\uf8ff')
       .limit(20)
       .snapshots();
   Set<String> userIds = {};
   Set<UserModelF> combinedSet = {};
   await for (var lowerSnapshot in lowerQuery) {
       for (var doc in lowerSnapshot.docs) {
         String userId = doc.id;
         if (!userIds.contains(userId)) {
           combinedSet.add(_userFromSnapshot(doc));
           userIds.add(userId);
           yield combinedSet;
         }
       }
     }
 }
}

class SearchService1{
  Set<UserModelP>_userListFromSnapshot(QuerySnapshot snapshot ){
    return snapshot.docs.map((doc){
      return UserModelP(
        userId: doc.id,
        stagename: doc['Stagename'] ?? '',
        email: '',
        url:doc['profileimage']??'',
        location:  '',
        genre: doc['genre'],
        profession: '',
        website: '',
        quote: '',timestamp: doc['createdAt'],);
    }).toSet();
  }

  UserModelP _userFromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return UserModelP(
      userId: doc.id,
      stagename: doc['Stagename'] ?? '',
      email: '',
      url:doc['profileimage']??'',
      location:  '',
      genre: doc['genre'],
      profession: '',
      website: '',
      quote: '',timestamp: doc['createdAt'],);
  }

  Stream<Set<UserModelP>> getUser(String search) async* {
    String searchLower = search.toLowerCase();
    String searchUpper = search.toUpperCase();
    final lowerQuery = FirebaseFirestore.instance
        .collection('Professionals')
        .orderBy('searchname')
        .where('searchname', isGreaterThanOrEqualTo: searchLower)
        .where('searchname', isLessThan: '$searchLower\uf8ff')
        .limit(4)
        .snapshots();
    Set<String> userIds = {};
    Set<UserModelP> combinedSet = {};
    await for (var lowerSnapshot in lowerQuery) {
      for (var doc in lowerSnapshot.docs) {
        String userId = doc.id;
        if (!userIds.contains(userId)) {
          combinedSet.add(_userFromSnapshot(doc));
          userIds.add(userId);
          yield combinedSet;
        }
      }
    }
  }
}

class SearchService2{
  Set<UserModelC>_userListFromSnapshot(QuerySnapshot snapshot ){
    return snapshot.docs.map((doc){
      return UserModelC(
        userId: doc.id,
        clubname: doc['Clubname'] ?? '',
        email: '',
        url:doc['profileimage']??'',
        location: '',
        genre:'',
        motto: '',
        website: '',
        timestamp: doc['createdAt'],
        );
    }).toSet();
  }

  UserModelC _userFromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return UserModelC(
      userId: doc.id,
      clubname: doc['Clubname'] ?? '',
      email: '',
      url:doc['profileimage']??'',
      location: '',
      genre:'',
      motto: '',
      website: '',
      timestamp: doc['createdAt'],
    );
  }

  Stream<Set<UserModelC>> getUser(String search) async* {
    String searchLower = search.toLowerCase();
    String searchUpper = search.toUpperCase();
    final lowerQuery = FirebaseFirestore.instance
        .collection('Clubs')
        .orderBy('searchname')
        .where('searchname', isGreaterThanOrEqualTo: searchLower)
        .where('searchname', isLessThan: '$searchLower\uf8ff')
        .limit(4)
        .snapshots();
    Set<String> userIds = {};
    Set<UserModelC> combinedSet = {};
    await for (var lowerSnapshot in lowerQuery) {
      for (var doc in lowerSnapshot.docs) {
        String userId = doc.id;
        if (!userIds.contains(userId)) {
          combinedSet.add(_userFromSnapshot(doc));
          userIds.add(userId);
          yield combinedSet;
        }
      }
    }
  }
}
class SearchService3{
  Set<Leagues>_userListFromSnapshot(QuerySnapshot snapshot ){
    return snapshot.docs.map((doc){
      return Leagues(
        leagueId: doc.id,
        genre: doc['genre'] ?? '',
        imageurl: doc['profileimage'] ?? '',
        authorId: doc['authorId'] ?? '',
        leaguename: doc['leaguename']??'',
        location:doc['location']??'',
        timestamp: doc['createdAt'], accountType: doc['accountType']??'',);
    }).toSet();
  }

  Leagues _userFromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return Leagues(
      accountType: doc['accountType']??'',
      leagueId: doc.id,
      genre: doc['genre'] ?? '',
      imageurl: doc['profileimage'] ?? '',
      authorId: doc['authorId'] ?? '',
      leaguename: doc['leaguename']??'',
      location:doc['location']??'',
      timestamp: doc['createdAt'],);
  }

  Stream<Set<Leagues>> getUser(String search) async* {
    String searchLower = search.toLowerCase();
    String searchUpper = search.toUpperCase();
    final lowerQuery = FirebaseFirestore.instance
        .collection('Leagues')
        .orderBy('searchname')
        .where('searchname', isGreaterThanOrEqualTo: searchLower)
        .where('searchname', isLessThan: '$searchLower\uf8ff')
        .limit(10)
        .snapshots();
    Set<String> userIds = {};
    Set<Leagues> combinedSet = {};
    await for (var lowerSnapshot in lowerQuery) {
      for (var doc in lowerSnapshot.docs) {
        String userId = doc.id;
        if (!userIds.contains(userId)) {
          combinedSet.add(_userFromSnapshot(doc));
          userIds.add(userId);
          yield combinedSet;
        }
      }
    }
    }
  }


class SearchService4{
  Set<UserModelC>_userListFromSnapshot(QuerySnapshot snapshot ){
    return snapshot.docs.map((doc){
      return UserModelC(
        userId: doc.id,
        clubname: doc['Clubname'] ?? '',
        email:  '',
        url:doc['profileimage']??'',
        location:  '',
        genre: '',
        motto:  '',
        website:'',
        timestamp: doc['createdAt'],
        );
    }).toSet();
  }

  UserModelC _userFromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return UserModelC(
      userId: doc.id,
      clubname: doc['Clubname'] ?? '',
      email:  '',
      url:doc['profileimage']??'',
      location:  '',
      genre: '',
      motto:  '',
      website:'',
      timestamp: doc['createdAt'],
    );
  }

  Stream<Set<UserModelC>> getUser(String search) async* {
    String searchLower = search.toLowerCase();
    String searchUpper = search.toUpperCase();
    final lowerQuery = FirebaseFirestore.instance
        .collection('Clubs')
        .orderBy('searchname')
        .where('searchname', isGreaterThanOrEqualTo: searchLower)
        .where('searchname', isLessThan: '$searchLower\uf8ff')
        .limit(20)
        .snapshots();
    Set<String> userIds = {};
    Set<UserModelC> combinedSet = {};
    await for (var lowerSnapshot in lowerQuery) {
      for (var doc in lowerSnapshot.docs) {
        String userId = doc.id;
        if (!userIds.contains(userId)) {
          combinedSet.add(_userFromSnapshot(doc));
          userIds.add(userId);
          yield combinedSet;
        }
      }
    }
  }
}

class SearchService5{
  Set<UserModelP>_userListFromSnapshot(QuerySnapshot snapshot ){
    return snapshot.docs.map((doc){
      return UserModelP(
        userId: doc.id,
        stagename: doc['Stagename'] ?? '',
        email: '',
        url:doc['profileimage']??'',
        location: '',
        genre: '',
        profession:  '',
        website: '',
        quote: '',
        timestamp: doc['createdAt'],
        );
    }).toSet();
  }

  UserModelP _userFromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return UserModelP(
      userId: doc.id,
      stagename: doc['Stagename'] ?? '',
      email: '',
      url:doc['profileimage']??'',
      location: '',
      genre: '',
      profession:  '',
      website: '',
      quote: '',
      timestamp: doc['createdAt'],
    );
  }

  Stream<Set<UserModelP>> getUser(String search) async* {
    String searchLower = search.toLowerCase();
    String searchUpper = search.toUpperCase();
    final lowerQuery = FirebaseFirestore.instance
        .collection('Professionals')
        .orderBy('searchname')
        .where('searchname', isGreaterThanOrEqualTo: searchLower)
        .where('searchname', isLessThan: '$searchLower\uf8ff')
        .limit(20)
        .snapshots();
    Set<String> userIds = {};
    Set<UserModelP> combinedSet = {};
    await for (var lowerSnapshot in lowerQuery) {
      for (var doc in lowerSnapshot.docs) {
        String userId = doc.id;
        if (!userIds.contains(userId)) {
          combinedSet.add(_userFromSnapshot(doc));
          userIds.add(userId);
          yield combinedSet;
        }
      }
    }
  }
}

class SearchService0 {
  Set<UserModelF> _userListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return UserModelF(
        userId: doc.id,
        username: doc['username'] ?? '',
        email: '',
        url: doc['profileimage']??'',
        location:  '',
        genre: '',
        bio: '',
        website: '',
        timestamp: doc['createdAt'],
       );
    }).toSet();
  }

  UserModelF _userFromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return UserModelF(
      userId: doc.id,
      username: doc['username'] ?? '',
      email: '',
      url: doc['profileimage']??'',
      location: '',
      genre:'',
      bio:'',
      website:'',
      timestamp: doc['createdAt'],
    );
  }

  UserModelP _userFromSnapshot1(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return UserModelP(
      userId: doc.id,
      stagename: doc['Stagename'] ?? '',
      email: '',
      url:doc['profileimage']??'',
      location: '',
      genre: '',
      profession:  '',
      website: '',
      quote: '',
      timestamp: doc['createdAt'],
    );
  }

  UserModelC _userFromSnapshot2(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return UserModelC(
      userId: doc.id,
      clubname: doc['Clubname'] ?? '',
      email:  '',
      url:doc['profileimage']??'',
      location:  '',
      genre: '',
      motto:  '',
      website:'',
      timestamp: doc['createdAt'],
    );
  }

  Stream<Set<UserModelF>> getUser(String search,String currentUser) async* {
    String searchLower = search.toLowerCase();
    String searchUpper = search.toUpperCase();
    final lowerQuery = FirebaseFirestore.instance
        .collection('Fans')
        .orderBy('searchname')
        .where('searchname', isGreaterThanOrEqualTo: searchLower)
        .where('searchname', isLessThan: '$searchLower\uf8ff')
        .limit(10)
        .snapshots();
   final following= FirebaseFirestore.instance
        .collection('Fans')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('following')
        .get();
   List<Map<String,dynamic>> data=[];
     following.then((value){
       for(final item in value.docs){
       List<Map<String,dynamic>> data1=List.from(item['following']);
       data.addAll(data1);
       }
     });
    final followers= FirebaseFirestore.instance
        .collection('Fans')
        .doc(currentUser)
        .collection('followers')
        .get();
    followers.then((value){
      for(final item in value.docs){
        List<Map<String,dynamic>> data1=List.from(item['followers']);
        data.addAll(data1);
      }
    });
    Set<String> userIds = {};
    Set<UserModelF> combinedSet = {};
    await for (var lowerSnapshot in lowerQuery) {
        for (var doc in lowerSnapshot.docs) {
          String userId = doc.id;
          for(final user in data) {
            if (!userIds.contains(userId) && userId==user['userId']) {
              combinedSet.add(_userFromSnapshot(
                  doc));
              userIds.add(userId);
              yield combinedSet;
            }
          }
      }
    }
  }

  Stream<Set<UserModelP>> getUser1(String search,String currentUser) async* {
    String searchLower = search.toLowerCase();
    String searchUpper = search.toUpperCase();
    final lowerQuery = FirebaseFirestore.instance
        .collection('Professionals')
        .orderBy('searchname')
        .where('searchname', isGreaterThanOrEqualTo: searchLower)
        .where('searchname', isLessThan: '$searchLower\uf8ff')
        .limit(10)
        .snapshots();
    Set<String> userIds = {};
    Set<UserModelP> combinedSet = {};
    final professionals= FirebaseFirestore.instance
        .collection('Fans')
        .doc(currentUser)
        .collection('professionals')
        .get();
    List<Map<String,dynamic>> data=[];
    professionals.then((value){
      for(final item in value.docs){
        List<Map<String,dynamic>> data1=List.from(item['professionals']);
        data.addAll(data1);
      }
    });
    await for (var lowerSnapshot in lowerQuery) {
        for (var doc in lowerSnapshot.docs) {
          String userId = doc.id;
          for(final user in data) {
            if (!userIds.contains(userId) && userId==user['userId']) {
              combinedSet.add(_userFromSnapshot1(
                  doc));
              userIds.add(userId);
              yield combinedSet;
            }
          }
      }
    }
  }

  Stream<Set<UserModelC>> getUser2(String search,String currentUser) async* {
    String searchLower = search.toLowerCase();
    String searchUpper = search.toUpperCase();
    final lowerQuery = FirebaseFirestore.instance
        .collection('Clubs')
        .orderBy('searchname')
        .where('searchname', isGreaterThanOrEqualTo: searchLower)
        .where('searchname', isLessThan: '$searchLower\uf8ff')
        .limit(10)
        .snapshots();
    Set<String> userIds = {};
    Set<UserModelC> combinedSet = {};
    final clubs= FirebaseFirestore.instance
        .collection('Fans')
        .doc(currentUser)
        .collection('clubs')
        .get();
    List<Map<String,dynamic>> data=[];
    clubs.then((value){
      for(final item in value.docs){
        List<Map<String,dynamic>> data1=List.from(item['clubs']);
        data.addAll(data1);
      }
    });
    await for (var lowerSnapshot in lowerQuery) {
        for (var doc in lowerSnapshot.docs) {
          String userId = doc.id;
          for(final user in data) {
            if (!userIds.contains(userId) && userId==user['userId']) {
              combinedSet.add(_userFromSnapshot2(
                  doc));
              userIds.add(userId);
              yield combinedSet;
            }
          }}
    }
  }

  Stream<Set<UserModelF>> getFans1(String search,String currentUser) async* {
    String searchLower = search.toLowerCase();
    String searchUpper = search.toUpperCase();
    final lowerQuery = FirebaseFirestore.instance
        .collection('Fans')
        .orderBy('searchname')
        .where('searchname', isGreaterThanOrEqualTo: searchLower)
        .where('searchname', isLessThan: '$searchLower\uf8ff')
        .limit(10)
        .snapshots();
    Set<String> userIds = {};
    Set<UserModelF> combinedSet = {};
    final professionals= FirebaseFirestore.instance
        .collection('Clubs')
        .doc(currentUser)
        .collection('fans')
        .get();
    List<Map<String,dynamic>> data=[];
    professionals.then((value){
      for(final item in value.docs){
        List<Map<String,dynamic>> data1=List.from(item['fans']);
        data.addAll(data1);
      }
    });
    await for (var lowerSnapshot in lowerQuery) {
        for (var doc in lowerSnapshot.docs) {
          String userId = doc.id;
          for(final user in data) {
            if (!userIds.contains(userId) && userId==user['userId']) {
              combinedSet.add(_userFromSnapshot(
                  doc));
              userIds.add(userId);
              yield combinedSet;
            }
          }
      }
    }
  }

  Stream<Set<UserModelF>> getFans2(String search,String currentUser) async* {
    String searchLower = search.toLowerCase();
    String searchUpper = search.toUpperCase();
    final lowerQuery = FirebaseFirestore.instance
        .collection('Fans')
        .orderBy('searchname')
        .where('searchname', isGreaterThanOrEqualTo: searchLower)
        .where('searchname', isLessThan: '$searchLower\uf8ff')
        .limit(10)
        .snapshots();
    Set<String> userIds = {};
    Set<UserModelF> combinedSet = {};
    final clubs= FirebaseFirestore.instance
        .collection('Professionals')
        .doc(currentUser)
        .collection('fans')
        .get();
    List<Map<String,dynamic>> data=[];
    clubs.then((value){
      for(final item in value.docs){
        List<Map<String,dynamic>> data1=List.from(item['fans']);
        data.addAll(data1);
      }
    });
    await for (var lowerSnapshot in lowerQuery) {
        for (var doc in lowerSnapshot.docs) {
          String userId = doc.id;
          for(final user in data) {
            if (!userIds.contains(userId) && userId==user['userId']) {
              combinedSet.add(_userFromSnapshot(
                  doc));
              userIds.add(userId);
              yield combinedSet;
            }
          }
      }
    }
  }
}


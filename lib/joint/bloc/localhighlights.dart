import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../../clubs/components/clubeventpost.dart';
import '../../reusablewidgets/carouselslider.dart';
// Add this import

class LocalHighlights extends StatefulWidget {
  const LocalHighlights({super.key});
  @override
  State<LocalHighlights> createState() => _LocalHighlightsState();
}

class _LocalHighlightsState extends State<LocalHighlights> {
  late Future<List<Map<String, dynamic>>> _highlightsFuture;

  @override
  void initState() {
    super.initState();
    _highlightsFuture = fetchHighlights();
  }

  Future<List<Map<String, dynamic>>> fetchHighlights() async {
    List<Map<String, dynamic>> allData = [];
    QuerySnapshot qSnapshot = await FirebaseFirestore.instance
        .collection('Fans')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('clubs')
        .get();

    for (var doc in qSnapshot.docs) {
      List<Map<String, dynamic>> clubs = List.from(doc['clubs']);
      for (var club in clubs) {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection('Highlights')
            .doc(club['userId'])
            .get();
        if (documentSnapshot.exists) {
          List<Map<String, dynamic>> data = List.from(documentSnapshot['highlights']);
          allData.addAll(data);
        }
      }
    }
    return allData;
  }

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return  FutureBuilder<List<Map<String, dynamic>>>(
        future: _highlightsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No Data"));
          } else if (snapshot.hasError) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${snapshot.error}"),
                const SizedBox(height: 10),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _highlightsFuture = fetchHighlights();
                    });
                  },
                  icon: const Icon(Icons.refresh, color: Colors.black),
                ),
                const Text('Refresh'),
              ],
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final matchWidgets = data.map((match) => HighlightCard(data: match, fun: (Map<String, dynamic> data) {  }, funedit: (Map<String, dynamic> data) {  },)).toList();
            return Stack(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.height * 0.3,
                    aspectRatio: 16 / 9,
                    autoPlay: true,
                    enlargeCenterPage: false,
                    viewportFraction: 1.0,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                  items: matchWidgets,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2, right: 2),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.96,
                      height: MediaQuery.of(context).size.height * 0.019,
                      child: Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: data.asMap().entries.map((entry) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _currentIndex = entry.key;
                                  });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.015,
                                  height: MediaQuery.of(context).size.height * 0.015,
                                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentIndex == entry.key ? Colors.blue : Colors.grey,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const SizedBox.shrink();
          }
        },
    );
  }
}

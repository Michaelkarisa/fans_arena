import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Ads extends StatefulWidget {
  const Ads({super.key});

  @override
  State<Ads> createState() => _AdsState();
}

class _AdsState extends State<Ads> {
  Set<String>  ads= {};
  List<String> selected=[];
  @override
  void initState(){
    super.initState();
    getAds();
  }
  bool _notifyUpdates = false;
  List<String> genres=['Football', 'Tennis', 'Basketball','Handball', 'Rugby', 'Horse racing', 'Cricket', 'Polo','Boxing', 'Rally','Golf','Formula one','Baseball', 'Cycling', 'Hockey','Motorsport','Netball', 'Chess', 'Volleyball', 'Swimming','Badminton', 'Wrestling', 'NFL', 'Marathon','Gaming', 'Javelin','High Jump', 'Long Jump', 'Dancing', 'Body Building','NBA'];
void getAds()async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    ads.add(prefs.getString('genre')!);
    selected.add(prefs.getString('genre')!);
    ads.addAll(genres);
    if(selected.isNotEmpty){
      _notifyUpdates = true;
    }
  });
}
  void _toggleNotification(bool value) {
    setState(() {
      _notifyUpdates = value;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ads',style:TextStyle(color: Colors.black) ,),
        elevation: 1,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Container(
                height: 60,
                color: Colors.grey[200],
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child:   SwitchListTile(
                    title: const Text('advertisements'),
                    value: _notifyUpdates,
                    onChanged: _toggleNotification,
                  ),
                ),
              ),
            ),
            Column(
              children: ads.map((ad){
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Container(
                    height: 60,
                    color: Colors.grey[200],
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(ad),
                          Checkbox(value:selected.any((a)=>a==ad) ,
                              onChanged:(value){
                            setState(() {
                              value=!value!;
                              if(value!) {
                                selected.add(ad);
                              }else{
                                selected.remove(ad);
                              }
                            });})
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

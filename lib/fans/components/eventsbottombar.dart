import 'package:fans_arena/fans/screens/events.dart';
import 'package:fans_arena/fans/screens/legues.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class Bottomeventsbar extends StatefulWidget {
  const Bottomeventsbar({super.key});

  @override
  State<Bottomeventsbar> createState() => _BottomeventsbarState();
}

class _BottomeventsbarState extends State<Bottomeventsbar> {

  int _selectedIndex = 0;
  final List<Widget> _pages = <Widget>[
    const EventsF(),
    const Legues(),
  ];
  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body:  OrientationBuilder(
            builder: (context, orientation) {
              return SafeArea(
                child: Stack(
                  children: [
                    Center(
                      child: _pages.elementAt(_selectedIndex),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (MediaQuery.of(context).size.height >650) {
                          return Align(
                            alignment: const Alignment(0.0,1),
                            child:  Container(
                              margin: EdgeInsets.all(displayWidth * .005),
                              width: MediaQuery.of(context).size.width * 0.515,
                              height: MediaQuery.of(context).size.height * 0.066,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.1),
                                    blurRadius: 30,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: ListView.builder(
                                itemCount: 2,
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.symmetric(horizontal: displayWidth * .015),
                                itemBuilder: (context, index) => InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = index;
                                      HapticFeedback.lightImpact();
                                    });
                                  },
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  child: Stack(
                                    children: [
                                      AnimatedContainer(
                                        duration: Duration(seconds: 1),
                                        curve: Curves.fastLinearToSlowEaseIn,
                                        width: index == _selectedIndex
                                            ? displayWidth * .31
                                            : displayWidth * .18,
                                        alignment: Alignment.center,
                                        child: AnimatedContainer(
                                          duration: Duration(seconds: 1),
                                          curve: Curves.fastLinearToSlowEaseIn,
                                          height: index == _selectedIndex ? displayWidth * .12 : 0,
                                          width: index == _selectedIndex ? displayWidth * .31 : 0,
                                          decoration: BoxDecoration(
                                            color: index == _selectedIndex
                                                ? Colors.blueAccent.withOpacity(.2)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                        ),
                                      ),
                                      AnimatedContainer(
                                        duration: Duration(seconds: 1),
                                        curve: Curves.fastLinearToSlowEaseIn,
                                        width: index == _selectedIndex
                                            ? displayWidth * .3
                                            : displayWidth * .18,
                                        alignment: Alignment.center,
                                        child: Stack(
                                          children: [
                                            Row(
                                              children: [
                                                AnimatedContainer(
                                                  duration: Duration(seconds: 1),
                                                  curve: Curves.fastLinearToSlowEaseIn,
                                                  width:
                                                  index == _selectedIndex ? displayWidth * .12 : 0,
                                                ),
                                                AnimatedOpacity(
                                                  opacity: index == _selectedIndex ? 1 : 0,
                                                  duration: Duration(seconds: 1),
                                                  curve: Curves.fastLinearToSlowEaseIn,
                                                  child: Text(
                                                    index == _selectedIndex
                                                        ? '${listOfStrings[index]}'
                                                        : '',
                                                    style: TextStyle(
                                                      color: Colors.blueAccent,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                AnimatedContainer(
                                                  duration: Duration(seconds: 1),
                                                  curve: Curves.fastLinearToSlowEaseIn,
                                                  width:
                                                  index == _selectedIndex ? displayWidth * .03 : 20,
                                                ),
                                                Icon(
                                                  listOfIcons[index],
                                                  size: displayWidth * .076,
                                                  color: index == _selectedIndex
                                                      ? Colors.blueAccent
                                                      : Colors.black54,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else if (MediaQuery.of(context).size.width>400) {
                          return Align(
                            alignment: const Alignment(0.0,1),
                            child: Container(
                              margin: EdgeInsets.all(displayWidth * .035),
                              width: MediaQuery.of(context).size.width * 0.212,
                              height: MediaQuery.of(context).size.height * 0.138,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.1),
                                    blurRadius: 30,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: ListView.builder(
                                itemCount: 2,
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.symmetric(horizontal: displayWidth * .02),
                                itemBuilder: (context, index) => InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = index;
                                      HapticFeedback.lightImpact();
                                    });
                                  },
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  child: Stack(
                                    children: [
                                      AnimatedContainer(
                                        duration: Duration(seconds: 1),
                                        curve: Curves.fastLinearToSlowEaseIn,
                                        width: index == _selectedIndex
                                            ? displayWidth * .32
                                            : displayWidth * .18,
                                        alignment: Alignment.center,
                                        child: AnimatedContainer(
                                          duration: Duration(seconds: 1),
                                          curve: Curves.fastLinearToSlowEaseIn,
                                          height: index == _selectedIndex ? displayWidth * .12 : 0,
                                          width: index == _selectedIndex ? displayWidth * .32 : 0,
                                          decoration: BoxDecoration(
                                            color: index == _selectedIndex
                                                ? Colors.blueAccent.withOpacity(.2)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                        ),
                                      ),
                                      AnimatedContainer(
                                        duration: Duration(seconds: 1),
                                        curve: Curves.fastLinearToSlowEaseIn,
                                        width: index == _selectedIndex
                                            ? displayWidth * .31
                                            : displayWidth * .18,
                                        alignment: Alignment.center,
                                        child: Stack(
                                          children: [
                                            Row(
                                              children: [
                                                AnimatedContainer(
                                                  duration: Duration(seconds: 1),
                                                  curve: Curves.fastLinearToSlowEaseIn,
                                                  width:
                                                  index == _selectedIndex ? displayWidth * .13 : 0,
                                                ),
                                                AnimatedOpacity(
                                                  opacity: index == _selectedIndex ? 1 : 0,
                                                  duration: Duration(seconds: 1),
                                                  curve: Curves.fastLinearToSlowEaseIn,
                                                  child: Text(
                                                    index == _selectedIndex
                                                        ? '${listOfStrings[index]}'
                                                        : '',
                                                    style: TextStyle(
                                                      color: Colors.blueAccent,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                AnimatedContainer(
                                                  duration: Duration(seconds: 1),
                                                  curve: Curves.fastLinearToSlowEaseIn,
                                                  width:
                                                  index == _selectedIndex ? displayWidth * .03 : 20,
                                                ),
                                                Icon(
                                                  listOfIcons[index],
                                                  size: displayWidth * .076,
                                                  color: index == _selectedIndex
                                                      ? Colors.blueAccent
                                                      : Colors.black54,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }else{
                          return Align(
                            alignment: const Alignment(0.0,1),
                            child: Container(
                              margin: EdgeInsets.all(displayWidth * .035),
                              width: MediaQuery.of(context).size.width * 0.4515,
                              height: MediaQuery.of(context).size.height * 0.09,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.1),
                                    blurRadius: 30,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child:ListView.builder(
                                itemCount: 2,
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.symmetric(horizontal: displayWidth * .02),
                                itemBuilder: (context, index) => InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = index;
                                      HapticFeedback.lightImpact();
                                    });
                                  },
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  child: Stack(
                                    children: [
                                      AnimatedContainer(
                                        duration: Duration(seconds: 1),
                                        curve: Curves.fastLinearToSlowEaseIn,
                                        width: index == _selectedIndex
                                            ? displayWidth * .32
                                            : displayWidth * .18,
                                        alignment: Alignment.center,
                                        child: AnimatedContainer(
                                          duration: Duration(seconds: 1),
                                          curve: Curves.fastLinearToSlowEaseIn,
                                          height: index == _selectedIndex ? displayWidth * .12 : 0,
                                          width: index == _selectedIndex ? displayWidth * .32 : 0,
                                          decoration: BoxDecoration(
                                            color: index == _selectedIndex
                                                ? Colors.blueAccent.withOpacity(.2)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                        ),
                                      ),
                                      AnimatedContainer(
                                        duration: Duration(seconds: 1),
                                        curve: Curves.fastLinearToSlowEaseIn,
                                        width: index == _selectedIndex
                                            ? displayWidth * .31
                                            : displayWidth * .18,
                                        alignment: Alignment.center,
                                        child: Stack(
                                          children: [
                                            Row(
                                              children: [
                                                AnimatedContainer(
                                                  duration: Duration(seconds: 1),
                                                  curve: Curves.fastLinearToSlowEaseIn,
                                                  width:
                                                  index == _selectedIndex ? displayWidth * .13 : 0,
                                                ),
                                                AnimatedOpacity(
                                                  opacity: index == _selectedIndex ? 1 : 0,
                                                  duration: Duration(seconds: 1),
                                                  curve: Curves.fastLinearToSlowEaseIn,
                                                  child: Text(
                                                    index == _selectedIndex
                                                        ? '${listOfStrings[index]}'
                                                        : '',
                                                    style: TextStyle(
                                                      color: Colors.blueAccent,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                AnimatedContainer(
                                                  duration: Duration(seconds: 1),
                                                  curve: Curves.fastLinearToSlowEaseIn,
                                                  width:
                                                  index == _selectedIndex ? displayWidth * .03 : 20,
                                                ),
                                                Icon(
                                                  listOfIcons[index],
                                                  size: displayWidth * .076,
                                                  color: index == _selectedIndex
                                                      ? Colors.blueAccent
                                                      : Colors.black54,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),

                  ],
                ),
              );
            })
    );
  }
  List<IconData> listOfIcons = [
    Icons.event_sharp,
    Icons.sports_score_outlined,
  ];

  List<String> listOfStrings = [
    'Events',
    'Leagues',
  ];
}
import 'package:fans_arena/fans/screens/homescreen.dart';
import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class Homebottomnav extends StatefulWidget {
  final int index;
  const Homebottomnav({super.key,required this.index});

  @override
  State<Homebottomnav> createState() => _HomebottomnavState();
}

class _HomebottomnavState extends State<Homebottomnav> {

  int _selectedIndex = 0;
  final List<Widget> _pages = <Widget>[
    const Homescreen(),
    const NewsFeed(),
  ];

  @override
  void initstate(){
    super.initState();
    setState(() {
      _selectedIndex=widget.index;
    });
  }
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
                          padding: EdgeInsets.symmetric(horizontal: displayWidth * .005),
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
    Icons.home_rounded,
    Icons.explore,
  ];

  List<String> listOfStrings = [
    'Home',
    'Explore',
  ];
}
class BottomNavItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final Widget child;
  final void Function()? onTap;

  const BottomNavItem({
    Key? key,
    required this.child,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

  @override
  _BottomNavItemState createState() => _BottomNavItemState();
}

class _BottomNavItemState extends State<BottomNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant BottomNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSelected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.1,
                      color: widget.isSelected ? Colors.grey : Colors.transparent,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isSelected ? Colors.blueAccent : Colors.grey,
                  fontSize: 11.0,
                  fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

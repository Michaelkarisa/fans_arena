import 'package:flutter/material.dart';


class ThreeIconAnimation extends StatefulWidget {
  const ThreeIconAnimation({super.key});

  @override
  _ThreeIconAnimationState createState() => _ThreeIconAnimationState();
}

class _ThreeIconAnimationState extends State<ThreeIconAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds:  120),
    )..forward();
    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds:  120),
    );
    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds:  120),
    );
    _controller1.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller2.forward();
      }
    });
    _controller2.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller3.forward();
      } else if (status == AnimationStatus.dismissed) {
        _controller1.forward();
      }
    });
    _controller3.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _controller1.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 0),
          child: _buildIcon(_controller1),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: _buildIcon(_controller2),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: _buildIcon(_controller3),
        ),
      ],
    );
  }

  Widget _buildIcon(AnimationController controller,) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Icon(
          Icons.arrow_forward_ios_rounded,
          size: 30,
          color: controller.value == 1.0 ?Colors.grey[800] : Colors.white ,
        );
      },
    );
  }
}

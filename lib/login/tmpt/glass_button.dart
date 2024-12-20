import 'package:flutter/material.dart';
import 'dart:ui';

class FrostedGlassBox extends StatelessWidget {
  const FrostedGlassBox(
      {super.key,
      required this.theWidth,
      required this.theHeight,
      required this.theChild});

  final theWidth;
  final theHeight;
  final theChild;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: theWidth,
        height: theHeight,
        color: const Color.fromARGB(0, 0, 0, 0),
        //we use Stack(); because we want the effects be on top of each other,
        //  just like layer in photoshop.
        child: Stack(
          children: [
            //blur effect ==> the third layer of stack
            BackdropFilter(
              filter: ImageFilter.blur(
                //sigmaX is the Horizontal blur
                sigmaX: 3.0,
                //sigmaY is the Vertical blur
                sigmaY: 3.0,
              ),
              //we use this container to scale up the blur effect to fit its
              //  parent, without this container the blur effect doesn't appear.
              child: Container(),
            ),
            //gradient effect ==> the second layer of stack
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.13)),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      //begin color
                      const Color.fromARGB(255, 203, 242, 247)
                          .withOpacity(0.15),
                      //end color
                      const Color.fromARGB(255, 193, 244, 250)
                          .withOpacity(0.05),
                    ]),
              ),
            ),
            //child ==> the first/top layer of stack
            Center(child: theChild),
          ],
        ),
      ),
    );
  }
}

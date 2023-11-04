import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:money_tracker/Screens/HomePage.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(

        key: GlobalKey<IntroductionScreenState>(),
        pages: [
          PageViewModel(
            title: 'Money',
            image: Image.asset('assets/images/image1.png'),
            bodyWidget: Text('Money is very imaportant in our life ',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900),)
          ),
          PageViewModel(
            title: 'Money',
            image: Image.asset('assets/images/image2.png'),
            bodyWidget: Text("Without Money you can't ful fill your Dream !!",textAlign: TextAlign.center,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900))
          ),
          PageViewModel(
          title: 'Money',
            image: Image.asset('assets/images/image3.webp'),
            bodyWidget: Text('So save your Money',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900))
          )
        ],
        showDoneButton: true,
        showNextButton: true,
        showSkipButton: true,
        skip: Text("Skip"),
        done: Text("Done"),
        next: Text("Next"),
        onDone: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(),));
        },
      )
    );
  }
}
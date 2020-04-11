import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:ui';
import 'package:dictionary/MyApp.dart';
import 'package:flutter/material.dart';

class splashScreen extends StatefulWidget {

  @override
  _splashScreenState createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> with SingleTickerProviderStateMixin{
  var spinkit;

  @override
  void initState() {
    super.initState();
     spinkit = SpinKitCircle(
      color: Colors.pink,
      size: 170.0,
     );
    Timer(
      Duration(seconds: 3),(){
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context){

            return MyApp();
          }
        ));
    }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink,Colors.green]
            )
          ),
          child: Stack(
            fit: StackFit.loose,
            children: <Widget>[
              Positioned(
                left: 120,
                top: 150,
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.green[200],Colors.pinkAccent[200]]
                    )
                  ),
                  child: Image.asset("asset/dictionary.png"),
                )
              ),
             Positioned(
               child:  spinkit,
               top: 130,
               left: 100,
             ),
              Container(
                margin: EdgeInsets.only(left: 80,top: 360),
                child: Text("Design By Shahmeer",style: TextStyle(fontWeight: FontWeight.normal,color: Colors.white70,fontSize: 22),)
              )
            ],
          ),
        ),
      ),
    );
  }

}

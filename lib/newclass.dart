import 'package:flutter/material.dart';



class newclass extends StatelessWidget {
  String valueimage,tagvalue;
  newclass(this.valueimage,this.tagvalue);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(

        appBar: AppBar(
          leading:IconButton(
            icon:  Icon(Icons.arrow_back,color: Colors.white,),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          title: Text(tagvalue),
        ),
        body:Center(
          child: Hero(
            tag: tagvalue,
            child: Container(
              child: GestureDetector(
                onDoubleTap: (){
                  Navigator.of(context).pop();
                },
                child: Image.network(valueimage),

              ),
            ),
          ),
        ),
      ),
    );
  }
}

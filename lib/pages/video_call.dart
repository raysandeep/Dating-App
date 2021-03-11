import 'package:dating_app/widgets/1to1videocall.dart';
import 'package:flutter/material.dart';

class CallPage extends StatefulWidget {
  final String videoCallName;
  final String channelName;
  CallPage(this.videoCallName, this.channelName);
  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  
  @override
  Widget build(BuildContext context) {
    print(widget.channelName);
    return Scaffold(
      backgroundColor: Color(0xFFFFDBD6),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.white,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.videoCallName,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body:VideoCall(widget.channelName),
        
      );
    
  }
}
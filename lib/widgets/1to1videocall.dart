import 'package:dating_app/data/app_id.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

class VideoCall extends StatefulWidget {
  final String channelName;
  VideoCall(this.channelName);
  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  
  RtcEngine _engine;

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
  }

  void toggleMute(){
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }
  void toggleCamera(){
    _engine.switchCamera();
  }
  void disconnectCall(){
    Navigator.pop(context);
  }

  Future<void> initialize() async {
    if (appID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    // await _engine.enableWebSdkInteroperability(true);
    await _engine.joinChannel(null, widget.channelName, null, 0);
  
  }

   /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(appID);
    await _engine.enableVideo();
  }

  /// agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState(() {
          final info = 'onError: $code';
          _infoStrings.add(info);
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
        });
      },
      leaveChannel: (stats) {
        setState(() {
          _infoStrings.add('onLeaveChannel');
          _users.clear();
        });
      },
      userJoined: (uid, elapsed) {
        setState(() {
          final info = 'userJoined: $uid';
          _infoStrings.add(info);
          _users.add(uid);
        });
      },
      userOffline: (uid, reason) {
        setState(() {
          final info = 'userOffline: $uid , reason: $reason';
          _infoStrings.add(info);
          _users.remove(uid);
        });
      },
      firstRemoteVideoFrame: (uid, width, height, elapsed) {
        setState(() {
          final info = 'firstRemoteVideoFrame: $uid';
          _infoStrings.add(info);
        });
      },
    ));
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    list.add(RtcLocalView.SurfaceView());
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }


  /// Remote video view wrapper
  Widget _videoView(view) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: view
    );
  }
  
  /// Local video view row wrapper
  Widget _localVideoView(view) {
    return Container(
      height: MediaQuery.of(context).size.height*0.27,
      width: MediaQuery.of(context).size.width*0.2,
      child: view,
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
          )
        );
      case 2:
        return Container(
            child: Stack(
          children: <Widget>[
            _videoView(views[1]),
            Align(
              alignment: Alignment(0.95, -0.95),
              child:_localVideoView(views[0])
            ),
          ],
        ));
      default:
    }
    return Container();
  }

  
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
            child: Stack(
              children: <Widget>[
                _viewRows(),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            child: Container(
      height: MediaQuery.of(context).size.height*0.1,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
                      child: IconButton(
              icon: muted ? Icon(Icons.mic_off, color: Colors.red,) : Icon(Icons.mic, color: Colors.green) , 
              onPressed: toggleMute,
            ),
          ),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.red,
            child: IconButton(
              icon: Icon(Icons.call_end, color: Colors.white,), 
              onPressed: disconnectCall,
            )
          ),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 30,
            child: IconButton(
              icon: Icon(Icons.switch_camera, color: Colors.blue,), 
              onPressed: toggleCamera,

            )
          ),
        ],
      ),
      
    ),
          )
      ],
    );
  }
}
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agora_live/utils/Config.dart';
import 'dart:async';

class LJJAnchorWidget extends StatefulWidget {
  String arguments;
  LJJAnchorWidget({Key key, this.arguments}) : super(key: key);
  @override
  _LJJAnchorWidgetState createState() => _LJJAnchorWidgetState();
}

class _LJJAnchorWidgetState extends State<LJJAnchorWidget> {
  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  int homeID;

  final StreamController<int> _streamController = StreamController<int>();

  @override
  void dispose() {
    _users.clear();
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    _streamController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initLive();
  }

  ///初始化视频配置信息
  Future<void> initLive() async {
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    //确定房间类型-> LiveBroadcasting -> 直播
    await AgoraRtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    //确定人员类型: Broadcaster->主播
    await AgoraRtcEngine.setClientRole(ClientRole.Broadcaster);
    print("--------${widget.arguments}");
    print("--------$APP_ID");
    await AgoraRtcEngine.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
    await AgoraRtcEngine.joinChannel(null, widget.arguments, null, 0);
  }

  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create(APP_ID);
    await AgoraRtcEngine.enableVideo();
  }

  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      homeID = uid;
      _streamController.add(homeID);
      // setState(() {
      //   final info = 'onJoinChannel: $channel, uid: $uid';
      //   print("------UID:$uid");
      //   _infoStrings.add(info);
      // });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame = (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('主播'),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _liveView(),
            Positioned(
              left: 10,
              top: 320,
              child: StreamBuilder<int>(
              stream: _streamController.stream,
              initialData: homeID,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot){
                return Card(
                  color: Colors.green,
                  child: Text("房间号:${widget.arguments} 房间ID:${snapshot.data}"),
                );
              },
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _liveView() {
    return Container(
      color: Colors.black,
      width: PhoneSize(context).width,
      height: PhoneSize(context).height,
      child: AgoraRenderWidget(
        0,
        local: true,
        preview: true,
      ),
    );
  }
}

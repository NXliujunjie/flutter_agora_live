import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agora_live/utils/Config.dart';

class LJJAudienceWidget extends StatefulWidget {
  String arguments;
  int homeID;
  LJJAudienceWidget({Key key, this.arguments, this.homeID}) : super(key: key);
  @override
  _LJJAudienceWidgetState createState() => _LJJAudienceWidgetState();
}

class _LJJAudienceWidgetState extends State<LJJAudienceWidget> {

  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;

   @override
  void dispose() {
    _users.clear();
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
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
    //确定人员类型: Broadcaster->观众
    await AgoraRtcEngine.setClientRole(ClientRole.Audience);
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
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
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
        title: Text('观众端'),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _liveView(),
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
      child: AgoraRenderWidget(widget.homeID),
    );
  }
}
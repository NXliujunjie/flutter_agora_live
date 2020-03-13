import 'package:flutter/material.dart';
import 'package:flutter_agora_live/LJJAnchorWidget.dart';
import 'package:flutter_agora_live/LJJAudienceWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _homeNum = '3368';
  int _homeID;
  final controller = TextEditingController();
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '直播房间号: $_homeNum',
            ),
            SizedBox(height: 20),
            MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text("开始直播"),
              onPressed: () async {
                await _handleCameraAndMic();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LJJAnchorWidget(
                      arguments: _homeNum,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text("观看直播直播"),
              onPressed: () async {
                await _handleCameraAndMic();
                inputHomeID(callback: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  if (_homeID <= 0 || _homeID == null) {
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LJJAudienceWidget(
                        arguments: _homeNum,
                        homeID: _homeID,
                      ),
                    ),
                  ).then((v){
                    _homeID = 0;
                  });
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }

  void inputHomeID({VoidCallback callback}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("请输入加入的主播房间ID"),
            content: SingleChildScrollView(
              child: TextFieldPage().buildTextField(value: (v) {
                setState(() {
                  _homeID = int.parse(v);
                });
              }),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("确定"),
                onPressed: () {
                  Navigator.pop(context);
                  callback();
                },
              ),
            ],
          );
        });
  }
}

class TextFieldPage {
  Widget buildTextField({ValueChanged value}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      height: 60.0,
      decoration: new BoxDecoration(
          color: Colors.blueGrey,
          border: new Border.all(color: Colors.black54, width: 4.0),
          borderRadius: new BorderRadius.circular(12.0)),
      child: new TextFormField(
        decoration: InputDecoration.collapsed(hintText: '主播房间ID'),
        keyboardType: TextInputType.phone,
        onChanged: (v) {
          value(v);
        },
      ),
    );
  }
}

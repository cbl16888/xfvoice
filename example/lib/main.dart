import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:xfvoice/xfvoice.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  String _voiceMsg = '暂无数据';
  String _resultString = '按下方块说话';

  XFJsonResult xfResult;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

   Future<void> initPlatformState() async {
    final voice = XFVoice.shared;
    // 请替换成你的appid
    voice.init(appIdIos: '5f607d0f', appIdAndroid: '5f607d0f');
    final param = new XFVoiceParam();
    param.domain = 'iat';
    // param.asr_ptt = '0';   //取消注释可去掉标点符号
    param.asr_audio_path = 'audio.pcm';
    param.result_type = 'json'; //可以设置plain
    final map = param.toMap();
    map['dwa'] = 'wpgs';        //设置动态修正，开启动态修正要使用json类型的返回格式
    voice.setParameter(map);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '测试的demo',
      home: Scaffold(
        appBar: AppBar(
          title: new Text('测试demo'),
        ),
        body: Center(
          child: GestureDetector(
            child: Container(
              child: Text(_resultString),
              width: 300.0,
              height: 300.0,
              color: Colors.blueAccent,
            ),
            onTapDown: (d) {
              setState(() {
                _voiceMsg = '按下';
              });
              _recognize();
            },
            onTapUp: (d) {
              _recognizeOver();
            },
          ),
        )
      ),
    );
  }

  void _recognize() {
    final listen = XFVoiceListener(
      onVolumeChanged: (volume) {
      },
      onBeginOfSpeech: () {
        xfResult = null;
      },
      onResults: (String result, isLast) {
        if (xfResult == null) {
          xfResult = XFJsonResult(result);
        } else {
          final another = XFJsonResult(result);
          xfResult.mix(another);
        }
        if (result.length > 0) {
          setState(() {
            _resultString = xfResult.resultText();
          });
        }
      },
      onCompleted: (Map<dynamic, dynamic> errInfo, String filePath) {
        setState(() {
          
        });
      }
    );
    XFVoice.shared.start(listener: listen);
  }

  void _recognizeOver() {
    XFVoice.shared.stop();
  }
}

import 'dart:math';
import 'package:event/src/event.dart';
import 'package:event/src/eventargs.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:flutter/services.dart';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

class Sender{
  String mCChannelId = "mcc55";//getRandomString(5);
  Event<Value<String>> peerConnectedEvent;

  static const sessionChannel = MethodChannel('sessionChannel');

  Sender(this.peerConnectedEvent){
    sessionChannel.invokeMethod('createSender', mCChannelId);
    sessionChannel.setMethodCallHandler((call) => call.method == "onPeerConnected"? _onPeerConnected(call.arguments as String):null);
  }


  _onPeerConnected(String peer){
    peerConnectedEvent.broadcast(Value(peer));
  }
  
  sendData(String data){
    sessionChannel.invokeMethod("sendData", data);
  }

  sendFile(String fileUrl){
    sessionChannel.invokeMethod("sendFile", fileUrl);
  }

  void showQrCode(BuildContext context) async{
    BuildContext? dialogContext;

    showDialog(context: context, barrierDismissible: false, builder: (BuildContext context) {
      dialogContext = context;

      return AlertDialog(
        title: const Text("Channel metadata"),
        content: SizedBox(
            width: 300,
            height: 300,
            child: QrImage(
                data: "c;$mCChannelId",
                version: QrVersions.auto
            )
        ),
      );
    });

    await Future.delayed(const Duration(seconds: 3));
    Navigator.of(dialogContext!).pop();
  }

  static String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}
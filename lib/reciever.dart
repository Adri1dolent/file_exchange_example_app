import 'package:event/event.dart';
import 'package:flutter/services.dart';

class Receiver{

  String mCChannelId;
  Event<Value<String>> dataRecievedEvent;
  String url;

  static const sessionChannel = MethodChannel('sessionChannel');

  Receiver(this.mCChannelId, this.dataRecievedEvent, this.url){
    final args = {"channelId" : mCChannelId, "toFolderUrl" : url};
    sessionChannel.invokeMethod("createReciever", args);
    sessionChannel.setMethodCallHandler((call) => call.method == "dataRecieved"?onDataRecieved(call.arguments as String):null);
  }

  onDataRecieved(String data){
    print(data);
    dataRecievedEvent.broadcast(Value(data));
  }

}
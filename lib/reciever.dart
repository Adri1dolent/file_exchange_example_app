import 'package:event/event.dart';
import 'package:flutter/services.dart';

class Receiver{

  String mCChannelId;
  Event<Value<String>> dataRecievedEvent;

  static const sessionChannel = MethodChannel('sessionChannel');

  Receiver(this.mCChannelId, this.dataRecievedEvent){
    sessionChannel.invokeMethod("createReciever", mCChannelId);
    sessionChannel.setMethodCallHandler((call) => call.method == "dataRecieved"?onDataRecieved(call.arguments as String):null);
  }

  onDataRecieved(String data){
    print(data);
    dataRecievedEvent.broadcast(Value(data));
  }

}
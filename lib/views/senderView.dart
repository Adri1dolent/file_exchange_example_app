import 'dart:io';

import 'package:event/event.dart';
import 'package:file_exchange_example_app/channelTypes/bootstrap_channel_type.dart';
import 'package:file_exchange_example_app/channelTypes/data_channel_type.dart';
import 'package:file_exchange_example_app/sender.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';


class SenderView extends StatefulWidget {
  const SenderView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SenderViewState();
}

class _SenderViewState extends State<SenderView> {
  BootstrapChannelType _bootstrapChannelType = BootstrapChannelType.qrCode;
  final List<DataChannelType> _dataChannelTypes = [];
  final textController = TextEditingController();
  File? _file;
  Event<Value<String>> peerConnectedEvent = Event<Value<String>>();

  late Sender s;
  late String data;

  void _setBootstrapChannelType(BootstrapChannelType type) {
    setState(() {
      _bootstrapChannelType = type;
    });
  }

  void _toggleDataChannelType(DataChannelType type) {
    setState(() {
      if (_dataChannelTypes.contains(type)) {
        _dataChannelTypes.remove(type);
      } else {
        _dataChannelTypes.add(type);
        _checkAssociatedPermissions(type);
      }
    });
  }

  void _checkAssociatedPermissions(DataChannelType type) async {
    switch(type) {
      case DataChannelType.wifi:
        await Permission.locationWhenInUse.request();
        break;
    }
  }

  @override
  void dispose(){
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    peerConnectedEvent + (args) => _onPeerConnected();
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 50),
            child: ElevatedButton(
                onPressed: () async {
                  // Please note that selecting a file that does not belong to
                  // current user will throw an error.
                  FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
                  if (result != null) {
                    setState(() {
                      _file = File(result.files.single.path!);
                    });
                  } else {
                    debugPrint("User selected no file.");
                  }
                },
                child: Text(
                    _file != null
                        ? _file!.uri.pathSegments.last
                        : "Select file to send"
                )
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            child: const Divider(),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            child: const Text(
              'Select bootstrap channel:',
            ),
          ),
          ListTile(
            title: const Text('QR code'),
            onTap: () => _setBootstrapChannelType(BootstrapChannelType.qrCode),
            trailing: Checkbox(
                value: _bootstrapChannelType == BootstrapChannelType.qrCode,
                onChanged: (v) => _setBootstrapChannelType(BootstrapChannelType.qrCode)),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            child: const Text(
              'Select data channels (at least one):',
            ),
          ),
          ListTile(
            title: const Text('Wi-Fi (IOS Multipeer)'),
            onTap: () => _toggleDataChannelType(DataChannelType.wifi),
            trailing: Checkbox(
                value: _dataChannelTypes.contains(DataChannelType.wifi),
                onChanged: (v) => _toggleDataChannelType(DataChannelType.wifi)
            ),
          ),
        ],
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: _canSendFile() ? () => _startSendingFile(context) : null,
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                const RoundedRectangleBorder( borderRadius: BorderRadius.zero )
            )
        ),
        child: Container(
          margin: const EdgeInsets.all(20),
          child: const Text("Send message"),
        ),
      ),
    );
  }

  bool _canSendFile() {
    return _file != null && _dataChannelTypes.isNotEmpty;
  }

  Future<void> _startSendingFile(BuildContext context) async {
    print(_file?.uri);
    s = Sender(peerConnectedEvent);
    print(s.mCChannelId);
    s.showQrCode(context);
    Fluttertoast.showToast( msg: "Waiting for a reciever...", timeInSecForIosWeb: 2);
  }

  _onPeerConnected(){
    Fluttertoast.showToast(msg: "Peer Connected");
    //s.sendData(data);
    s.sendFile(_file!.path);
    sleep(const Duration(seconds:1));
    Fluttertoast.showToast(msg: "Data sent");
  }


}
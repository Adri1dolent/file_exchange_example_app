import 'dart:io';

import 'package:event/event.dart';
import 'package:file_exchange_example_app/channelTypes/bootstrap_channel_type.dart';
import 'package:file_exchange_example_app/channelTypes/data_channel_type.dart';
import 'package:file_exchange_example_app/reciever.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ReceiverView extends StatefulWidget {
  const ReceiverView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReceiverViewState();
}

class _ReceiverViewState extends State<ReceiverView> {
  BootstrapChannelType _bootstrapChannelType = BootstrapChannelType.qrCode;
  final List<DataChannelType> _dataChannelTypes = [];
  var dataRecievedEvent = Event<Value<String>>();
  Directory? _destination;

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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    dataRecievedEvent + (args) => Fluttertoast.showToast(msg: "Data recieved: ${args?.value}");
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 50),
            child: ElevatedButton(
                onPressed: () async {
                  String? result = await FilePicker.platform.getDirectoryPath(dialogTitle: "test");
                  if (result != null) {
                    setState(() {
                      _destination = Directory(result);
                    });
                  } else {
                    debugPrint("User selected no file.");
                  }
                },
                child: Text(
                    _destination != null
                        ? _destination!.uri.toString()
                        : "Select file destination"
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
            title: const Text('Wi-Fi'),
            onTap: () => _toggleDataChannelType(DataChannelType.wifi),
            trailing: Checkbox(
                value: _dataChannelTypes.contains(DataChannelType.wifi),
                onChanged: (v) => _toggleDataChannelType(DataChannelType.wifi)
            ),
          ),
        ],
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: _canReceiveFile() ? () => initReceiver(context) : null,
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                const RoundedRectangleBorder( borderRadius: BorderRadius.zero )
            )
        ),
        child: Container(
          margin: const EdgeInsets.all(20),
          child: const Text("Receive data"),
        ),
      ),
    );
  }

  bool _canReceiveFile() {
    return _destination != null && _dataChannelTypes.isNotEmpty;
  }

  Future<void> _startReceivingFile(BuildContext context, String channelId) async {
    Fluttertoast.showToast(
        msg: "Starting file reception..."
    );
    print(_destination!.path);
    Receiver r = Receiver(channelId, dataRecievedEvent, _destination!.path);
  }

  Future<void> initReceiver(BuildContext ctx) async {
    showModalBottomSheet(context: context, builder: (BuildContext cContext) {
      return DraggableScrollableSheet(
        initialChildSize: 1,
        maxChildSize: 1,
        builder: (dContext, controller) {
          return Container(
            color: Colors.red,
            child: MobileScanner(fit: BoxFit.fill, onDetect: (code, arguments) {
              String value = code.rawValue!;
              List<String> words = value.split(";");

              if (!["c", "f"].contains(words[0])) {
                throw StateError("Received packet with unknown format.");
              }

              if (words[0] == "c") {
                _startReceivingFile(context, words[1]);
                Navigator.of(context).pop();
              } else {
                Fluttertoast.showToast(msg: "Error in QR code");
              }
            }),
          );
        },
      );
    });
  }
}
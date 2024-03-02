import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bluetooth_print/bluetooth_print.dart';

class printingdata extends StatefulWidget {
  final String labelText;

  printingdata({Key? key, required this.labelText}) : super(key: key);

  @override
  State<printingdata> createState() => _printingdataState();
}

class _printingdataState extends State<printingdata> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  late List<BluetoothDevice> _devices = [];
  late List<BluetoothDevice> _selectedDevice = [];
  String _deviceMsg = "";
  bool _connected = false;
  String tips = 'No Device connected';

  @override
  void initState() {
    // print(widget.counterValue);
    super.initState();

    bluetoothPrint.scanResults.listen((device) async {
      setState(() {
        _devices = device;
      });
    });
    _startScanDevices();
  }

  void _startScanDevices() async {
    setState(() {
      _devices = [];
    });
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));
    bool? isConnected = await bluetoothPrint.isConnected;

    bluetoothPrint.state.listen((state) {
      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'Connected successfully';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'Disconnect successfully';
          });
          break;
        default:
          break;
      }
    });
    if (!mounted) return;

    if (isConnected != null && isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  Future<void> initPrinter() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
      ),
      body: StreamBuilder<List<BluetoothDevice>>(
        stream: bluetoothPrint.scanResults,
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 9,
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          color: Colors.blueGrey,
                          height: 50.0,
                          child: InkWell(
                            onTap: () => _openDialog(context),
                            child: Text(_devices.length == 0
                                ? 'Select Printer'
                                : '${_devices.length} Devices'),
                          ),
                        ),
                        // Container(
                        //     alignment: Alignment.center,
                        //     width: double.infinity,
                        //     color: Colors.blueGrey,
                        //     height: 50.0,
                        //     child: InkWell(
                        //       onTap: () => _openDialog(context),
                        //       child: Text('PRINTER'),
                        //     ),
                        //   ),
                        Expanded(
                            child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            _selectedDevice.length > 0
                                ? _selectedDevice[0].name.toString()
                                : 'selecteddata',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        )),
                      ],
                    )),
                Flexible(
                  child: InkWell(
                    onTap: () {
                      print(_connected);
                      _connected == true
                          ? _printText()
                          : _PrintSnackBar(
                              context, 'YOU MUST SELECT A PRINTING DEVICE');
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      color: Colors.blueAccent,
                      child: Text(
                        'PRINT',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ],
            );
          }
          return CircularProgressIndicator();
        },
      ),
      // floatingActionButton: StreamBuilder(
      //   stream: bluetoothPrint.isScanning,
      //   initialData: false,
      //   builder: (_, snapshot) {
      //     if (snapshot.hasData && snapshot.data == true) {
      //       return FloatingActionButton(
      //         onPressed: () => bluetoothPrint.stopScan(),
      //         child: Icon(Icons.stop),
      //         backgroundColor: Colors.blueAccent,
      //       );
      //     } else {
      //       return FloatingActionButton(
      //         onPressed: () => _startScanDevices(),
      //         child: Icon(Icons.search),
      //       );
      //     }
      //   },
      // ),
    );
  }

  Future _openDialog(BuildContext _context) {
    return showDialog(
        context: _context,
        builder: (_) => CupertinoAlertDialog(
              title: Column(
                children: [
                  Text("Select Printer"),
                  SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
              content: _setupDialogContainer(_context),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(_context).pop();
                    },
                    child: Text('Close'))
              ],
            ));
  }

  Widget _setupDialogContainer(BuildContext _context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 200.0,
          width: 300.0,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: _devices.length,
              itemBuilder: (BuildContext _context, int index) {
                return GestureDetector(
                  onTap: () async {
                    await bluetoothPrint.connect(_devices[index]);
                    setState(() {
                      _selectedDevice.add(_devices[index]);
                    });
                    Navigator.of(_context).pop();
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 70.0,
                        padding: EdgeInsets.only(left: 10.0),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Icon(Icons.print),
                            SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_devices[index].name ?? ''),
                                Text(_devices[index].address.toString()),
                                Flexible(
                                    child: Text(
                                  'click here',
                                  style: TextStyle(color: Colors.blue),
                                ))
                              ],
                            ))
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                );
              }),
        )
      ],
    );
  }

  _PrintSnackBar(BuildContext _context, String _text) {
    final snackBar = SnackBar(
        content: Text(_text),
        action: SnackBarAction(label: 'close', onPressed: () {}));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _printText() async {
    Map<String, dynamic> config = Map();
    List<LineText> list = [];
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Counted Value :',
        weight: 1,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    list.add(LineText(linefeed: 1));
    // list.add(LineText(
    //     type: LineText.TYPE_TEXT,
    //     content: 'this is conent left',
    //     weight: 0,
    //     align: LineText.ALIGN_LEFT,
    //     linefeed: 1));
    // list.add(LineText(
    //     type: LineText.TYPE_TEXT,
    //     content: 'this is conent right',
    //     align: LineText.ALIGN_RIGHT,
    //     linefeed: 1));
    // list.add(LineText(linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: widget.labelText,
        size: 10,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    list.add(LineText(linefeed: 1));
    // list.add(LineText(
    //     type: LineText.TYPE_QRCODE,
    //     content: 'qrcode i',
    //     size: 10,
    //     align: LineText.ALIGN_CENTER,
    //     linefeed: 1));

    // Getting Started

    // ByteData data = await rootBundle.load("assets/images/guide3.png");
    //List<int> imageBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    // String base64Image = base64Encode(imageBytes);
    //list.add(LineText(type: LineText.TYPE_IMAGE, content: base64Image, align: LineText.ALIGN_CENTER, linefeed: 1));
/*This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.*/

    await bluetoothPrint.printReceipt(config, list);
  }

  @override
  void dispose() {
    // Disconnect the printer when the widget is disposed
    bluetoothPrint.disconnect();
    super.dispose();
  }
}

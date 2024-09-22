import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR Code Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QRViewExample(),
    );
  }
}

class QRViewExample extends StatefulWidget {
  @override
  _QRViewExampleState createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedData;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.green,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
              formatsAllowed: [BarcodeFormat.qrcode],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (scannedData != null)
                  ? GestureDetector(
                      onTap: () => _launchURL(scannedData!),
                      child: Text(
                        '$scannedData\nClick to Open',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Text('Scan a QR code'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    controller?.pauseCamera();
                  },
                  child: Text('Pause'),
                ),
                ElevatedButton(
                  onPressed: () {
                    controller?.resumeCamera();
                  },
                  child: Text('Resume'),
                ),
                ElevatedButton(
                  onPressed: () {
                    controller?.flipCamera();
                  },
                  child: Text('Flip Camera'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
   controller.scannedDataStream.listen((scanData) {
  setState(() {
    scannedData = scanData.code;
    print('Scanned Data: $scannedData');
  });
});

  }

Future<void> _launchURL(String url) async {
  try {
    // Add scheme if missing
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final Uri uri = Uri.parse(url);
    print('Attempting to launch: $uri');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      print('Launched successfully!');
    } else {
      print('Could not launch $url');
    }
  } catch (e) {
    print('Error launching URL: $e');
  }
}

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

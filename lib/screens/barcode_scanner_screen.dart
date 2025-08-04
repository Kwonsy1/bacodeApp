import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late MobileScannerController controller;
  bool isScanning = false;
  String? lastScannedCode;
  BarcodeFormat? lastScannedFormat;
  bool hasPermission = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      hasPermission = status == PermissionStatus.granted;
    });
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (!isScanning) return;
    
    final barcode = capture.barcodes.first;
    if (barcode.rawValue != null) {
      setState(() {
        lastScannedCode = barcode.rawValue;
        lastScannedFormat = barcode.format;
        isScanning = false;
      });
      
      _showResultDialog(barcode.rawValue!, barcode.format);
    }
  }

  void _showResultDialog(String code, BarcodeFormat format) {
    String formatName = _getFormatName(format);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('스캔 결과'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('포맷: $formatName'),
            const SizedBox(height: 8),
            Text('내용: $code'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startScanning();
            },
            child: const Text('다시 스캔'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  String _getFormatName(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.qrCode:
        return 'QR 코드';
      case BarcodeFormat.code128:
        return 'Code 128';
      case BarcodeFormat.code39:
        return 'Code 39';
      case BarcodeFormat.code93:
        return 'Code 93';
      case BarcodeFormat.ean13:
        return 'EAN-13';
      case BarcodeFormat.ean8:
        return 'EAN-8';
      case BarcodeFormat.upcA:
        return 'UPC-A';
      case BarcodeFormat.upcE:
        return 'UPC-E';
      case BarcodeFormat.dataMatrix:
        return 'Data Matrix';
      case BarcodeFormat.pdf417:
        return 'PDF417';
      case BarcodeFormat.aztec:
        return 'Aztec';
      default:
        return '알 수 없음';
    }
  }

  void _startScanning() {
    setState(() {
      isScanning = true;
      lastScannedCode = null;
      lastScannedFormat = null;
    });
  }

  void _stopScanning() {
    setState(() {
      isScanning = false;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!hasPermission) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('바코드 스캐너'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('카메라 권한이 필요합니다'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _requestCameraPermission,
                child: const Text('권한 요청'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('바코드 스캐너'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: _onBarcodeDetected,
                ),
                if (!isScanning)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Text(
                        '스캔이 중지되었습니다',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: isScanning ? _stopScanning : _startScanning,
                        icon: Icon(isScanning ? Icons.stop : Icons.play_arrow),
                        label: Text(isScanning ? '중지' : '시작'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => controller.toggleTorch(),
                        icon: const Icon(Icons.flash_on),
                        label: const Text('플래시'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (lastScannedCode != null) ...[
                    const Text('마지막 스캔 결과:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('포맷: ${_getFormatName(lastScannedFormat!)}'),
                    const SizedBox(height: 4),
                    Text('내용: $lastScannedCode'),
                  ] else
                    const Text('바코드를 스캔해주세요'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
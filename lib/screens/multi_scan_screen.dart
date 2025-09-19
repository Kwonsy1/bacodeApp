import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../providers/barcode_provider.dart';
import '../models/barcode_item.dart';
import '../widgets/server_upload_dialog.dart';
import '../widgets/duplicate_scan_notification.dart';
import 'scan_list_screen.dart';

class MultiScanScreen extends StatefulWidget {
  const MultiScanScreen({super.key});

  @override
  State<MultiScanScreen> createState() => _MultiScanScreenState();
}

class _MultiScanScreenState extends State<MultiScanScreen> {
  late MobileScannerController controller;
  bool continuousScan = true;
  bool hasPermission = false;
  BarcodeItem? lastScanned;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      hasPermission = status == PermissionStatus.granted;
    });
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (!continuousScan && lastScanned != null) return;
    
    final barcode = capture.barcodes.first;
    if (barcode.rawValue != null) {
      final item = BarcodeItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        code: barcode.rawValue!,
        format: barcode.format,
        scannedAt: DateTime.now(),
      );

      setState(() {
        lastScanned = item;
      });

      final result = context.read<BarcodeProvider>().addItem(item);

      // 쿨다운 중인 경우 처리하지 않음
      if (result == null) {
        // 쿨다운 중일 때는 아무 동작도 하지 않음 (너무 빠른 스캔)
        return;
      }

      // 진동 피드백 (성공적으로 스캔된 경우에만)
      HapticFeedback.lightImpact();

      // 중복 스캔 알림 (기존 아이템에 수량이 추가된 경우)
      if (result == true && mounted) {
        final existingItem = context.read<BarcodeProvider>().scannedItems
            .firstWhere((i) => i.code == item.code);
        DuplicateScanNotification.show(
          context, 
          item.code, 
          existingItem.quantity,
        );
      }

      if (!continuousScan) {
        controller.stop();
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BarcodeProvider>();
    final screenHeight = MediaQuery.of(context).size.height;

    if (!hasPermission) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('다중 스캔'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
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
        title: const Text('다중 스캔'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          SizedBox(
            height: screenHeight * 0.4, // 화면의 40%를 카메라 영역으로
            child: Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: _onBarcodeDetected,
                ),
                _buildScanOverlay(),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (lastScanned != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '최근 스캔',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                lastScanned!.code,
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                _formatTime(lastScanned!.scannedAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                          const SizedBox(height: 12),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: SwitchListTile(
                                title: const Text('연속 스캔'),
                                value: continuousScan,
                                onChanged: (value) {
                                  setState(() {
                                    continuousScan = value;
                                    if (value) {
                                      controller.start();
                                    }
                                  });
                                },
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                controller.torchEnabled ? Icons.flash_on : Icons.flash_off,
                                color: controller.torchEnabled ? Colors.yellow[700] : null,
                              ),
                              onPressed: () => controller.toggleTorch(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 스캔된 아이템 목록
                  Expanded(
                    child: provider.itemCount == 0
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.qr_code_scanner,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '스캔된 항목이 없습니다',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: provider.scannedItems.length,
                            itemBuilder: (context, index) {
                              final item = provider.scannedItems[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  leading: Icon(
                                    _getFormatIcon(item.format),
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  title: Text(
                                    item.code,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    DateFormat('HH:mm:ss').format(item.scannedAt),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => provider.removeItem(item.id),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  // 하단 액션 버튼
                  if (provider.itemCount > 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showUploadDialog(context),
                              icon: const Icon(Icons.cloud_upload),
                              label: Text('서버 전송 (${provider.itemCount}개)'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ScanListScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('편집'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[600],
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return Center(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // 코너 마커들
            Positioned(
              top: 0,
              left: 0,
              child: _buildCornerMarker(true, true),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: _buildCornerMarker(true, false),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: _buildCornerMarker(false, true),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: _buildCornerMarker(false, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerMarker(bool isTop, bool isLeft) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
          left: isLeft ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ServerUploadDialog(
        selectedOnly: false, // multi_scan_screen에서는 항상 전체 전송
        onSuccess: () {
          // 성공 시 메인 화면으로 이동
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }

  IconData _getFormatIcon(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.qrCode:
        return Icons.qr_code;
      case BarcodeFormat.dataMatrix:
        return Icons.grid_on;
      default:
        return Icons.linear_scale;
    }
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/barcode_provider.dart';

class ServerUploadDialog extends StatefulWidget {
  final VoidCallback? onSuccess;
  final bool selectedOnly;
  
  const ServerUploadDialog({
    super.key, 
    this.onSuccess,
    this.selectedOnly = false,
  });

  @override
  State<ServerUploadDialog> createState() => _ServerUploadDialogState();
}

class _ServerUploadDialogState extends State<ServerUploadDialog> {
  bool _isUploading = false;
  bool _uploadComplete = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _uploadedCount = 0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _startUpload();
  }

  Future<void> _startUpload() async {
    final provider = context.read<BarcodeProvider>();
    setState(() {
      _isUploading = true;
      _totalCount = provider.itemCount;
    });

    try {
      // 실제 업로드 시뮬레이션
      for (int i = 0; i < _totalCount; i++) {
        await Future.delayed(const Duration(milliseconds: 300));
        setState(() {
          _uploadedCount = i + 1;
        });
      }

      // 서버로 데이터 전송
      final success = await provider.sendToServer(selectedOnly: widget.selectedOnly);
      
      setState(() {
        _isUploading = false;
        _uploadComplete = success;
        _hasError = !success;
        if (!success) {
          String baseError = provider.errorMessage ?? '네트워크 오류가 발생했습니다.';
          _errorMessage = '에러 상세:\n$baseError\n\n전송하려던 데이터:\n';
          
          // 전송하려던 바코드 정보도 추가
          for (int i = 0; i < provider.scannedItems.length && i < 3; i++) {
            final item = provider.scannedItems[i];
            _errorMessage += '${i + 1}. "${item.code}" (${_getFormatName(item.format)})\n';
          }
          
          if (provider.scannedItems.length > 3) {
            _errorMessage += '... 외 ${provider.scannedItems.length - 3}개';
          }
        }
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isUploading) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              '서버 전송 중...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('$_uploadedCount/$_totalCount 완료'),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: _totalCount > 0 ? _uploadedCount / _totalCount : 0,
            ),
          ],
        ),
      );
    }

    if (_uploadComplete) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 60,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '전송 완료',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$_totalCount개 항목이 성공적으로 전송되었습니다.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
              if (widget.onSuccess != null) {
                widget.onSuccess!(); // 메인 화면으로 이동
              }
            },
            child: const Text('홈으로'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      );
    }

    if (_hasError) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '전송 실패',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: SelectableText(
                  _errorMessage,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('나중에'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startUpload();
            },
            child: const Text('재시도'),
          ),
        ],
      );
    }

    // 전송 확인 다이얼로그
    final provider = context.read<BarcodeProvider>();
    final formatCounts = <BarcodeFormat, int>{};
    
    final itemsToSend = widget.selectedOnly 
        ? provider.scannedItems.where((item) => item.isSelected).toList()
        : provider.scannedItems;
    
    for (final item in itemsToSend) {
      formatCounts[item.format] = (formatCounts[item.format] ?? 0) + 1;
    }

    return AlertDialog(
      title: Text(widget.selectedOnly ? '선택된 항목 전송' : '전체 항목 전송'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.selectedOnly 
                ? '${provider.selectedCount}개 선택된 항목을 서버로 전송하시겠습니까?'
                : '${provider.itemCount}개 전체 항목을 서버로 전송하시겠습니까?',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ...formatCounts.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '• ${_getFormatName(entry.key)} ${entry.value}개',
                style: TextStyle(color: Colors.grey[700]),
              ),
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _startUpload,
          child: const Text('전송'),
        ),
      ],
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
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/barcode_provider.dart';
import '../models/barcode_item.dart';
import '../widgets/server_upload_dialog.dart';

class ScanListScreen extends StatelessWidget {
  const ScanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<BarcodeProvider>(
          builder: (context, provider, child) {
            return Text('스캔 목록 (${provider.itemCount})');
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          Consumer<BarcodeProvider>(
            builder: (context, provider, child) {
              if (provider.itemCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => _showUploadDialog(context, false),
                child: const Text(
                  '전송',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<BarcodeProvider>(
        builder: (context, provider, child) {
          if (provider.itemCount == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '스캔된 항목이 없습니다',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '바코드를 스캔하여 목록에 추가하세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: provider.scannedItems.length,
                  itemBuilder: (context, index) {
                    final item = provider.scannedItems[index];
                    return _buildItemCard(context, item, provider);
                  },
                ),
              ),
              _buildBottomActionBar(context, provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, BarcodeItem item, BarcodeProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => provider.removeItem(item.id),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: '삭제',
            ),
          ],
        ),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Checkbox(
                  value: item.isSelected,
                  onChanged: (_) => provider.toggleSelection(item.id),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getFormatIcon(item.format),
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getFormatName(item.format),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.code,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('yyyy.MM.dd HH:mm').format(item.scannedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: item.quantity > 1
                          ? () => provider.updateQuantity(item.id, item.quantity - 1)
                          : null,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.quantity.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => provider.updateQuantity(item.id, item.quantity + 1),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => provider.removeItem(item.id),
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, BarcodeProvider provider) {
    final hasSelectedItems = provider.selectedCount > 0;
    
    return Container(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 첫 번째 줄: 전체 선택/해제 버튼
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  if (provider.selectedCount == provider.itemCount) {
                    provider.deselectAll();
                  } else {
                    provider.selectAll();
                  }
                },
                icon: Icon(
                  provider.selectedCount == provider.itemCount
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                ),
                label: Text(
                  provider.selectedCount == provider.itemCount ? '전체 해제' : '전체 선택',
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: provider.itemCount > 0
                    ? () => _showUploadDialog(context, hasSelectedItems)
                    : null,
                icon: const Icon(Icons.cloud_upload),
                label: Text(hasSelectedItems ? '선택 전송' : '전체 전송'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: hasSelectedItems ? Colors.orange : null,
                ),
              ),
            ],
          ),
          // 두 번째 줄: 선택 삭제 버튼 (선택된 항목이 있을 때만)
          if (hasSelectedItems)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () => provider.removeSelectedItems(),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: Text(
                      '선택 삭제 (${provider.selectedCount})',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showUploadDialog(BuildContext context, bool selectedOnly) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ServerUploadDialog(
        selectedOnly: selectedOnly,
        onSuccess: () {
          Navigator.of(context).pop(); // 다이얼로그 닫기
          Navigator.of(context).pop(); // 리스트 화면 닫기 (메인으로 이동)
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
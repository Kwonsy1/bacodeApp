import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/barcode_provider.dart';
import '../models/barcode_item.dart';

class ServerDataScreen extends StatefulWidget {
  const ServerDataScreen({super.key});

  @override
  State<ServerDataScreen> createState() => _ServerDataScreenState();
}

class _ServerDataScreenState extends State<ServerDataScreen> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BarcodeProvider>().loadFromServer(isRefresh: true);
    });
    
    // 스크롤 리스너 추가
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // 끝에서 200픽셀 전에 다음 페이지 로드
      context.read<BarcodeProvider>().loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('저장된 데이터'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BarcodeProvider>().loadFromServer(isRefresh: true);
            },
          ),
        ],
      ),
      body: Consumer<BarcodeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingServer) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('서버 데이터를 불러오는 중...'),
                ],
              ),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '오류 발생',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<BarcodeProvider>().loadFromServer(isRefresh: true);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          if (provider.serverItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_off,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '저장된 데이터가 없습니다',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '바코드를 스캔하여 서버에 전송해보세요',
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
              // 상단 통계
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue[50],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      '총 바코드',
                      provider.serverItems.length.toString(),
                      Icons.qr_code,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'QR 코드',
                      provider.serverItems
                          .where((item) => item.format == BarcodeFormat.qrCode)
                          .length
                          .toString(),
                      Icons.qr_code_2,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'EAN/UPC',
                      provider.serverItems
                          .where((item) => 
                              item.format == BarcodeFormat.ean13 ||
                              item.format == BarcodeFormat.ean8 ||
                              item.format == BarcodeFormat.upcA)
                          .length
                          .toString(),
                      Icons.linear_scale,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
              // 데이터 리스트
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: provider.serverItems.length + (provider.isPaginating || provider.hasMoreData ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.serverItems.length) {
                      // 페이징 로딩 인디케이터
                      if (provider.isPaginating) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (provider.hasMoreData) {
                        // 다음 페이지 로드 트리거
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          provider.loadNextPage();
                        });
                        return const SizedBox.shrink();
                      }
                    }
                    
                    final item = provider.serverItems[index];
                    return _buildServerItemCard(item);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerItemCard(BarcodeItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getFormatColor(item.format).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getFormatIcon(item.format),
            color: _getFormatColor(item.format),
            size: 20,
          ),
        ),
        title: Text(
          item.code,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getFormatName(item.format),
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              DateFormat('yyyy-MM-dd HH:mm').format(item.scannedAt),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '서버',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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

  Color _getFormatColor(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.qrCode:
        return Colors.blue;
      case BarcodeFormat.ean13:
      case BarcodeFormat.ean8:
        return Colors.green;
      case BarcodeFormat.upcA:
      case BarcodeFormat.upcE:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getFormatName(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.qrCode:
        return 'QR 코드';
      case BarcodeFormat.ean13:
        return 'EAN-13';
      case BarcodeFormat.ean8:
        return 'EAN-8';
      case BarcodeFormat.upcA:
        return 'UPC-A';
      case BarcodeFormat.upcE:
        return 'UPC-E';
      case BarcodeFormat.code128:
        return 'Code 128';
      case BarcodeFormat.dataMatrix:
        return 'Data Matrix';
      default:
        return '알 수 없음';
    }
  }
}
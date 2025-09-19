import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import '../models/barcode_item.dart';
import '../services/barcode_api_service.dart';

class BarcodeProvider extends ChangeNotifier {
  List<BarcodeItem> _scannedItems = [];
  List<BarcodeItem> _serverItems = []; // 서버에서 가져온 데이터
  bool _isLoading = false;
  bool _isLoadingServer = false;
  String? _errorMessage;
  final Map<String, DateTime> _lastScanTimes = {}; // 마지막 스캔 시간 추적
  static const Duration _scanCooldown = Duration(seconds: 1); // 쿨다운 시간
  
  // 페이징 관련 속성
  int _currentPage = 0;
  final int _pageSize = 50; // DB 최적화로 인해 20→50으로 증가
  bool _hasMoreData = true;
  bool _isPaginating = false;

  List<BarcodeItem> get scannedItems => _scannedItems;
  List<BarcodeItem> get serverItems => _serverItems;
  bool get isLoading => _isLoading;
  bool get isLoadingServer => _isLoadingServer;
  String? get errorMessage => _errorMessage;
  int get itemCount => _scannedItems.length;
  int get selectedCount => _scannedItems.where((item) => item.isSelected).length;
  int get totalQuantity => _scannedItems.fold(0, (sum, item) => sum + item.quantity);
  bool get hasMoreData => _hasMoreData;
  bool get isPaginating => _isPaginating;

  BarcodeProvider() {
    _loadFromLocal();
  }

  /// 바코드 아이템을 추가합니다.
  /// 반환값: null = 쿨다운 중, false = 새 아이템 추가, true = 기존 아이템 수량 증가
  bool? addItem(BarcodeItem item) {
    final now = DateTime.now();
    final lastScanTime = _lastScanTimes[item.code];
    
    // 쿨다운 시간 체크 (1초 이내 중복 스캔 방지)
    if (lastScanTime != null && 
        now.difference(lastScanTime) < _scanCooldown) {
      debugPrint('Scan cooldown active for ${item.code}');
      return null; // 쿨다운 중이므로 처리하지 않음
    }
    
    // 마지막 스캔 시간 업데이트
    _lastScanTimes[item.code] = now;
    
    // 주기적으로 오래된 쿨다운 기록 정리
    if (_lastScanTimes.length > 100) {
      _cleanupOldScanTimes();
    }
    
    final existingIndex = _scannedItems.indexWhere((i) => i.code == item.code);
    bool isDuplicate = false;
    
    if (existingIndex != -1) {
      _scannedItems[existingIndex].quantity++;
      isDuplicate = true;
    } else {
      _scannedItems.add(item);
    }
    
    _saveToLocal();
    notifyListeners();
    return isDuplicate;
  }

  void removeItem(String id) {
    _scannedItems.removeWhere((item) => item.id == id);
    _saveToLocal();
    notifyListeners();
  }

  void removeSelectedItems() {
    _scannedItems.removeWhere((item) => item.isSelected);
    _saveToLocal();
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    final index = _scannedItems.indexWhere((item) => item.id == id);
    if (index != -1 && quantity > 0) {
      _scannedItems[index].quantity = quantity;
      _saveToLocal();
      notifyListeners();
    }
  }

  void toggleSelection(String id) {
    final index = _scannedItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      _scannedItems[index].isSelected = !_scannedItems[index].isSelected;
      notifyListeners();
    }
  }

  void selectAll() {
    for (var item in _scannedItems) {
      item.isSelected = true;
    }
    notifyListeners();
  }

  void deselectAll() {
    for (var item in _scannedItems) {
      item.isSelected = false;
    }
    notifyListeners();
  }

  void clearAll() {
    _scannedItems.clear();
    _lastScanTimes.clear(); // 쿨다운 기록도 함께 정리
    _saveToLocal();
    notifyListeners();
  }

  /// 1분 이상 된 쿨다운 기록을 정리합니다 (메모리 관리)
  void _cleanupOldScanTimes() {
    final now = DateTime.now();
    _lastScanTimes.removeWhere((code, time) => 
        now.difference(time) > const Duration(minutes: 1));
  }

  Future<bool> sendToServer({bool selectedOnly = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      List<BarcodeItem> itemsToSend;
      
      if (selectedOnly) {
        itemsToSend = _scannedItems.where((item) => item.isSelected).toList();
        debugPrint('=== 선택된 항목만 서버 전송 시작 ===');
      } else {
        itemsToSend = _scannedItems;
        debugPrint('=== 전체 항목 서버 전송 시작 ===');
      }
      
      if (itemsToSend.isEmpty) {
        _errorMessage = selectedOnly ? '선택된 항목이 없습니다.' : '전송할 항목이 없습니다.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      debugPrint('전송할 아이템 수: ${itemsToSend.length}');
      for (var item in itemsToSend) {
        debugPrint('- ${item.code} (수량: ${item.quantity})');
      }
      
      // 실제 서버 API 호출
      final response = await BarcodeApiService.createBarcodesBatch(itemsToSend);
      
      debugPrint('API 응답 - Success: ${response.success}');
      debugPrint('API 응답 - Message: ${response.message}');
      debugPrint('API 응답 - Count: ${response.count}');
      
      if (response.success) {
        // 성공 시 전송된 항목들만 제거
        if (selectedOnly) {
          _scannedItems.removeWhere((item) => item.isSelected);
        } else {
          _scannedItems.clear();
          _lastScanTimes.clear();
        }
        _saveToLocal();
        
        // 서버 캐시 무효화를 위해 서버 데이터 강제 새로고침
        try {
          await loadFromServer(isRefresh: true);
          debugPrint('서버 데이터 새로고침 완료');
        } catch (e) {
          debugPrint('서버 데이터 새로고침 실패: $e');
          // 새로고침 실패해도 전송은 성공했으므로 계속 진행
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? '서버 전송에 실패했습니다.';
        debugPrint('전송 실패 - 에러 메시지: $_errorMessage');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      _errorMessage = '네트워크 오류: ${e.toString()}';
      debugPrint('전송 중 예외 발생: $e');
      debugPrint('스택 트레이스: $stackTrace');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 서버에서 바코드 데이터 로드 (페이징 지원)
  Future<void> loadFromServer({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 0;
      _serverItems.clear();
      _hasMoreData = true;
    }
    
    if (!_hasMoreData || _isPaginating) return;
    
    if (_currentPage == 0) {
      _isLoadingServer = true;
    } else {
      _isPaginating = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await BarcodeApiService.getAllBarcodes(
        page: _currentPage, 
        size: _pageSize
      );
      
      if (response.success && response.data != null) {
        final newItems = response.data!.map((dto) => BarcodeItem(
          id: dto.barcodeId?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          code: dto.barcodeValue,
          format: _mapStringToBarcodeFormat(dto.barcodeType),
          scannedAt: DateTime.tryParse(dto.createdDate ?? '') ?? DateTime.now(),
          quantity: 1,
        )).toList();
        
        _serverItems.addAll(newItems);
        
        // 더 이상 데이터가 없는지 확인
        if (newItems.length < _pageSize) {
          _hasMoreData = false;
        }
        
        _currentPage++;
        _isLoadingServer = false;
        _isPaginating = false;
        notifyListeners();
      } else {
        _errorMessage = response.message ?? '서버 데이터 로드에 실패했습니다.';
        _isLoadingServer = false;
        _isPaginating = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = '네트워크 오류: ${e.toString()}';
      _isLoadingServer = false;
      _isPaginating = false;
      notifyListeners();
    }
  }
  
  /// 다음 페이지 로드
  Future<void> loadNextPage() async {
    await loadFromServer();
  }

  /// 서버 통계 조회
  Future<int?> getServerBarcodeCount() async {
    try {
      final response = await BarcodeApiService.getBarcodeCount();
      
      if (response.success) {
        return response.data;
      } else {
        _errorMessage = response.message ?? '통계 조회에 실패했습니다.';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = '네트워크 오류: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// API 바코드 타입을 BarcodeFormat으로 변환
  BarcodeFormat _mapStringToBarcodeFormat(String type) {
    switch (type.toUpperCase()) {
      // QR 코드
      case 'QR':
        return BarcodeFormat.qrCode;
      
      // Code 시리즈
      case 'CODE128':
        return BarcodeFormat.code128;
      case 'CODE39':
        return BarcodeFormat.code39;
      case 'CODE93':
        return BarcodeFormat.code93;
      
      // EAN 시리즈
      case 'EAN13':
        return BarcodeFormat.ean13;
      case 'EAN8':
        return BarcodeFormat.ean8;
      
      // UPC 시리즈
      case 'UPC-A':
        return BarcodeFormat.upcA;
      case 'UPC-E':
        return BarcodeFormat.upcE;
      case 'UPC': // 기존 호환성 유지
        return BarcodeFormat.upcA;
      
      // 2D 바코드
      case 'DATAMATRIX':
        return BarcodeFormat.dataMatrix;
      case 'PDF417':
        return BarcodeFormat.pdf417;
      case 'AZTEC':
        return BarcodeFormat.aztec;
      
      // 기타 바코드
      case 'CODABAR':
        return BarcodeFormat.codabar;
      case 'ITF':
        return BarcodeFormat.itf;
      
      default:
        return BarcodeFormat.unknown;
    }
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? itemsJson = prefs.getString('scanned_items');
      
      if (itemsJson != null) {
        final List<dynamic> decoded = json.decode(itemsJson);
        _scannedItems = decoded.map((item) => BarcodeItem.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading from local: $e');
    }
  }

  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String itemsJson = json.encode(
        _scannedItems.map((item) => item.toJson()).toList(),
      );
      await prefs.setString('scanned_items', itemsJson);
    } catch (e) {
      debugPrint('Error saving to local: $e');
    }
  }
}
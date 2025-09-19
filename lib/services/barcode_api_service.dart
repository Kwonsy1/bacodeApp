import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/api_response.dart';
import '../models/barcode_item.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../config/app_config.dart';

class BarcodeApiService {
  static String get baseUrl => AppConfig.serverUrl;
  static String get apiPath => AppConfig.apiPath;
  static Duration get timeout => AppConfig.timeout;

  /// 바코드 타입을 API 형식으로 변환
  static String _mapBarcodeFormat(BarcodeFormat format) {
    switch (format) {
      // QR 코드
      case BarcodeFormat.qrCode:
        return 'QR';
      
      // Code 시리즈
      case BarcodeFormat.code128:
        return 'Code128';
      case BarcodeFormat.code39:
        return 'Code39';
      case BarcodeFormat.code93:
        return 'Code93';
      
      // EAN 시리즈
      case BarcodeFormat.ean13:
        return 'EAN13';
      case BarcodeFormat.ean8:
        return 'EAN8';
      
      // UPC 시리즈
      case BarcodeFormat.upcA:
        return 'UPC';  // 서버는 'UPC'만 허용
      case BarcodeFormat.upcE:
        return 'UPC';  // 서버는 'UPC'만 허용
      
      // 2D 바코드
      case BarcodeFormat.dataMatrix:
        return 'DataMatrix';
      case BarcodeFormat.pdf417:
        return 'PDF417';
      case BarcodeFormat.aztec:
        return 'Aztec';
      
      // 기타 바코드
      case BarcodeFormat.codabar:
        return 'Codabar';
      case BarcodeFormat.itf:
        return 'ITF';
      
      default:
        return 'Unknown';
    }
  }

  /// 단일 바코드 생성
  static Future<ApiResponse<BarcodeDto>> createBarcode(BarcodeItem item) async {
    try {
      final url = Uri.parse('$baseUrl$apiPath');
      
      final barcodeDto = BarcodeDto(
        barcodeValue: item.code,
        barcodeType: _mapBarcodeFormat(item.format),
        phoneModel: await _getDeviceModel(),
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(barcodeDto.toJson()),
      ).timeout(timeout);

      debugPrint('API Request: POST $url');
      debugPrint('Request Body: ${jsonEncode(barcodeDto.toJson())}');
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.fromJson(
          responseData,
          (data) => BarcodeDto.fromJson(data),
        );
      } else {
        return ApiResponse<BarcodeDto>(
          success: false,
          message: responseData['message'] ?? 'Unknown error',
        );
      }
    } catch (e) {
      debugPrint('API Error: $e');
      return ApiResponse<BarcodeDto>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  /// 네트워크 연결 상태 확인
  static Future<bool> checkServerConnection() async {
    try {
      final url = Uri.parse('$baseUrl$apiPath');
      debugPrint('서버 연결 테스트: $url');
      
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      debugPrint('서버 연결 테스트 결과 - 상태 코드: ${response.statusCode}');
      // 200 또는 다른 정상 응답 코드면 연결 성공으로 판단
      return response.statusCode < 500;
    } catch (e) {
      debugPrint('서버 연결 테스트 실패: $e');
      return false;
    }
  }

  /// 다중 바코드 생성 (배치)
  static Future<ApiResponse<List<BarcodeDto>>> createBarcodesBatch(List<BarcodeItem> items) async {
    try {
      final url = Uri.parse('$baseUrl$apiPath/batch');
      
      final deviceModel = await _getDeviceModel();
      final barcodeDtos = <Map<String, dynamic>>[];
      
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        
        try {
          // 바코드 값 정리 및 유효성 검사
          String cleanValue = item.code.trim();
          
          debugPrint('Processing item $i: "${cleanValue.substring(0, cleanValue.length > 50 ? 50 : cleanValue.length)}${cleanValue.length > 50 ? '...' : ''}"');
          debugPrint('Original length: ${item.code.length}, Type: ${_mapBarcodeFormat(item.format)}');
          
          // 컨트롤 문자 제거
          cleanValue = cleanValue.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');
          
          // 너무 긴 값은 잘라내기 (서버 검증 제한: 500자)
          if (cleanValue.length > 500) {
            cleanValue = cleanValue.substring(0, 500);
            debugPrint('Warning: Barcode value truncated to 500 characters');
          }
          
          // 빈 값 체크
          if (cleanValue.isEmpty) {
            debugPrint('Warning: Empty barcode value after cleaning, skipping');
            continue;
          }
          
          
          final dto = BarcodeDto(
            barcodeValue: cleanValue,
            barcodeType: _mapBarcodeFormat(item.format),
            phoneModel: deviceModel,
          );
          
          final jsonData = dto.toJson();
          debugPrint('Generated JSON for item $i: $jsonData');
          
          barcodeDtos.add(jsonData);
          
        } catch (e) {
          debugPrint('Error processing item $i: $e');
          // 개별 아이템 에러는 건너뛰고 계속 진행
          continue;
        }
      }
      
      if (barcodeDtos.isEmpty) {
        throw Exception('모든 바코드 데이터 처리에 실패했습니다.');
      }
      
      debugPrint('전송할 아이템 수: ${barcodeDtos.length}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(barcodeDtos),
      ).timeout(timeout);

      debugPrint('API Request: POST $url');
      debugPrint('Request Body: ${jsonEncode(barcodeDtos)}');
      debugPrint('Individual barcode data:');
      for (int i = 0; i < items.length; i++) {
        debugPrint('  [$i] Value: "${items[i].code}" (length: ${items[i].code.length})');
        debugPrint('  [$i] Type: ${_mapBarcodeFormat(items[i].format)}');
        debugPrint('  [$i] Contains special chars: ${items[i].code.contains(RegExp(r'[^\w\d]'))}');
      }
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 배치 API는 data 필드 없이 성공 응답만 반환
        bool isSuccess = responseData['success'] ?? true;
        debugPrint('서버 응답 success 필드: $isSuccess');
        
        return ApiResponse<List<BarcodeDto>>(
          success: isSuccess,
          message: responseData['message'],
          count: responseData['count'],
          data: [], // 배치 생성 시에는 생성된 데이터를 반환하지 않음
        );
      } else {
        debugPrint('HTTP 에러 - 상태 코드: ${response.statusCode}');
        
        // 검증 에러인 경우 상세 메시지 처리
        String errorMessage = responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        if (response.statusCode == 400 && responseData['errors'] != null) {
          // 필드별 에러 메시지가 있는 경우
          final errors = responseData['errors'] as Map<String, dynamic>;
          final errorMessages = errors.values.join(', ');
          errorMessage = '$errorMessage: $errorMessages';
        }
        
        return ApiResponse<List<BarcodeDto>>(
          success: false,
          message: errorMessage,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('=== Batch API Error Details ===');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error message: $e');
      debugPrint('Request URL: $baseUrl$apiPath/batch');
      debugPrint('Items count: ${items.length}');
      debugPrint('Stack trace: $stackTrace');
      
      String errorMessage = 'Network error: ';
      if (e.toString().contains('SocketException')) {
        errorMessage += '서버에 연결할 수 없습니다. 네트워크를 확인해주세요.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage += '요청 시간이 초과되었습니다.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage += 'JSON 형식 오류가 발생했습니다.';
      } else if (e.toString().contains('HttpException')) {
        errorMessage += 'HTTP 요청 오류가 발생했습니다.';
      } else {
        errorMessage += e.toString();
      }
      
      return ApiResponse<List<BarcodeDto>>(
        success: false,
        message: errorMessage,
      );
    }
  }

  /// 전체 바코드 조회 (페이징 지원)
  static Future<ApiResponse<List<BarcodeDto>>> getAllBarcodes({int page = 0, int size = 50}) async {
    try {
      final url = Uri.parse('$baseUrl$apiPath?page=$page&size=$size');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(timeout);

      debugPrint('API Request: GET $url');
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // 페이징 응답 처리: data 필드에 실제 데이터가 있음
        final List<dynamic> dataList = responseData['data'] ?? [];
        final pagination = responseData['pagination'];
        
        return ApiResponse<List<BarcodeDto>>(
          success: responseData['success'] ?? true,
          data: dataList.map((item) => BarcodeDto.fromJson(item)).toList(),
          message: responseData['message'],
          // 페이징 정보를 메시지에 포함 (필요시 ApiResponse 클래스에 pagination 필드 추가 가능)
          count: pagination?['totalElements'] ?? dataList.length,
        );
      } else {
        return ApiResponse<List<BarcodeDto>>(
          success: false,
          message: responseData['message'] ?? 'Unknown error',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('API Error: $e');
      debugPrint('Stack trace: $stackTrace');
      String errorMessage = 'Network error: ';
      if (e.toString().contains('SocketException')) {
        errorMessage += '서버에 연결할 수 없습니다. 네트워크를 확인해주세요.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage += '요청 시간이 초과되었습니다.';
      } else {
        errorMessage += e.toString();
      }
      return ApiResponse<List<BarcodeDto>>(
        success: false,
        message: errorMessage,
      );
    }
  }

  /// ID로 바코드 조회
  static Future<ApiResponse<BarcodeDto>> getBarcodeById(int id) async {
    try {
      final url = Uri.parse('$baseUrl$apiPath/$id');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(timeout);

      debugPrint('API Request: GET $url');
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(
          responseData,
          (data) => BarcodeDto.fromJson(data),
        );
      } else {
        return ApiResponse<BarcodeDto>(
          success: false,
          message: responseData['message'] ?? 'Unknown error',
        );
      }
    } catch (e) {
      debugPrint('API Error: $e');
      return ApiResponse<BarcodeDto>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  /// 바코드 통계 조회
  static Future<ApiResponse<int>> getBarcodeCount() async {
    try {
      final url = Uri.parse('$baseUrl$apiPath/stats/count');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(timeout);

      debugPrint('API Request: GET $url');
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return ApiResponse<int>(
          success: responseData['success'] ?? true,
          data: responseData['totalCount'] ?? 0,
        );
      } else {
        return ApiResponse<int>(
          success: false,
          message: responseData['message'] ?? 'Unknown error',
        );
      }
    } catch (e) {
      debugPrint('API Error: $e');
      return ApiResponse<int>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  /// 디바이스 모델 정보 가져오기
  static Future<String> _getDeviceModel() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return '${iosInfo.name} (${iosInfo.model})';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.brand} ${androidInfo.model}';
      } else {
        return 'Unknown Device';
      }
    } catch (e) {
      debugPrint('Device info error: $e');
      // 에러 발생 시 기본값 반환
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return 'iOS Device';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        return 'Android Device';
      } else {
        return 'Unknown Device';
      }
    }
  }
}
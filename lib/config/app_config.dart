import 'package:flutter/foundation.dart';

class AppConfig {
  static const String _defaultServerUrl = 'http://192.168.0.168:9830';
  
  // 안드로이드 에뮬레이터에서 로컬 서버 접근 시
  static const String _androidEmulatorUrl = 'http://10.0.2.2:9830';
  
  static String get serverUrl {
    // 디버그 모드에서만 로그 출력
    if (kDebugMode) {
      print('Platform: ${defaultTargetPlatform}');
      print('Server URL: $_defaultServerUrl');
    }
    
    // 실제 기기나 에뮬레이터 모두 같은 URL 사용
    // 필요시 플랫폼별 분기 가능
    return _defaultServerUrl;
  }
  
  static String get apiPath => '/api/barcodes';
  
  static Duration get timeout => const Duration(seconds: 30);
}
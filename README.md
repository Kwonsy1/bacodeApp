# BacodeApp - 바코드 스캐너 애플리케이션

Flutter로 개발된 크로스 플랫폼 바코드 스캐너 애플리케이션입니다. 다양한 바코드 형식을 인식하고 스캔 결과를 실시간으로 표시합니다.

## 주요 기능

### 바코드 스캔
- 실시간 바코드/QR코드 스캔
- 다양한 바코드 형식 지원:
  - QR 코드
  - Code 128, Code 39, Code 93
  - EAN-13, EAN-8
  - UPC-A, UPC-E
  - Data Matrix, PDF417, Aztec

### 사용자 편의 기능
- 카메라 권한 자동 요청 및 관리
- 스캔 시작/중지 제어
- 플래시(토치) 온/오프
- 스캔 결과 다이얼로그 표시
- 마지막 스캔 결과 저장 및 표시

## 기술 스택

### Framework & Language
- **Flutter 3.8.1+** - 크로스 플랫폼 UI 프레임워크
- **Dart** - 프로그래밍 언어

### 주요 라이브러리
- `mobile_scanner: ^5.0.14` - 바코드/QR코드 스캔 기능
- `permission_handler: ^11.3.1` - 카메라 권한 관리
- `cupertino_icons: ^1.0.8` - iOS 스타일 아이콘

### 지원 플랫폼
- ✅ Android
- ✅ iOS 
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 프로젝트 구조

```
lib/
├── main.dart                           # 앱 진입점 및 MaㅇㄷㄴterialApp 설정
└── screens/
    └── barcode_scanner_screen.dart     # 바코드 스캔 화면 구현
```

## 설치 및 실행

### 사전 요구사항
- Flutter SDK 3.8.1 이상
- Android Studio / Xcode (플랫폼별)
- 카메라가 있는 실제 디바이스 (에뮬레이터에서는 카메라 기능 제한)

### 설치
```bash
git clone [repository-url]
cd BacodeApp
flutter pub get
```

### 실행
```bash
# Android
flutter run

# iOS
flutter run -d ios

# 웹
flutter run -d web

# 특정 디바이스
flutter devices
flutter run -d [device-id]
```

## 앱 구성 요소

### 1. BarcodeApp (main.dart:8)
- MaterialApp 설정
- 앱 테마 구성 (Material 3 디자인)
- 기본 색상 스키마: Blue

### 2. BarcodeScannerScreen (barcode_scanner_screen.dart:5)
주요 상태 변수:
- `isScanning`: 스캔 활성화 상태
- `lastScannedCode`: 마지막 스캔된 바코드 데이터
- `lastScannedFormat`: 마지막 스캔된 바코드 형식
- `hasPermission`: 카메라 권한 상태

핵심 메서드:
- `_onBarcodeDetected()` - 바코드 감지 시 콜백
- `_showResultDialog()` - 스캔 결과 다이얼로그 표시
- `_getFormatName()` - 바코드 형식을 한국어로 변환
- `_requestCameraPermission()` - 카메라 권한 요청

## 사용법

1. **앱 실행**: 앱을 실행하면 자동으로 카메라 권한을 요청합니다.
2. **권한 허용**: 카메라 권한을 허용해야 스캔 기능을 사용할 수 있습니다.
3. **스캔 시작**: '시작' 버튼을 눌러 바코드 스캔을 활성화합니다.
4. **바코드 스캔**: 카메라를 바코드에 향하게 하면 자동으로 인식됩니다.
5. **결과 확인**: 스캔된 바코드의 형식과 내용이 다이얼로그로 표시됩니다.
6. **추가 기능**: 
   - 플래시 버튼으로 어두운 환경에서 조명 사용
   - 중지 버튼으로 스캔 일시 정지
   - 하단에 마지막 스캔 결과 표시

## 개발 정보

- **개발 환경**: Flutter 3.8.1
- **코드 품질**: flutter_lints 5.0.0 적용
- **아키텍처**: StatefulWidget 기반 단일 화면 구조
- **상태 관리**: 내장 setState 사용
- **UI 디자인**: Material 3 디자인 시스템

## 라이선스

Private project - 배포 금지 (pubspec.yaml의 `publish_to: 'none'` 설정)

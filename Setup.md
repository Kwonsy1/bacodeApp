# BacodeApp 설치 및 설정 가이드

Flutter 바코드 스캐너 앱을 로컬 환경에서 실행하기 위한 단계별 설치 가이드입니다.

## 사전 요구사항

### 1. Flutter SDK 설치
Flutter 3.8.1 이상이 필요합니다.

> **참고**: Flutter SDK에는 Dart SDK가 포함되어 있어 별도로 Dart를 설치할 필요가 없습니다. 
> 또한 이 프로젝트는 순수 Flutter 앱이므로 Node.js나 npm 등의 웹 개발 도구는 필요하지 않습니다.

#### macOS/Linux
```bash
# Flutter SDK 다운로드 및 설치
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# 설치 확인
flutter doctor
```

#### Windows
1. [Flutter 공식 사이트](https://flutter.dev/docs/get-started/install/windows)에서 Flutter SDK 다운로드
2. 압축 해제 후 PATH 환경변수에 `flutter/bin` 추가
3. PowerShell에서 `flutter doctor` 실행

### 2. 개발 환경 설정

#### Android 개발 (필수)
1. **Android Studio 설치**
   - [Android Studio](https://developer.android.com/studio) 다운로드 및 설치
   - Android SDK, Android SDK Command-line Tools, Android SDK Build-Tools 설치

2. **Android 에뮬레이터 또는 실제 디바이스 준비**
   ```bash
   # 사용 가능한 디바이스 확인
   flutter devices
   ```

#### iOS 개발 (macOS 전용)
1. **Xcode 설치** (App Store에서 설치)
2. **Xcode 명령행 도구 설치**
   ```bash
   sudo xcode-select --install
   ```
3. **iOS 시뮬레이터 또는 실제 디바이스 준비**

## 프로젝트 설치

### 1. 소스코드 다운로드
```bash
# 프로젝트 클론
git clone [repository-url]
cd BacodeApp
```

### 2. 의존성 설치
```bash
# Flutter 패키지 의존성 설치
flutter pub get
```

### 3. 설치 확인
```bash
# Flutter 환경 검사
flutter doctor

# 프로젝트 분석
flutter analyze
```

## 실행 방법

### Android에서 실행
```bash
# Android 디바이스/에뮬레이터에서 실행
flutter run

# 또는 특정 Android 디바이스 지정
flutter run -d android
```

### iOS에서 실행 (macOS만 가능)
```bash
# iOS 시뮬레이터에서 실행
flutter run -d ios

# 실제 iOS 디바이스에서 실행 (개발자 계정 필요)
flutter run -d [ios-device-id]
```

### 웹에서 실행
```bash
# 웹 브라우저에서 실행
flutter run -d web

# 또는 Chrome에서 실행
flutter run -d chrome
```

### 데스크톱에서 실행

#### Windows
```bash
flutter run -d windows
```

#### macOS
```bash
flutter run -d macos
```

#### Linux
```bash
flutter run -d linux
```

## 빌드 방법

### Android APK 빌드
```bash
# Debug APK
flutter build apk

# Release APK
flutter build apk --release

# APK 파일 위치: build/app/outputs/flutter-apk/app-release.apk
```

### iOS 앱 빌드 (macOS만 가능)
```bash
# iOS 앱 빌드
flutter build ios

# App Store 배포용
flutter build ios --release
```

### 웹 앱 빌드
```bash
# 웹 앱 빌드
flutter build web

# 빌드 파일 위치: build/web/
```

## 문제 해결

### 일반적인 문제

#### 1. "Camera permission not granted" 오류
- **실제 디바이스 사용**: 카메라 기능은 에뮬레이터에서 제한적입니다.
- **권한 허용**: 앱 실행 시 카메라 권한을 허용해주세요.

#### 2. Flutter doctor 경고
```bash
# Android toolchain 문제
flutter doctor --android-licenses

# iOS 설정 문제 (macOS)
sudo gem install cocoapods
```

#### 3. 의존성 문제
```bash
# 패키지 캐시 정리
flutter clean
flutter pub get

# Dart 패키지 캐시 초기화
dart pub cache repair
```

#### 4. Gradle 빌드 오류 (Android)
```bash
# Gradle wrapper 권한 설정 (macOS/Linux)
chmod +x android/gradlew

# Gradle 캐시 정리
cd android
./gradlew clean
cd ..
```

### 플랫폼별 추가 설정

#### Android
- **최소 SDK 버전**: API 21 (Android 5.0) 이상
- **컴파일 SDK 버전**: API 34 이상
- **카메라 권한**: `android.permission.CAMERA` 자동 요청

#### iOS
- **최소 배포 버전**: iOS 12.0 이상
- **카메라 권한**: `NSCameraUsageDescription` 자동 설정
- **개발자 계정**: 실제 디바이스 테스트 시 필요

#### Web
- **브라우저 지원**: Chrome, Firefox, Safari, Edge
- **HTTPS 필요**: 카메라 접근을 위해 HTTPS 환경 권장
- **로컬 테스트**: `flutter run -d web --web-port 8080`

## 추가 도구

### 개발 도구
```bash
# 핫 리로드로 개발
flutter run --hot

# 성능 분석
flutter run --profile

# 디버그 정보 확인
flutter logs
```

### 코드 품질 검사
```bash
# 코드 분석
flutter analyze

# 코드 포맷팅
dart format .

# 테스트 실행
flutter test
```

## 지원 및 문의

- **Flutter 공식 문서**: https://flutter.dev/docs
- **mobile_scanner 라이브러리**: https://pub.dev/packages/mobile_scanner
- **permission_handler 라이브러리**: https://pub.dev/packages/permission_handler

설치 과정에서 문제가 발생하면 `flutter doctor -v` 명령으로 상세한 환경 정보를 확인해보세요.
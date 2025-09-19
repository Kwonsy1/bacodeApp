# Barcode Server API

바코드 관리 시스템을 위한 Spring Boot REST API 서버입니다. 앱에서 읽은 바코드 정보를 저장, 조회, 수정, 삭제할 수 있는 완전한 CRUD API를 제공합니다.

## 📋 프로젝트 개요

### 주요 기능
- 📱 **바코드 저장**: 앱에서 읽은 단일/다중 바코드 정보 저장
- 🔍 **바코드 조회**: ID, 바코드 값, 타입, 카테고리별 조회
- ✏️ **바코드 수정**: 바코드 정보 업데이트 및 상태 변경
- 🗑️ **바코드 삭제**: ID 또는 바코드 값으로 삭제
- 📊 **통계 기능**: 바코드 개수 및 타입별 통계
- 🔍 **검색 기능**: 제품명으로 바코드 검색

### 기술 스택
- **Framework**: Spring Boot 3.4.7
- **Java Version**: OpenJDK 17
- **Database**: MySQL 8.0
- **ORM**: MyBatis 3.0.4
- **API Documentation**: Swagger/OpenAPI 3
- **Build Tool**: Gradle 8.5

## 🚀 시작하기

### 사전 요구사항
- Java 17 이상
- MySQL 8.0 서버 (192.168.0.32:3306)
- macOS 환경

### 1. 프로젝트 클론 및 설정

```bash
# 프로젝트 디렉토리로 이동
cd /Users/kwonsy/Source/BarcodeServer

# 프로젝트 구조 확인
ls -la
```

### 2. 데이터베이스 설정

MySQL 서버에 접속하여 데이터베이스를 생성합니다:

```bash
# MySQL 서버 접속
mysql -h 192.168.0.32 -u root -p1234

# 또는 스키마 파일로 직접 생성
mysql -h 192.168.0.32 -u root -p1234 < schema.sql
```

**데이터베이스 정보:**
- Host: `192.168.0.32:3306`
- Database: `barcodeServer`
- Username: `root`
- Password: `1234`

### 3. 애플리케이션 설정 확인

`src/main/resources/application.properties` 파일에서 DB 연결 정보를 확인합니다:

```properties
# MySQL Database Configuration
spring.datasource.url=jdbc:mysql://192.168.0.32:3306/barcodeServer?useSSL=false&serverTimezone=UTC&characterEncoding=UTF-8
spring.datasource.username=root
spring.datasource.password=1234
```

### 4. 서버 실행

#### 방법 1: Gradle Wrapper 사용
```bash
# 프로젝트 빌드
./gradlew build

# 서버 실행 (개발 모드)
./gradlew bootRun
```

#### 방법 2: JAR 파일 실행
```bash
# 프로젝트 빌드
./gradlew build

# JAR 파일로 실행
java -jar build/libs/BarcodeServer-0.0.1-SNAPSHOT.jar
```

#### 방법 3: 백그라운드 실행
```bash
# 백그라운드에서 실행
nohup java -jar build/libs/BarcodeServer-0.0.1-SNAPSHOT.jar > server.log 2>&1 &

# 로그 확인
tail -f server.log

# 프로세스 종료
ps aux | grep BarcodeServer
kill [PID]
```

### 5. 서버 실행 확인

서버가 정상적으로 시작되면 다음과 같은 로그가 출력됩니다:

```
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/

 :: Spring Boot ::                (v3.4.7)

Started BarcodeServerApplication in 1.063 seconds
Tomcat started on port 8080 (http)
```

## 📖 API 문서

### Swagger UI
서버 실행 후 다음 URL에서 API 문서를 확인할 수 있습니다:

- **Swagger UI**: http://localhost:8080/swagger-ui/index.html
- **OpenAPI JSON**: http://localhost:8080/v3/api-docs

### API 엔드포인트

#### 바코드 생성
- `POST /api/barcodes` - 단일 바코드 생성
- `POST /api/barcodes/batch` - 다중 바코드 생성

#### 바코드 조회
- `GET /api/barcodes` - 전체 바코드 조회
- `GET /api/barcodes/{barcodeId}` - ID로 바코드 조회
- `GET /api/barcodes/value/{barcodeValue}` - 바코드 값으로 조회
- `GET /api/barcodes/type/{barcodeType}` - 타입별 조회
- `GET /api/barcodes/category/{category}` - 카테고리별 조회
- `GET /api/barcodes/search?productName={name}` - 제품명 검색

#### 바코드 수정
- `PUT /api/barcodes/{barcodeId}` - 바코드 정보 수정
- `PATCH /api/barcodes/{barcodeId}/status?status={status}` - 상태 변경

#### 바코드 삭제
- `DELETE /api/barcodes/{barcodeId}` - ID로 삭제
- `DELETE /api/barcodes/value/{barcodeValue}` - 값으로 삭제

#### 통계
- `GET /api/barcodes/stats/count` - 바코드 총 개수

### API 사용 예제

#### 바코드 생성
```bash
curl -X POST http://localhost:8080/api/barcodes \
  -H "Content-Type: application/json" \
  -d '{
    "barcodeValue": "1234567890123",
    "barcodeType": "EAN13",
    "productName": "테스트 제품",
    "description": "테스트용 바코드",
    "manufacturer": "테스트 제조사",
    "price": 10000.0,
    "category": "Electronics"
  }'
```

#### 바코드 조회
```bash
# 전체 조회
curl http://localhost:8080/api/barcodes

# ID로 조회
curl http://localhost:8080/api/barcodes/1

# 바코드 값으로 조회
curl http://localhost:8080/api/barcodes/value/1234567890123
```

## 🗂️ 프로젝트 구조

```
BarcodeServer/
├── src/
│   └── main/
│       ├── java/com/example/barcodeserver/
│       │   ├── config/
│       │   │   └── SwaggerConfig.java          # Swagger 설정
│       │   ├── controller/
│       │   │   └── BarcodeController.java      # REST API 컨트롤러
│       │   ├── dto/
│       │   │   └── BarcodeDto.java            # 데이터 전송 객체
│       │   ├── mapper/
│       │   │   └── BarcodeMapper.java         # MyBatis 매퍼 인터페이스
│       │   ├── service/
│       │   │   └── BarcodeService.java        # 비즈니스 로직
│       │   └── BarcodeServerApplication.java   # 메인 애플리케이션
│       └── resources/
│           ├── mappers/
│           │   └── BarcodeMapper.xml          # MyBatis XML 매퍼
│           ├── application.properties         # 설정 파일
│           └── mybatis-config.xml            # MyBatis 설정
├── build.gradle                              # Gradle 빌드 설정
├── schema.sql                               # 데이터베이스 스키마
└── README.md                               # 프로젝트 문서
```

## 🗄️ 데이터베이스 스키마

### barcodes 테이블
```sql
CREATE TABLE barcodes (
    barcodeId BIGINT AUTO_INCREMENT PRIMARY KEY,
    barcodeValue VARCHAR(255) NOT NULL UNIQUE,
    barcodeType VARCHAR(50) NOT NULL,
    productName VARCHAR(255),
    description TEXT,
    manufacturer VARCHAR(255),
    price DECIMAL(10, 2),
    category VARCHAR(100),
    status VARCHAR(20) DEFAULT 'ACTIVE',
    createdDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedDate DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    createdBy VARCHAR(100),
    updatedBy VARCHAR(100)
);
```

**주요 특징:**
- 모든 컬럼명이 카멜케이스로 구성
- 바코드 값의 유니크 제약 조건
- 생성/수정 시간 자동 관리
- 인덱스 최적화

## 🔧 설정 및 커스터마이징

### 포트 변경
`application.properties`에서 서버 포트를 변경할 수 있습니다:
```properties
server.port=9090
```

### 로그 레벨 설정
```properties
logging.level.com.example.barcodeserver=DEBUG
logging.level.org.apache.ibatis=DEBUG
```

### 커넥션 풀 설정
```properties
spring.datasource.hikari.maximum-pool-size=20
spring.datasource.hikari.minimum-idle=5
```

## 🧪 테스트

### API 테스트
Swagger UI를 통해 각 API를 직접 테스트할 수 있습니다:
http://localhost:8080/swagger-ui/index.html

### 헬스 체크
```bash
curl http://localhost:8080/api/barcodes/stats/count
```

## 🔍 문제해결

### 일반적인 문제들

#### 1. 데이터베이스 연결 오류
```
Error: Communications link failure
```
**해결방법:**
- MySQL 서버가 실행 중인지 확인
- 네트워크 연결 상태 확인
- 방화벽 설정 확인

#### 2. 포트 충돌
```
Port 8080 was already in use
```
**해결방법:**
```bash
# 포트 사용 프로세스 확인
lsof -i :8080

# 프로세스 종료
kill -9 [PID]
```

#### 3. Java 버전 문제
```
Unsupported major.minor version
```
**해결방법:**
```bash
# Java 버전 확인
java -version

# Java 17 설치 (Homebrew 사용)
brew install openjdk@17
```

## 📞 지원

문제가 발생하거나 질문이 있으면 다음을 확인하세요:

1. **로그 파일**: `server.log` 또는 콘솔 출력
2. **Swagger 문서**: API 사용법 및 예제
3. **데이터베이스 연결**: MySQL 서버 상태 확인

## 📄 라이선스

이 프로젝트는 개인/교육 목적으로 사용됩니다.
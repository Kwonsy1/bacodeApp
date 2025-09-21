# 📊 데이터베이스 설정 가이드

## 🔧 DB 접속 정보 관리

### 현재 상태
DB 접속 정보는 환경변수 또는 별도의 프로파일 설정 파일에서 관리됩니다. 
**보안상 실제 접속 정보는 Git에 포함되지 않습니다.**

### 🛡️ 보안 설정 방법

#### 방법 1: 환경변수 사용 (권장)

```bash
# 시스템 환경변수 설정
export DB_HOST=192.168.0.32
export DB_PORT=3306
export DB_NAME=barcodeServer
export DB_USERNAME=root
export DB_PASSWORD=your_secure_password

# 서버 실행
java -jar build/libs/BarcodeServer-0.0.1-SNAPSHOT.jar
```

#### 방법 2: 실행 시 인자로 전달

```bash
java -jar build/libs/BarcodeServer-0.0.1-SNAPSHOT.jar \
  --spring.datasource.url=jdbc:mysql://your-host:3306/barcodeServer \
  --spring.datasource.username=your_username \
  --spring.datasource.password=your_password
```

#### 방법 3: 프로파일별 설정 파일 생성 (권장)

```bash
# 1. 템플릿 파일을 복사하여 실제 설정 파일 생성
cp src/main/resources/application-local.properties.template src/main/resources/application-local.properties

# 2. 실제 DB 정보로 수정
vi src/main/resources/application-local.properties

# 3. 로컬 프로파일로 실행
java -jar -Dspring.profiles.active=local build/libs/BarcodeServer-0.0.1-SNAPSHOT.jar
```

### 📁 설정 파일 구조

```
src/main/resources/
├── application.properties           # 기본 설정 (환경변수 사용)
├── application-dev.properties       # 개발 환경 (.gitignore에 포함)
└── application-prod.properties      # 운영 환경 (.gitignore에 포함)
```

### 🔄 마이그레이션 가이드

#### 기존 환경에서 새 환경으로 이전

1. **설정 파일 복사**:
   ```bash
   cp application-example.properties application-local.properties
   ```

2. **접속 정보 수정**:
   ```properties
   # application-local.properties
   spring.datasource.url=jdbc:mysql://YOUR_HOST:3306/barcodeServer
   spring.datasource.username=YOUR_USERNAME
   spring.datasource.password=YOUR_PASSWORD
   ```

3. **프로파일 지정하여 실행**:
   ```bash
   java -jar -Dspring.profiles.active=local build/libs/BarcodeServer-0.0.1-SNAPSHOT.jar
   ```

### 📊 DB 초기 설정

1. **데이터베이스 생성**:
   ```bash
   mysql -u root -p < schema.sql
   ```

2. **서버 시작**:
   ```bash
   ./gradlew bootRun
   ```

3. **접속 확인**:
   ```bash
   curl http://localhost:8080/api/barcodes/admin/health
   ```

### ⚠️ 보안 주의사항

- **application-dev.properties**, **application-prod.properties**는 Git에 커밋하지 마세요
- 운영 환경에서는 반드시 환경변수나 외부 설정을 사용하세요
- 기본 패스워드(`1234`)는 개발 환경에서만 사용하세요

### 🔧 트러블슈팅

#### 연결 실패 시 확인사항

1. **네트워크 연결**:
   ```bash
   telnet 192.168.0.32 3306
   ```

2. **DB 서버 상태**:
   ```bash
   mysql -h 192.168.0.32 -u root -p -e "SELECT 1"
   ```

3. **방화벽 설정**: 3306 포트 오픈 확인

4. **권한 확인**: MySQL 사용자 권한 점검
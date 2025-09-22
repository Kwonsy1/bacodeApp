# Barcode Server API 스펙

## 기본 정보
- **Base URL**: `http://localhost:9830` 또는 `http://192.168.0.32:9830`
- **Content-Type**: `application/json`
- **API 버전**: 1.0.0

## 📱 데이터 모델

### BarcodeDto
```json
{
  "barcodeId": 1,
  "barcodeValue": "1234567890123",
  "barcodeType": "EAN13",
  "phoneModel": "iPhone 15 Pro",
  "status": "ACTIVE",
  "createdDate": "2025-09-16T13:35:55",
  "updatedDate": null
}
```

## 🚀 API 엔드포인트

### 1. 바코드 생성

#### 단일 바코드 생성
```http
POST /api/barcodes
Content-Type: application/json

{
  "barcodeValue": "1234567890123",
  "barcodeType": "EAN13",
  "phoneModel": "iPhone 15 Pro"
}
```

**응답:**
```json
{
  "success": true,
  "message": "Barcode created successfully",
  "data": {
    "barcodeId": 6,
    "barcodeValue": "1234567890123",
    "barcodeType": "EAN13",
    "phoneModel": "iPhone 15 Pro",
    "status": "ACTIVE",
    "createdDate": "2025-09-16T13:35:55"
  }
}
```

#### 다중 바코드 생성
```http
POST /api/barcodes/batch
Content-Type: application/json

[
  {
    "barcodeValue": "1111111111111",
    "barcodeType": "EAN13",
    "phoneModel": "iPhone 15"
  },
  {
    "barcodeValue": "2222222222222",
    "barcodeType": "UPC",
    "phoneModel": "Galaxy S24"
  }
]
```

### 2. 바코드 조회

#### 전체 바코드 조회
```http
GET /api/barcodes
```

#### ID로 바코드 조회
```http
GET /api/barcodes/{barcodeId}
```

#### 바코드 값으로 조회
```http
GET /api/barcodes/value/{barcodeValue}
```

#### 타입별 조회
```http
GET /api/barcodes/type/{barcodeType}
```

#### 카테고리별 조회
```http
GET /api/barcodes/category/{category}
```

#### 휴대폰 모델로 검색
```http
GET /api/barcodes/search?productName={phoneModel}
```

**조회 응답 예시:**
```json
{
  "success": true,
  "data": [
    {
      "barcodeId": 1,
      "barcodeValue": "1234567890123",
      "barcodeType": "EAN13",
      "phoneModel": "iPhone 15 Pro",
      "status": "ACTIVE",
      "createdDate": "2025-09-16T13:35:55",
      "updatedDate": null
    }
  ],
  "count": 1
}
```

### 3. 바코드 수정

#### 바코드 정보 수정
```http
PUT /api/barcodes/{barcodeId}
Content-Type: application/json

{
  "barcodeValue": "1234567890123",
  "barcodeType": "EAN13",
  "phoneModel": "iPhone 15 Pro Max"
}
```

#### 바코드 상태 변경
```http
PATCH /api/barcodes/{barcodeId}/status?status=INACTIVE
```

### 4. 바코드 삭제

#### ID로 삭제
```http
DELETE /api/barcodes/{barcodeId}
```

#### 바코드 값으로 삭제
```http
DELETE /api/barcodes/value/{barcodeValue}
```

### 5. 통계

#### 바코드 총 개수
```http
GET /api/barcodes/stats/count
```

**응답:**
```json
{
  "success": true,
  "totalCount": 5
}
```

## 📊 응답 형식

### 성공 응답
```json
{
  "success": true,
  "message": "작업 성공 메시지",
  "data": { /* 데이터 객체 */ },
  "count": 1
}
```

### 오류 응답
```json
{
  "success": false,
  "message": "오류 메시지"
}
```

## 🔧 HTTP 상태 코드

| 코드 | 설명 |
|------|------|
| 200 | 성공 |
| 201 | 생성 성공 |
| 404 | 리소스를 찾을 수 없음 |
| 409 | 충돌 (중복된 바코드) |
| 500 | 서버 오류 |

## 📱 프론트엔드 개발 참고사항

### 필수 필드
- `barcodeValue`: 바코드 값 (필수)
- `barcodeType`: 바코드 타입 (필수)

### 선택 필드
- `phoneModel`: 휴대폰 모델명

### 바코드 타입
- `EAN13`: 유럽 표준 13자리
- `EAN8`: 유럽 표준 8자리
- `UPC`: 미국 표준 12자리
- `Code128`: 고밀도 바코드
- `QR`: QR 코드

### 상태 값
- `ACTIVE`: 활성 (기본값)
- `INACTIVE`: 비활성
- `DELETED`: 삭제됨

## 🧪 테스트 예시

### curl 명령어 예시
```bash
# 바코드 생성
curl -X POST http://localhost:8080/api/barcodes \
  -H "Content-Type: application/json" \
  -d '{
    "barcodeValue": "9999999999999",
    "barcodeType": "EAN13",
    "phoneModel": "Test Phone"
  }'

# 전체 조회
curl http://localhost:8080/api/barcodes

# ID로 조회
curl http://localhost:8080/api/barcodes/1

# 검색
curl "http://localhost:8080/api/barcodes/search?productName=iPhone"
```

### JavaScript fetch 예시
```javascript
// 바코드 생성
const createBarcode = async () => {
  const response = await fetch('http://localhost:8080/api/barcodes', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      barcodeValue: '1234567890123',
      barcodeType: 'EAN13',
      phoneModel: 'iPhone 15 Pro'
    })
  });
  
  const result = await response.json();
  console.log(result);
};

// 바코드 조회
const getBarcodes = async () => {
  const response = await fetch('http://localhost:8080/api/barcodes');
  const result = await response.json();
  console.log(result.data);
};
```
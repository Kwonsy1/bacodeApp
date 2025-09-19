-- 바코드 데이터베이스 생성
CREATE DATABASE IF NOT EXISTS barcodeServer CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE barcodeServer;

-- 바코드 테이블 생성 (서버 validation 규칙과 일치)
CREATE TABLE IF NOT EXISTS barcodes (
    barcode_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    barcode_value VARCHAR(500) NOT NULL,  -- 서버 validation: 최대 500자
    barcode_type VARCHAR(50) NOT NULL,    -- 지원 타입: QR, Code128, EAN13, UPC, DataMatrix, PDF417, Code39, Code93, ITF, Codabar, Aztec, MaxiCode
    phone_model VARCHAR(100),             -- 서버 validation: 최대 100자
    status VARCHAR(20) DEFAULT 'ACTIVE',  -- ACTIVE 또는 INACTIVE
    created_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_date DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    
    -- 기본 인덱스
    INDEX idx_barcode_value (barcode_value),
    INDEX idx_barcode_type (barcode_type),
    INDEX idx_phone_model (phone_model),
    INDEX idx_status (status),
    INDEX idx_created_date (created_date),
    
    -- 성능 최적화를 위한 복합 인덱스
    INDEX idx_status_type_created (status, barcode_type, created_date DESC),
    INDEX idx_type_phone_model (barcode_type, phone_model),
    INDEX idx_status_created (status, created_date DESC),
    INDEX idx_phone_created (phone_model, created_date DESC)
);

-- 샘플 데이터 삽입 (서버에서 지원하는 바코드 타입 사용)
INSERT INTO barcodes (barcode_value, barcode_type, phone_model) VALUES
('1234567890123', 'EAN13', 'iPhone 15 Pro'),
('8801234567890', 'EAN13', 'Galaxy S24 Ultra'),
('9788901234567', 'EAN13', 'iPhone 15'),
('012345678905', 'UPC', 'Galaxy S24'),
('CODE128_SAMPLE_001', 'Code128', 'iPhone 14 Pro Max'),
('http://example.com/qr', 'QR', 'iPad Pro'),
('DATAMATRIX_001', 'DataMatrix', 'Galaxy Tab S9');

-- 테이블 최적화 (선택사항)
-- OPTIMIZE TABLE barcodes;
-- ANALYZE TABLE barcodes;

-- 바코드 타입별 통계 조회 (확인용)
SELECT 
    barcode_type,
    COUNT(*) as count,
    MIN(created_date) as oldest,
    MAX(created_date) as newest
FROM barcodes 
WHERE status = 'ACTIVE'
GROUP BY barcode_type
ORDER BY count DESC;
package com.example.barcodeserver.controller;

import com.example.barcodeserver.dto.BarcodeDto;
import com.example.barcodeserver.service.BarcodeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.jdbc.core.JdbcTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/barcodes")
@CrossOrigin(origins = "*")
@Validated
@Tag(name = "Barcode API", description = "바코드 관리 API")
public class BarcodeController {

    @Autowired
    private BarcodeService barcodeService;
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    @Value("${app.batch.maxSize:100}")
    private int maxBatchSize;

    @PostMapping
    @Operation(summary = "바코드 생성", description = "새로운 바코드를 생성합니다")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "바코드 생성 성공"),
            @ApiResponse(responseCode = "409", description = "이미 존재하는 바코드"),
            @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    public ResponseEntity<Map<String, Object>> createBarcode(@Valid @RequestBody BarcodeDto barcodeDto) {
        Map<String, Object> response = new HashMap<>();
        try {
            if (barcodeService.existsByBarcodeValue(barcodeDto.getBarcodeValue())) {
                response.put("success", false);
                response.put("message", "Barcode already exists");
                return ResponseEntity.status(HttpStatus.CONFLICT).body(response);
            }
            
            barcodeService.saveBarcode(barcodeDto);
            response.put("success", true);
            response.put("message", "Barcode created successfully");
            response.put("data", barcodeDto);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error creating barcode: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @PostMapping("/batch")
    @Operation(summary = "다중 바코드 생성", description = "여러 바코드를 한번에 생성합니다")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "바코드들 생성 성공"),
            @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    public ResponseEntity<Map<String, Object>> createBarcodes(@Valid @RequestBody @NotEmpty List<@Valid BarcodeDto> barcodes) {
        Map<String, Object> response = new HashMap<>();
        try {
            // 배치 크기 검증
            if (barcodes == null || barcodes.isEmpty()) {
                response.put("success", false);
                response.put("message", "Barcode list cannot be empty");
                return ResponseEntity.badRequest().body(response);
            }
            
            if (barcodes.size() > maxBatchSize) {
                response.put("success", false);
                response.put("message", "Batch size exceeds maximum allowed: " + maxBatchSize + ". Current size: " + barcodes.size());
                return ResponseEntity.badRequest().body(response);
            }
            
            barcodeService.saveBarcodes(barcodes);
            response.put("success", true);
            response.put("message", "Barcodes created successfully");
            response.put("count", barcodes.size());
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error creating barcodes: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @GetMapping("/{barcodeId}")
    @Operation(summary = "ID로 바코드 조회", description = "바코드 ID로 바코드 정보를 조회합니다")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "404", description = "바코드를 찾을 수 없음"),
            @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    public ResponseEntity<Map<String, Object>> getBarcodeById(
            @Parameter(description = "바코드 ID", required = true) @PathVariable Long barcodeId) {
        Map<String, Object> response = new HashMap<>();
        try {
            BarcodeDto barcode = barcodeService.getBarcodeById(barcodeId);
            if (barcode != null) {
                response.put("success", true);
                response.put("data", barcode);
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "Barcode not found");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error retrieving barcode: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @GetMapping("/value/{barcodeValue}")
    @Operation(summary = "바코드 값으로 조회", description = "바코드 값으로 바코드 정보를 조회합니다")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "404", description = "바코드를 찾을 수 없음"),
            @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    public ResponseEntity<Map<String, Object>> getBarcodeByValue(
            @Parameter(description = "바코드 값", required = true) @PathVariable String barcodeValue) {
        Map<String, Object> response = new HashMap<>();
        try {
            BarcodeDto barcode = barcodeService.getBarcodeByValue(barcodeValue);
            if (barcode != null) {
                response.put("success", true);
                response.put("data", barcode);
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "Barcode not found");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error retrieving barcode: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @GetMapping
    @Operation(summary = "전체 바코드 조회", description = "모든 바코드 목록을 조회합니다 (페이징 지원)")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    public ResponseEntity<Map<String, Object>> getAllBarcodes(
            @Parameter(description = "페이지 번호 (0부터 시작)") @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "페이지 크기") @RequestParam(defaultValue = "50") int size) {
        Map<String, Object> response = new HashMap<>();
        try {
            // 페이지 크기 제한
            if (size > 100) {
                size = 100;
            }
            if (size < 1) {
                size = 50;
            }
            if (page < 0) {
                page = 0;
            }
            
            int totalCount = barcodeService.getTotalBarcodesCount();
            int offset = page * size;
            
            List<BarcodeDto> barcodes;
            if (offset >= totalCount) {
                barcodes = new java.util.ArrayList<>();
            } else {
                barcodes = barcodeService.getBarcodesPaginated(offset, size);
            }
            
            int totalPages = (int) Math.ceil((double) totalCount / size);
            
            response.put("success", true);
            response.put("data", barcodes);
            response.put("pagination", Map.of(
                "currentPage", page,
                "pageSize", size,
                "totalElements", totalCount,
                "totalPages", totalPages,
                "hasNext", page < totalPages - 1,
                "hasPrevious", page > 0
            ));
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error retrieving barcodes: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @GetMapping("/type/{barcodeType}")
    @Operation(summary = "타입별 바코드 조회", description = "바코드 타입별로 바코드 목록을 조회합니다")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    public ResponseEntity<Map<String, Object>> getBarcodesByType(
            @Parameter(description = "바코드 타입 (예: EAN13, UPC, Code128)", required = true) @PathVariable String barcodeType) {
        Map<String, Object> response = new HashMap<>();
        try {
            List<BarcodeDto> barcodes = barcodeService.getBarcodesByType(barcodeType);
            response.put("success", true);
            response.put("data", barcodes);
            response.put("count", barcodes.size());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error retrieving barcodes: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @GetMapping("/category/{category}")
    @Operation(summary = "카테고리별 바코드 조회", description = "카테고리별로 바코드 목록을 조회합니다")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    public ResponseEntity<Map<String, Object>> getBarcodesByCategory(
            @Parameter(description = "카테고리명", required = true) @PathVariable String category) {
        Map<String, Object> response = new HashMap<>();
        try {
            List<BarcodeDto> barcodes = barcodeService.getBarcodesByCategory(category);
            response.put("success", true);
            response.put("data", barcodes);
            response.put("count", barcodes.size());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error retrieving barcodes: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @GetMapping("/search")
    @Operation(summary = "휴대폰 모델로 바코드 검색", description = "휴대폰 모델명으로 바코드를 검색합니다")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "검색 성공"),
            @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    public ResponseEntity<Map<String, Object>> searchBarcodes(
            @Parameter(description = "검색할 휴대폰 모델명", required = true) @RequestParam String productName) {
        Map<String, Object> response = new HashMap<>();
        try {
            List<BarcodeDto> barcodes = barcodeService.searchBarcodesByProductName(productName);
            response.put("success", true);
            response.put("data", barcodes);
            response.put("count", barcodes.size());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error searching barcodes: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @PutMapping("/{barcodeId}")
    @Operation(summary = "바코드 정보 수정", description = "바코드 정보를 수정합니다")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "수정 성공"),
            @ApiResponse(responseCode = "404", description = "바코드를 찾을 수 없음"),
            @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    public ResponseEntity<Map<String, Object>> updateBarcode(
            @Parameter(description = "바코드 ID", required = true) @PathVariable Long barcodeId, 
            @Valid @RequestBody BarcodeDto barcodeDto) {
        Map<String, Object> response = new HashMap<>();
        try {
            BarcodeDto existingBarcode = barcodeService.getBarcodeById(barcodeId);
            if (existingBarcode == null) {
                response.put("success", false);
                response.put("message", "Barcode not found");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }
            
            barcodeDto.setBarcodeId(barcodeId);
            barcodeService.updateBarcode(barcodeDto);
            response.put("success", true);
            response.put("message", "Barcode updated successfully");
            response.put("data", barcodeDto);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error updating barcode: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @PatchMapping("/{barcodeId}/status")
    @Operation(summary = "바코드 상태 변경", description = "바코드의 상태를 변경합니다")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "상태 변경 성공"),
            @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    public ResponseEntity<Map<String, Object>> updateBarcodeStatus(
            @Parameter(description = "바코드 ID", required = true) @PathVariable Long barcodeId, 
            @Parameter(description = "변경할 상태 (ACTIVE, INACTIVE)", required = true) @RequestParam String status) {
        Map<String, Object> response = new HashMap<>();
        try {
            barcodeService.updateBarcodeStatus(barcodeId, status);
            response.put("success", true);
            response.put("message", "Barcode status updated successfully");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error updating barcode status: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @DeleteMapping("/{barcodeId}")
    @Operation(summary = "바코드 삭제 (ID)", description = "바코드 ID로 바코드를 삭제합니다")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "삭제 성공"),
            @ApiResponse(responseCode = "404", description = "바코드를 찾을 수 없음"),
            @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    public ResponseEntity<Map<String, Object>> deleteBarcodeById(
            @Parameter(description = "바코드 ID", required = true) @PathVariable Long barcodeId) {
        Map<String, Object> response = new HashMap<>();
        try {
            BarcodeDto existingBarcode = barcodeService.getBarcodeById(barcodeId);
            if (existingBarcode == null) {
                response.put("success", false);
                response.put("message", "Barcode not found");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }
            
            barcodeService.deleteBarcodeById(barcodeId);
            response.put("success", true);
            response.put("message", "Barcode deleted successfully");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error deleting barcode: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @DeleteMapping("/value/{barcodeValue}")
    @Operation(summary = "바코드 삭제 (값)", description = "바코드 값으로 바코드를 삭제합니다")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "삭제 성공"),
            @ApiResponse(responseCode = "404", description = "바코드를 찾을 수 없음"),
            @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    public ResponseEntity<Map<String, Object>> deleteBarcodeByValue(
            @Parameter(description = "바코드 값", required = true) @PathVariable String barcodeValue) {
        Map<String, Object> response = new HashMap<>();
        try {
            BarcodeDto existingBarcode = barcodeService.getBarcodeByValue(barcodeValue);
            if (existingBarcode == null) {
                response.put("success", false);
                response.put("message", "Barcode not found");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }
            
            barcodeService.deleteBarcodeByValue(barcodeValue);
            response.put("success", true);
            response.put("message", "Barcode deleted successfully");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error deleting barcode: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @GetMapping("/stats/count")
    @Operation(summary = "바코드 통계", description = "바코드 총 개수 통계를 조회합니다")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "통계 조회 성공"),
            @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    public ResponseEntity<Map<String, Object>> getBarcodesStats() {
        Map<String, Object> response = new HashMap<>();
        try {
            int totalCount = barcodeService.getTotalBarcodesCount();
            response.put("success", true);
            response.put("totalCount", totalCount);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error retrieving barcode stats: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    @PostMapping("/admin/remove-unique-constraint")
    @Operation(summary = "UNIQUE 제약조건 제거", description = "barcode_value 컬럼의 UNIQUE 제약조건을 제거합니다")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "제약조건 제거 성공"),
            @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    public ResponseEntity<Map<String, Object>> removeUniqueConstraint() {
        Map<String, Object> response = new HashMap<>();
        try {
            // UNIQUE 제약조건 제거
            jdbcTemplate.execute("ALTER TABLE barcodes DROP INDEX barcode_value");
            
            response.put("success", true);
            response.put("message", "UNIQUE constraint removed successfully. Duplicate barcode values are now allowed.");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error removing unique constraint: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    @PostMapping("/admin/optimize-indexes")
    @Operation(summary = "데이터베이스 인덱스 최적화", description = "성능 향상을 위한 복합 인덱스를 생성합니다")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "인덱스 최적화 성공"),
            @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    public ResponseEntity<Map<String, Object>> optimizeIndexes() {
        Map<String, Object> response = new HashMap<>();
        try {
            // 복합 인덱스 생성 (기존 인덱스가 있으면 무시)
            String[] indexQueries = {
                "CREATE INDEX idx_status_type_created ON barcodes(status, barcode_type, created_date DESC)",
                "CREATE INDEX idx_type_phone_model ON barcodes(barcode_type, phone_model)",
                "CREATE INDEX idx_status_created ON barcodes(status, created_date DESC)",
                "CREATE INDEX idx_phone_created ON barcodes(phone_model, created_date DESC)"
            };
            
            int successCount = 0;
            
            for (String query : indexQueries) {
                try {
                    jdbcTemplate.execute(query);
                    successCount++;
                } catch (Exception e) {
                    // 이미 존재하는 인덱스는 무시
                    if (!e.getMessage().contains("Duplicate key name")) {
                        throw e;
                    }
                }
            }
            
            response.put("success", true);
            response.put("message", "Database indexes optimized successfully. Created " + successCount + " new compound indexes for improved query performance.");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error optimizing indexes: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    @GetMapping("/admin/health")
    @Operation(summary = "시스템 상태 확인", description = "데이터베이스 연결 상태 및 성능 지표를 확인합니다")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "상태 확인 성공"),
            @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    public ResponseEntity<Map<String, Object>> getSystemHealth() {
        Map<String, Object> response = new HashMap<>();
        try {
            // 데이터베이스 연결 테스트
            long startTime = System.currentTimeMillis();
            int count = barcodeService.getTotalBarcodesCount();
            long queryTime = System.currentTimeMillis() - startTime;
            
            response.put("success", true);
            response.put("database", "connected");
            response.put("totalBarcodes", count);
            response.put("queryTime", queryTime + "ms");
            response.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("database", "error");
            response.put("message", "Health check failed: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    @PostMapping("/admin/optimize-database")
    @Operation(summary = "데이터베이스 최적화", description = "테이블 최적화 및 통계 업데이트를 수행합니다")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "최적화 성공"),
            @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    public ResponseEntity<Map<String, Object>> optimizeDatabase() {
        Map<String, Object> response = new HashMap<>();
        try {
            // 테이블 최적화
            jdbcTemplate.execute("OPTIMIZE TABLE barcodes");
            
            // 통계 업데이트
            jdbcTemplate.execute("ANALYZE TABLE barcodes");
            
            // 통계 정보 조회
            Map<String, Object> stats = jdbcTemplate.queryForMap(
                "SELECT table_rows, " +
                "ROUND(data_length/1024/1024, 2) as data_size_mb, " +
                "ROUND(index_length/1024/1024, 2) as index_size_mb " +
                "FROM information_schema.tables " +
                "WHERE table_schema = DATABASE() AND table_name = 'barcodes'"
            );
            
            // 현재 인덱스 정보 조회
            List<Map<String, Object>> indexes = jdbcTemplate.queryForList(
                "SELECT DISTINCT index_name " +
                "FROM information_schema.statistics " +
                "WHERE table_schema = DATABASE() AND table_name = 'barcodes'"
            );
            
            response.put("success", true);
            response.put("message", "Database optimization completed successfully");
            response.put("stats", stats);
            response.put("indexes", indexes);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Database optimization failed: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}
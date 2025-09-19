package com.example.barcodeserver.dto;

import jakarta.validation.constraints.*;
import java.time.LocalDateTime;

public class BarcodeDto {
    private Long barcodeId;
    
    @NotBlank(message = "바코드 값은 필수입니다")
    @Size(min = 1, max = 500, message = "바코드 값은 1-500자 사이여야 합니다")
    private String barcodeValue;
    
    @NotBlank(message = "바코드 타입은 필수입니다")
    @Pattern(regexp = "^(QR|Code128|EAN13|UPC|DataMatrix|PDF417|Code39|Code93|ITF|Codabar|Aztec|MaxiCode)$", 
             message = "유효하지 않은 바코드 타입입니다")
    private String barcodeType;
    
    @Size(max = 100, message = "휴대폰 모델명은 100자를 초과할 수 없습니다")
    private String phoneModel;
    
    @Pattern(regexp = "^(ACTIVE|INACTIVE)$", message = "상태는 ACTIVE 또는 INACTIVE여야 합니다")
    private String status;
    
    private LocalDateTime createdDate;
    private LocalDateTime updatedDate;

    public BarcodeDto() {}

    public BarcodeDto(String barcodeValue, String barcodeType) {
        this.barcodeValue = barcodeValue;
        this.barcodeType = barcodeType;
        this.createdDate = LocalDateTime.now();
        this.status = "ACTIVE";
    }

    public Long getBarcodeId() { return barcodeId; }
    public void setBarcodeId(Long barcodeId) { this.barcodeId = barcodeId; }

    public String getBarcodeValue() { return barcodeValue; }
    public void setBarcodeValue(String barcodeValue) { this.barcodeValue = barcodeValue; }

    public String getBarcodeType() { return barcodeType; }
    public void setBarcodeType(String barcodeType) { this.barcodeType = barcodeType; }

    public String getPhoneModel() { return phoneModel; }
    public void setPhoneModel(String phoneModel) { this.phoneModel = phoneModel; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedDate() { return createdDate; }
    public void setCreatedDate(LocalDateTime createdDate) { this.createdDate = createdDate; }

    public LocalDateTime getUpdatedDate() { return updatedDate; }
    public void setUpdatedDate(LocalDateTime updatedDate) { this.updatedDate = updatedDate; }
}
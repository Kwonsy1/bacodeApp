package com.example.barcodeserver.mapper;

import com.example.barcodeserver.dto.BarcodeDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface BarcodeMapper {
    
    void insertBarcode(BarcodeDto barcodeDto);
    
    void insertBarcodes(@Param("barcodes") List<BarcodeDto> barcodes);
    
    BarcodeDto selectBarcodeById(@Param("barcodeId") Long barcodeId);
    
    BarcodeDto selectBarcodeByValue(@Param("barcodeValue") String barcodeValue);
    
    List<BarcodeDto> selectAllBarcodes();
    
    List<BarcodeDto> selectBarcodesByType(@Param("barcodeType") String barcodeType);
    
    List<BarcodeDto> selectBarcodesByCategory(@Param("category") String category);
    
    List<BarcodeDto> selectBarcodesByStatus(@Param("status") String status);
    
    List<BarcodeDto> selectBarcodesByProductName(@Param("productName") String productName);
    
    void updateBarcode(BarcodeDto barcodeDto);
    
    void updateBarcodeStatus(@Param("barcodeId") Long barcodeId, @Param("status") String status);
    
    void deleteBarcodeById(@Param("barcodeId") Long barcodeId);
    
    void deleteBarcodeByValue(@Param("barcodeValue") String barcodeValue);
    
    int countTotalBarcodes();
    
    int countBarcodesByType(@Param("barcodeType") String barcodeType);
    
    List<BarcodeDto> selectBarcodesPaginated(@Param("offset") int offset, @Param("limit") int limit);
}
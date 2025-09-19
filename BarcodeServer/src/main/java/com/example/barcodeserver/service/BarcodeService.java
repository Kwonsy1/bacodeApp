package com.example.barcodeserver.service;

import com.example.barcodeserver.dto.BarcodeDto;
import com.example.barcodeserver.mapper.BarcodeMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@Transactional
public class BarcodeService {

    @Autowired
    private BarcodeMapper barcodeMapper;

    @CacheEvict(value = {"barcodesCount", "recentBarcodes"}, allEntries = true)
    public void saveBarcode(BarcodeDto barcodeDto) {
        barcodeDto.setCreatedDate(LocalDateTime.now());
        if (barcodeDto.getStatus() == null) {
            barcodeDto.setStatus("ACTIVE");
        }
        barcodeMapper.insertBarcode(barcodeDto);
    }

    @CacheEvict(value = {"barcodesCount", "recentBarcodes"}, allEntries = true)
    public void saveBarcodes(List<BarcodeDto> barcodes) {
        LocalDateTime now = LocalDateTime.now();
        for (BarcodeDto barcode : barcodes) {
            barcode.setCreatedDate(now);
            if (barcode.getStatus() == null) {
                barcode.setStatus("ACTIVE");
            }
        }
        barcodeMapper.insertBarcodes(barcodes);
    }

    @Transactional(readOnly = true)
    public BarcodeDto getBarcodeById(Long barcodeId) {
        return barcodeMapper.selectBarcodeById(barcodeId);
    }

    @Transactional(readOnly = true)
    public BarcodeDto getBarcodeByValue(String barcodeValue) {
        return barcodeMapper.selectBarcodeByValue(barcodeValue);
    }

    @Transactional(readOnly = true)
    public List<BarcodeDto> getAllBarcodes() {
        return barcodeMapper.selectAllBarcodes();
    }

    @Transactional(readOnly = true)
    public List<BarcodeDto> getBarcodesByType(String barcodeType) {
        return barcodeMapper.selectBarcodesByType(barcodeType);
    }

    @Transactional(readOnly = true)
    public List<BarcodeDto> getBarcodesByCategory(String category) {
        return barcodeMapper.selectBarcodesByCategory(category);
    }

    @Transactional(readOnly = true)
    public List<BarcodeDto> getBarcodesByStatus(String status) {
        return barcodeMapper.selectBarcodesByStatus(status);
    }

    @Transactional(readOnly = true)
    public List<BarcodeDto> searchBarcodesByProductName(String productName) {
        return barcodeMapper.selectBarcodesByProductName(productName);
    }

    @CacheEvict(value = {"barcodesCount", "recentBarcodes"}, allEntries = true)
    public void updateBarcode(BarcodeDto barcodeDto) {
        barcodeDto.setUpdatedDate(LocalDateTime.now());
        barcodeMapper.updateBarcode(barcodeDto);
    }

    @CacheEvict(value = {"barcodesCount", "recentBarcodes"}, allEntries = true)
    public void updateBarcodeStatus(Long barcodeId, String status) {
        barcodeMapper.updateBarcodeStatus(barcodeId, status);
    }

    @CacheEvict(value = {"barcodesCount", "recentBarcodes"}, allEntries = true)
    public void deleteBarcodeById(Long barcodeId) {
        barcodeMapper.deleteBarcodeById(barcodeId);
    }

    @CacheEvict(value = {"barcodesCount", "recentBarcodes"}, allEntries = true)
    public void deleteBarcodeByValue(String barcodeValue) {
        barcodeMapper.deleteBarcodeByValue(barcodeValue);
    }

    @Transactional(readOnly = true)
    @Cacheable(value = "barcodesCount")
    public int getTotalBarcodesCount() {
        return barcodeMapper.countTotalBarcodes();
    }

    @Transactional(readOnly = true)
    public int getBarcodesCountByType(String barcodeType) {
        return barcodeMapper.countBarcodesByType(barcodeType);
    }

    @Transactional(readOnly = true)
    public boolean existsByBarcodeValue(String barcodeValue) {
        return barcodeMapper.selectBarcodeByValue(barcodeValue) != null;
    }
    
    @Transactional(readOnly = true)
    public List<BarcodeDto> getBarcodesPaginated(int offset, int limit) {
        return barcodeMapper.selectBarcodesPaginated(offset, limit);
    }
}
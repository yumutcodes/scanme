package com.backend.dto;

import java.time.LocalDateTime;

public class HistoryDto {
    private Long id;
    private String barcode;
    private String productName;
    private Boolean isSafe;
    private LocalDateTime scanDate;

    public HistoryDto() {
    }

    public HistoryDto(Long id, String barcode, String productName, Boolean isSafe, LocalDateTime scanDate) {
        this.id = id;
        this.barcode = barcode;
        this.productName = productName;
        this.isSafe = isSafe;
        this.scanDate = scanDate;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getBarcode() {
        return barcode;
    }

    public void setBarcode(String barcode) {
        this.barcode = barcode;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public Boolean getIsSafe() {
        return isSafe;
    }

    public void setIsSafe(Boolean isSafe) {
        this.isSafe = isSafe;
    }

    public LocalDateTime getScanDate() {
        return scanDate;
    }

    public void setScanDate(LocalDateTime scanDate) {
        this.scanDate = scanDate;
    }
}

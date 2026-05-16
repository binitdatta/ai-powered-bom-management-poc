package com.bomiq.sdm.dto;

import com.bomiq.sdm.model.BomHeader;
import com.bomiq.sdm.model.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class BomSummaryDto {
    private Long   id;
    private String bomNumber;
    private String bomRevision;
    private String bomTitle;
    private String productCode;
    private String productName;
    private String bomType;
    private String bomStatus;
    private LocalDate effectiveDate;
    private BigDecimal totalMaterialCost;
    private String currencyCode;
    private Integer levelInHierarchy;
    private Long   parentBomId;
    private String parentBomNumber;
    private String assemblyLocation;
    private String riskLevel;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static BomSummaryDto from(BomHeader b) {
        return BomSummaryDto.builder()
            .id(b.getId())
            .bomNumber(b.getBomNumber())
            .bomRevision(b.getBomRevision())
            .bomTitle(b.getBomTitle())
            .productCode(b.getProduct() != null ? b.getProduct().getProductCode() : null)
            .productName(b.getProduct() != null ? b.getProduct().getProductName() : null)
            .bomType(b.getBomType() != null ? b.getBomType().name() : null)
            .bomStatus(b.getBomStatus() != null ? b.getBomStatus().name() : null)
            .effectiveDate(b.getEffectiveDate())
            .totalMaterialCost(b.getTotalMaterialCost())
            .currencyCode(b.getCurrencyCode())
            .levelInHierarchy(b.getLevelInHierarchy())
            .parentBomId(b.getParentBom() != null ? b.getParentBom().getId() : null)
            .parentBomNumber(b.getParentBom() != null ? b.getParentBom().getBomNumber() : null)
            .assemblyLocation(b.getAssemblyLocation())
            .riskLevel(b.getRiskLevel() != null ? b.getRiskLevel().name() : null)
            .isActive(b.getIsActive())
            .createdAt(b.getCreatedAt())
            .updatedAt(b.getUpdatedAt())
            .build();
    }
}

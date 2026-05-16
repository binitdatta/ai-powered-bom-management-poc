package com.bomiq.sdm.dto;

import com.bomiq.sdm.model.BomHeader;
import com.bomiq.sdm.model.BomLineItem;
import com.bomiq.sdm.model.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class BomDetailDto {
    private Long   id;
    private String bomNumber;
    private String bomRevision;
    private String bomTitle;
    private String productCode;
    private String productName;
    private String bomType;
    private String bomStatus;
    private LocalDate effectiveDate;
    private LocalDate expiryDate;
    private String engineeringChangeNo;
    private String changeDescription;
    private BigDecimal totalMaterialCost;
    private BigDecimal totalLaborCost;
    private BigDecimal totalOverheadCost;
    private BigDecimal totalBomCost;
    private String currencyCode;
    private BigDecimal weightKg;
    private Integer targetAssemblyTimeMin;
    private String assemblyLocation;
    private String qualityPlanRef;
    private String riskLevel;
    private String approvedBy;
    private LocalDateTime approvedAt;
    private String notes;
    private Integer levelInHierarchy;
    private Long   parentBomId;
    private List<BomLineItemDto> lineItems;
    private List<BomSummaryDto>  childBoms;

    public static BomDetailDto from(BomHeader b, List<BomLineItem> lines, List<BomHeader> children) {
        return BomDetailDto.builder()
            .id(b.getId())
            .bomNumber(b.getBomNumber())
            .bomRevision(b.getBomRevision())
            .bomTitle(b.getBomTitle())
            .productCode(b.getProduct() != null ? b.getProduct().getProductCode() : null)
            .productName(b.getProduct() != null ? b.getProduct().getProductName() : null)
            .bomType(b.getBomType() != null ? b.getBomType().name() : null)
            .bomStatus(b.getBomStatus() != null ? b.getBomStatus().name() : null)
            .effectiveDate(b.getEffectiveDate())
            .expiryDate(b.getExpiryDate())
            .engineeringChangeNo(b.getEngineeringChangeNo())
            .changeDescription(b.getChangeDescription())
            .totalMaterialCost(b.getTotalMaterialCost())
            .totalLaborCost(b.getTotalLaborCost())
            .totalOverheadCost(b.getTotalOverheadCost())
            .totalBomCost(b.getTotalBomCost())
            .currencyCode(b.getCurrencyCode())
            .weightKg(b.getWeightKg())
            .targetAssemblyTimeMin(b.getTargetAssemblyTimeMin())
            .assemblyLocation(b.getAssemblyLocation())
            .qualityPlanRef(b.getQualityPlanRef())
            .riskLevel(b.getRiskLevel() != null ? b.getRiskLevel().name() : null)
            .approvedBy(b.getApprovedBy())
            .approvedAt(b.getApprovedAt())
            .notes(b.getNotes())
            .levelInHierarchy(b.getLevelInHierarchy())
            .parentBomId(b.getParentBom() != null ? b.getParentBom().getId() : null)
            .lineItems(lines != null ? lines.stream().map(BomLineItemDto::from).toList() : List.of())
            .childBoms(children != null ? children.stream().map(BomSummaryDto::from).toList() : List.of())
            .build();
    }
}

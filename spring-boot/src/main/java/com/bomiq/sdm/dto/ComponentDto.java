package com.bomiq.sdm.dto;

import com.bomiq.sdm.model.Component;
import com.bomiq.sdm.model.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class ComponentDto {
    private Long   id;
    private String partNumber;
    private String partRevision;
    private String partName;
    private String partDescription;
    private String materialClassName;
    private String preferredSupplierCode;
    private BigDecimal unitCost;
    private String currencyCode;
    private BigDecimal weightGrams;
    private BigDecimal voltageRatingV;
    private BigDecimal currentRatingA;
    private String ipRating;
    private BigDecimal operatingTempMinC;
    private BigDecimal operatingTempMaxC;
    private Boolean rohsCompliant;
    private Boolean reachCompliant;
    private String manufacturerPartNo;
    private String manufacturerName;
    private String lifecycleStatus;
    private String procurementType;
    private LocalDateTime updatedAt;

    public static ComponentDto from(Component c) {
        return ComponentDto.builder()
            .id(c.getId())
            .partNumber(c.getPartNumber())
            .partRevision(c.getPartRevision())
            .partName(c.getPartName())
            .partDescription(c.getPartDescription())
            .materialClassName(c.getMaterialClass() != null ? c.getMaterialClass().getClassName() : null)
            .preferredSupplierCode(c.getPreferredSupplier() != null ? c.getPreferredSupplier().getSupplierCode() : null)
            .unitCost(c.getUnitCost())
            .currencyCode(c.getCurrencyCode())
            .weightGrams(c.getWeightGrams())
            .voltageRatingV(c.getVoltageRatingV())
            .currentRatingA(c.getCurrentRatingA())
            .ipRating(c.getIpRating())
            .operatingTempMinC(c.getOperatingTempMinC())
            .operatingTempMaxC(c.getOperatingTempMaxC())
            .rohsCompliant(c.getRohsCompliant())
            .reachCompliant(c.getReachCompliant())
            .manufacturerPartNo(c.getManufacturerPartNo())
            .manufacturerName(c.getManufacturerName())
            .lifecycleStatus(c.getLifecycleStatus() != null ? c.getLifecycleStatus().name() : null)
            .procurementType(c.getProcurementType() != null ? c.getProcurementType().name() : null)
            .updatedAt(c.getUpdatedAt())
            .build();
    }
}

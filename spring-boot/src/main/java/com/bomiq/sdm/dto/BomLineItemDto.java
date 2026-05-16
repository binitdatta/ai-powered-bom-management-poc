package com.bomiq.sdm.dto;

import com.bomiq.sdm.model.BomLineItem;
import com.bomiq.sdm.model.*;
import lombok.*;
import java.math.BigDecimal;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class BomLineItemDto {
    private Long   id;
    private Integer lineSequence;
    private String partNumber;
    private String partName;
    private BigDecimal quantity;
    private String uomCode;
    private String referenceDesignator;
    private Integer findNumber;
    private String itemType;
    private String procurementType;
    private BigDecimal unitCost;
    private BigDecimal extendedCost;
    private Integer leadTimeDays;
    private BigDecimal scrapFactorPct;
    private Boolean criticalComponent;
    private String supplierCode;
    private String supplierPartNo;
    private String assemblyInstruction;
    private String notes;

    public static BomLineItemDto from(BomLineItem li) {
        return BomLineItemDto.builder()
            .id(li.getId())
            .lineSequence(li.getLineSequence())
            .partNumber(li.getComponent() != null ? li.getComponent().getPartNumber() : null)
            .partName(li.getComponent() != null ? li.getComponent().getPartName() : null)
            .quantity(li.getQuantity())
            .uomCode(li.getUom() != null ? li.getUom().getUomCode() : null)
            .referenceDesignator(li.getReferenceDesignator())
            .findNumber(li.getFindNumber())
            .itemType(li.getItemType() != null ? li.getItemType().name() : null)
            .procurementType(li.getProcurementType() != null ? li.getProcurementType().name() : null)
            .unitCost(li.getUnitCost())
            .extendedCost(li.getExtendedCost())
            .leadTimeDays(li.getLeadTimeDays())
            .scrapFactorPct(li.getScrapFactorPct())
            .criticalComponent(li.getCriticalComponent())
            .supplierCode(li.getPreferredSupplier() != null ? li.getPreferredSupplier().getSupplierCode() : null)
            .supplierPartNo(li.getSupplierPartNo())
            .assemblyInstruction(li.getAssemblyInstruction())
            .notes(li.getNotes())
            .build();
    }
}

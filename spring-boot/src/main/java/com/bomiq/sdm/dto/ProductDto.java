package com.bomiq.sdm.dto;

import com.bomiq.sdm.model.Product;
import com.bomiq.sdm.model.*;
import lombok.*;
import java.time.LocalDate;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class ProductDto {
    private Long   id;
    private String productCode;
    private String productName;
    private String productFamily;
    private String productLine;
    private String targetMarket;
    private String lifecyclePhase;
    private Boolean isActive;
    private LocalDate launchDate;
    private LocalDate endOfLifeDate;

    public static ProductDto from(Product p) {
        return ProductDto.builder()
            .id(p.getId())
            .productCode(p.getProductCode())
            .productName(p.getProductName())
            .productFamily(p.getProductFamily())
            .productLine(p.getProductLine())
            .targetMarket(p.getTargetMarket())
            .lifecyclePhase(p.getLifecyclePhase() != null ? p.getLifecyclePhase().name() : null)
            .isActive(p.getIsActive())
            .launchDate(p.getLaunchDate())
            .endOfLifeDate(p.getEndOfLifeDate())
            .build();
    }
}

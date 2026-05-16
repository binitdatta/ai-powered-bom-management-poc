package com.bomiq.sdm.dto;

import com.bomiq.sdm.model.Supplier;
import com.bomiq.sdm.model.*;
import lombok.*;
import java.time.LocalDateTime;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class SupplierDto {
    private Long   id;
    private String supplierCode;
    private String legalName;
    private String tradeName;
    private String supplierTier;
    private String riskRating;
    private String countryOfOrigin;
    private String headquartersCity;
    private String primaryContact;
    private String contactEmail;
    private Integer leadTimeDays;
    private String paymentTerms;
    private String currencyCode;
    private String certifications;
    private Boolean isApproved;
    private LocalDateTime approvedAt;
    private Boolean isActive;

    public static SupplierDto from(Supplier s) {
        return SupplierDto.builder()
            .id(s.getId())
            .supplierCode(s.getSupplierCode())
            .legalName(s.getLegalName())
            .tradeName(s.getTradeName())
            .supplierTier(s.getSupplierTier() != null ? s.getSupplierTier().name() : null)
            .riskRating(s.getRiskRating() != null ? s.getRiskRating().name() : null)
            .countryOfOrigin(s.getCountryOfOrigin())
            .headquartersCity(s.getHeadquartersCity())
            .primaryContact(s.getPrimaryContact())
            .contactEmail(s.getContactEmail())
            .leadTimeDays(s.getLeadTimeDays())
            .paymentTerms(s.getPaymentTerms())
            .currencyCode(s.getCurrencyCode())
            .certifications(s.getCertifications())
            .isApproved(s.getIsApproved())
            .approvedAt(s.getApprovedAt())
            .isActive(s.getIsActive())
            .build();
    }
}

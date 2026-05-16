package com.bomiq.sdm.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.LocalDateTime;

@Entity
@Table(name = "supplier")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Supplier {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(name="supplier_code", nullable=false, unique=true, length=30) private String supplierCode;
    @Column(name="legal_name",    nullable=false, length=200)             private String legalName;
    @Column(name="trade_name",    length=200)                             private String tradeName;
    @Column(name="duns_number",   unique=true, length=15)                 private String dunsNumber;
    @Column(name="tax_id",        length=30)                              private String taxId;
    @Enumerated(EnumType.STRING)
    @Column(name="supplier_tier", length=10)                              private SupplierTier supplierTier;
    @Enumerated(EnumType.STRING)
    @Column(name="risk_rating",   length=10)                              private RiskRating riskRating;
    @Column(name="country_of_origin", length=2)                           private String countryOfOrigin;
    @Column(name="headquarters_city", length=100)                         private String headquartersCity;
    @Column(name="primary_contact",   length=150)                         private String primaryContact;
    @Column(name="contact_email",     length=200)                         private String contactEmail;
    @Column(name="contact_phone",     length=30)                          private String contactPhone;
    @Column(name="lead_time_days")                                        private Integer leadTimeDays;
    @Column(name="payment_terms",     length=50)                          private String paymentTerms;
    @Column(name="currency_code",     length=3)                           private String currencyCode;
    @Column(name="certifications",    columnDefinition="TEXT")            private String certifications;
    @Column(name="notes",             columnDefinition="TEXT")            private String notes;
    @Column(name="is_approved")                                           private Boolean isApproved = false;
    @Column(name="approved_by",       length=100)                         private String approvedBy;
    @Column(name="approved_at")                                           private LocalDateTime approvedAt;
    @Column(name="is_active")                                             private Boolean isActive = true;
    @CreationTimestamp @Column(name="created_at", updatable=false)        private LocalDateTime createdAt;
    @UpdateTimestamp   @Column(name="updated_at")                         private LocalDateTime updatedAt;

    public enum SupplierTier { TIER1, TIER2, TIER3, SPOT }
    public enum RiskRating   { LOW, MEDIUM, HIGH, CRITICAL }
}
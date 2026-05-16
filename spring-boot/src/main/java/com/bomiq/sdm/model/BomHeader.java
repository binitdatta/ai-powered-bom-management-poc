package com.bomiq.sdm.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "bom_header")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class BomHeader {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "bom_number", nullable = false, unique = true, length = 50)
    private String bomNumber;

    @Column(name = "bom_revision", nullable = false, length = 10)
    private String bomRevision;

    @Column(name = "bom_title", nullable = false, length = 300)
    private String bomTitle;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Enumerated(EnumType.STRING)
    @Column(name = "bom_type", length = 20)
    private BomType bomType;

    @Enumerated(EnumType.STRING)
    @Column(name = "bom_status", length = 20)
    private BomStatus bomStatus;

    @Column(name = "effective_date")
    private LocalDate effectiveDate;

    @Column(name = "expiry_date")
    private LocalDate expiryDate;

    @Column(name = "engineering_change_no", length = 50)
    private String engineeringChangeNo;

    @Column(name = "change_description", columnDefinition = "TEXT")
    private String changeDescription;

    @Column(name = "total_material_cost", precision = 18, scale = 4)
    private BigDecimal totalMaterialCost;

    @Column(name = "total_labor_cost", precision = 18, scale = 4)
    private BigDecimal totalLaborCost;

    @Column(name = "total_overhead_cost", precision = 18, scale = 4)
    private BigDecimal totalOverheadCost;

    @Column(name = "total_bom_cost", precision = 18, scale = 4)
    private BigDecimal totalBomCost;

    @Column(name = "currency_code", length = 3)
    private String currencyCode;

    @Column(name = "costing_date")
    private LocalDate costingDate;

    @Column(name = "weight_kg", precision = 12, scale = 4)
    private BigDecimal weightKg;

    @Column(name = "volume_cm3", precision = 14, scale = 4)
    private BigDecimal volumeCm3;

    @Column(name = "target_assembly_time_min")
    private Integer targetAssemblyTimeMin;

    @Column(name = "assembly_location", length = 100)
    private String assemblyLocation;

    @Column(name = "quality_plan_ref", length = 50)
    private String qualityPlanRef;

    @Enumerated(EnumType.STRING)
    @Column(name = "risk_level", length = 10)
    private RiskLevel riskLevel;

    @Column(name = "approval_required_by", length = 100)
    private String approvalRequiredBy;

    @Column(name = "approved_by", length = 100)
    private String approvedBy;

    @Column(name = "approved_at")
    private LocalDateTime approvedAt;

    @Column(name = "released_by", length = 100)
    private String releasedBy;

    @Column(name = "released_at")
    private LocalDateTime releasedAt;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_bom_id")
    private BomHeader parentBom;

    @Column(name = "level_in_hierarchy")
    private Integer levelInHierarchy;

    @Column(name = "created_by", length = 100)
    private String createdBy;

    @Column(name = "updated_by", length = 100)
    private String updatedBy;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // ── Relationships ──────────────────────────────────────────────────────
    @OneToMany(mappedBy = "bomHeader", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @OrderBy("lineSequence ASC")
    private List<BomLineItem> lineItems = new ArrayList<>();

    @OneToMany(mappedBy = "parentBom", fetch = FetchType.LAZY)
    private List<BomHeader> childBoms = new ArrayList<>();

    // ── Enums ──────────────────────────────────────────────────────────────
    public enum BomType {
        ENGINEERING, MANUFACTURING, SERVICE, SALES, PLANNING
    }

    public enum BomStatus {
        DRAFT, IN_REVIEW, APPROVED, RELEASED, OBSOLETE, SUPERSEDED
    }

    public enum RiskLevel {
        LOW, MEDIUM, HIGH, CRITICAL
    }
}

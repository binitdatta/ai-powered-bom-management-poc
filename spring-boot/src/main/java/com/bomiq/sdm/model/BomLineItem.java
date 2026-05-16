package com.bomiq.sdm.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "bom_line_item")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class BomLineItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bom_header_id", nullable = false)
    private BomHeader bomHeader;

    @Column(name = "line_sequence", nullable = false)
    private Integer lineSequence;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "component_id", nullable = false)
    private Component component;

    @Column(name = "quantity", nullable = false, precision = 14, scale = 6)
    private BigDecimal quantity;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "uom_id")
    private UnitOfMeasure uom;

    @Column(name = "reference_designator", length = 200)
    private String referenceDesignator;

    @Column(name = "find_number")
    private Integer findNumber;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sub_bom_id")
    private BomHeader subBom;

    @Enumerated(EnumType.STRING)
    @Column(name = "item_type", length = 15)
    private ItemType itemType;

    @Enumerated(EnumType.STRING)
    @Column(name = "procurement_type", length = 15)
    private ProcurementType procurementType;

    @Column(name = "unit_cost", precision = 18, scale = 4)
    private BigDecimal unitCost;

    @Column(name = "extended_cost", precision = 18, scale = 4)
    private BigDecimal extendedCost;

    @Column(name = "lead_time_days")
    private Integer leadTimeDays;

    @Column(name = "scrap_factor_pct", precision = 6, scale = 2)
    private BigDecimal scrapFactorPct;

    @Column(name = "yield_factor_pct", precision = 6, scale = 2)
    private BigDecimal yieldFactorPct;

    @Column(name = "effective_date")
    private LocalDate effectiveDate;

    @Column(name = "expiry_date")
    private LocalDate expiryDate;

    @Column(name = "engineering_change_no", length = 50)
    private String engineeringChangeNo;

    @Column(name = "position_description", length = 200)
    private String positionDescription;

    @Column(name = "assembly_instruction", columnDefinition = "TEXT")
    private String assemblyInstruction;

    @Column(name = "inspection_note", columnDefinition = "TEXT")
    private String inspectionNote;

    @Column(name = "substitution_allowed")
    private Boolean substitutionAllowed;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "substitute_component_id")
    private Component substituteComponent;

    @Column(name = "critical_component")
    private Boolean criticalComponent;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "preferred_supplier_id")
    private Supplier preferredSupplier;

    @Column(name = "supplier_part_no", length = 80)
    private String supplierPartNo;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    @Column(name = "created_by", length = 100)
    private String createdBy;

    @Column(name = "updated_by", length = 100)
    private String updatedBy;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public enum ItemType {
        STANDARD, PHANTOM, REFERENCE, SELECT, VARIANT
    }

    public enum ProcurementType {
        BUY, MAKE, CONSIGNED, PHANTOM
    }
}

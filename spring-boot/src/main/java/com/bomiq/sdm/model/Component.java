package com.bomiq.sdm.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.math.BigDecimal;
import java.time.LocalDateTime;

// ============================================================
// Component (Part Master)
// ============================================================
@Entity
@Table(name = "component")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Component {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "part_number", nullable = false, unique = true, length = 50)
    private String partNumber;

    @Column(name = "part_revision", nullable = false, length = 10)
    private String partRevision;

    @Column(name = "part_name", nullable = false, length = 200)
    private String partName;

    @Column(name = "part_description", columnDefinition = "TEXT")
    private String partDescription;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "material_class_id")
    private MaterialClass materialClass;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "preferred_supplier_id")
    private Supplier preferredSupplier;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "uom_id")
    private UnitOfMeasure uom;

    @Column(name = "unit_cost", precision = 18, scale = 4)
    private BigDecimal unitCost;

    @Column(name = "standard_cost", precision = 18, scale = 4)
    private BigDecimal standardCost;

    @Column(name = "currency_code", length = 3)
    private String currencyCode;

    @Column(name = "weight_grams", precision = 12, scale = 4)
    private BigDecimal weightGrams;

    @Column(name = "length_mm", precision = 12, scale = 4)
    private BigDecimal lengthMm;

    @Column(name = "width_mm", precision = 12, scale = 4)
    private BigDecimal widthMm;

    @Column(name = "height_mm", precision = 12, scale = 4)
    private BigDecimal heightMm;

    @Column(name = "color_code", length = 30)
    private String colorCode;

    @Column(name = "material_grade", length = 50)
    private String materialGrade;

    @Column(name = "tensile_strength_mpa", precision = 10, scale = 2)
    private BigDecimal tensileStrengthMpa;

    @Column(name = "thermal_rating_c", precision = 8, scale = 2)
    private BigDecimal thermalRatingC;

    @Column(name = "voltage_rating_v", precision = 10, scale = 2)
    private BigDecimal voltageRatingV;

    @Column(name = "current_rating_a", precision = 10, scale = 2)
    private BigDecimal currentRatingA;

    @Column(name = "ip_rating", length = 10)
    private String ipRating;

    @Column(name = "operating_temp_min_c", precision = 8, scale = 2)
    private BigDecimal operatingTempMinC;

    @Column(name = "operating_temp_max_c", precision = 8, scale = 2)
    private BigDecimal operatingTempMaxC;

    @Column(name = "shelf_life_days")
    private Integer shelfLifeDays;

    @Column(name = "storage_conditions", length = 200)
    private String storageConditions;

    @Column(name = "hazmat_class", length = 20)
    private String hazmatClass;

    @Column(name = "rohs_compliant")
    private Boolean rohsCompliant;

    @Column(name = "reach_compliant")
    private Boolean reachCompliant;

    @Column(name = "country_of_origin", length = 2)
    private String countryOfOrigin;

    @Column(name = "hs_tariff_code", length = 15)
    private String hsTariffCode;

    @Column(name = "drawing_number", length = 50)
    private String drawingNumber;

    @Column(name = "drawing_revision", length = 10)
    private String drawingRevision;

    @Column(name = "datasheet_url", length = 500)
    private String datasheetUrl;

    @Column(name = "manufacturer_part_no", length = 80)
    private String manufacturerPartNo;

    @Column(name = "manufacturer_name", length = 150)
    private String manufacturerName;

    @Enumerated(EnumType.STRING)
    @Column(name = "lifecycle_status", length = 15)
    private LifecycleStatus lifecycleStatus;

    @Enumerated(EnumType.STRING)
    @Column(name = "procurement_type", length = 15)
    private ProcurementType procurementType;

    @Column(name = "abc_classification", length = 1)
    private String abcClassification;

    @Column(name = "minimum_order_qty", precision = 12, scale = 4)
    private BigDecimal minimumOrderQty;

    @Column(name = "reorder_point", precision = 12, scale = 4)
    private BigDecimal reorderPoint;

    @Column(name = "safety_stock", precision = 12, scale = 4)
    private BigDecimal safetyStock;

    @Enumerated(EnumType.STRING)
    @Column(name = "inspection_level", length = 10)
    private InspectionLevel inspectionLevel;

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

    public enum LifecycleStatus { ACTIVE, OBSOLETE, NRND, NEW, PROTOTYPE }
    public enum ProcurementType { BUY, MAKE, CONSIGNED, PHANTOM }
    public enum InspectionLevel { NONE, INCOMING, FULL }
}

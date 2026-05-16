package com.bomiq.sdm.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

// ============================================================
// Product
// ============================================================
@Entity
@Table(name = "product")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "product_code", nullable = false, unique = true, length = 50)
    private String productCode;

    @Column(name = "product_name", nullable = false, length = 200)
    private String productName;

    @Column(name = "product_family", length = 100)
    private String productFamily;

    @Column(name = "product_line", length = 100)
    private String productLine;

    @Column(name = "model_number", length = 80)
    private String modelNumber;

    @Column(name = "platform_code", length = 30)
    private String platformCode;

    @Column(name = "target_market", length = 100)
    private String targetMarket;

    @Column(name = "product_category", length = 80)
    private String productCategory;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "regulatory_marks", length = 200)
    private String regulatoryMarks;

    @Column(name = "launch_date")
    private LocalDate launchDate;

    @Column(name = "end_of_life_date")
    private LocalDate endOfLifeDate;

    @Column(name = "product_manager", length = 100)
    private String productManager;

    @Column(name = "design_owner", length = 100)
    private String designOwner;

    @Enumerated(EnumType.STRING)
    @Column(name = "lifecycle_phase", length = 20)
    private LifecyclePhase lifecyclePhase;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public enum LifecyclePhase {
        CONCEPT, DESIGN, PILOT, PRODUCTION, PHASE_OUT, EOL
    }
}

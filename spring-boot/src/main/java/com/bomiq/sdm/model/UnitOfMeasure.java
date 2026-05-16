package com.bomiq.sdm.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "unit_of_measure")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class UnitOfMeasure {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(name="uom_code",          nullable=false, unique=true, length=20) private String uomCode;
    @Column(name="uom_name",          nullable=false, length=100)             private String uomName;
    @Column(name="uom_category",      length=50)                              private String uomCategory;
    @Column(name="base_unit",         length=20)                              private String baseUnit;
    @Column(name="conversion_factor", precision=18, scale=6)                  private BigDecimal conversionFactor;
    @Column(name="is_active")                                                 private Boolean isActive = true;
    @CreationTimestamp @Column(name="created_at", updatable=false)            private LocalDateTime createdAt;
    @UpdateTimestamp   @Column(name="updated_at")                             private LocalDateTime updatedAt;
}
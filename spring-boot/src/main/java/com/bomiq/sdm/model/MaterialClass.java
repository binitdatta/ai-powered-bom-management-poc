package com.bomiq.sdm.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.time.LocalDateTime;

@Entity
@Table(name = "material_class")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class MaterialClass {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(name="class_code",  nullable=false, unique=true, length=30) private String classCode;
    @Column(name="class_name",  nullable=false, length=100)             private String className;
    @ManyToOne(fetch=FetchType.LAZY)
    @JoinColumn(name="parent_class_id")                                 private MaterialClass parentClass;
    @Column(name="hazmat_flag")                                         private Boolean hazmatFlag = false;
    @Column(name="rohs_flag")                                           private Boolean rohsFlag = false;
    @Column(name="reach_flag")                                          private Boolean reachFlag = false;
    @Column(name="description", columnDefinition="TEXT")                private String description;
    @Column(name="is_active")                                           private Boolean isActive = true;
    @CreationTimestamp @Column(name="created_at", updatable=false)      private LocalDateTime createdAt;
}
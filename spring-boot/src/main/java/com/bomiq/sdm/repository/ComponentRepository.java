package com.bomiq.sdm.repository;

import com.bomiq.sdm.model.Component;
import com.bomiq.sdm.model.MaterialClass;
import com.bomiq.sdm.model.*;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ComponentRepository extends JpaRepository<Component, Long> {

    Optional<Component> findByPartNumberAndIsActive(String partNumber, Boolean isActive);

    @Query("""
        SELECT c FROM Component c
        LEFT JOIN FETCH c.preferredSupplier s
        LEFT JOIN FETCH c.materialClass mc
        WHERE c.isActive = true
        ORDER BY c.partNumber ASC
        """)
    List<Component> findAllActiveWithDetails();

    Page<Component> findByPartNameContainingIgnoreCaseAndIsActive(
            String keyword, Boolean isActive, Pageable pageable);

    @Query("""
        SELECT c FROM Component c
        LEFT JOIN FETCH c.preferredSupplier
        LEFT JOIN FETCH c.materialClass
        WHERE c.id = :id
        """)
    Optional<Component> findByIdWithDetails(@Param("id") Long id);

    List<Component> findByLifecycleStatusAndIsActive(Component.LifecycleStatus status, Boolean isActive);

    @Query("SELECT DISTINCT mc FROM Component c JOIN c.materialClass mc WHERE mc IS NOT NULL ORDER BY mc.className ASC")
    List<MaterialClass> findAllMaterialClasses();

    @Query("""
        SELECT c FROM Component c
        JOIN FETCH c.preferredSupplier s
        WHERE s.id = :supplierId
        AND c.isActive = true
        """)
    List<Component> findByPreferredSupplierId(@Param("supplierId") Long supplierId);
}
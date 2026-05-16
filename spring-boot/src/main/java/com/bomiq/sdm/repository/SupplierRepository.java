package com.bomiq.sdm.repository;

import com.bomiq.sdm.model.Supplier;
import com.bomiq.sdm.model.*;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.*;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SupplierRepository extends JpaRepository<Supplier, Long> {

    Optional<Supplier> findBySupplierCodeAndIsActive(String supplierCode, Boolean isActive);

    List<Supplier> findByIsApprovedAndIsActive(Boolean isApproved, Boolean isActive);

    Page<Supplier> findByLegalNameContainingIgnoreCaseAndIsActive(
        String keyword, Boolean isActive, Pageable pageable);

    List<Supplier> findBySupplierTierAndIsActive(Supplier.SupplierTier tier, Boolean isActive);

    List<Supplier> findByRiskRatingAndIsActive(Supplier.RiskRating riskRating, Boolean isActive);
}

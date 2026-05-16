package com.bomiq.sdm.repository;

import com.bomiq.sdm.model.BomHeader;
import com.bomiq.sdm.model.*;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BomHeaderRepository extends JpaRepository<BomHeader, Long> {

    @Query("""
        SELECT b FROM BomHeader b
        JOIN FETCH b.product p
        WHERE b.isActive = true
        ORDER BY b.levelInHierarchy ASC, b.bomNumber ASC
        """)
    List<BomHeader> findAllActiveWithProduct();

    @Query("""
        SELECT b FROM BomHeader b
        JOIN FETCH b.product p
        LEFT JOIN FETCH b.parentBom
        WHERE b.id = :id
        """)
    Optional<BomHeader> findByIdWithDetails(@Param("id") Long id);

    @Query("""
        SELECT b FROM BomHeader b
        JOIN FETCH b.product p
        WHERE b.parentBom.id = :parentId
        AND b.isActive = true
        ORDER BY b.levelInHierarchy ASC, b.bomNumber ASC
        """)
    List<BomHeader> findChildBoms(@Param("parentId") Long parentId);

    @Query("""
        SELECT b FROM BomHeader b
        JOIN FETCH b.product p
        WHERE b.parentBom IS NULL
        AND b.isActive = true
        ORDER BY b.bomNumber ASC
        """)
    List<BomHeader> findRootBoms();

    List<BomHeader> findByBomStatusAndIsActive(BomHeader.BomStatus status, Boolean isActive);

    Page<BomHeader> findByBomTitleContainingIgnoreCaseAndIsActive(
        String keyword, Boolean isActive, Pageable pageable);

    @Query("SELECT b FROM BomHeader b JOIN FETCH b.product WHERE b.product.id = :productId AND b.isActive = true")
    List<BomHeader> findByProductId(@Param("productId") Long productId);

    @Query("""
        SELECT b FROM BomHeader b
        JOIN FETCH b.product
        LEFT JOIN FETCH b.lineItems li
        LEFT JOIN FETCH li.component
        WHERE b.id = :id
        """)
    Optional<BomHeader> findByIdWithLineItems(@Param("id") Long id);
}

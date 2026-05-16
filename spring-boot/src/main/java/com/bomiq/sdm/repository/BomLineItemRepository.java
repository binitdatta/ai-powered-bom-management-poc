package com.bomiq.sdm.repository;

import com.bomiq.sdm.model.BomLineItem;
import com.bomiq.sdm.model.*;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BomLineItemRepository extends JpaRepository<BomLineItem, Long> {

    @Query("""
        SELECT li FROM BomLineItem li
        JOIN FETCH li.component c
        LEFT JOIN FETCH c.preferredSupplier
        LEFT JOIN FETCH li.uom
        WHERE li.bomHeader.id = :bomId
        AND li.isActive = true
        ORDER BY li.lineSequence ASC
        """)
    List<BomLineItem> findByBomHeaderIdWithDetails(@Param("bomId") Long bomId);

    List<BomLineItem> findByComponentIdAndIsActive(Long componentId, Boolean isActive);

    @Query("SELECT COUNT(li) FROM BomLineItem li WHERE li.bomHeader.id = :bomId AND li.isActive = true")
    long countByBomHeaderId(@Param("bomId") Long bomId);
}

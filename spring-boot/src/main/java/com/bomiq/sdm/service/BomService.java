package com.bomiq.sdm.service;

import com.bomiq.sdm.model.BomHeader;
import com.bomiq.sdm.model.BomLineItem;
import com.bomiq.sdm.repository.BomHeaderRepository;
import com.bomiq.sdm.repository.BomLineItemRepository;
import com.bomiq.sdm.repository.ComponentRepository;
import com.bomiq.sdm.repository.ProductRepository;
import com.bomiq.sdm.model.*;
import com.bomiq.sdm.repository.*;
import com.bomiq.sdm.dto.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.*;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class BomService {

    private final BomHeaderRepository bomHeaderRepository;
    private final BomLineItemRepository bomLineItemRepository;
    private final ComponentRepository componentRepository;
    private final ProductRepository productRepository;

    public List<BomHeader> findAllActive() {
        return bomHeaderRepository.findAllActiveWithProduct();
    }

    public List<BomHeader> findRootBoms() {
        return bomHeaderRepository.findRootBoms();
    }

    public Optional<BomHeader> findById(Long id) {
        return bomHeaderRepository.findByIdWithDetails(id);
    }

    public Optional<BomHeader> findByIdWithLineItems(Long id) {
        return bomHeaderRepository.findByIdWithLineItems(id);
    }

    public List<BomHeader> findChildBoms(Long parentId) {
        return bomHeaderRepository.findChildBoms(parentId);
    }

    public List<BomHeader> findByProductId(Long productId) {
        return bomHeaderRepository.findByProductId(productId);
    }

    public Page<BomHeader> search(String keyword, int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("bomNumber").ascending());
        return bomHeaderRepository.findByBomTitleContainingIgnoreCaseAndIsActive(keyword, true, pageable);
    }

    @Transactional
    public BomHeader save(BomHeader bom) {
        String user = currentUser();
        if (bom.getId() == null) {
            bom.setCreatedBy(user);
            bom.setIsActive(true);
        }
        bom.setUpdatedBy(user);
        return bomHeaderRepository.save(bom);
    }

    @Transactional
    public BomHeader updateStatus(Long id, BomHeader.BomStatus newStatus) {
        BomHeader bom = bomHeaderRepository.findByIdWithDetails(id)
                .orElseThrow(() -> new NoSuchElementException("BOM not found: " + id));
        bom.setBomStatus(newStatus);
        if (newStatus == BomHeader.BomStatus.APPROVED) {
            bom.setApprovedBy(currentUser());
            bom.setApprovedAt(LocalDateTime.now());
        } else if (newStatus == BomHeader.BomStatus.RELEASED) {
            bom.setReleasedBy(currentUser());
            bom.setReleasedAt(LocalDateTime.now());
        }
        bom.setUpdatedBy(currentUser());
        log.info("BOM {} status changed to {}", bom.getBomNumber(), newStatus);
        return bomHeaderRepository.save(bom);
    }

    @Transactional
    public BomLineItem saveLineItem(BomLineItem item) {
        item.setUpdatedBy(currentUser());
        if (item.getId() == null) {
            item.setCreatedBy(currentUser());
            item.setIsActive(true);
        }
        if (item.getUnitCost() != null && item.getQuantity() != null) {
            item.setExtendedCost(item.getUnitCost().multiply(item.getQuantity()));
        }
        return bomLineItemRepository.save(item);
    }

    public BomSummaryStats getBomStats() {
        List<BomHeader> all = findAllActive();
        long released = all.stream().filter(b -> b.getBomStatus() == BomHeader.BomStatus.RELEASED).count();
        long inReview = all.stream().filter(b -> b.getBomStatus() == BomHeader.BomStatus.IN_REVIEW).count();
        long draft    = all.stream().filter(b -> b.getBomStatus() == BomHeader.BomStatus.DRAFT).count();
        BigDecimal totalCost = all.stream()
                .filter(b -> b.getTotalMaterialCost() != null)
                .map(BomHeader::getTotalMaterialCost)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        return new BomSummaryStats(all.size(), released, inReview, draft, totalCost);
    }

    private String currentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return auth != null ? auth.getName() : "system";
    }

    public record BomSummaryStats(long total, long released, long inReview, long draft,
                                  BigDecimal totalMaterialCost) {}
}
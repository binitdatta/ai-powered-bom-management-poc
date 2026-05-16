package com.bomiq.sdm.service;

import com.bomiq.sdm.model.Supplier;
import com.bomiq.sdm.repository.SupplierRepository;
import com.bomiq.sdm.model.*;
import com.bomiq.sdm.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class SupplierService {

    private final SupplierRepository supplierRepository;

    public List<Supplier> findAllActive() {
        return supplierRepository.findByIsApprovedAndIsActive(null, true);
    }

    public List<Supplier> findApproved() {
        return supplierRepository.findByIsApprovedAndIsActive(true, true);
    }

    public Optional<Supplier> findById(Long id) {
        return supplierRepository.findById(id);
    }

    public Page<Supplier> search(String keyword, int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("legalName").ascending());
        return supplierRepository.findByLegalNameContainingIgnoreCaseAndIsActive(keyword, true, pageable);
    }

    @Transactional
    public Supplier save(Supplier supplier) {
        return supplierRepository.save(supplier);
    }
}
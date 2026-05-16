package com.bomiq.sdm.service;

import com.bomiq.sdm.model.Component;
import com.bomiq.sdm.repository.ComponentRepository;
import com.bomiq.sdm.model.*;
import com.bomiq.sdm.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.*;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class ComponentService {

    private final ComponentRepository componentRepository;

    public List<Component> findAllActive() {
        return componentRepository.findAllActiveWithDetails();
    }

    public Optional<Component> findById(Long id) {
        return componentRepository.findByIdWithDetails(id);
    }

    public Page<Component> search(String keyword, int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("partNumber").ascending());
        return componentRepository.findByPartNameContainingIgnoreCaseAndIsActive(keyword, true, pageable);
    }

    @Transactional
    public Component save(Component component) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String user = auth != null ? auth.getName() : "system";
        if (component.getId() == null) {
            component.setCreatedBy(user);
            component.setIsActive(true);
        }
        component.setUpdatedBy(user);
        return componentRepository.save(component);
    }

    public List<Component> findBySupplier(Long supplierId) {
        return componentRepository.findByPreferredSupplierId(supplierId);
    }
}
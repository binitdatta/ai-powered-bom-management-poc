package com.bomiq.sdm.repository;

import com.bomiq.sdm.model.Product;
import com.bomiq.sdm.model.*;
import org.springframework.data.jpa.repository.*;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    List<Product> findByIsActive(Boolean isActive);
    Optional<Product> findByProductCodeAndIsActive(String code, Boolean isActive);
}

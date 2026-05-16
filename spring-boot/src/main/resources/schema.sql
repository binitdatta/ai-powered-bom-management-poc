-- ============================================================
-- bomiq SDM — Schema DDL
-- MySQL 8.x | DBA-owned | No app-level DDL privileges
-- ============================================================

CREATE DATABASE IF NOT EXISTS bomiq_sdm CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bomiq_sdm;

-- ----------------------------------------------------------
-- 1. UNIT OF MEASURE
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS unit_of_measure (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    uom_code        VARCHAR(20)  NOT NULL UNIQUE,
    uom_name        VARCHAR(100) NOT NULL,
    uom_category    VARCHAR(50),
    base_unit       VARCHAR(20),
    conversion_factor DECIMAL(18,6),
    is_active       TINYINT(1)   NOT NULL DEFAULT 1,
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------
-- 2. SUPPLIER
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS supplier (
    id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    supplier_code       VARCHAR(30)  NOT NULL UNIQUE,
    legal_name          VARCHAR(200) NOT NULL,
    trade_name          VARCHAR(200),
    duns_number         VARCHAR(15)  UNIQUE,
    tax_id              VARCHAR(30),
    supplier_tier       ENUM('TIER1','TIER2','TIER3','SPOT') DEFAULT 'TIER2',
    risk_rating         ENUM('LOW','MEDIUM','HIGH','CRITICAL'),
    country_of_origin   CHAR(2),
    headquarters_city   VARCHAR(100),
    primary_contact     VARCHAR(150),
    contact_email       VARCHAR(200),
    contact_phone       VARCHAR(30),
    lead_time_days      SMALLINT UNSIGNED,
    payment_terms       VARCHAR(50),
    currency_code       CHAR(3)      DEFAULT 'USD',
    certifications      TEXT,
    notes               TEXT,
    is_approved         TINYINT(1)   DEFAULT 0,
    approved_by         VARCHAR(100),
    approved_at         DATETIME,
    is_active           TINYINT(1)   NOT NULL DEFAULT 1,
    created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------
-- 3. MATERIAL CLASS
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS material_class (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    class_code      VARCHAR(30)  NOT NULL UNIQUE,
    class_name      VARCHAR(100) NOT NULL,
    parent_class_id BIGINT UNSIGNED,
    hazmat_flag     TINYINT(1)   DEFAULT 0,
    rohs_flag       TINYINT(1)   DEFAULT 0,
    reach_flag      TINYINT(1)   DEFAULT 0,
    description     TEXT,
    is_active       TINYINT(1)   NOT NULL DEFAULT 1,
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_class_id) REFERENCES material_class(id)
);

-- ----------------------------------------------------------
-- 4. COMPONENT (Part Master)
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS component (
    id                      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    part_number             VARCHAR(50)  NOT NULL UNIQUE,
    part_revision           VARCHAR(10)  NOT NULL DEFAULT 'A',
    part_name               VARCHAR(200) NOT NULL,
    part_description        TEXT,
    material_class_id       BIGINT UNSIGNED,
    preferred_supplier_id   BIGINT UNSIGNED,
    alternate_supplier_id   BIGINT UNSIGNED,
    uom_id                  BIGINT UNSIGNED,
    unit_cost               DECIMAL(18,4),
    standard_cost           DECIMAL(18,4),
    currency_code           CHAR(3)      DEFAULT 'USD',
    weight_grams            DECIMAL(12,4),
    length_mm               DECIMAL(12,4),
    width_mm                DECIMAL(12,4),
    height_mm               DECIMAL(12,4),
    color_code              VARCHAR(30),
    material_grade          VARCHAR(50),
    tensile_strength_mpa    DECIMAL(10,2),
    thermal_rating_c        DECIMAL(8,2),
    voltage_rating_v        DECIMAL(10,2),
    current_rating_a        DECIMAL(10,2),
    ip_rating               VARCHAR(10),
    operating_temp_min_c    DECIMAL(8,2),
    operating_temp_max_c    DECIMAL(8,2),
    shelf_life_days         INT UNSIGNED,
    storage_conditions      VARCHAR(200),
    hazmat_class            VARCHAR(20),
    rohs_compliant          TINYINT(1)   DEFAULT NULL,
    reach_compliant         TINYINT(1)   DEFAULT NULL,
    country_of_origin       CHAR(2),
    hs_tariff_code          VARCHAR(15),
    drawing_number          VARCHAR(50),
    drawing_revision        VARCHAR(10),
    datasheet_url           VARCHAR(500),
    manufacturer_part_no    VARCHAR(80),
    manufacturer_name       VARCHAR(150),
    lifecycle_status        ENUM('ACTIVE','OBSOLETE','NRND','NEW','PROTOTYPE') DEFAULT 'ACTIVE',
    procurement_type        ENUM('BUY','MAKE','CONSIGNED','PHANTOM') DEFAULT 'BUY',
    abc_classification      CHAR(1),
    minimum_order_qty       DECIMAL(12,4),
    reorder_point           DECIMAL(12,4),
    safety_stock            DECIMAL(12,4),
    inspection_level        ENUM('NONE','INCOMING','FULL'),
    created_by              VARCHAR(100),
    updated_by              VARCHAR(100),
    is_active               TINYINT(1)   NOT NULL DEFAULT 1,
    created_at              DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (material_class_id)     REFERENCES material_class(id),
    FOREIGN KEY (preferred_supplier_id) REFERENCES supplier(id),
    FOREIGN KEY (alternate_supplier_id) REFERENCES supplier(id),
    FOREIGN KEY (uom_id)                REFERENCES unit_of_measure(id)
);

-- ----------------------------------------------------------
-- 5. PRODUCT (Top-Level BOM parent)
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS product (
    id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_code        VARCHAR(50)  NOT NULL UNIQUE,
    product_name        VARCHAR(200) NOT NULL,
    product_family      VARCHAR(100),
    product_line        VARCHAR(100),
    model_number        VARCHAR(80),
    platform_code       VARCHAR(30),
    target_market       VARCHAR(100),
    product_category    VARCHAR(80),
    description         TEXT,
    regulatory_marks    VARCHAR(200),
    launch_date         DATE,
    end_of_life_date    DATE,
    product_manager     VARCHAR(100),
    design_owner        VARCHAR(100),
    lifecycle_phase     ENUM('CONCEPT','DESIGN','PILOT','PRODUCTION','PHASE_OUT','EOL') DEFAULT 'PRODUCTION',
    is_active           TINYINT(1)   NOT NULL DEFAULT 1,
    created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------
-- 6. BOM HEADER (One per product/revision)
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS bom_header (
    id                      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    bom_number              VARCHAR(50)  NOT NULL UNIQUE,
    bom_revision            VARCHAR(10)  NOT NULL DEFAULT 'A',
    bom_title               VARCHAR(300) NOT NULL,
    product_id              BIGINT UNSIGNED NOT NULL,
    bom_type                ENUM('ENGINEERING','MANUFACTURING','SERVICE','SALES','PLANNING') DEFAULT 'ENGINEERING',
    bom_status              ENUM('DRAFT','IN_REVIEW','APPROVED','RELEASED','OBSOLETE','SUPERSEDED') DEFAULT 'DRAFT',
    effective_date          DATE,
    expiry_date             DATE,
    engineering_change_no   VARCHAR(50),
    change_description      TEXT,
    total_material_cost     DECIMAL(18,4),
    total_labor_cost        DECIMAL(18,4),
    total_overhead_cost     DECIMAL(18,4),
    total_bom_cost          DECIMAL(18,4),
    currency_code           CHAR(3)      DEFAULT 'USD',
    costing_date            DATE,
    weight_kg               DECIMAL(12,4),
    volume_cm3              DECIMAL(14,4),
    target_assembly_time_min SMALLINT UNSIGNED,
    assembly_location       VARCHAR(100),
    quality_plan_ref        VARCHAR(50),
    risk_level              ENUM('LOW','MEDIUM','HIGH','CRITICAL'),
    approval_required_by    VARCHAR(100),
    approved_by             VARCHAR(100),
    approved_at             DATETIME,
    released_by             VARCHAR(100),
    released_at             DATETIME,
    notes                   TEXT,
    parent_bom_id           BIGINT UNSIGNED,
    level_in_hierarchy      TINYINT UNSIGNED DEFAULT 1,
    created_by              VARCHAR(100),
    updated_by              VARCHAR(100),
    is_active               TINYINT(1)  NOT NULL DEFAULT 1,
    created_at              DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id)    REFERENCES product(id),
    FOREIGN KEY (parent_bom_id) REFERENCES bom_header(id)
);

-- ----------------------------------------------------------
-- 7. BOM LINE ITEM
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS bom_line_item (
    id                      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    bom_header_id           BIGINT UNSIGNED NOT NULL,
    line_sequence           SMALLINT UNSIGNED NOT NULL,
    component_id            BIGINT UNSIGNED NOT NULL,
    quantity                DECIMAL(14,6) NOT NULL DEFAULT 1.000000,
    uom_id                  BIGINT UNSIGNED,
    reference_designator    VARCHAR(200),
    find_number             SMALLINT UNSIGNED,
    sub_bom_id              BIGINT UNSIGNED,
    item_type               ENUM('STANDARD','PHANTOM','REFERENCE','SELECT','VARIANT') DEFAULT 'STANDARD',
    procurement_type        ENUM('BUY','MAKE','CONSIGNED','PHANTOM'),
    unit_cost               DECIMAL(18,4),
    extended_cost           DECIMAL(18,4),
    lead_time_days          SMALLINT UNSIGNED,
    scrap_factor_pct        DECIMAL(6,2),
    yield_factor_pct        DECIMAL(6,2) DEFAULT 100.00,
    effective_date          DATE,
    expiry_date             DATE,
    engineering_change_no   VARCHAR(50),
    position_description    VARCHAR(200),
    assembly_instruction    TEXT,
    inspection_note         TEXT,
    substitution_allowed    TINYINT(1)  DEFAULT 0,
    substitute_component_id BIGINT UNSIGNED,
    critical_component      TINYINT(1)  DEFAULT 0,
    preferred_supplier_id   BIGINT UNSIGNED,
    supplier_part_no        VARCHAR(80),
    notes                   TEXT,
    created_by              VARCHAR(100),
    updated_by              VARCHAR(100),
    is_active               TINYINT(1)  NOT NULL DEFAULT 1,
    created_at              DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (bom_header_id)          REFERENCES bom_header(id),
    FOREIGN KEY (component_id)           REFERENCES component(id),
    FOREIGN KEY (uom_id)                 REFERENCES unit_of_measure(id),
    FOREIGN KEY (sub_bom_id)             REFERENCES bom_header(id),
    FOREIGN KEY (substitute_component_id) REFERENCES component(id),
    FOREIGN KEY (preferred_supplier_id)  REFERENCES supplier(id),
    UNIQUE KEY uq_bom_seq (bom_header_id, line_sequence)
);

-- ----------------------------------------------------------
-- 8. BOM CHANGE LOG (audit trail)
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS bom_change_log (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    bom_header_id   BIGINT UNSIGNED NOT NULL,
    change_type     ENUM('CREATE','UPDATE','STATUS_CHANGE','APPROVE','RELEASE','OBSOLETE'),
    field_changed   VARCHAR(100),
    old_value       TEXT,
    new_value       TEXT,
    changed_by      VARCHAR(100),
    change_reason   TEXT,
    ecn_number      VARCHAR(50),
    changed_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bom_header_id) REFERENCES bom_header(id)
);

-- ----------------------------------------------------------
-- 9. BOM ATTACHMENT
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS bom_attachment (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    bom_header_id   BIGINT UNSIGNED NOT NULL,
    attachment_type ENUM('DRAWING','DATASHEET','TEST_REPORT','PHOTO','CAD','OTHER'),
    file_name       VARCHAR(255),
    file_path       VARCHAR(500),
    file_size_bytes BIGINT UNSIGNED,
    mime_type       VARCHAR(100),
    description     TEXT,
    uploaded_by     VARCHAR(100),
    uploaded_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bom_header_id) REFERENCES bom_header(id)
);

-- ----------------------------------------------------------
-- INDEXES for performance
-- ----------------------------------------------------------
CREATE INDEX idx_bom_header_product   ON bom_header(product_id);
CREATE INDEX idx_bom_header_status    ON bom_header(bom_status);
CREATE INDEX idx_bom_header_parent    ON bom_header(parent_bom_id);
CREATE INDEX idx_bom_line_bom         ON bom_line_item(bom_header_id);
CREATE INDEX idx_bom_line_component   ON bom_line_item(component_id);
CREATE INDEX idx_component_pn         ON component(part_number);
CREATE INDEX idx_component_supplier   ON component(preferred_supplier_id);
CREATE INDEX idx_supplier_code        ON supplier(supplier_code);

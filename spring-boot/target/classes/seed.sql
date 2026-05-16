-- ============================================================
-- bomiq SDM — Seed Data
-- 20 Hierarchical BOMs: Industrial IoT Gateway Product Family
-- ============================================================
USE bomiq_sdm;

-- ----------------------------------------------------------
-- UOM
-- ----------------------------------------------------------
INSERT INTO unit_of_measure (uom_code, uom_name, uom_category, base_unit, conversion_factor) VALUES
('EA',   'Each',          'Discrete',    'EA',   1.000000),
('KG',   'Kilogram',      'Mass',        'KG',   1.000000),
('GR',   'Gram',          'Mass',        'KG',   0.001000),
('MM',   'Millimeter',    'Length',      'M',    0.001000),
('M',    'Meter',         'Length',      'M',    1.000000),
('LTR',  'Liter',         'Volume',      'LTR',  1.000000),
('ML',   'Milliliter',    'Volume',      'LTR',  0.001000),
('MTR',  'Meter (wire)',  'Length',      'M',    1.000000),
('PKT',  'Packet',        'Discrete',    'EA',   1.000000),
('SET',  'Set',           'Discrete',    'EA',   1.000000);

-- ----------------------------------------------------------
-- SUPPLIERS
-- ----------------------------------------------------------
INSERT INTO supplier (supplier_code, legal_name, trade_name, duns_number, supplier_tier, risk_rating,
    country_of_origin, headquarters_city, primary_contact, contact_email, lead_time_days,
    payment_terms, currency_code, certifications, is_approved, approved_by) VALUES
('SUP-001','Texas Instruments Inc.',     'TI',         '006932717', 'TIER1','LOW',     'US','Dallas TX',      'John Liu',     'jliu@ti.example.com',       21, 'Net30', 'USD', 'ISO9001,IATF16949,AEC-Q100', 1, 'procurement@bomiq.com'),
('SUP-002','STMicroelectronics N.V.',    'ST',         '271837154', 'TIER1','LOW',     'NL','Geneva',         'Marie Dupont', 'mdupont@st.example.com',    28, 'Net45', 'USD', 'ISO9001,ISO14001,AEC-Q100',  1, 'procurement@bomiq.com'),
('SUP-003','Molex LLC',                 'Molex',      '042569791', 'TIER1','LOW',     'US','Lisle IL',        'Sam Park',     'spark@molex.example.com',   14, 'Net30', 'USD', 'ISO9001,IATF16949',          1, 'procurement@bomiq.com'),
('SUP-004','Würth Elektronik GmbH',     'Würth',      '315629841', 'TIER2','LOW',     'DE','Waldenburg',      'Hans Braun',   'hbraun@we.example.com',     21, 'Net30', 'EUR', 'ISO9001,ISO14001',           1, 'procurement@bomiq.com'),
('SUP-005','Murata Manufacturing Co.',  'Murata',     '692154870', 'TIER1','LOW',     'JP','Kyoto',          'Kenji Sato',   'ksato@murata.example.com',  35, 'Net45', 'USD', 'ISO9001,AEC-Q200',           1, 'procurement@bomiq.com'),
('SUP-006','Amphenol Corp.',            'Amphenol',   '056984013', 'TIER1','LOW',     'US','Wallingford CT',  'Lisa Chen',    'lchen@amphenol.example.com',28, 'Net30', 'USD', 'ISO9001,IATF16949',          1, 'procurement@bomiq.com'),
('SUP-007','Marvell Technology Inc.',   'Marvell',    '110493821', 'TIER1','MEDIUM',  'US','Santa Clara CA',  'Dave Wang',    'dwang@marvell.example.com', 42, 'Net60', 'USD', 'ISO9001',                    1, 'procurement@bomiq.com'),
('SUP-008','Laird Connectivity',        'Laird',      '204871539', 'TIER2','LOW',     'GB','London',          'Tom Hawkins',  'thawkins@laird.example.com',21, 'Net30', 'USD', 'ISO9001,FCC,CE',             1, 'procurement@bomiq.com'),
('SUP-009','Belden Inc.',               'Belden',     '008127634', 'TIER2','LOW',     'US','Chicago IL',      'Amy Ross',     'aross@belden.example.com',  14, 'Net30', 'USD', 'ISO9001,UL',                 1, 'procurement@bomiq.com'),
('SUP-010','Phoenix Contact GmbH',      'Phoenix',    '317284910', 'TIER2','LOW',     'DE','Blomberg',        'Klaus Richter','krichter@phoenixc.example.com',21,'Net30','EUR','ISO9001,UL,CE',             1, 'procurement@bomiq.com');

-- ----------------------------------------------------------
-- MATERIAL CLASS (hierarchical)
-- ----------------------------------------------------------
INSERT INTO material_class (id, class_code, class_name, parent_class_id, hazmat_flag, rohs_flag) VALUES
(1,  'ELEC',    'Electronics',         NULL, 0, 1),
(2,  'IC',      'Integrated Circuits',    1, 0, 1),
(3,  'MCU',     'Microcontrollers',       2, 0, 1),
(4,  'COMM-IC', 'Communications ICs',     2, 0, 1),
(5,  'PWR-IC',  'Power Management ICs',   2, 0, 1),
(6,  'PASSIVE', 'Passives',               1, 0, 1),
(7,  'RESIST',  'Resistors',              6, 0, 1),
(8,  'CAP',     'Capacitors',             6, 0, 1),
(9,  'INDUCT',  'Inductors',              6, 0, 1),
(10, 'CONN',    'Connectors',             1, 0, 1),
(11, 'MODULE',  'RF & Wireless Modules',  1, 0, 1),
(12, 'MECH',    'Mechanical',          NULL, 0, 0),
(13, 'PCB',     'Printed Circuit Board', 12, 0, 1),
(14, 'ENCL',    'Enclosures',            12, 0, 0),
(15, 'CABLE',   'Cables & Harnesses',  NULL, 0, 1),
(16, 'LABEL',   'Labels & Markings',   NULL, 0, 0),
(17, 'PACKING', 'Packaging',           NULL, 0, 0),
(18, 'FIRMWARE','Firmware & Software', NULL, 0, 0);

-- ----------------------------------------------------------
-- PRODUCTS
-- ----------------------------------------------------------
INSERT INTO product (product_code, product_name, product_family, product_line, model_number,
    platform_code, target_market, product_category, regulatory_marks, lifecycle_phase) VALUES
('EDGE-GW-5000',  'EdgeConnect 5000 Industrial IoT Gateway',  'EdgeConnect', 'Industrial IoT', 'EC-5000', 'EDGE-V5', 'Industrial Automation', 'IoT Gateway',    'CE,FCC,UL,IP67', 'PRODUCTION'),
('EDGE-GW-5100',  'EdgeConnect 5100 Heavy-Duty IoT Gateway',  'EdgeConnect', 'Industrial IoT', 'EC-5100', 'EDGE-V5', 'Oil & Gas',             'IoT Gateway',    'CE,FCC,ATEX,IP68','PILOT'),
('EDGE-GW-5200',  'EdgeConnect 5200 Rail-Grade Gateway',      'EdgeConnect', 'Industrial IoT', 'EC-5200', 'EDGE-V5', 'Rail & Transit',        'IoT Gateway',    'CE,EN50155,IP65', 'DESIGN'),
('EDGE-PSU-100W', 'EdgePower 100W DIN-Rail PSU',              'EdgePower',   'Power Systems',  'EP-100W', 'PWRV2',   'Industrial',            'Power Supply',   'CE,UL,TUV',       'PRODUCTION'),
('EDGE-ANT-4G',   'EdgeAntenna 4G/LTE External Antenna',      'EdgeAntenna', 'Wireless',       'EA-4G',   'ANTV1',   'Industrial IoT',        'Antenna',        'CE,FCC',          'PRODUCTION');

-- ----------------------------------------------------------
-- BOM HEADERS — 20 hierarchical BOMs
-- BOM 1 = top-level EC-5000; BOMs 2-8 = subassemblies; etc.
-- ----------------------------------------------------------
INSERT INTO bom_header (id, bom_number, bom_revision, bom_title, product_id, bom_type, bom_status,
    effective_date, total_material_cost, currency_code, weight_kg, target_assembly_time_min,
    assembly_location, risk_level, level_in_hierarchy, parent_bom_id, created_by, notes) VALUES

-- LEVEL 1 — Top-level finished goods
(1, 'BOM-EC5000-001', 'C', 'EdgeConnect 5000 — Top-Level Manufacturing BOM', 1, 'MANUFACTURING','RELEASED',
    '2024-01-15', 487.25, 'USD', 1.420, 45, 'Assembly Line A', 'MEDIUM', 1, NULL, 'eng.team@bomiq.com',
    'Full build including all subassemblies. Requires ESD-safe workstation.'),

(2, 'BOM-EC5100-001', 'A', 'EdgeConnect 5100 Heavy-Duty — Top-Level BOM',   2, 'ENGINEERING',  'IN_REVIEW',
    '2024-06-01', 612.80, 'USD', 1.890, 60, 'Assembly Line B', 'HIGH',   1, NULL, 'eng.team@bomiq.com',
    'ATEX Zone 2 rated variant. Pending regulatory sign-off.'),

(3, 'BOM-EC5200-001', 'A', 'EdgeConnect 5200 Rail — Top-Level BOM',         3, 'ENGINEERING',  'DRAFT',
    NULL,          NULL,   'USD', NULL,  NULL, NULL,              'HIGH',   1, NULL, 'eng.team@bomiq.com',
    'EN50155 rail variant. Design phase.'),

-- LEVEL 2 — Major subassemblies of EC-5000
(4, 'BOM-EC5000-MB', 'B', 'EC-5000 Main Processing Board Subassembly',      1, 'MANUFACTURING','RELEASED',
    '2024-01-15', 198.40, 'USD', 0.380, 20, 'SMT Line 1',     'MEDIUM', 2, 1,  'smt.eng@bomiq.com',
    'ARM Cortex-A55 SoC based main board. 4-layer PCB.'),

(5, 'BOM-EC5000-CM', 'B', 'EC-5000 Cellular Modem Subassembly',             1, 'MANUFACTURING','RELEASED',
    '2024-01-15',  89.75, 'USD', 0.095, 10, 'SMT Line 2',     'MEDIUM', 2, 1,  'smt.eng@bomiq.com',
    'Cat-M1/NB-IoT/4G-LTE module with SIM management.'),

(6, 'BOM-EC5000-WL', 'A', 'EC-5000 Wi-Fi & BLE Wireless Subassembly',       1, 'MANUFACTURING','RELEASED',
    '2024-01-15',  42.60, 'USD', 0.055, 8,  'SMT Line 2',     'LOW',    2, 1,  'smt.eng@bomiq.com',
    'Wi-Fi 6 (802.11ax) + BLE 5.3 combo module assembly.'),

(7, 'BOM-EC5000-IO', 'C', 'EC-5000 I/O Expansion Board Subassembly',        1, 'MANUFACTURING','RELEASED',
    '2024-01-15',  67.30, 'USD', 0.120, 12, 'SMT Line 1',     'LOW',    2, 1,  'smt.eng@bomiq.com',
    'RS-485/RS-232, DI/DO, 4-20mA analog I/O expansion board.'),

(8, 'BOM-EC5000-PSU','B', 'EC-5000 Internal Power Supply Subassembly',       1, 'MANUFACTURING','RELEASED',
    '2024-01-15',  55.20, 'USD', 0.180, 10, 'SMT Line 3',     'MEDIUM', 2, 1,  'pwr.eng@bomiq.com',
    'Wide input 9-36VDC switching regulator with protection circuits.'),

(9, 'BOM-EC5000-ENC','A', 'EC-5000 Enclosure & Mechanical Subassembly',     1, 'MANUFACTURING','RELEASED',
    '2024-01-15',  34.00, 'USD', 0.590, 15, 'Mech Assembly',  'LOW',    2, 1,  'mech.eng@bomiq.com',
    'IP67 die-cast aluminum enclosure with DIN-rail mount.'),

-- LEVEL 3 — Sub-subassemblies
(10, 'BOM-EC5000-MB-CPU','B','EC-5000 Main Board CPU Section',               1, 'MANUFACTURING','RELEASED',
    '2024-01-15', 112.00, 'USD', 0.080, 8,  'SMT Line 1',     'HIGH',   3, 4,  'smt.eng@bomiq.com',
    'SoC, LPDDR4 RAM, eMMC flash, crystal oscillator section.'),

(11, 'BOM-EC5000-MB-PWR','A','EC-5000 Main Board Power Rail Section',        1, 'MANUFACTURING','RELEASED',
    '2024-01-15',  38.50, 'USD', 0.040, 5,  'SMT Line 1',     'MEDIUM', 3, 4,  'pwr.eng@bomiq.com',
    'DC-DC buck/boost converters, LDOs, bulk decoupling.'),

(12, 'BOM-EC5000-MB-ETH','A','EC-5000 Main Board Ethernet Section',          1, 'MANUFACTURING','RELEASED',
    '2024-01-15',  28.90, 'USD', 0.025, 4,  'SMT Line 1',     'MEDIUM', 3, 4,  'smt.eng@bomiq.com',
    'Gigabit Ethernet PHY, magnetics, RJ45 connector.'),

(13, 'BOM-EC5000-IO-DIO','A','EC-5000 I/O Board Digital I/O Section',        1, 'MANUFACTURING','RELEASED',
    '2024-01-15',  22.40, 'USD', 0.035, 5,  'SMT Line 1',     'LOW',    3, 7,  'smt.eng@bomiq.com',
    'Optocoupler-isolated 8x DI + 4x DO with surge protection.'),

(14, 'BOM-EC5000-IO-AIO','A','EC-5000 I/O Board Analog I/O Section',         1, 'MANUFACTURING','RELEASED',
    '2024-01-15',  19.60, 'USD', 0.020, 4,  'SMT Line 1',     'LOW',    3, 7,  'smt.eng@bomiq.com',
    '4-channel 4-20mA input, 2-channel 0-10V output.'),

(15, 'BOM-EC5000-IO-SER','A','EC-5000 I/O Board Serial Comm Section',        1, 'MANUFACTURING','RELEASED',
    '2024-01-15',  18.70, 'USD', 0.020, 4,  'SMT Line 1',     'LOW',    3, 7,  'smt.eng@bomiq.com',
    'RS-485 (x2) and RS-232 (x1) half/full-duplex transceivers.'),

-- LEVEL 2 — Cables, labels, packaging for EC-5000
(16, 'BOM-EC5000-CBL','A', 'EC-5000 Cable & Harness Kit',                    1, 'MANUFACTURING','RELEASED',
    '2024-01-15',  12.80, 'USD', 0.085, 8,  'Mech Assembly',  'LOW',    2, 1,  'mech.eng@bomiq.com',
    'Internal cable harnesses: USB, power, I/O board interconnect.'),

(17, 'BOM-EC5000-FW', 'C', 'EC-5000 Firmware & Software Load BOM',          1, 'MANUFACTURING','RELEASED',
    '2024-01-15',   0.00, 'USD', 0.000, 5,  'Flash Station',  'LOW',    2, 1,  'fw.eng@bomiq.com',
    'Factory firmware load: bootloader v2.1, OS v5.4, app v3.2.1.'),

(18, 'BOM-EC5000-LBL','A', 'EC-5000 Labeling & Documentation Kit',          1, 'MANUFACTURING','RELEASED',
    '2024-01-15',   3.20, 'USD', 0.015, 3,  'Pack Station',   'LOW',    2, 1,  'mfg.eng@bomiq.com',
    'Regulatory labels, CE mark, serial number, QR code, calibration cert.'),

(19, 'BOM-EC5000-PKG','B', 'EC-5000 Retail & Shipping Packaging BOM',       1, 'MANUFACTURING','RELEASED',
    '2024-01-15',   8.50, 'USD', 0.320, 5,  'Pack Station',   'LOW',    2, 1,  'mfg.eng@bomiq.com',
    'Custom foam insert, recycled cardboard outer, quick-start guide.'),

-- LEVEL 1 — Standalone PSU product
(20, 'BOM-EP100W-001','B','EdgePower 100W DIN-Rail PSU — Manufacturing BOM', 4, 'MANUFACTURING','RELEASED',
    '2024-03-01', 124.60, 'USD', 0.880, 30, 'SMT Line 3',     'MEDIUM', 1, NULL,'pwr.eng@bomiq.com',
    'Wide-input 85-264VAC, 24VDC/4.2A output PSU.');

-- ----------------------------------------------------------
-- COMPONENTS (Part Master — representative set)
-- ----------------------------------------------------------
INSERT INTO component (part_number, part_revision, part_name, part_description,
    material_class_id, preferred_supplier_id, uom_id,
    unit_cost, weight_grams, length_mm, width_mm, height_mm,
    operating_temp_min_c, operating_temp_max_c,
    rohs_compliant, lifecycle_status, procurement_type,
    manufacturer_part_no, manufacturer_name, created_by) VALUES

-- SoC / CPU
('PN-SOC-001','A','ARM Cortex-A55 SoC 1.8GHz Quad-Core',
 'Industrial-grade SoC with integrated Gigabit Ethernet MAC, USB 3.0, PCIe 2.0, CAN 2.0',
 3,1,1, 48.50, 14.0, 14.0, 14.0, 1.6, -40, 85, 1,'ACTIVE','BUY','AM6442BZCEAAP1','Texas Instruments','smt.eng@bomiq.com'),

-- LPDDR4 RAM
('PN-MEM-001','A','LPDDR4 4GB RAM Module',
 '4GB x32 LPDDR4 SDRAM, 3200Mbps, 96-ball BGA',
 2,2,1, 18.20, 0.8, 9.0, 9.0, 1.0, -40, 85, 1,'ACTIVE','BUY','MT53E512M32D2NP-046','Micron','smt.eng@bomiq.com'),

-- eMMC Flash
('PN-FLS-001','A','32GB eMMC 5.1 Industrial Flash',
 '32GB eMMC 5.1 HS400, industrial grade, -40°C to 85°C',
 2,2,1, 12.75, 0.6, 11.5, 13.0, 1.0, -40, 85, 1,'ACTIVE','BUY','FEMDNN032G-88A19','Samsung','smt.eng@bomiq.com'),

-- Cellular modem module
('PN-MOD-4G','A','Cat-M1/NB-IoT/LTE-M Cellular Module',
 'Multi-band LTE module, USB 2.0 + UART host interface, embedded SIM ready, FCC/CE certified',
 11,8,1, 28.40, 6.5, 30.0, 24.0, 3.0, -40, 85, 1,'ACTIVE','BUY','EG21-G-MINIPCIE','Quectel','smt.eng@bomiq.com'),

-- Wi-Fi+BLE combo module
('PN-MOD-WB','A','Wi-Fi 6 + BLE 5.3 Combo Module',
 '802.11ax 2.4/5GHz + BLE 5.3, PCIe/SDIO/UART interface, FCC/CE/IC certified',
 11,8,1, 14.80, 3.2, 18.0, 14.0, 2.4, -40, 85, 1,'ACTIVE','BUY','WB5X-SDIO','Laird Connectivity','smt.eng@bomiq.com'),

-- Ethernet PHY
('PN-PHY-001','A','Gigabit Ethernet PHY Transceiver',
 'IEEE 802.3 1000BASE-T/100BASE-TX, RGMII interface, EEE compliant, industrial temp',
 4,1,1, 4.20, 0.5, 7.0, 7.0, 0.9, -40, 85, 1,'ACTIVE','BUY','DP83867ISRGZ','Texas Instruments','smt.eng@bomiq.com'),

-- RS-485 Transceiver
('PN-TR-485','A','RS-485/422 Half/Full Duplex Transceiver',
 '±15kV ESD, 50Mbps, 1/8-unit-load, industrial -40 to 125°C',
 4,1,1, 1.85, 0.1, 5.0, 4.0, 0.9, -40, 125, 1,'ACTIVE','BUY','THVD1450DSGR','Texas Instruments','smt.eng@bomiq.com'),

-- Optocoupler
('PN-OPT-001','A','High-Speed Digital Optocoupler 10Mbps',
 '10Mbps CMOS output, 2500Vrms isolation, 8-SOIC, wide temp',
 2,2,1, 0.95, 0.1, 5.0, 4.0, 1.5, -40, 85, 1,'ACTIVE','BUY','TLP2362(TP,E)','Toshiba','smt.eng@bomiq.com'),

-- Buck converter
('PN-BUCK-001','A','Synchronous Step-Down DC-DC Controller 4A',
 '4A, 4.5-60V input, adjustable output, 95% efficiency, EN/AECQ100',
 5,1,1, 3.40, 0.1, 3.0, 3.0, 0.9, -40, 125, 1,'ACTIVE','BUY','TPS54360BDDAR','Texas Instruments','smt.eng@bomiq.com'),

-- LDO
('PN-LDO-001','A','300mA Ultra-Low Noise LDO Regulator',
 '300mA, 1.5-5.5V input, adjustable, 6μVrms noise, 5-SOT23',
 5,2,1, 0.65, 0.02, 1.6, 1.6, 0.6, -40, 125, 1,'ACTIVE','BUY','LD39020PU33R','STMicroelectronics','smt.eng@bomiq.com'),

-- MLCCs bulk
('PN-CAP-100N','A','100nF 50V X7R MLCC 0402',
 '100nF ±10% 50V X7R ceramic capacitor 0402 (1005 metric)',
 8,5,1, 0.008, 0.001, 1.0, 0.5, 0.5, -55, 125, 1,'ACTIVE','BUY','GRM155R71H104KE14D','Murata','smt.eng@bomiq.com'),

('PN-CAP-10U','A','10µF 25V X5R MLCC 0805',
 '10µF ±20% 25V X5R ceramic capacitor 0805 (2012 metric)',
 8,5,1, 0.042, 0.004, 2.0, 1.25, 0.95, -55, 85, 1,'ACTIVE','BUY','GRM21BR61E106KA73L','Murata','smt.eng@bomiq.com'),

-- Resistors
('PN-RES-10K','A','10KΩ ±1% 0.1W Thick Film Resistor 0402',
 '10kΩ ±1% 100mW AEC-Q200 0402 thick film',
 7,4,1, 0.003, 0.001, 1.0, 0.5, 0.35, -55, 155, 1,'ACTIVE','BUY','RC0402FR-0710KL','Yageo','smt.eng@bomiq.com'),

-- Connector - industrial
('PN-CONN-RJ45','A','Industrial RJ45 Jack with Magnetics',
 'Shielded RJ45 integrated 10/100/1000 magnetics, IP20, right-angle THT',
 10,3,1, 2.80, 5.0, 16.0, 14.0, 13.5, -40, 85, 1,'ACTIVE','BUY','74990111121','Würth Elektronik','smt.eng@bomiq.com'),

('PN-CONN-M12','A','M12 A-Code 8-Pin Industrial Connector Panel Mount',
 'IP67 M12 8-pin A-code panel mount socket, stainless steel, screw terminal',
 10,6,1, 8.50, 32.0, NULL, NULL, NULL, -40, 85, 1,'ACTIVE','BUY','T4110512041-000','Phoenix Contact','smt.eng@bomiq.com'),

-- PCB
('PN-PCB-MB','A','EC-5000 Main Processing Board Bare PCB',
 '4-layer 155x100mm FR4 PCB, 1oz copper, ENIG finish, impedance controlled',
 13,NULL,1, 22.00, 48.0, 155.0, 100.0, 1.6, NULL, NULL, 1,'ACTIVE','BUY','PCB-EC5000-MB-R2','Spectrum PCB','smt.eng@bomiq.com'),

('PN-PCB-IO','A','EC-5000 I/O Expansion Board Bare PCB',
 '2-layer 80x60mm FR4 PCB, 1oz copper, HASL finish',
 13,NULL,1, 8.50, 18.0, 80.0, 60.0, 1.6, NULL, NULL, 1,'ACTIVE','BUY','PCB-EC5000-IO-R1','Spectrum PCB','smt.eng@bomiq.com'),

-- Enclosure
('PN-ENC-001','A','IP67 Die-Cast Aluminum Enclosure 175x125x60mm',
 'IP67 die-cast aluminum, DIN-rail mounting integrated, M3 stainless inserts, powder coated gray RAL7035',
 14,NULL,1, 28.00, 520.0, 175.0, 125.0, 60.0, -40, 85, NULL,'ACTIVE','BUY','EC-DC-175-125-60-AL','Bopla','mech.eng@bomiq.com'),

-- Power components
('PN-XFMR-001','A','100W Power Transformer 85-264VAC:24VDC',
 'Universal input switching transformer, 100W, potted, UL/CE approved',
 5,NULL,1, 14.20, 185.0, NULL, NULL, NULL, -20, 70, NULL,'ACTIVE','BUY','TX-100W-24V','Talema','pwr.eng@bomiq.com'),

-- Cable
('PN-CBL-FLAT','A','200mm 10-way IDC Flat Cable Assembly',
 '200mm 10-way 1.27mm pitch IDC flat cable, UL2651 28AWG gray',
 15,9,1, 1.20, 4.0, 200.0, 13.0, 3.0, -40, 85, 1,'ACTIVE','BUY','FC10-200MM-GRY','Belden','mech.eng@bomiq.com');

-- ----------------------------------------------------------
-- BOM LINE ITEMS — sample lines for key BOMs
-- ----------------------------------------------------------

-- BOM 4: Main Processing Board
INSERT INTO bom_line_item (bom_header_id, line_sequence, component_id, quantity, uom_id,
    reference_designator, find_number, unit_cost, extended_cost, scrap_factor_pct, critical_component,
    assembly_instruction, created_by) VALUES
(4,  10, (SELECT id FROM component WHERE part_number='PN-SOC-001'),   1, 1, 'U1',   10, 48.50,  48.50, 0.50, 1, 'Apply thermal paste before heatsink attachment. ESD precautions mandatory.', 'smt.eng@bomiq.com'),
(4,  20, (SELECT id FROM component WHERE part_number='PN-MEM-001'),   2, 1, 'U2,U3',20, 18.20,  36.40, 0.25, 1, 'Route DDR signals as differential pairs, length-matched ±10mil.', 'smt.eng@bomiq.com'),
(4,  30, (SELECT id FROM component WHERE part_number='PN-FLS-001'),   1, 1, 'U4',   30, 12.75,  12.75, 0.25, 1, 'Flash programming at SMT stage before conformal coat.', 'smt.eng@bomiq.com'),
(4,  40, (SELECT id FROM component WHERE part_number='PN-PHY-001'),   1, 1, 'U5',   40, 4.20,   4.20,  0.50, 0, 'Impedance control required on MDI pairs.', 'smt.eng@bomiq.com'),
(4,  50, (SELECT id FROM component WHERE part_number='PN-CAP-100N'), 48, 1, 'C1-C48',50,0.008,  0.38,  2.00, 0, 'Bulk decoupling. Place within 0.5mm of power pins.', 'smt.eng@bomiq.com'),
(4,  60, (SELECT id FROM component WHERE part_number='PN-CAP-10U'),  12, 1, 'C49-C60',60,0.042, 0.50,  1.00, 0, NULL, 'smt.eng@bomiq.com'),
(4,  70, (SELECT id FROM component WHERE part_number='PN-RES-10K'),  24, 1, 'R1-R24',70,0.003,  0.072, 2.00, 0, NULL, 'smt.eng@bomiq.com'),
(4,  80, (SELECT id FROM component WHERE part_number='PN-CONN-RJ45'),1, 1, 'J1',   80, 2.80,   2.80,  0.50, 0, NULL, 'smt.eng@bomiq.com'),
(4,  90, (SELECT id FROM component WHERE part_number='PN-PCB-MB'),   1, 1, 'PCB1', 90, 22.00,  22.00, 0.25, 1, 'Incoming inspection: dimensional check + netlist test.', 'smt.eng@bomiq.com'),
(4, 100, (SELECT id FROM component WHERE part_number='PN-BUCK-001'), 2, 1, 'U6,U7',100,3.40,   6.80,  0.50, 0, NULL, 'smt.eng@bomiq.com'),
(4, 110, (SELECT id FROM component WHERE part_number='PN-LDO-001'),  3, 1, 'U8-U10',110,0.65,  1.95,  0.50, 0, NULL, 'smt.eng@specright.com');

-- BOM 5: Cellular Modem Subassembly
INSERT INTO bom_line_item (bom_header_id, line_sequence, component_id, quantity, uom_id,
    reference_designator, find_number, unit_cost, extended_cost, scrap_factor_pct, critical_component, created_by) VALUES
(5, 10, (SELECT id FROM component WHERE part_number='PN-MOD-4G'),   1, 1, 'MOD1', 10, 28.40, 28.40, 0.50, 1, 'smt.eng@specright.com'),
(5, 20, (SELECT id FROM component WHERE part_number='PN-CAP-100N'),12, 1, 'C1-C12',20, 0.008, 0.096, 2.00, 0, 'smt.eng@specright.com'),
(5, 30, (SELECT id FROM component WHERE part_number='PN-RES-10K'),  8, 1, 'R1-R8',  30, 0.003, 0.024, 2.00, 0, 'smt.eng@specright.com');

-- BOM 6: Wi-Fi + BLE Subassembly
INSERT INTO bom_line_item (bom_header_id, line_sequence, component_id, quantity, uom_id,
    reference_designator, find_number, unit_cost, extended_cost, critical_component, created_by) VALUES
(6, 10, (SELECT id FROM component WHERE part_number='PN-MOD-WB'),   1, 1, 'MOD2', 10, 14.80, 14.80, 1, 'smt.eng@specright.com'),
(6, 20, (SELECT id FROM component WHERE part_number='PN-CAP-100N'), 8, 1, 'C1-C8', 20, 0.008, 0.064, 0, 'smt.eng@specright.com');

-- BOM 7: I/O Expansion Board
INSERT INTO bom_line_item (bom_header_id, line_sequence, component_id, quantity, uom_id,
    reference_designator, find_number, unit_cost, extended_cost, critical_component,
    sub_bom_id, created_by) VALUES
(7, 10, (SELECT id FROM component WHERE part_number='PN-PCB-IO'), 1, 1, 'PCB1',10, 8.50,  8.50, 1, NULL, 'smt.eng@specright.com'),
(7, 20, (SELECT id FROM component WHERE part_number='PN-TR-485'), 2, 1, 'U1,U2',20, 1.85, 3.70, 0, NULL, 'smt.eng@specright.com'),
(7, 30, (SELECT id FROM component WHERE part_number='PN-OPT-001'),8, 1, 'U3-U10',30,0.95, 7.60, 0, NULL, 'smt.eng@specright.com'),
(7, 40, (SELECT id FROM component WHERE part_number='PN-CONN-M12'),4, 1, 'J1-J4',40, 8.50,34.00, 1, NULL, 'smt.eng@specright.com');

-- BOM 9: Enclosure
INSERT INTO bom_line_item (bom_header_id, line_sequence, component_id, quantity, uom_id,
    reference_designator, find_number, unit_cost, extended_cost, critical_component, created_by) VALUES
(9, 10, (SELECT id FROM component WHERE part_number='PN-ENC-001'), 1, 1, 'ENC1', 10, 28.00, 28.00, 1, 'mech.eng@specright.com');

-- BOM 16: Cable Kit
INSERT INTO bom_line_item (bom_header_id, line_sequence, component_id, quantity, uom_id,
    reference_designator, find_number, unit_cost, extended_cost, critical_component, created_by) VALUES
(16, 10, (SELECT id FROM component WHERE part_number='PN-CBL-FLAT'), 3, 1, 'CBL1-3', 10, 1.20, 3.60, 0, 'mech.eng@specright.com');

-- ----------------------------------------------------------
-- Sample BOM change log
-- ----------------------------------------------------------
INSERT INTO bom_change_log (bom_header_id, change_type, field_changed, old_value, new_value,
    changed_by, change_reason, ecn_number) VALUES
(1, 'STATUS_CHANGE', 'bom_status', 'IN_REVIEW', 'RELEASED',
    'mgr.approval@specright.com', 'Design review complete. All RPN items resolved.', 'ECN-2024-0042'),
(4, 'UPDATE', 'bom_revision', 'A', 'B',
    'smt.eng@specright.com', 'Updated DDR routing constraint from ±5mil to ±10mil per SI analysis.', 'ECN-2024-0039'),
(4, 'UPDATE', 'bom_revision', 'B', 'C',  -- already at C per header
    'smt.eng@specright.com', 'Added conformal coat process step to CPU section notes.', 'ECN-2024-0041');

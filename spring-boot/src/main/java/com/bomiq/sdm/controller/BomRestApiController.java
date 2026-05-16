package com.bomiq.sdm.controller;

import com.bomiq.sdm.dto.*;
import com.bomiq.sdm.model.BomHeader;
import com.bomiq.sdm.model.BomLineItem;
import com.bomiq.sdm.model.Component;
import com.bomiq.sdm.model.Supplier;
import com.bomiq.sdm.repository.BomHeaderRepository;
import com.bomiq.sdm.repository.ComponentRepository;
import com.bomiq.sdm.repository.ProductRepository;
import com.bomiq.sdm.repository.SupplierRepository;
import com.bomiq.sdm.dto.*;
import com.bomiq.sdm.model.*;
import com.bomiq.sdm.repository.*;
import com.bomiq.sdm.service.BomService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * REST API Controller — endpoints consumed by the Python Flask ChatBot
 * via Bearer JWT token.  All routes: /api/v1/**
 */
@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
@CrossOrigin(origins = {"http://localhost:5000", "http://localhost:5001"})
public class BomRestApiController {

    private final BomService             bomService;
    private final BomHeaderRepository bomHeaderRepository;
    private final ComponentRepository componentRepository;
    private final SupplierRepository supplierRepository;
    private final ProductRepository productRepository;

    // ── HEALTH CHECK (public) ──────────────────────────────────────────────
    @GetMapping("/public/health")
    public Map<String, Object> health() {
        return Map.of(
                "status",  "UP",
                "service", "bomiq SDM API",
                "version", "1.0.0"
        );
    }

    // ── BOM LIST ───────────────────────────────────────────────────────────
    /** All active BOMs (summary) */
    @GetMapping("/boms")
    public ResponseEntity<ApiResponse<List<BomSummaryDto>>> listBoms(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Long   productId) {

        List<BomHeader> boms;
        if (status != null) {
            boms = bomHeaderRepository.findByBomStatusAndIsActive(
                    BomHeader.BomStatus.valueOf(status.toUpperCase()), true);
        } else if (productId != null) {
            boms = bomHeaderRepository.findByProductId(productId);
        } else {
            boms = bomService.findAllActive();
        }
        return ResponseEntity.ok(ApiResponse.ok(boms.stream().map(BomSummaryDto::from).toList()));
    }

    /** BOM hierarchy tree — root BOMs with child counts */
    @GetMapping("/boms/hierarchy")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getBomHierarchy() {
        List<BomHeader> roots = bomService.findRootBoms();
        List<Map<String, Object>> tree = roots.stream().map(r -> {
            Map<String, Object> node = new LinkedHashMap<>();
            node.put("bom",      BomSummaryDto.from(r));
            node.put("children", bomService.findChildBoms(r.getId())
                    .stream().map(BomSummaryDto::from).toList());
            return node;
        }).toList();
        return ResponseEntity.ok(ApiResponse.ok(tree));
    }

    /** Full BOM detail with line items and child BOMs */
    @GetMapping("/boms/{id}")
    public ResponseEntity<ApiResponse<BomDetailDto>> getBomDetail(@PathVariable Long id) {
        return bomService.findById(id)
                .map(bom -> {
                    List<BomLineItem> lines    = bomHeaderRepository.findByIdWithLineItems(id)
                            .map(b -> b.getLineItems()).orElse(List.of());
                    List<BomHeader>   children = bomService.findChildBoms(id);
                    return ResponseEntity.ok(ApiResponse.ok(BomDetailDto.from(bom, lines, children)));
                })
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    /** BOM line items only */
    @GetMapping("/boms/{id}/lines")
    public ResponseEntity<ApiResponse<List<BomLineItemDto>>> getBomLines(@PathVariable Long id) {
        return bomHeaderRepository.findByIdWithLineItems(id)
                .map(bom -> ResponseEntity.ok(
                        ApiResponse.ok(bom.getLineItems().stream().map(BomLineItemDto::from).toList())))
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    /** BOM cost summary */
    @GetMapping("/boms/{id}/cost-summary")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getBomCostSummary(@PathVariable Long id) {
        return bomService.findById(id).map(bom -> {
            Map<String, Object> cost = new LinkedHashMap<>();
            cost.put("bomId",              bom.getId());
            cost.put("bomNumber",          bom.getBomNumber());
            cost.put("totalMaterialCost",  bom.getTotalMaterialCost());
            cost.put("totalLaborCost",     bom.getTotalLaborCost());
            cost.put("totalOverheadCost",  bom.getTotalOverheadCost());
            cost.put("totalBomCost",       bom.getTotalBomCost());
            cost.put("currencyCode",       bom.getCurrencyCode());
            cost.put("lineItemCount",      bom.getLineItems().size());
            return ResponseEntity.ok(ApiResponse.ok(cost));
        }).orElseGet(() -> ResponseEntity.notFound().build());
    }

    /** Child BOMs of a given BOM */
    @GetMapping("/boms/{id}/children")
    public ResponseEntity<ApiResponse<List<BomSummaryDto>>> getChildBoms(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(
                bomService.findChildBoms(id).stream().map(BomSummaryDto::from).toList()));
    }

    /** BOM statistics dashboard */
    @GetMapping("/boms/stats/summary")
    public ResponseEntity<ApiResponse<BomService.BomSummaryStats>> getBomStats() {
        return ResponseEntity.ok(ApiResponse.ok(bomService.getBomStats()));
    }

    /** Update BOM status */
    @PatchMapping("/boms/{id}/status")
    @PreAuthorize("hasAnyRole('bomiq-admin','bomiq-engineer')")
    public ResponseEntity<ApiResponse<BomSummaryDto>> updateStatus(
            @PathVariable Long id,
            @RequestParam String status) {
        BomHeader updated = bomService.updateStatus(id, BomHeader.BomStatus.valueOf(status.toUpperCase()));
        return ResponseEntity.ok(ApiResponse.ok("Status updated", BomSummaryDto.from(updated)));
    }

    // ── COMPONENTS ─────────────────────────────────────────────────────────
    @GetMapping("/components")
    public ResponseEntity<ApiResponse<List<ComponentDto>>> listComponents(
            @RequestParam(defaultValue = "")  String keyword,
            @RequestParam(defaultValue = "0") int    page,
            @RequestParam(defaultValue = "50") int   size) {
        if (!keyword.isEmpty()) {
            Page<Component> pg = componentRepository
                    .findByPartNameContainingIgnoreCaseAndIsActive(keyword, true,
                            PageRequest.of(page, size));
            return ResponseEntity.ok(ApiResponse.ok(pg.stream().map(ComponentDto::from).toList()));
        }
        return ResponseEntity.ok(ApiResponse.ok(
                componentRepository.findAllActiveWithDetails().stream().map(ComponentDto::from).toList()));
    }

    @GetMapping("/components/{id}")
    public ResponseEntity<ApiResponse<ComponentDto>> getComponent(@PathVariable Long id) {
        return componentRepository.findByIdWithDetails(id)
                .map(c -> ResponseEntity.ok(ApiResponse.ok(ComponentDto.from(c))))
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    /** Components by supplier — useful for vendor validation */
    @GetMapping("/components/by-supplier/{supplierId}")
    public ResponseEntity<ApiResponse<List<ComponentDto>>> getComponentsBySupplier(
            @PathVariable Long supplierId) {
        return ResponseEntity.ok(ApiResponse.ok(
                componentRepository.findByPreferredSupplierId(supplierId)
                        .stream().map(ComponentDto::from).toList()));
    }

    /** Obsolete/NRND components — compliance check */
    @GetMapping("/components/lifecycle/{status}")
    public ResponseEntity<ApiResponse<List<ComponentDto>>> getComponentsByLifecycle(
            @PathVariable String status) {
        return ResponseEntity.ok(ApiResponse.ok(
                componentRepository.findByLifecycleStatusAndIsActive(
                                Component.LifecycleStatus.valueOf(status.toUpperCase()), true)
                        .stream().map(ComponentDto::from).toList()));
    }

    // ── SUPPLIERS ──────────────────────────────────────────────────────────
    @GetMapping("/suppliers")
    public ResponseEntity<ApiResponse<List<SupplierDto>>> listSuppliers(
            @RequestParam(required = false) String tier,
            @RequestParam(required = false) String risk) {
        List<Supplier> suppliers;
        if (tier != null) {
            suppliers = supplierRepository.findBySupplierTierAndIsActive(
                    Supplier.SupplierTier.valueOf(tier.toUpperCase()), true);
        } else if (risk != null) {
            suppliers = supplierRepository.findByRiskRatingAndIsActive(
                    Supplier.RiskRating.valueOf(risk.toUpperCase()), true);
        } else {
            suppliers = supplierRepository.findAll().stream().filter(s -> Boolean.TRUE.equals(s.getIsActive())).collect(java.util.stream.Collectors.toList());
        }
        return ResponseEntity.ok(ApiResponse.ok(suppliers.stream().map(SupplierDto::from).toList()));
    }

    @GetMapping("/suppliers/{id}")
    public ResponseEntity<ApiResponse<SupplierDto>> getSupplier(@PathVariable Long id) {
        return supplierRepository.findById(id)
                .map(s -> ResponseEntity.ok(ApiResponse.ok(SupplierDto.from(s))))
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    // ── PRODUCTS ───────────────────────────────────────────────────────────
    @GetMapping("/products")
    public ResponseEntity<ApiResponse<List<ProductDto>>> listProducts() {
        return ResponseEntity.ok(ApiResponse.ok(
                productRepository.findByIsActive(true).stream().map(ProductDto::from).toList()));
    }

    @GetMapping("/products/{id}/boms")
    public ResponseEntity<ApiResponse<List<BomSummaryDto>>> getProductBoms(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(
                bomHeaderRepository.findByProductId(id).stream().map(BomSummaryDto::from).toList()));
    }

    // ── BOM VALIDATION ENDPOINT (called by LangGraph agent) ──────────────
    /**
     * Comprehensive validation payload for a BOM — collects:
     * header, line items, component lifecycle, supplier risk, cost breakdown
     * so the Flask LangGraph agent can make a single structured call.
     */
    @GetMapping("/boms/{id}/validation-payload")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getValidationPayload(@PathVariable Long id) {
        Optional<BomHeader> opt = bomService.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();

        BomHeader bom = opt.get();
        List<BomLineItem> lines = bomHeaderRepository.findByIdWithLineItems(id)
                .map(b -> b.getLineItems()).orElse(List.of());

        // Gather compliance risks
        List<Map<String, String>> complianceIssues = new ArrayList<>();
        lines.forEach(li -> {
            Component c = li.getComponent();
            if (c != null) {
                if (c.getRohsCompliant() == null) {
                    complianceIssues.add(Map.of(
                            "partNumber", c.getPartNumber(),
                            "issue", "RoHS compliance status unknown"));
                }
                if (c.getLifecycleStatus() == Component.LifecycleStatus.OBSOLETE ||
                        c.getLifecycleStatus() == Component.LifecycleStatus.NRND) {
                    complianceIssues.add(Map.of(
                            "partNumber", c.getPartNumber(),
                            "issue", "Component is " + c.getLifecycleStatus().name()));
                }
            }
        });

        // Supplier risk flags
        List<Map<String, String>> supplierRisks = new ArrayList<>();
        lines.stream()
                .filter(li -> li.getPreferredSupplier() != null)
                .forEach(li -> {
                    Supplier s = li.getPreferredSupplier();
                    if (s.getRiskRating() == Supplier.RiskRating.HIGH ||
                            s.getRiskRating() == Supplier.RiskRating.CRITICAL) {
                        supplierRisks.add(Map.of(
                                "supplierCode", s.getSupplierCode(),
                                "risk",         s.getRiskRating().name(),
                                "component",    li.getComponent().getPartNumber()));
                    }
                });

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("bom",              BomSummaryDto.from(bom));
        payload.put("lineItemCount",    lines.size());
        payload.put("criticalCount",    lines.stream().filter(li -> Boolean.TRUE.equals(li.getCriticalComponent())).count());
        payload.put("totalCost",        bom.getTotalMaterialCost());
        payload.put("complianceIssues", complianceIssues);
        payload.put("supplierRisks",    supplierRisks);
        payload.put("lineItems",        lines.stream().map(BomLineItemDto::from).toList());
        payload.put("children",         bomService.findChildBoms(id).stream().map(BomSummaryDto::from).toList());

        return ResponseEntity.ok(ApiResponse.ok(payload));
    }
}
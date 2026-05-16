package com.bomiq.sdm.controller;

import com.bomiq.sdm.model.BomHeader;
import com.bomiq.sdm.model.BomLineItem;
import com.bomiq.sdm.model.Component;
import com.bomiq.sdm.model.Supplier;
import com.bomiq.sdm.repository.BomHeaderRepository;
import com.bomiq.sdm.repository.ComponentRepository;
import com.bomiq.sdm.repository.ProductRepository;
import com.bomiq.sdm.repository.SupplierRepository;
import com.bomiq.sdm.model.*;
import com.bomiq.sdm.repository.*;
import com.bomiq.sdm.service.BomService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import java.util.NoSuchElementException;

/**
 * Thymeleaf UI controller — renders Bootstrap 5 light-blue themed pages.
 */
@Controller
@RequiredArgsConstructor
public class BomController {

    private final BomService          bomService;
    private final BomHeaderRepository bomHeaderRepository;
    private final ProductRepository productRepository;
    private final SupplierRepository supplierRepository;
    private final ComponentRepository componentRepository;

    // ── Home / Dashboard ──────────────────────────────────────────────────
    @GetMapping("/")
    public String home(Model model, @AuthenticationPrincipal OidcUser user) {
        if (user != null) return "redirect:/bom";
        return "home";
    }

    @GetMapping("/bom")
    public String bomList(Model model,
                          @RequestParam(defaultValue = "") String q,
                          @AuthenticationPrincipal OidcUser principal) {
        List<BomHeader> boms = q.isEmpty()
                ? bomService.findAllActive()
                : bomHeaderRepository.findByBomTitleContainingIgnoreCaseAndIsActive(
                q, true, org.springframework.data.domain.PageRequest.of(0, 100)).getContent();

        model.addAttribute("boms",     boms);
        model.addAttribute("rootBoms", bomService.findRootBoms());
        model.addAttribute("stats",    bomService.getBomStats());
        model.addAttribute("q",        q);
        model.addAttribute("user",     principal != null ? principal.getPreferredUsername() : "");
        return "bom/list";
    }

    // ── BOM Detail (view + edit) ──────────────────────────────────────────
    @GetMapping("/bom/{id}")
    public String bomDetail(@PathVariable Long id, Model model,
                            @AuthenticationPrincipal OidcUser principal) {
        BomHeader bom = bomService.findById(id)
                .orElseThrow(() -> new NoSuchElementException("BOM not found"));

        List<BomLineItem> lines    = bomHeaderRepository.findByIdWithLineItems(id)
                .map(b -> b.getLineItems()).orElse(List.of());
        List<BomHeader>   children = bomService.findChildBoms(id);

        model.addAttribute("bom",       bom);
        model.addAttribute("lineItems", lines);
        model.addAttribute("children",  children);
        model.addAttribute("products",  productRepository.findByIsActive(true));
        model.addAttribute("statuses",  BomHeader.BomStatus.values());
        model.addAttribute("bomTypes",  BomHeader.BomType.values());
        model.addAttribute("riskLevels",BomHeader.RiskLevel.values());
        model.addAttribute("user",      principal != null ? principal.getPreferredUsername() : "");
        return "bom/detail";
    }

    // ── BOM Edit ──────────────────────────────────────────────────────────
    @GetMapping("/bom/{id}/edit")
    public String bomEditForm(@PathVariable Long id, Model model,
                              @AuthenticationPrincipal OidcUser principal) {
        BomHeader bom = bomService.findById(id)
                .orElseThrow(() -> new NoSuchElementException("BOM not found"));
        model.addAttribute("bom",       bom);
        model.addAttribute("products",  productRepository.findByIsActive(true));
        model.addAttribute("statuses",  BomHeader.BomStatus.values());
        model.addAttribute("bomTypes",  BomHeader.BomType.values());
        model.addAttribute("riskLevels",BomHeader.RiskLevel.values());
        model.addAttribute("user",      principal != null ? principal.getPreferredUsername() : "");
        return "bom/edit";
    }

    @PostMapping("/bom/{id}/edit")
    public String bomEditSave(@PathVariable Long id,
                              @ModelAttribute BomHeader formBom,
                              RedirectAttributes ra,
                              @AuthenticationPrincipal OidcUser principal) {
        BomHeader existing = bomService.findById(id)
                .orElseThrow(() -> new NoSuchElementException("BOM not found"));

        // Map editable fields only — never touch created_by, id, etc.
        existing.setBomRevision(formBom.getBomRevision());
        existing.setBomTitle(formBom.getBomTitle());
        existing.setBomType(formBom.getBomType());
        existing.setBomStatus(formBom.getBomStatus());
        existing.setEffectiveDate(formBom.getEffectiveDate());
        existing.setExpiryDate(formBom.getExpiryDate());
        existing.setEngineeringChangeNo(formBom.getEngineeringChangeNo());
        existing.setChangeDescription(formBom.getChangeDescription());
        existing.setTotalMaterialCost(formBom.getTotalMaterialCost());
        existing.setTotalLaborCost(formBom.getTotalLaborCost());
        existing.setTotalOverheadCost(formBom.getTotalOverheadCost());
        existing.setTotalBomCost(formBom.getTotalBomCost());
        existing.setCurrencyCode(formBom.getCurrencyCode());
        existing.setWeightKg(formBom.getWeightKg());
        existing.setTargetAssemblyTimeMin(formBom.getTargetAssemblyTimeMin());
        existing.setAssemblyLocation(formBom.getAssemblyLocation());
        existing.setQualityPlanRef(formBom.getQualityPlanRef());
        existing.setRiskLevel(formBom.getRiskLevel());
        existing.setNotes(formBom.getNotes());
        existing.setApprovalRequiredBy(formBom.getApprovalRequiredBy());

        bomService.save(existing);
        ra.addFlashAttribute("successMsg", "BOM saved successfully.");
        return "redirect:/bom/" + id;
    }

    // ── New BOM ───────────────────────────────────────────────────────────
    @GetMapping("/bom/new")
    public String newBomForm(Model model, @AuthenticationPrincipal OidcUser principal) {
        model.addAttribute("bom",       new BomHeader());
        model.addAttribute("products",  productRepository.findByIsActive(true));
        model.addAttribute("statuses",  BomHeader.BomStatus.values());
        model.addAttribute("bomTypes",  BomHeader.BomType.values());
        model.addAttribute("riskLevels",BomHeader.RiskLevel.values());
        model.addAttribute("rootBoms",  bomService.findRootBoms());
        model.addAttribute("user",      principal != null ? principal.getPreferredUsername() : "");
        return "bom/new";
    }

    @PostMapping("/bom/new")
    public String newBomSave(@ModelAttribute BomHeader formBom,
                             RedirectAttributes ra) {
        BomHeader saved = bomService.save(formBom);
        ra.addFlashAttribute("successMsg", "BOM " + saved.getBomNumber() + " created.");
        return "redirect:/bom/" + saved.getId();
    }

    // ── Suppliers ─────────────────────────────────────────────────────────
    @GetMapping("/suppliers")
    public String supplierList(Model model, @AuthenticationPrincipal OidcUser principal) {
        List<Supplier> suppliers = supplierRepository.findAll().stream().filter(s -> Boolean.TRUE.equals(s.getIsActive())).collect(java.util.stream.Collectors.toList());

        long tier1Count = suppliers.stream()
                .filter(s -> s.getSupplierTier() != null && s.getSupplierTier().name().equals("TIER1"))
                .count();
        long highRiskCount = 0L; // riskRating not in model
        long activeCount = suppliers.stream()
                .filter(s -> Boolean.TRUE.equals(s.getIsActive()))
                .count();

        model.addAttribute("suppliers",    suppliers);
        model.addAttribute("tier1Count",   tier1Count);
        model.addAttribute("highRiskCount",highRiskCount);
        model.addAttribute("activeCount",  activeCount);
        model.addAttribute("user", principal != null ? principal.getPreferredUsername() : "");
        return "supplier/list";
    }

    // ── Components ────────────────────────────────────────────────────────
    @GetMapping("/components")
    public String componentList(@RequestParam(defaultValue = "") String q,
                                @RequestParam(defaultValue = "") String lifecycle,
                                @RequestParam(required = false) Long materialClassId,
                                Model model,
                                @AuthenticationPrincipal OidcUser principal) {
        List<Component> comps = q.isEmpty()
                ? componentRepository.findAllActiveWithDetails()
                : componentRepository.findByPartNameContainingIgnoreCaseAndIsActive(
                q, true, org.springframework.data.domain.PageRequest.of(0, 100)).getContent();

        // Apply lifecycle filter if provided
        if (!lifecycle.isEmpty()) {
            final String lc = lifecycle;
            comps = comps.stream()
                    .filter(c -> c.getLifecycleStatus() != null && c.getLifecycleStatus().name().equals(lc))
                    .collect(java.util.stream.Collectors.toList());
        }

        // Apply material class filter if provided
        if (materialClassId != null) {
            final Long mcId = materialClassId;
            comps = comps.stream()
                    .filter(c -> c.getMaterialClass() != null && mcId.equals(c.getMaterialClass().getId()))
                    .collect(java.util.stream.Collectors.toList());
        }

        // Compute counts in Java — avoid complex SpEL in template
        long activePreferredCount = comps.stream()
                .filter(c -> c.getLifecycleStatus() != null &&
                        (c.getLifecycleStatus().name().equals("ACTIVE") || c.getLifecycleStatus().name().equals("PREFERRED")))
                .count();
        long obsoleteCount = comps.stream()
                .filter(c -> c.getLifecycleStatus() != null && c.getLifecycleStatus().name().equals("OBSOLETE"))
                .count();
        long criticalCount = comps.stream()
                .filter(c -> Boolean.TRUE.equals(c.getRohsCompliant()))
                .count();

        model.addAttribute("components",           comps);
        model.addAttribute("activePreferredCount", activePreferredCount);
        model.addAttribute("obsoleteCount",        obsoleteCount);
        model.addAttribute("criticalCount",        criticalCount);
        model.addAttribute("materialClasses",      componentRepository.findAllMaterialClasses());
        model.addAttribute("searchQuery",          q);
        model.addAttribute("selectedLifecycle",    lifecycle);
        model.addAttribute("selectedMaterialClassId", materialClassId);
        model.addAttribute("user",                 principal != null ? principal.getPreferredUsername() : "");
        return "component/list";
    }

    @GetMapping("/components/{id}")
    public String componentDetail(@PathVariable Long id, Model model,
                                  @AuthenticationPrincipal OidcUser principal) {
        Component c = componentRepository.findByIdWithDetails(id)
                .orElseThrow(() -> new NoSuchElementException("Component not found"));
        model.addAttribute("component", c);
        model.addAttribute("user", principal != null ? principal.getPreferredUsername() : "");
        return "component/detail";
    }
}
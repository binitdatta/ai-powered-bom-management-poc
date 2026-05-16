/**
 * bomiq SDM — Frontend JavaScript
 * Bootstrap 5 + custom UX enhancements
 */

document.addEventListener('DOMContentLoaded', function () {

    // ── Auto-dismiss flash messages after 4 seconds ──────────────────────────
    document.querySelectorAll('.alert-dismissible').forEach(function (alert) {
        setTimeout(function () {
            const bsAlert = bootstrap.Alert.getOrCreateInstance(alert);
            bsAlert.close();
        }, 4000);
    });

    // ── BOM Cost Auto-Computation ─────────────────────────────────────────────
    const unitCostInput   = document.getElementById('unitCost');
    const quantityInput   = document.getElementById('bomQuantity');
    const extCostDisplay  = document.getElementById('extendedCostDisplay');

    function recomputeExtendedCost() {
        const unitCost = parseFloat(unitCostInput?.value) || 0;
        const qty      = parseFloat(quantityInput?.value) || 0;
        const ext      = (unitCost * qty).toFixed(4);
        if (extCostDisplay) extCostDisplay.textContent = '$' + parseFloat(ext).toLocaleString('en-US', { minimumFractionDigits: 2 });
    }

    unitCostInput?.addEventListener('input', recomputeExtendedCost);
    quantityInput?.addEventListener('input', recomputeExtendedCost);
    recomputeExtendedCost();

    // ── BOM Total Cost rollup (sum of line items on edit page) ────────────────
    function recomputeTotalBomCost() {
        let total = 0;
        document.querySelectorAll('.line-item-ext-cost').forEach(function (el) {
            total += parseFloat(el.dataset.value) || 0;
        });
        const totalEl = document.getElementById('totalBomCostRollup');
        if (totalEl) {
            totalEl.textContent = '$' + total.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        }
    }
    recomputeTotalBomCost();

    // ── Form validation ───────────────────────────────────────────────────────
    document.querySelectorAll('form.needs-validation').forEach(function (form) {
        form.addEventListener('submit', function (event) {
            if (!form.checkValidity()) {
                event.preventDefault();
                event.stopPropagation();
            }
            form.classList.add('was-validated');
        }, false);
    });

    // ── Confirm on destructive actions ────────────────────────────────────────
    document.querySelectorAll('[data-confirm]').forEach(function (el) {
        el.addEventListener('click', function (e) {
            if (!confirm(el.dataset.confirm)) {
                e.preventDefault();
            }
        });
    });

    // ── BOM Tree sidebar: expand/collapse ─────────────────────────────────────
    document.querySelectorAll('.bom-tree-toggle').forEach(function (toggle) {
        toggle.addEventListener('click', function () {
            const targetId = toggle.dataset.target;
            const childList = document.getElementById(targetId);
            if (childList) {
                childList.classList.toggle('d-none');
                const icon = toggle.querySelector('.tree-icon');
                if (icon) {
                    icon.classList.toggle('bi-chevron-down');
                    icon.classList.toggle('bi-chevron-right');
                }
            }
        });
    });

    // ── Status badge color helper ─────────────────────────────────────────────
    function getBadgeClass(status) {
        const map = {
            'DRAFT':        'bg-secondary',
            'IN_REVIEW':    'bg-warning text-dark',
            'APPROVED':     'bg-info',
            'RELEASED':     'bg-success',
            'OBSOLETE':     'bg-danger',
            'ON_HOLD':      'bg-dark',
            'SUPERSEDED':   'bg-primary',
        };
        return map[status] || 'bg-secondary';
    }

    document.querySelectorAll('.status-badge[data-status]').forEach(function (el) {
        el.className = 'badge status-badge ' + getBadgeClass(el.dataset.status);
    });

    // ── Tooltip init ─────────────────────────────────────────────────────────
    document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(function (el) {
        new bootstrap.Tooltip(el, { trigger: 'hover' });
    });

    // ── Popover init ─────────────────────────────────────────────────────────
    document.querySelectorAll('[data-bs-toggle="popover"]').forEach(function (el) {
        new bootstrap.Popover(el);
    });

    // ── Search field: clear button ────────────────────────────────────────────
    const searchInput = document.getElementById('searchInput');
    const clearBtn    = document.getElementById('clearSearchBtn');
    if (searchInput && clearBtn) {
        searchInput.addEventListener('input', function () {
            clearBtn.style.display = searchInput.value ? 'inline-block' : 'none';
        });
        clearBtn.addEventListener('click', function () {
            searchInput.value = '';
            clearBtn.style.display = 'none';
            searchInput.closest('form').submit();
        });
    }

    // ── Date input defaults to today ─────────────────────────────────────────
    document.querySelectorAll('input[data-default-today]').forEach(function (el) {
        if (!el.value) {
            el.value = new Date().toISOString().split('T')[0];
        }
    });

    // ── Numeric field: prevent negative ──────────────────────────────────────
    document.querySelectorAll('input[type="number"][min="0"]').forEach(function (el) {
        el.addEventListener('change', function () {
            if (parseFloat(el.value) < 0) el.value = 0;
        });
    });

    // ── API Explorer panel (detail page) ─────────────────────────────────────
    const apiBtnContainer = document.getElementById('apiExplorerBtns');
    if (apiBtnContainer) {
        apiBtnContainer.querySelectorAll('.api-btn').forEach(function (btn) {
            btn.addEventListener('click', function () {
                const url = btn.dataset.url;
                const responseDiv = document.getElementById('apiResponse');
                const pre = document.getElementById('apiResponsePre');
                if (!url || !responseDiv || !pre) return;

                btn.disabled = true;
                btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Loading…';

                fetch(url, { headers: { 'Accept': 'application/json' } })
                    .then(r => r.json())
                    .then(data => {
                        pre.textContent = JSON.stringify(data, null, 2);
                        responseDiv.classList.remove('d-none');
                        btn.disabled = false;
                        btn.innerHTML = btn.dataset.label || 'Try API';
                    })
                    .catch(err => {
                        pre.textContent = 'Error: ' + err.message;
                        responseDiv.classList.remove('d-none');
                        btn.disabled = false;
                        btn.innerHTML = btn.dataset.label || 'Try API';
                    });
            });
        });
    }

    // ── Flash on page load if URL has ?saved=true ─────────────────────────────
    const params = new URLSearchParams(window.location.search);
    if (params.get('saved') === 'true') {
        const toast = document.getElementById('savedToast');
        if (toast) bootstrap.Toast.getOrCreateInstance(toast).show();
    }

    // ── Copy to clipboard buttons ─────────────────────────────────────────────
    document.querySelectorAll('.copy-btn').forEach(function (btn) {
        btn.addEventListener('click', function () {
            const text = document.getElementById(btn.dataset.target)?.textContent || btn.dataset.text;
            if (text) {
                navigator.clipboard.writeText(text).then(function () {
                    const orig = btn.innerHTML;
                    btn.innerHTML = '<i class="bi bi-check2"></i>';
                    setTimeout(() => btn.innerHTML = orig, 1500);
                });
            }
        });
    });

    // ── Column visibility toggle (table) ──────────────────────────────────────
    document.querySelectorAll('.col-toggle').forEach(function (cb) {
        cb.addEventListener('change', function () {
            const colIdx = parseInt(cb.dataset.col);
            const table = document.querySelector(cb.dataset.table);
            if (!table) return;
            table.querySelectorAll('tr').forEach(function (row) {
                const cells = row.querySelectorAll('th, td');
                if (cells[colIdx]) {
                    cells[colIdx].style.display = cb.checked ? '' : 'none';
                }
            });
        });
    });

    console.info('bomiq SDM JS initialized');
});

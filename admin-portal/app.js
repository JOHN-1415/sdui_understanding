
  function formatCssBox(val) {
    if (!val) return '';
    if (typeof val === 'number') return `${val}px`;
    if (Array.isArray(val)) {
      if (val.length === 4) return `${val[0]}px ${val[1]}px ${val[2]}px ${val[3]}px`;
      if (val.length === 2) return `${val[0]}px ${val[1]}px`;
    }
    return '';
  }

/**
 * SDUI Studio - Dual-Mode Admin Architecture Controller
 * Unified Bi-directional State Management between:
 * Mode A: Raw JSON Editor
 * Mode B: Visual Component Arranger
 * Live Phone Preview Simulator
 */

(function () {
  'use strict';

  // Config & State
  let backendBaseUrl = window.location.origin.includes('localhost') || window.location.origin.includes('127.0.0.1') || window.location.origin.includes(':5000')
    ? window.location.origin
    : 'http://localhost:5000';

  let currentScreenId = 'home';
  let isUpdatingInternally = false;
  let activeEditingIndex = -1;

  // Master State Schema
  let currentSchema = {
    screenId: 'home',
    title: 'SDUI Dynamic Store',
    version: '1.0.0',
    updatedAt: new Date().toISOString(),
    theme: {
      primaryColor: '#6366F1',
      backgroundColor: '#0F172A',
      surfaceColor: '#1E293B',
      textColor: '#F8FAFC',
      accentColor: '#10B981'
    },
    components: []
  };

  // Component Templates for Quick Insertion
  const COMPONENT_TEMPLATES = {
    card_le_smash: {
      type: "container",
      props: { elevation: 4 },
      styles: {
        backgroundColor: "#FFFFFF",
        borderRadius: 20,
        borderColor: "#E2E8F0",
        borderWidth: 1,
        margin: [8, 14, 12, 14]
      },
      children: [
        {
          id: "le_smash_stack",
          type: "stack",
          props: { alignment: "bottomLeft" },
          styles: { borderRadius: 20 },
          children: [
            {
              id: "le_smash_img",
              type: "image",
              props: {
                url: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80",
                fit: "cover",
                height: 180,
                gradientOverlay: { colors: ["#00000000", "#10000000", "#E0000000"] }
              }
            },
            {
              id: "le_smash_title_row",
              type: "row",
              props: {
                position: { bottom: 12, left: 14, right: 14 },
                mainAxisAlignment: "spaceBetween",
                crossAxisAlignment: "center"
              },
              children: [
                { id: "le_smash_name", type: "text", props: { text: "Le Smash", fontSize: 22, fontWeight: "800", color: "#FFFFFF" } },
                { id: "le_smash_rating", type: "badge", props: { text: "4.7", icon: "star", fontSize: 13, fontWeight: "bold", backgroundColor: "#0B6B38", textColor: "#FFFFFF", padding: [4, 8, 4, 8] }, styles: { borderRadius: 14 } }
              ]
            }
          ]
        },
        {
          id: "le_smash_details",
          type: "container",
          styles: { padding: [12, 14, 14, 14] },
          children: [
            {
              id: "le_smash_cuisine_row",
              type: "row",
              props: { mainAxisAlignment: "spaceBetween" },
              styles: { margin: [0, 0, 4, 0] },
              children: [
                { id: "le_smash_cuisine", type: "text", props: { text: "Asian • Italian", fontSize: 13, color: "#64748B", fontWeight: "500" } },
                { id: "le_smash_cost", type: "text", props: { text: "₹1000 for two", fontSize: 13, color: "#334155", fontWeight: "600" } }
              ]
            },
            {
              id: "le_smash_loc_row",
              type: "row",
              props: { mainAxisAlignment: "spaceBetween" },
              styles: { margin: [0, 0, 10, 0] },
              children: [
                { id: "le_smash_location", type: "text", props: { text: "Nungambakkam, Chennai", fontSize: 13, color: "#64748B" } },
                { id: "le_smash_distance", type: "text", props: { text: "7.9 km", fontSize: 13, color: "#334155" } }
              ]
            },
            {
              id: "le_smash_offer_pill1",
              type: "container",
              action: { type: "toast", payload: { message: "Flat 10% off walk-in discount activated!" } },
              styles: { backgroundColor: "#16A34A", borderRadius: 10, padding: [8, 12, 8, 12], margin: [0, 0, 8, 0] },
              children: [
                {
                  id: "pill1_row",
                  type: "row",
                  props: { mainAxisAlignment: "spaceBetween", crossAxisAlignment: "center" },
                  children: [
                    {
                      id: "pill1_left",
                      type: "row",
                      props: { mainAxisAlignment: "start", spacing: 6, crossAxisAlignment: "center" },
                      children: [
                        { id: "pill1_icon", type: "icon", props: { name: "percent", size: 14, color: "#FFFFFF" } },
                        { id: "pill1_text", type: "text", props: { text: "Flat 10% off on walk-in", fontSize: 13, fontWeight: "700", color: "#FFFFFF" } }
                      ]
                    },
                    { id: "pill1_more", type: "text", props: { text: "+ 1 more", fontSize: 12, fontWeight: "700", color: "#FFFFFF" } }
                  ]
                }
              ]
            },
            {
              id: "le_smash_offer_pill2",
              type: "container",
              action: { type: "toast", payload: { message: "Bank offers will be applied at payment" } },
              styles: { backgroundColor: "#BBF7D0", borderRadius: 10, padding: [8, 12, 8, 12], margin: [0, 0, 8, 0] },
              children: [
                { id: "pill2_text", type: "text", props: { text: "Up to 10% off with bank offers", fontSize: 13, fontWeight: "600", color: "#065F46" } }
              ]
            },
            {
              id: "le_smash_promo_code",
              type: "text",
              action: { type: "copy_code", payload: { code: "PAYTMNEW", message: "Coupon PAYTMNEW copied! Extra ₹125 OFF" } },
              styles: { margin: [4, 0, 2, 0] },
              props: { text: "Get extra ₹125 off using PAYTMNEW", fontSize: 13, fontWeight: "600", color: "#4F46E5" }
            }
          ]
        }
      ]
    },
    card_grocery_icecream: {
      type: "container",
      props: { elevation: 3 },
      styles: {
        backgroundColor: "#FFFFFF",
        borderRadius: 16,
        borderColor: "#E2E8F0",
        borderWidth: 1,
        width: 190,
        margin: [8, 14, 12, 14],
        padding: [10, 10, 12, 10]
      },
      children: [
        {
          id: "grocery_img_stack",
          type: "stack",
          styles: { borderRadius: 14 },
          children: [
            {
              id: "grocery_img",
              type: "image",
              props: { url: "https://images.unsplash.com/photo-1501443762994-82bd5dace89a?w=500&q=80", height: 160, width: 170, fit: "cover", borderRadius: 14 }
            },
            {
              id: "grocery_add_btn",
              type: "container",
              action: { type: "toast", payload: { message: "Added Go Zero Only Vanilla to cart!" } },
              props: { position: { top: 8, right: 8 } },
              styles: { backgroundColor: "#F8FAFC", borderColor: "#2563EB", borderWidth: 1.5, borderRadius: 10, padding: [6, 8, 6, 8] },
              children: [
                { id: "grocery_add_icon", type: "icon", props: { name: "add", color: "#2563EB", size: 18 } }
              ]
            }
          ]
        },
        { id: "grocery_delivery_time", type: "text", styles: { margin: [8, 0, 4, 0] }, props: { text: "26 MINS", fontSize: 11, fontWeight: "800", color: "#71717A" } },
        { id: "grocery_title", type: "text", styles: { margin: [0, 0, 4, 0] }, props: { text: "Go Zero Only Vanilla Guilt Free...", fontSize: 14, fontWeight: "800", color: "#18181B", maxLines: 2 } },
        { id: "grocery_unit", type: "text", styles: { margin: [0, 0, 8, 0] }, props: { text: "1 ltr", fontSize: 13, color: "#52525B", fontWeight: "500" } },
        {
          id: "grocery_discount_row",
          type: "row",
          props: { mainAxisAlignment: "spaceBetween", crossAxisAlignment: "center", spacing: 8 },
          styles: { margin: [0, 0, 8, 0] },
          children: [
            { id: "grocery_discount_text", type: "text", props: { text: "14% OFF", fontSize: 12, fontWeight: "800", color: "#059669" } },
            { id: "grocery_dashed_line", type: "divider", props: { expanded: true, dashed: true, thickness: 1, color: "#CBD5E1" } }
          ]
        },
        {
          id: "grocery_price_row",
          type: "row",
          props: { mainAxisAlignment: "start", crossAxisAlignment: "center", spacing: 8 },
          children: [
            { id: "grocery_price", type: "text", props: { text: "₹212", fontSize: 17, fontWeight: "800", color: "#18181B" } },
            { id: "grocery_orig_price", type: "text", props: { text: "₹249", fontSize: 13, fontWeight: "500", color: "#94A3B8", decoration: "lineThrough" } }
          ]
        }
      ]
    },
    container: {
      type: "container",
      props: { elevation: 2 },
      styles: {
        backgroundColor: "#1E293B",
        borderRadius: 12,
        padding: [12, 12, 12, 12],
        margin: [8, 16, 8, 16]
      },
      children: [
        { type: "text", props: { text: "Container Header", fontSize: 15, fontWeight: "700", color: "#FFFFFF" } },
        { type: "text", props: { text: "Add any child primitives inside this container.", fontSize: 12, color: "#94A3B8" } }
      ]
    },
    row: {
      type: "row",
      props: { mainAxisAlignment: "spaceBetween", crossAxisAlignment: "center", spacing: 8 },
      styles: { margin: [4, 16, 4, 16] },
      children: [
        { type: "text", props: { text: "Left Column", fontSize: 13, color: "#94A3B8" } },
        { type: "badge", props: { text: "Right Tag", backgroundColor: "#6366F1", textColor: "#FFFFFF" }, styles: { borderRadius: 8 } }
      ]
    },
    column: {
      type: "column",
      props: { spacing: 6, crossAxisAlignment: "start" },
      styles: { margin: [4, 16, 4, 16] },
      children: [
        { type: "text", props: { text: "Primary Heading", fontSize: 16, fontWeight: "bold", color: "#FFFFFF" } },
        { type: "text", props: { text: "Secondary supporting description text", fontSize: 12, color: "#94A3B8" } }
      ]
    },
    stack: {
      type: "stack",
      props: { alignment: "bottomLeft" },
      styles: { borderRadius: 12, margin: [8, 16, 8, 16] },
      children: [
        { type: "image", props: { url: "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600&q=80", height: 140, fit: "cover", borderRadius: 12 } },
        { type: "badge", props: { position: { top: 8, right: 8 }, text: "HOT", backgroundColor: "#EF4444", textColor: "#FFFFFF" }, styles: { borderRadius: 6 } }
      ]
    },
    text: {
      type: "text",
      props: { text: "Custom SDUI Headline", fontSize: 16, fontWeight: "700", color: "#FFFFFF" },
      styles: { margin: [4, 16, 4, 16] }
    },
    badge: {
      type: "badge",
      props: { text: "★ 4.8 Rating", icon: "star", backgroundColor: "#0B6B38", textColor: "#FFFFFF", fontSize: 12, fontWeight: "bold" },
      styles: { borderRadius: 10, margin: [4, 16, 4, 16] }
    },
    divider: {
      type: "divider",
      props: { dashed: true, thickness: 1, color: "#475569" },
      styles: { margin: [6, 16, 6, 16] }
    },
    search_bar: {
      type: 'search_bar',
      props: {
        placeholder: 'Search 10,000+ items, services & offers...',
        showFilter: true
      },
      action: { type: 'toast', payload: { message: 'Search filter tapped' } },
      styles: { margin: [12, 16, 8, 16] }
    },
    banner: {
      type: 'banner',
      props: {
        badge: '⚡ LIMITED TIME OFFER',
        title: 'Weekend Flash Super Sale',
        subtitle: 'Up to 50% discount on all wireless electronics and audio gear today.',
        imageUrl: 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800&q=80',
        ctaText: 'Claim 50% OFF'
      },
      action: {
        type: 'dialog',
        payload: {
          title: 'Promo Claimed 🎉',
          message: 'Coupon code FLASH50 applied to your cart.'
        }
      },
      styles: {
        backgroundColor: '#4F46E5',
        textColor: '#FFFFFF',
        borderRadius: 16,
        margin: [8, 16, 12, 16]
      }
    },
    category_chips: {
      type: 'category_chips',
      props: {
        selectedIndex: 0,
        items: ['🔥 All Deals', '💻 Electronics', '🛠️ Services', '👟 Fashion', '🛋️ Home']
      },
      action: { type: 'toast', payload: { message: 'Category selected' } },
      styles: { margin: [4, 16, 12, 16] }
    },
    section_title: {
      type: 'section_title',
      props: {
        title: 'Popular Services',
        subtitle: 'Book certified professionals in 1 click',
        actionText: 'View All'
      },
      action: { type: 'toast', payload: { message: 'Opening all services...' } },
      styles: { margin: [8, 16, 8, 16] }
    },
    service_grid: {
      type: 'service_grid',
      props: {
        columns: 4,
        items: [
          { title: 'Repairs', icon: 'build', badge: 'Top', action: { type: 'toast', payload: { message: 'Repairs chosen' } } },
          { title: 'Cleaning', icon: 'cleaning_services', badge: '20% OFF', action: { type: 'toast', payload: { message: 'Cleaning chosen' } } },
          { title: 'Plumbing', icon: 'plumbing', badge: null, action: { type: 'toast', payload: { message: 'Plumbing chosen' } } },
          { title: 'Electric', icon: 'bolt', badge: 'Fast', action: { type: 'toast', payload: { message: 'Electric chosen' } } }
        ]
      },
      styles: { margin: [0, 16, 12, 16] }
    },
    promo_card: {
      type: 'promo_card',
      props: {
        title: 'Community Voucher',
        discount: 'FLAT $25 OFF',
        code: 'SDUI25',
        description: 'Valid on orders over $50. Tap copy code to apply instantly.',
        expires: 'Valid until Midnight'
      },
      action: {
        type: 'copy_code',
        payload: { code: 'SDUI25', message: "Coupon code 'SDUI25' copied to clipboard!" }
      },
      styles: {
        backgroundColor: '#059669',
        textColor: '#FFFFFF',
        margin: [4, 16, 16, 16]
      }
    },
    product_card: {
      type: 'product_card',
      props: {
        title: 'Studio ANC Wireless Pro Headphones',
        description: 'Noise cancellation, 45h battery life, spatial audio.',
        price: '$129.99',
        originalPrice: '$219.00',
        rating: '4.9 ★',
        reviews: '(1,450)',
        tag: 'TOP SELLER',
        imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=700&q=80'
      },
      action: {
        type: 'dialog',
        payload: {
          title: 'Added to Cart 🛒',
          message: 'Studio ANC Headphones added to your cart!'
        }
      },
      styles: { margin: [0, 16, 16, 16] }
    },
    carousel: {
      type: 'carousel',
      props: {
        items: [
          { title: 'Smart Home', subtitle: 'Automate living', imageUrl: 'https://images.unsplash.com/photo-1558002038-1055907df827?w=600&q=80', tag: 'NEW' },
          { title: 'Studio Audio', subtitle: 'Acoustic fidelity', imageUrl: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=600&q=80', tag: 'TRENDING' },
          { title: 'Fitness Gear', subtitle: 'Heart rate tracking', imageUrl: 'https://images.unsplash.com/photo-1510519138161-58474ebf8463?w=600&q=80', tag: 'HOT' }
        ]
      },
      styles: { margin: [0, 0, 16, 0] }
    },
    button_action: {
      type: 'button_action',
      props: {
        text: 'Explore Complete Directory ➔',
        variant: 'primary'
      },
      action: { type: 'toast', payload: { message: 'Navigating to full directory...' } },
      styles: {
        backgroundColor: '#6366F1',
        textColor: '#FFFFFF',
        margin: [0, 16, 24, 16]
      }
    },
    spacer: {
      type: 'spacer',
      props: { height: 16 }
    }
  };

  // DOM Elements
  const rawJsonTextarea = document.getElementById('rawJsonTextarea');
  const jsonValidationTag = document.getElementById('jsonValidationTag');
  const jsonErrorFooter = document.getElementById('jsonErrorFooter');
  const componentCanvas = document.getElementById('componentCanvas');
  const componentCountBadge = document.getElementById('componentCountBadge');
  const phoneContent = document.getElementById('phoneContent');
  const previewAppTitle = document.getElementById('previewAppTitle');
  const serverStatusPill = document.getElementById('serverStatusPill');
  const serverStatusText = document.getElementById('serverStatusText');
  const screenSelect = document.getElementById('screenSelect');
  const toastContainer = document.getElementById('toastContainer');
  const dropZone = document.getElementById('dropZone');
  const fileInput = document.getElementById('fileInput');

  // Inspector Elements
  const inspectorBackdrop = document.getElementById('inspectorBackdrop');
  const inspectorTitle = document.getElementById('inspectorTitle');
  const inspectorTypeBadge = document.getElementById('inspectorTypeBadge');
  const inspectorFormContent = document.getElementById('inspectorFormContent');
  const btnCloseInspector = document.getElementById('btnCloseInspector');
  const btnSaveInspector = document.getElementById('btnSaveInspector');
  const btnDeleteFromInspector = document.getElementById('btnDeleteFromInspector');

  // Settings Elements
  const settingsBackdrop = document.getElementById('settingsBackdrop');
  const btnSettings = document.getElementById('btnSettings');
  const btnCloseSettings = document.getElementById('btnCloseSettings');
  const serverUrlInput = document.getElementById('serverUrlInput');
  const btnTestConnection = document.getElementById('btnTestConnection');
  const testConnectionResult = document.getElementById('testConnectionResult');
  const btnSaveSettings = document.getElementById('btnSaveSettings');
  const detectedIpsList = document.getElementById('detectedIpsList');
  const apkDownloadLink = document.getElementById('apkDownloadLink');
  const btnDirectDownloadLink = document.getElementById('btnDirectDownloadLink');
  const btnDownloadApk = document.getElementById('btnDownloadApk');

  // Action Simulator Elements
  const actionModalBackdrop = document.getElementById('actionModalBackdrop');
  const actionModalTitle = document.getElementById('actionModalTitle');
  const actionModalMessage = document.getElementById('actionModalMessage');
  const btnCloseActionModal = document.getElementById('btnCloseActionModal');

  // Mode Tabs
  const mainLayout = document.getElementById('mainLayout');
  const tabModeSplit = document.getElementById('tabModeSplit');
  const tabModeVisual = document.getElementById('tabModeVisual');
  const tabModeJson = document.getElementById('tabModeJson');

  // Initialize
  function init() {
    updateClock();
    setInterval(updateClock, 30000);

    setupEventListeners();
    checkBackendHealth();
    fetchScreenSchema(currentScreenId);
  }

  function updateClock() {
    const now = new Date();
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const el = document.getElementById('deviceTime');
    if (el) el.textContent = `${hours}:${minutes}`;
  }

  // ========================================================
  // Unified Bi-directional Sync
  // ========================================================

  /**
   * Mode B -> Mode A (Visual to JSON)
   */
  function syncVisualToJson() {
    if (isUpdatingInternally) return;
    isUpdatingInternally = true;

    try {
      currentSchema.updatedAt = new Date().toISOString();
      const formatted = JSON.stringify(currentSchema, null, 2);
      rawJsonTextarea.value = formatted;

      jsonValidationTag.textContent = 'Valid JSON';
      jsonValidationTag.className = 'validation-tag valid';
      jsonErrorFooter.classList.add('hidden');

      renderLivePhonePreview();
    } finally {
      isUpdatingInternally = false;
    }
  }

  /**
   * Mode A -> Mode B (JSON to Visual)
   */
  function syncJsonToVisual() {
    if (isUpdatingInternally) return;
    isUpdatingInternally = true;

    try {
      const text = rawJsonTextarea.value.trim();
      if (!text) {
        throw new Error('Schema is empty');
      }

      const parsed = JSON.parse(text);
      if (!Array.isArray(parsed.components)) {
        throw new Error("JSON schema must contain a 'components' array.");
      }

      currentSchema = parsed;
      jsonValidationTag.textContent = 'Valid JSON';
      jsonValidationTag.className = 'validation-tag valid';
      jsonErrorFooter.classList.add('hidden');

      renderVisualComponentCanvas();
      renderLivePhonePreview();
    } catch (err) {
      jsonValidationTag.textContent = 'Invalid JSON';
      jsonValidationTag.className = 'validation-tag invalid';
      jsonErrorFooter.textContent = `Syntax Error: ${err.message}`;
      jsonErrorFooter.classList.remove('hidden');
    } finally {
      isUpdatingInternally = false;
    }
  }

  // ========================================================
  // Mode B: Visual Canvas Rendering
  // ========================================================
  function renderVisualComponentCanvas() {
    componentCanvas.innerHTML = '';
    const comps = currentSchema.components || [];
    componentCountBadge.textContent = `${comps.length} component${comps.length === 1 ? '' : 's'}`;

    if (comps.length === 0) {
      componentCanvas.innerHTML = `
        <div style="text-align:center; padding: 40px 20px; color: var(--text-dim); border: 2px dashed rgba(255,255,255,0.06); border-radius: 12px;">
          <p style="font-size: 1.1rem; margin-bottom: 8px;">No components yet</p>
          <p style="font-size: 0.8rem;">Click on any widget from the library palette above to add it to your screen layout.</p>
        </div>
      `;
      return;
    }

    comps.forEach((comp, index) => {
      const card = createComponentCard(comp, index, comps.length);
      componentCanvas.appendChild(card);
    });
  }

  function getComponentIcon(type) {
    const icons = {
      card_le_smash: '🍽️',
      card_grocery_icecream: '🍦',
      container: '◫',
      row: '↔',
      column: '↕',
      stack: '⧉',
      image: '🖼️',
      text: '𝐓',
      badge: '🏷️',
      icon: '⭐',
      divider: '┄',
      button: '🔘',
      search_bar: '🔍',
      banner: '🖼️',
      category_chips: '🏷️',
      section_title: '📑',
      service_grid: '⚡',
      promo_card: '🎟️',
      product_card: '🛍️',
      carousel: '🎠',
      button_action: '🔘',
      spacer: '↕️'
    };
    return icons[type] || '📦';
  }

  function createComponentCard(comp, index, total) {
    const card = document.createElement('div');
    card.className = 'component-card';
    card.dataset.index = index;
    card.draggable = true;

    const icon = getComponentIcon(comp.type);
    let titlePreview = comp.props?.title || comp.props?.placeholder || comp.props?.text || `${comp.type} component`;
    let subPreview = comp.props?.subtitle || comp.props?.description || (comp.props?.items ? `${comp.props.items.length} items` : (comp.props?.height ? `Height: ${comp.props.height}px` : ''));

    card.innerHTML = `
      <div class="card-top">
        <div class="card-left-info">
          <span class="drag-handle" title="Drag to reorder">☰</span>
          <span class="component-type-tag">${icon} ${comp.type}</span>
          <span class="component-id-label">${comp.id || 'comp_' + index}</span>
        </div>
        <div class="card-reorder-actions">
          <button class="btn-arrow btn-move-up" title="Move Up" ${index === 0 ? 'disabled style="opacity:0.3;"' : ''}>▲</button>
          <button class="btn-arrow btn-move-down" title="Move Down" ${index === total - 1 ? 'disabled style="opacity:0.3;"' : ''}>▼</button>
        </div>
      </div>
      <div class="card-body-preview">
        <div class="card-summary">
          <span class="card-title-preview">${escapeHtml(titlePreview)}</span>
          ${subPreview ? `<span class="card-desc-preview">${escapeHtml(subPreview)}</span>` : ''}
          <div class="card-badges">
            ${comp.action ? `<span class="card-badge">Action: ${comp.action.type}</span>` : ''}
            ${comp.props?.badge ? `<span class="card-badge">${escapeHtml(comp.props.badge)}</span>` : ''}
            ${comp.children && comp.children.length > 0 ? `<span class="nested-count-pill">${comp.children.length} nested item${comp.children.length === 1 ? '' : 's'}</span>` : ''}
          </div>
        </div>
        <div class="card-toolbar">
          <button class="btn btn-sm btn-outline btn-edit-props">Edit</button>
          <button class="btn btn-sm btn-outline btn-duplicate-comp" title="Duplicate">Copy</button>
          <button class="btn btn-sm btn-danger-outline btn-delete-comp" title="Delete">✕</button>
        </div>
      </div>
    `;

    // Event Listeners for Card
    const btnUp = card.querySelector('.btn-move-up');
    const btnDown = card.querySelector('.btn-move-down');
    const btnEdit = card.querySelector('.btn-edit-props');
    const btnDuplicate = card.querySelector('.btn-duplicate-comp');
    const btnDelete = card.querySelector('.btn-delete-comp');

    btnUp.addEventListener('click', (e) => {
      e.stopPropagation();
      moveComponent(index, -1);
    });

    btnDown.addEventListener('click', (e) => {
      e.stopPropagation();
      moveComponent(index, 1);
    });

    btnEdit.addEventListener('click', (e) => {
      e.stopPropagation();
      openPropertyInspector(index);
    });

    card.addEventListener('click', () => {
      openPropertyInspector(index);
    });

    btnDuplicate.addEventListener('click', (e) => {
      e.stopPropagation();
      duplicateComponent(index);
    });

    btnDelete.addEventListener('click', (e) => {
      e.stopPropagation();
      deleteComponent(index);
    });

    // Drag and Drop
    card.addEventListener('dragstart', (e) => {
      e.dataTransfer.setData('text/plain', index);
      card.style.opacity = '0.5';
    });

    card.addEventListener('dragend', () => {
      card.style.opacity = '1';
    });

    card.addEventListener('dragover', (e) => {
      e.preventDefault();
      card.style.borderTop = '2px solid var(--primary)';
    });

    card.addEventListener('dragleave', () => {
      card.style.borderTop = '';
    });

    card.addEventListener('drop', (e) => {
      e.preventDefault();
      card.style.borderTop = '';
      const sourceIndex = parseInt(e.dataTransfer.getData('text/plain'), 10);
      const targetIndex = index;
      if (!isNaN(sourceIndex) && sourceIndex !== targetIndex) {
        reorderComponent(sourceIndex, targetIndex);
      }
    });

    return card;
  }

  function moveComponent(index, direction) {
    const target = index + direction;
    if (target < 0 || target >= currentSchema.components.length) return;
    reorderComponent(index, target);
  }

  function reorderComponent(fromIndex, toIndex) {
    const item = currentSchema.components.splice(fromIndex, 1)[0];
    currentSchema.components.splice(toIndex, 0, item);
    renderVisualComponentCanvas();
    syncVisualToJson();
    showToast(`Moved ${item.type} to position ${toIndex + 1}`, 'success');
  }

  function addComponentByType(type) {
    const template = COMPONENT_TEMPLATES[type] || {
      type: type,
      props: { title: `New ${type}` },
      styles: { margin: [8, 16, 8, 16] }
    };

    // Deep clone template
    const newComp = JSON.parse(JSON.stringify(template));
    newComp.id = `comp_${type}_${Date.now().toString().slice(-4)}`;

    currentSchema.components.push(newComp);
    renderVisualComponentCanvas();
    syncVisualToJson();
    showToast(`Added widget: ${type}`, 'success');

    // Scroll canvas to bottom
    const scrollContainer = document.querySelector('.canvas-scrollable');
    if (scrollContainer) {
      setTimeout(() => {
        scrollContainer.scrollTop = scrollContainer.scrollHeight;
      }, 50);
    }
  }

  function duplicateComponent(index) {
    const original = currentSchema.components[index];
    const clone = JSON.parse(JSON.stringify(original));
    clone.id = `comp_${clone.type}_${Date.now().toString().slice(-4)}`;
    if (clone.props?.title) {
      clone.props.title += ' (Copy)';
    }

    currentSchema.components.splice(index + 1, 0, clone);
    renderVisualComponentCanvas();
    syncVisualToJson();
    showToast(`Duplicated ${original.type}`, 'success');
  }

  function deleteComponent(index) {
    const removed = currentSchema.components.splice(index, 1)[0];
    renderVisualComponentCanvas();
    syncVisualToJson();
    showToast(`Removed ${removed.type}`, 'success');
  }

  // ========================================================
  // Property Inspector Form Generator
  // ========================================================
  function openPropertyInspector(index) {
    activeEditingIndex = index;
    const comp = currentSchema.components[index];
    if (!comp) return;

    // Highlight card in canvas
    document.querySelectorAll('.component-card').forEach((c, i) => {
      c.classList.toggle('selected', i === index);
    });

    inspectorTitle.textContent = `Edit ${comp.type}`;
    inspectorTypeBadge.textContent = `${getComponentIcon(comp.type)} ${comp.type}`;

    renderInspectorForm(comp);
    inspectorBackdrop.classList.remove('hidden');
  }

  function closePropertyInspector() {
    inspectorBackdrop.classList.add('hidden');
    activeEditingIndex = -1;
    document.querySelectorAll('.component-card').forEach(c => c.classList.remove('selected'));
  }

  function renderInspectorForm(comp) {
    inspectorFormContent.innerHTML = '';
    comp.props = comp.props || {};
    comp.styles = comp.styles || {};

    let html = `
      <div class="form-group">
        <label>Component ID:</label>
        <input type="text" class="form-input" id="propCompId" value="${escapeHtml(comp.id || '')}" />
      </div>
    `;

    // Specific Fields based on Component Type
    switch (comp.type) {
      case 'banner':
        html += `
          <div class="form-group">
            <label>Badge Tag:</label>
            <input type="text" class="form-input" id="propBadge" value="${escapeHtml(comp.props.badge || '')}" placeholder="e.g. ⚡ LIMITED TIME" />
          </div>
          <div class="form-group">
            <label>Title:</label>
            <input type="text" class="form-input" id="propTitle" value="${escapeHtml(comp.props.title || '')}" />
          </div>
          <div class="form-group">
            <label>Subtitle / Description:</label>
            <textarea class="form-textarea" rows="2" id="propSubtitle">${escapeHtml(comp.props.subtitle || '')}</textarea>
          </div>
          <div class="form-group">
            <label>Background Image URL:</label>
            <input type="text" class="form-input" id="propImageUrl" value="${escapeHtml(comp.props.imageUrl || '')}" />
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>CTA Button Text:</label>
              <input type="text" class="form-input" id="propCtaText" value="${escapeHtml(comp.props.ctaText || '')}" />
            </div>
            <div class="form-group">
              <label>Border Radius (px):</label>
              <input type="number" class="form-input" id="propBorderRadius" value="${comp.styles.borderRadius || 16}" />
            </div>
          </div>
        `;
        break;

      case 'section_title':
        html += `
          <div class="form-group">
            <label>Section Title:</label>
            <input type="text" class="form-input" id="propTitle" value="${escapeHtml(comp.props.title || '')}" />
          </div>
          <div class="form-group">
            <label>Subtitle:</label>
            <input type="text" class="form-input" id="propSubtitle" value="${escapeHtml(comp.props.subtitle || '')}" />
          </div>
          <div class="form-group">
            <label>Action Text (Right Link):</label>
            <input type="text" class="form-input" id="propActionText" value="${escapeHtml(comp.props.actionText || '')}" placeholder="e.g. View All" />
          </div>
        `;
        break;

      case 'promo_card':
        html += `
          <div class="form-group">
            <label>Promo Title:</label>
            <input type="text" class="form-input" id="propTitle" value="${escapeHtml(comp.props.title || '')}" />
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Discount Badge:</label>
              <input type="text" class="form-input" id="propDiscount" value="${escapeHtml(comp.props.discount || '')}" placeholder="FLAT $25 OFF" />
            </div>
            <div class="form-group">
              <label>Coupon Code:</label>
              <input type="text" class="form-input" id="propCode" value="${escapeHtml(comp.props.code || '')}" placeholder="SDUI25" />
            </div>
          </div>
          <div class="form-group">
            <label>Description:</label>
            <textarea class="form-textarea" rows="2" id="propDescription">${escapeHtml(comp.props.description || '')}</textarea>
          </div>
          <div class="form-group">
            <label>Expires Text:</label>
            <input type="text" class="form-input" id="propExpires" value="${escapeHtml(comp.props.expires || '')}" />
          </div>
        `;
        break;

      case 'product_card':
        html += `
          <div class="form-group">
            <label>Product Title:</label>
            <input type="text" class="form-input" id="propTitle" value="${escapeHtml(comp.props.title || '')}" />
          </div>
          <div class="form-group">
            <label>Description:</label>
            <textarea class="form-textarea" rows="2" id="propDescription">${escapeHtml(comp.props.description || '')}</textarea>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Current Price:</label>
              <input type="text" class="form-input" id="propPrice" value="${escapeHtml(comp.props.price || '')}" placeholder="$129.99" />
            </div>
            <div class="form-group">
              <label>Original Price (strikethrough):</label>
              <input type="text" class="form-input" id="propOriginalPrice" value="${escapeHtml(comp.props.originalPrice || '')}" placeholder="$219.00" />
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Rating:</label>
              <input type="text" class="form-input" id="propRating" value="${escapeHtml(comp.props.rating || '')}" placeholder="4.9 ★" />
            </div>
            <div class="form-group">
              <label>Badge Tag:</label>
              <input type="text" class="form-input" id="propTag" value="${escapeHtml(comp.props.tag || '')}" placeholder="TOP SELLER" />
            </div>
          </div>
          <div class="form-group">
            <label>Product Image URL:</label>
            <input type="text" class="form-input" id="propImageUrl" value="${escapeHtml(comp.props.imageUrl || '')}" />
          </div>
        `;
        break;

      case 'search_bar':
        html += `
          <div class="form-group">
            <label>Placeholder Text:</label>
            <input type="text" class="form-input" id="propPlaceholder" value="${escapeHtml(comp.props.placeholder || '')}" />
          </div>
          <div class="form-group">
            <label>
              <input type="checkbox" id="propShowFilter" ${comp.props.showFilter ? 'checked' : ''} />
              Show Filter Action Button
            </label>
          </div>
        `;
        break;

      case 'category_chips':
        html += `
          <div class="form-group">
            <label>Category Chips (Comma separated):</label>
            <textarea class="form-textarea" rows="3" id="propChipsList">${(comp.props.items || []).join(', ')}</textarea>
            <small class="form-hint">Separate items with commas. E.g. 🔥 All Deals, 💻 Electronics, 👟 Fashion</small>
          </div>
        `;
        break;

      case 'service_grid':
        html += `
          <div class="form-group">
            <label>Grid Columns:</label>
            <select class="form-select" id="propColumns">
              <option value="2" ${comp.props.columns === 2 ? 'selected' : ''}>2 Columns</option>
              <option value="3" ${comp.props.columns === 3 ? 'selected' : ''}>3 Columns</option>
              <option value="4" ${comp.props.columns === 4 ? 'selected' : ''}>4 Columns</option>
            </select>
          </div>
          <div class="form-group">
            <label>Service Items (JSON Array):</label>
            <textarea class="form-textarea" rows="6" id="propGridItems" style="font-family: var(--font-mono); font-size: 0.75rem;">${escapeHtml(JSON.stringify(comp.props.items || [], null, 2))}</textarea>
            <small class="form-hint">Each object can have title, icon, badge, and action.</small>
          </div>
        `;
        break;

      case 'carousel':
        html += `
          <div class="form-group">
            <label>Carousel Slides (JSON Array):</label>
            <textarea class="form-textarea" rows="6" id="propCarouselItems" style="font-family: var(--font-mono); font-size: 0.75rem;">${escapeHtml(JSON.stringify(comp.props.items || [], null, 2))}</textarea>
          </div>
        `;
        break;

      case 'button_action':
        html += `
          <div class="form-group">
            <label>Button Label Text:</label>
            <input type="text" class="form-input" id="propBtnText" value="${escapeHtml(comp.props.text || '')}" />
          </div>
          <div class="form-group">
            <label>Button Variant:</label>
            <select class="form-select" id="propBtnVariant">
              <option value="primary" ${comp.props.variant === 'primary' ? 'selected' : ''}>Primary (Solid Gradient)</option>
              <option value="secondary" ${comp.props.variant === 'secondary' ? 'selected' : ''}>Secondary</option>
              <option value="outline" ${comp.props.variant === 'outline' ? 'selected' : ''}>Outline</option>
            </select>
          </div>
        `;
        break;

      case 'spacer':
        html += `
          <div class="form-group">
            <label>Height (px):</label>
            <input type="number" class="form-input" id="propHeight" value="${comp.props.height || 16}" />
          </div>
        `;
        break;

      default:
        html += `
          <div class="form-group">
            <label>Raw Props JSON:</label>
            <textarea class="form-textarea" rows="6" id="propRawProps" style="font-family:var(--font-mono);">${escapeHtml(JSON.stringify(comp.props || {}, null, 2))}</textarea>
          </div>
        `;
        break;
    }

    // Styling & Colors Section
    html += `
      <hr class="modal-divider" />
      <h4 style="font-size:0.82rem; margin-bottom:8px;">Appearance & Action Controls</h4>
      <div class="form-group">
        <label>Background Color:</label>
        <div class="color-picker-row">
          <input type="color" class="color-input" id="propBgColorPicker" value="${comp.styles?.backgroundColor || '#4F46E5'}" />
          <input type="text" class="form-input" id="propBgColorHex" value="${comp.styles?.backgroundColor || '#4F46E5'}" style="width: 100px;" />
          <div class="color-presets">
            <span class="color-preset-pill" style="background:#4F46E5;" data-color="#4F46E5"></span>
            <span class="color-preset-pill" style="background:#059669;" data-color="#059669"></span>
            <span class="color-preset-pill" style="background:#BE185D;" data-color="#BE185D"></span>
            <span class="color-preset-pill" style="background:#D97706;" data-color="#D97706"></span>
            <span class="color-preset-pill" style="background:#0F172A;" data-color="#0F172A"></span>
          </div>
        </div>
      </div>

      <div class="form-group">
        <label>Action Type:</label>
        <select class="form-select" id="propActionType">
          <option value="none" ${!comp.action ? 'selected' : ''}>None</option>
          <option value="toast" ${comp.action?.type === 'toast' ? 'selected' : ''}>Toast Notification</option>
          <option value="dialog" ${comp.action?.type === 'dialog' ? 'selected' : ''}>Alert Dialog Modal</option>
          <option value="copy_code" ${comp.action?.type === 'copy_code' ? 'selected' : ''}>Copy Coupon Code</option>
          <option value="navigate" ${comp.action?.type === 'navigate' ? 'selected' : ''}>Navigate Screen</option>
        </select>
      </div>

      <div class="form-group" id="actionPayloadGroup">
        <label>Action Message / Payload:</label>
        <input type="text" class="form-input" id="propActionMessage" value="${escapeHtml(comp.action?.payload?.message || comp.action?.payload?.code || '')}" placeholder="Message shown on tap" />
      </div>
    `;

    inspectorFormContent.innerHTML = html;

    // Attach color preset events
    document.querySelectorAll('.color-preset-pill').forEach(pill => {
      pill.addEventListener('click', () => {
        const hex = pill.dataset.color;
        const colorPicker = document.getElementById('propBgColorPicker');
        const colorHex = document.getElementById('propBgColorHex');
        if (colorPicker) colorPicker.value = hex;
        if (colorHex) colorHex.value = hex;
        applyInspectorChangesToState();
      });
    });

    const colorPicker = document.getElementById('propBgColorPicker');
    const colorHex = document.getElementById('propBgColorHex');
    if (colorPicker && colorHex) {
      colorPicker.addEventListener('input', () => {
        colorHex.value = colorPicker.value;
        applyInspectorChangesToState();
      });
      colorHex.addEventListener('input', () => {
        if (/^#[0-9A-Fa-f]{6}$/.test(colorHex.value)) {
          colorPicker.value = colorHex.value;
        }
        applyInspectorChangesToState();
      });
    }

    // Real-time live update while typing in form
    inspectorFormContent.querySelectorAll('input, textarea, select').forEach(input => {
      input.addEventListener('input', applyInspectorChangesToState);
    });
  }

  function applyInspectorChangesToState() {
    if (activeEditingIndex < 0) return;
    const comp = currentSchema.components[activeEditingIndex];
    if (!comp) return;

    // Save ID
    const idInput = document.getElementById('propCompId');
    if (idInput && idInput.value.trim()) comp.id = idInput.value.trim();

    // Specific component props
    const title = document.getElementById('propTitle');
    if (title) comp.props.title = title.value;

    const subtitle = document.getElementById('propSubtitle');
    if (subtitle) comp.props.subtitle = subtitle.value;

    const badge = document.getElementById('propBadge');
    if (badge) comp.props.badge = badge.value;

    const imageUrl = document.getElementById('propImageUrl');
    if (imageUrl) comp.props.imageUrl = imageUrl.value;

    const ctaText = document.getElementById('propCtaText');
    if (ctaText) comp.props.ctaText = ctaText.value;

    const actionText = document.getElementById('propActionText');
    if (actionText) comp.props.actionText = actionText.value;

    const discount = document.getElementById('propDiscount');
    if (discount) comp.props.discount = discount.value;

    const code = document.getElementById('propCode');
    if (code) comp.props.code = code.value;

    const description = document.getElementById('propDescription');
    if (description) comp.props.description = description.value;

    const expires = document.getElementById('propExpires');
    if (expires) comp.props.expires = expires.value;

    const price = document.getElementById('propPrice');
    if (price) comp.props.price = price.value;

    const origPrice = document.getElementById('propOriginalPrice');
    if (origPrice) comp.props.originalPrice = origPrice.value;

    const rating = document.getElementById('propRating');
    if (rating) comp.props.rating = rating.value;

    const tag = document.getElementById('propTag');
    if (tag) comp.props.tag = tag.value;

    const placeholder = document.getElementById('propPlaceholder');
    if (placeholder) comp.props.placeholder = placeholder.value;

    const showFilter = document.getElementById('propShowFilter');
    if (showFilter) comp.props.showFilter = showFilter.checked;

    const btnText = document.getElementById('propBtnText');
    if (btnText) comp.props.text = btnText.value;

    const btnVariant = document.getElementById('propBtnVariant');
    if (btnVariant) comp.props.variant = btnVariant.value;

    const height = document.getElementById('propHeight');
    if (height) comp.props.height = parseInt(height.value, 10) || 16;

    // Chips
    const chipsList = document.getElementById('propChipsList');
    if (chipsList) {
      comp.props.items = chipsList.value.split(',').map(s => s.trim()).filter(Boolean);
    }

    // Grid items
    const gridItems = document.getElementById('propGridItems');
    if (gridItems) {
      try {
        comp.props.items = JSON.parse(gridItems.value);
      } catch (e) {}
    }

    // Carousel items
    const carouselItems = document.getElementById('propCarouselItems');
    if (carouselItems) {
      try {
        comp.props.items = JSON.parse(carouselItems.value);
      } catch (e) {}
    }

    // Colors & Styles
    const bgHex = document.getElementById('propBgColorHex');
    if (bgHex) comp.styles.backgroundColor = bgHex.value;

    const borderRadius = document.getElementById('propBorderRadius');
    if (borderRadius) comp.styles.borderRadius = parseInt(borderRadius.value, 10) || 16;

    // Action
    const actionType = document.getElementById('propActionType');
    const actionMsg = document.getElementById('propActionMessage');
    if (actionType && actionType.value !== 'none') {
      comp.action = {
        type: actionType.value,
        payload: {
          message: actionMsg ? actionMsg.value : '',
          code: comp.props.code || (actionMsg ? actionMsg.value : '')
        }
      };
    } else if (actionType && actionType.value === 'none') {
      delete comp.action;
    }

    // Update canvas title preview & sync to Mode A
    renderVisualComponentCanvas();
    syncVisualToJson();
  }

  // ========================================================
  // Mode C: Live Phone Simulator Rendering
  // ========================================================
  function renderLivePhonePreview() {
    phoneContent.innerHTML = '';
    previewAppTitle.textContent = currentSchema.title || 'SDUI Store';

    if (currentSchema.theme?.backgroundColor) {
      phoneContent.style.backgroundColor = currentSchema.theme.backgroundColor;
    }

    const comps = currentSchema.components || [];
    comps.forEach((comp, idx) => {
      const el = createSimulatedWidgetElement(comp, idx);
      if (el) phoneContent.appendChild(el);
    });
  }

  function createSimulatedWidgetElement(comp, index) {
    if (!comp) return null;
    const div = document.createElement('div');
    const props = comp.props || {};
    const styles = comp.styles || {};

    switch (comp.type) {
      // Approach 1 Atomic Primitives
      case 'container':
      case 'card': {
        div.className = 'sim-container';
        if (styles.backgroundColor) div.style.backgroundColor = styles.backgroundColor;
        if (styles.borderRadius) div.style.borderRadius = `${styles.borderRadius}px`;
        if (styles.borderColor) {
          div.style.border = `${styles.borderWidth || 1}px solid ${styles.borderColor}`;
        }
        if (styles.width) div.style.width = `${styles.width}px`;
        if (styles.height) div.style.height = `${styles.height}px`;
        if (styles.margin) div.style.margin = formatCssBox(styles.margin);
        if (styles.padding) div.style.padding = formatCssBox(styles.padding);
        if (props.elevation) div.style.boxShadow = '0 4px 14px rgba(0,0,0,0.12)';

        div.style.display = 'flex';
        div.style.flexDirection = props.layout === 'row' ? 'row' : 'column';

        if (comp.children && comp.children.length > 0) {
          comp.children.forEach(child => {
            const childEl = createSimulatedWidgetElement(child);
            if (childEl) div.appendChild(childEl);
          });
        }

        if (comp.action) {
          div.style.cursor = 'pointer';
          div.onclick = (e) => {
            e.stopPropagation();
            triggerSimulatedAction(comp.action, 'Container card tapped');
          };
        }
        break;
      }

      case 'column': {
        div.className = 'sim-column';
        if (props.spacing) div.style.gap = `${props.spacing}px`;
        if (styles.margin) div.style.margin = formatCssBox(styles.margin);
        if (styles.padding) div.style.padding = formatCssBox(styles.padding);

        const crossAlign = { start: 'flex-start', end: 'flex-end', center: 'center', stretch: 'stretch' };
        div.style.alignItems = crossAlign[props.crossAxisAlignment] || 'flex-start';

        if (comp.children && comp.children.length > 0) {
          comp.children.forEach(child => {
            const childEl = createSimulatedWidgetElement(child);
            if (childEl) div.appendChild(childEl);
          });
        }
        break;
      }

      case 'row': {
        div.className = 'sim-row';
        if (props.spacing) div.style.gap = `${props.spacing}px`;
        if (styles.margin) div.style.margin = formatCssBox(styles.margin);
        if (styles.padding) div.style.padding = formatCssBox(styles.padding);

        const crossAlign = { start: 'flex-start', end: 'flex-end', center: 'center', baseline: 'baseline' };
        div.style.alignItems = crossAlign[props.crossAxisAlignment] || 'center';

        const mainAlign = { start: 'flex-start', end: 'flex-end', center: 'center', spaceBetween: 'space-between', spaceAround: 'space-around', spaceEvenly: 'space-evenly' };
        div.style.justifyContent = mainAlign[props.mainAxisAlignment] || 'space-between';

        if (comp.children && comp.children.length > 0) {
          comp.children.forEach(child => {
            const childEl = createSimulatedWidgetElement(child);
            if (childEl) {
              if (child.props?.expanded || child.props?.flex) {
                childEl.style.flex = `${child.props.flex || 1}`;
              }
              div.appendChild(childEl);
            }
          });
        }
        break;
      }

      case 'stack': {
        div.className = 'sim-stack';
        if (styles.borderRadius) div.style.borderRadius = `${styles.borderRadius}px`;
        if (styles.margin) div.style.margin = formatCssBox(styles.margin);

        if (comp.children && comp.children.length > 0) {
          comp.children.forEach(child => {
            const childEl = createSimulatedWidgetElement(child);
            if (childEl) {
              const pos = child.props?.position;
              if (pos) {
                childEl.style.position = 'absolute';
                if (pos.top !== undefined) childEl.style.top = `${pos.top}px`;
                if (pos.bottom !== undefined) childEl.style.bottom = `${pos.bottom}px`;
                if (pos.left !== undefined) childEl.style.left = `${pos.left}px`;
                if (pos.right !== undefined) childEl.style.right = `${pos.right}px`;
                childEl.style.zIndex = '2';
              }
              div.appendChild(childEl);
            }
          });
        }
        break;
      }

      case 'image': {
        div.className = 'sim-image-box';
        const url = props.url || props.imageUrl;
        const widthVal = styles.width || props.width;
        const heightVal = styles.height || props.height || 160;
        div.style.width = widthVal ? `${widthVal}px` : '100%';
        div.style.height = `${heightVal}px`;

        const br = styles.borderRadius || props.borderRadius;
        if (br) div.style.borderRadius = `${br}px`;
        if (styles.margin) div.style.margin = formatCssBox(styles.margin);

        if (url) {
          const img = document.createElement('img');
          img.src = url;
          img.style.width = '100%';
          img.style.height = '100%';
          img.style.objectFit = props.fit || 'cover';
          img.style.display = 'block';
          if (br) img.style.borderRadius = `${br}px`;
          div.appendChild(img);
        }

        if (props.gradientOverlay) {
          const overlay = document.createElement('div');
          overlay.className = 'sim-gradient-overlay';
          const colors = props.gradientOverlay.colors || ['rgba(0,0,0,0)', 'rgba(0,0,0,0.8)'];
          overlay.style.background = `linear-gradient(to bottom, ${colors.join(', ')})`;
          div.appendChild(overlay);
        }

        if (comp.action) {
          div.style.cursor = 'pointer';
          div.onclick = (e) => {
            e.stopPropagation();
            triggerSimulatedAction(comp.action, 'Image tapped');
          };
        }
        break;
      }

      case 'text': {
        div.textContent = props.text || props.content || '';
        div.style.fontSize = `${props.fontSize || 14}px`;
        div.style.fontWeight = props.fontWeight || '400';
        div.style.color = props.color || styles.textColor || '#18181B';
        if (props.decoration === 'lineThrough') div.style.textDecoration = 'line-through';
        if (styles.margin) div.style.margin = formatCssBox(styles.margin);
        if (styles.padding) div.style.padding = formatCssBox(styles.padding);

        if (props.maxLines) {
          div.style.display = '-webkit-box';
          div.style.webkitLineClamp = `${props.maxLines}`;
          div.style.webkitBoxOrient = 'vertical';
          div.style.overflow = 'hidden';
        }

        if (comp.action) {
          div.style.cursor = 'pointer';
          div.onclick = (e) => {
            e.stopPropagation();
            triggerSimulatedAction(comp.action, props.text || 'Text tapped');
          };
        }
        break;
      }

      case 'badge': {
        div.className = 'sim-badge-pill';
        div.style.backgroundColor = styles.backgroundColor || props.backgroundColor || '#10B981';
        div.style.color = styles.textColor || props.textColor || '#FFFFFF';
        div.style.borderRadius = `${styles.borderRadius || props.borderRadius || 12}px`;
        div.style.padding = formatCssBox(styles.padding || props.padding) || '4px 8px';
        div.style.fontSize = `${props.fontSize || 12}px`;
        div.style.fontWeight = props.fontWeight || '700';
        if (styles.margin) div.style.margin = formatCssBox(styles.margin);

        let iconSvg = '';
        if (props.icon === 'star') iconSvg = '★ ';
        else if (props.icon === 'percent') iconSvg = '% ';
        else if (props.icon) iconSvg = '• ';

        div.textContent = `${iconSvg}${props.text || ''}`;

        if (comp.action) {
          div.style.cursor = 'pointer';
          div.onclick = (e) => {
            e.stopPropagation();
            triggerSimulatedAction(comp.action, props.text || 'Badge tapped');
          };
        }
        break;
      }

      case 'icon': {
        const iconName = props.name || 'widgets';
        const iconSize = props.size || 18;
        const iconColor = props.color || styles.textColor || '#2563EB';

        div.style.display = 'inline-flex';
        div.style.alignItems = 'center';
        div.style.justifyContent = 'center';

        if (iconName === 'add' || iconName === 'plus') {
          div.innerHTML = `<svg width="${iconSize}" height="${iconSize}" viewBox="0 0 24 24" fill="none" stroke="${iconColor}" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>`;
        } else if (iconName === 'star') {
          div.innerHTML = `<span style="color:${iconColor}; font-size:${iconSize}px;">★</span>`;
        } else if (iconName === 'percent') {
          div.innerHTML = `<span style="color:${iconColor}; font-size:${iconSize}px; font-weight:800;">%</span>`;
        } else {
          div.innerHTML = `<span style="color:${iconColor}; font-size:${iconSize}px;">•</span>`;
        }

        if (styles.margin) div.style.margin = formatCssBox(styles.margin);
        if (styles.padding) div.style.padding = formatCssBox(styles.padding);

        if (comp.action) {
          div.style.cursor = 'pointer';
          div.onclick = (e) => {
            e.stopPropagation();
            triggerSimulatedAction(comp.action, 'Icon clicked');
          };
        }
        break;
      }

      case 'divider': {
        if (props.dashed) {
          div.className = 'sim-dashed-line';
        } else {
          div.className = 'sim-solid-line';
        }
        div.style.borderColor = props.color || styles.borderColor || '#CBD5E1';
        div.style.borderBottomWidth = `${props.thickness || 1}px`;
        if (styles.margin) div.style.margin = formatCssBox(styles.margin);
        break;
      }

      case 'button': {
        const btn = document.createElement('button');
        btn.textContent = props.text || 'Button';
        btn.style.padding = formatCssBox(styles.padding) || '6px 14px';
        btn.style.borderRadius = `${styles.borderRadius || 8}px`;
        btn.style.cursor = 'pointer';
        btn.style.fontWeight = props.fontWeight || '700';

        if (props.variant === 'outline') {
          btn.style.background = 'transparent';
          btn.style.border = `1.5px solid ${styles.backgroundColor || '#6366F1'}`;
          btn.style.color = styles.backgroundColor || '#6366F1';
        } else {
          btn.style.background = styles.backgroundColor || '#6366F1';
          btn.style.border = 'none';
          btn.style.color = styles.textColor || '#FFFFFF';
        }

        btn.onclick = (e) => {
          e.stopPropagation();
          triggerSimulatedAction(comp.action, props.text || 'Button clicked');
        };
        div.appendChild(btn);
        if (styles.margin) div.style.margin = formatCssBox(styles.margin);
        break;
      }

      case 'search_bar': {
        div.className = 'sim-search-bar';
        div.innerHTML = `
          <div class="sim-search-content">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
            <span>${escapeHtml(props.placeholder || 'Search...')}</span>
          </div>
          ${props.showFilter ? '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="4" y1="21" x2="4" y2="14"></line><line x1="4" y1="10" x2="4" y2="3"></line><line x1="12" y1="21" x2="12" y2="12"></line><line x1="12" y1="8" x2="12" y2="3"></line><line x1="20" y1="21" x2="20" y2="16"></line><line x1="20" y1="12" x2="20" y2="3"></line></svg>' : ''}
        `;
        div.onclick = () => triggerSimulatedAction(comp.action, 'Search Bar Tapped');
        break;
      }

      case 'banner': {
        div.className = 'sim-banner';
        if (styles.backgroundColor) div.style.backgroundColor = styles.backgroundColor;
        if (styles.borderRadius) div.style.borderRadius = `${styles.borderRadius}px`;
        if (props.imageUrl) {
          div.style.backgroundImage = `linear-gradient(rgba(0,0,0,0.4), rgba(0,0,0,0.7)), url('${props.imageUrl}')`;
        }
        div.innerHTML = `
          ${props.badge ? `<span class="sim-banner-badge">${escapeHtml(props.badge)}</span>` : ''}
          <h3 class="sim-banner-title">${escapeHtml(props.title || '')}</h3>
          <p class="sim-banner-sub">${escapeHtml(props.subtitle || '')}</p>
          ${props.ctaText ? `<button class="sim-banner-btn">${escapeHtml(props.ctaText)}</button>` : ''}
        `;
        div.onclick = () => triggerSimulatedAction(comp.action, props.title);
        break;
      }

      case 'category_chips': {
        div.className = 'sim-chips-container';
        const items = props.items || [];
        items.forEach((item, i) => {
          const chip = document.createElement('span');
          chip.className = `sim-chip ${i === (props.selectedIndex || 0) ? 'active' : ''}`;
          chip.textContent = item;
          chip.onclick = (e) => {
            e.stopPropagation();
            div.querySelectorAll('.sim-chip').forEach(c => c.classList.remove('active'));
            chip.classList.add('active');
            props.selectedIndex = i;
            triggerSimulatedAction(comp.action, `Selected: ${item}`);
          };
          div.appendChild(chip);
        });
        break;
      }

      case 'section_title': {
        div.className = 'sim-section-header';
        div.innerHTML = `
          <div>
            <span class="sim-section-title">${escapeHtml(props.title || '')}</span>
            ${props.subtitle ? `<span class="sim-section-sub">${escapeHtml(props.subtitle)}</span>` : ''}
          </div>
          ${props.actionText ? `<span class="sim-section-action">${escapeHtml(props.actionText)}</span>` : ''}
        `;
        div.onclick = () => triggerSimulatedAction(comp.action, props.title);
        break;
      }

      case 'service_grid': {
        div.className = 'sim-grid-4';
        const items = props.items || [];
        items.forEach(item => {
          const gridItem = document.createElement('div');
          gridItem.className = 'sim-grid-item';
          gridItem.innerHTML = `
            ${item.badge ? `<span class="sim-grid-badge">${escapeHtml(item.badge)}</span>` : ''}
            <span class="sim-grid-icon">${getIconEmoji(item.icon)}</span>
            <span class="sim-grid-title">${escapeHtml(item.title || '')}</span>
          `;
          gridItem.onclick = (e) => {
            e.stopPropagation();
            triggerSimulatedAction(item.action || comp.action, item.title);
          };
          div.appendChild(gridItem);
        });
        break;
      }

      case 'promo_card': {
        div.className = 'sim-promo-card';
        if (styles.backgroundColor) div.style.backgroundColor = styles.backgroundColor;
        div.innerHTML = `
          <div class="sim-promo-info">
            <h4>${escapeHtml(props.title || 'Promo')}</h4>
            <p>${escapeHtml(props.discount || '')} ${props.code ? `• Code: <b>${escapeHtml(props.code)}</b>` : ''}</p>
          </div>
          <button class="sim-promo-btn">${props.code ? 'COPY' : 'CLAIM'}</button>
        `;
        div.onclick = () => triggerSimulatedAction(comp.action, props.code ? `Copied code: ${props.code}` : 'Promo Claimed');
        break;
      }

      case 'product_card': {
        div.className = 'sim-product-card';
        div.innerHTML = `
          ${props.imageUrl ? `<img src="${props.imageUrl}" class="sim-product-img" alt="product" />` : ''}
          <div class="sim-product-details">
            <h4 class="sim-product-title">${escapeHtml(props.title || '')}</h4>
            <div class="sim-product-rating">${escapeHtml(props.rating || '')} ${escapeHtml(props.reviews || '')}</div>
            <div class="sim-product-footer">
              <div>
                <span class="sim-product-price">${escapeHtml(props.price || '')}</span>
                ${props.originalPrice ? `<span class="sim-product-oldprice">${escapeHtml(props.originalPrice)}</span>` : ''}
              </div>
              <button class="sim-product-btn">Add to Cart</button>
            </div>
          </div>
        `;
        div.onclick = () => triggerSimulatedAction(comp.action, `Added to cart: ${props.title}`);
        break;
      }

      case 'carousel': {
        div.className = 'sim-carousel-box';
        const items = props.items || [];
        items.forEach(item => {
          const card = document.createElement('div');
          card.className = 'sim-carousel-item';
          if (item.imageUrl) {
            card.style.backgroundImage = `url('${item.imageUrl}')`;
          } else {
            card.style.backgroundColor = '#334155';
          }
          card.innerHTML = `
            <div class="sim-carousel-overlay"></div>
            <span class="sim-carousel-text">${escapeHtml(item.title || '')}</span>
          `;
          card.onclick = (e) => {
            e.stopPropagation();
            triggerSimulatedAction(item.action || comp.action, item.title);
          };
          div.appendChild(card);
        });
        break;
      }

      case 'button_action': {
        div.className = 'sim-btn-action';
        if (styles.backgroundColor) div.style.backgroundColor = styles.backgroundColor;
        div.textContent = props.text || 'Action Button';
        div.onclick = () => triggerSimulatedAction(comp.action, props.text);
        break;
      }

      case 'spacer': {
        div.className = 'sim-spacer';
        div.style.height = `${props.height || 16}px`;
        break;
      }

      default: {
        div.style.padding = '8px 14px';
        div.style.color = '#94A3B8';
        div.style.fontSize = '0.75rem';
        div.textContent = `[Widget: ${comp.type}]`;
      }
    }

    return div;
  }

  function getIconEmoji(name) {
    const map = {
      build: '🔧',
      cleaning_services: '🧹',
      plumbing: '🚰',
      bolt: '⚡',
      star: '⭐',
      shopping_bag: '🛍️',
      local_shipping: '🚚'
    };
    return map[name] || '✨';
  }

  function triggerSimulatedAction(action, fallbackText) {
    if (!action) {
      showToast(fallbackText || 'Widget tapped', 'success');
      return;
    }

    if (action.type === 'toast' || action.type === 'copy_code') {
      const msg = action.payload?.message || action.payload?.code || fallbackText;
      showToast(msg, 'success');
    } else if (action.type === 'dialog') {
      actionModalTitle.textContent = action.payload?.title || 'SDUI Alert Dialog';
      actionModalMessage.textContent = action.payload?.message || fallbackText || 'Action confirmed!';
      actionModalBackdrop.classList.remove('hidden');
    } else {
      showToast(`Action: ${action.type}`, 'success');
    }
  }

  // ========================================================
  // Backend & Networking Operations
  // ========================================================
  async function fetchScreenSchema(screenId) {
    try {
      const res = await fetch(`${backendBaseUrl}/api/v1/screen/${screenId}`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const json = await res.json();
      if (json.success && json.data) {
        currentSchema = json.data;
        rawJsonTextarea.value = JSON.stringify(currentSchema, null, 2);
        renderVisualComponentCanvas();
        renderLivePhonePreview();
        showToast(`Loaded '${screenId}' screen from server`, 'success');
      }
    } catch (err) {
      console.warn('Backend unavailable, using local schema fallback:', err);
      renderVisualComponentCanvas();
      syncVisualToJson();
      setServerStatus(false, 'Local Offline Mode');
    }
  }

  async function publishSchemaToBackend() {
    const btnPublish = document.getElementById('btnPublish');
    const originalText = btnPublish.innerHTML;
    btnPublish.innerHTML = '<span>Publishing...</span>';
    btnPublish.disabled = true;

    try {
      // Validate schema first
      const payload = JSON.parse(rawJsonTextarea.value);
      currentSchema = payload;

      const res = await fetch(`${backendBaseUrl}/api/v1/screen/${currentScreenId}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(currentSchema)
      });

      const result = await res.json();
      if (result.success) {
        showToast(`🚀 UI Schema published! Screen '${currentScreenId}' updated.`, 'success');
        setServerStatus(true);
      } else {
        throw new Error(result.error || 'Publish failed');
      }
    } catch (err) {
      showToast(`Error publishing schema: ${err.message}`, 'error');
      setServerStatus(false);
    } finally {
      btnPublish.innerHTML = originalText;
      btnPublish.disabled = false;
    }
  }

  async function checkBackendHealth() {
    try {
      const res = await fetch(`${backendBaseUrl}/api/v1/status`);
      if (res.ok) {
        const data = await res.json();
        setServerStatus(true, `Live on :${data.port}`);
        updateDetectedIps(data.localIps || []);
      } else {
        setServerStatus(false);
      }
    } catch (e) {
      setServerStatus(false);
    }
  }

  function setServerStatus(online, text) {
    const dot = serverStatusPill.querySelector('.status-dot');
    dot.className = `status-dot ${online ? 'online' : 'offline'}`;
    serverStatusText.textContent = online ? (text || 'Backend Live') : 'Backend Offline';
  }

  function updateDetectedIps(ips) {
    if (!detectedIpsList) return;
    if (ips.length === 0) {
      detectedIpsList.innerHTML = '<code>http://localhost:5000</code>';
      return;
    }

    detectedIpsList.innerHTML = '';
    ips.forEach(ip => {
      const pill = document.createElement('span');
      pill.className = 'ip-pill';
      pill.textContent = `http://${ip}:5000`;
      pill.onclick = () => {
        serverUrlInput.value = `http://${ip}:5000`;
        showToast(`Copied ${pill.textContent} to input`, 'success');
      };
      detectedIpsList.appendChild(pill);
    });

    const firstIp = ips[0] || 'localhost';
    if (apkDownloadLink) {
      apkDownloadLink.textContent = `http://${firstIp}:5000/api/v1/download-apk`;
    }
    if (btnDirectDownloadLink) {
      btnDirectDownloadLink.href = `http://${firstIp}:5000/api/v1/download-apk`;
    }
  }

  // ========================================================
  // Event Listeners Setup
  // ========================================================
  function setupEventListeners() {
    // Mode A: JSON Textarea typing
    rawJsonTextarea.addEventListener('input', () => {
      syncJsonToVisual();
    });

    // Format & Minify Buttons
    document.getElementById('btnFormatJson').addEventListener('click', () => {
      try {
        const parsed = JSON.parse(rawJsonTextarea.value);
        rawJsonTextarea.value = JSON.stringify(parsed, null, 2);
        showToast('JSON formatted cleanly', 'success');
      } catch (e) {
        showToast('Cannot format invalid JSON', 'error');
      }
    });

    document.getElementById('btnCopyJson').addEventListener('click', () => {
      navigator.clipboard.writeText(rawJsonTextarea.value).then(() => {
        showToast('JSON schema copied to clipboard', 'success');
      });
    });

    // Reset Screen
    document.getElementById('btnResetScreen').addEventListener('click', async () => {
      if (confirm('Reset all screens to default templates?')) {
        try {
          const res = await fetch(`${backendBaseUrl}/api/v1/screens/reset`, { method: 'POST' });
          if (res.ok) {
            await fetchScreenSchema(currentScreenId);
            showToast('Screen reset to factory default!', 'success');
          }
        } catch (e) {
          showToast('Failed to reset screen', 'error');
        }
      }
    });

    // Drag and Drop File Upload
    dropZone.addEventListener('dragover', (e) => {
      e.preventDefault();
      dropZone.classList.add('dragover');
    });

    dropZone.addEventListener('dragleave', () => {
      dropZone.classList.remove('dragover');
    });

    dropZone.addEventListener('drop', (e) => {
      e.preventDefault();
      dropZone.classList.remove('dragover');
      const files = e.dataTransfer.files;
      if (files.length > 0) handleFileRead(files[0]);
    });

    dropZone.addEventListener('click', () => fileInput.click());
    document.getElementById('btnUploadJson').addEventListener('click', () => fileInput.click());

    fileInput.addEventListener('change', (e) => {
      if (e.target.files.length > 0) handleFileRead(e.target.files[0]);
    });

    function handleFileRead(file) {
      if (!file.name.endsWith('.json')) {
        showToast('Please upload a valid .json file', 'error');
        return;
      }
      const reader = new FileReader();
      reader.onload = (event) => {
        rawJsonTextarea.value = event.target.result;
        syncJsonToVisual();
        showToast(`Uploaded schema file: ${file.name}`, 'success');
      };
      reader.readAsText(file);
    }

    // Snippet Buttons
    document.querySelectorAll('.snippet-pill').forEach(pill => {
      pill.addEventListener('click', () => {
        const snippetType = pill.dataset.snippet;
        addComponentByType(snippetType);
      });
    });

    // Palette Items
    document.querySelectorAll('.palette-item').forEach(item => {
      item.addEventListener('click', () => {
        const type = item.dataset.type;
        addComponentByType(type);
      });
    });

    // Publish Button
    document.getElementById('btnPublish').addEventListener('click', publishSchemaToBackend);

    // Screen Select Change
    screenSelect.addEventListener('change', (e) => {
      currentScreenId = e.target.value;
      fetchScreenSchema(currentScreenId);
    });

    // View Mode Tabs
    tabModeSplit.addEventListener('click', () => {
      mainLayout.className = 'main-layout';
      updateTabActive(tabModeSplit);
    });

    tabModeVisual.addEventListener('click', () => {
      mainLayout.className = 'main-layout view-visual-only';
      updateTabActive(tabModeVisual);
    });

    tabModeJson.addEventListener('click', () => {
      mainLayout.className = 'main-layout view-json-only';
      updateTabActive(tabModeJson);
    });

    function updateTabActive(btn) {
      [tabModeSplit, tabModeVisual, tabModeJson].forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
    }

    // Inspector Modal
    btnCloseInspector.addEventListener('click', closePropertyInspector);
    btnSaveInspector.addEventListener('click', closePropertyInspector);
    btnDeleteFromInspector.addEventListener('click', () => {
      if (activeEditingIndex >= 0) {
        deleteComponent(activeEditingIndex);
        closePropertyInspector();
      }
    });

    // Settings Modal
    btnSettings.addEventListener('click', () => {
      serverUrlInput.value = backendBaseUrl;
      settingsBackdrop.classList.remove('hidden');
    });

    serverStatusPill.addEventListener('click', () => {
      btnSettings.click();
    });

    btnCloseSettings.addEventListener('click', () => {
      settingsBackdrop.classList.add('hidden');
    });

    btnSaveSettings.addEventListener('click', () => {
      const val = serverUrlInput.value.trim().replace(/\/$/, '');
      if (val) {
        backendBaseUrl = val;
        checkBackendHealth();
        fetchScreenSchema(currentScreenId);
        showToast(`Backend URL set to: ${backendBaseUrl}`, 'success');
      }
      settingsBackdrop.classList.add('hidden');
    });

    btnTestConnection.addEventListener('click', async () => {
      testConnectionResult.textContent = 'Testing...';
      testConnectionResult.style.color = 'var(--text-muted)';
      try {
        const testUrl = serverUrlInput.value.trim().replace(/\/$/, '');
        const res = await fetch(`${testUrl}/api/v1/status`);
        if (res.ok) {
          testConnectionResult.textContent = '✓ Connected successfully!';
          testConnectionResult.style.color = 'var(--success)';
        } else {
          testConnectionResult.textContent = `✗ HTTP Error ${res.status}`;
          testConnectionResult.style.color = 'var(--danger)';
        }
      } catch (err) {
        testConnectionResult.textContent = `✗ Unreachable (${err.message})`;
        testConnectionResult.style.color = 'var(--danger)';
      }
    });

    btnDownloadApk.addEventListener('click', () => {
      btnSettings.click();
      setTimeout(() => {
        const section = document.querySelector('.apk-download-section');
        if (section) section.scrollIntoView({ behavior: 'smooth' });
      }, 100);
    });

    // Action Simulator Dismiss
    btnCloseActionModal.addEventListener('click', () => {
      actionModalBackdrop.classList.add('hidden');
    });

    // Live Preview Refresh
    document.getElementById('btnRefreshPreview').addEventListener('click', () => {
      renderLivePhonePreview();
      showToast('Phone preview refreshed', 'success');
    });
  }

  // ========================================================
  // Helpers
  // ========================================================
  function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.textContent = message;
    toastContainer.appendChild(toast);
    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transform = 'translateY(-10px)';
      setTimeout(() => toast.remove(), 300);
    }, 3500);
  }

  function escapeHtml(str) {
    if (typeof str !== 'string') return '';
    return str
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }

  // Run on DOM Ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();

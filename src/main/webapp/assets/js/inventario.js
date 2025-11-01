// ============================================
// INVENTARIO.JS - Control de Inventario (autodetección + fallback mock)
// ============================================

(function () {
  'use strict';

  // ------------------------
  // Helpers base / entorno
  // ------------------------
  function getApiBase() {
    const meta = document.querySelector('meta[name="api-base"]')?.content || '';
    const ls = localStorage.getItem('api_base') || '';
    return (ls || meta || '').trim().replace(/\/+$/, '');
  }
  function ctxPath() {
    try {
      const seg = location.pathname.split('/').filter(Boolean);
      return seg.length > 1 ? ('/' + seg[0]) : '';
    } catch { return ''; }
  }
  const API_BASE = getApiBase();  // p.ej. http://localhost:8080
  const CTX      = ctxPath();     // p.ej. /frontend

  // ------------------------
  // Endpoints candidatos
  // ------------------------
  const ENDPOINTS = {
    bodegas: [
      '/api/bodegas',
      '/bodegas'
    ],
    stock: [
      '/api/inventario',
      '/api/inventarios',
      '/inventario',
      '/inventarios',
      '/api/stock',
      '/stock'
    ],
    movimientos: [
      '/api/inventario/movimientos',
      '/api/inventarios/movimientos',
      '/inventario/movimientos',
      '/inventarios/movimientos',
      '/api/kardex',
      '/kardex'
    ],
    alertas: [
      '/api/inventario/alertas',
      '/api/inventarios/alertas',
      '/inventario/alertas',
      '/inventarios/alertas',
      '/api/alertas-inventario',
      '/alertas-inventario'
    ]
  };

  // ------------------------
  // Mock data (fallback)
  // ------------------------
  const MOCK = {
    bodegas: [
      { id: 1, nombre: 'Central' },
      { id: 2, nombre: 'Zona 19' }
    ],
    stock: [
      { productoCodigo: 'NT-001', productoNombre: 'Laptop Pro 14"', bodegaNombre: 'Central', cantidadDisponible: 8,  cantidadReservada: 1, cantidadEnTransito: 0, cantidadActual: 9,  ultimoCosto: 6500 },
      { productoCodigo: 'NT-002', productoNombre: 'Mouse Inalámbrico', bodegaNombre: 'Central', cantidadDisponible: 0,  cantidadReservada: 0, cantidadEnTransito: 5, cantidadActual: 5,  ultimoCosto: 90   },
      { productoCodigo: 'NT-003', productoNombre: 'Teclado Mecánico',  bodegaNombre: 'Zona 19', cantidadDisponible: 4,  cantidadReservada: 0, cantidadEnTransito: 0, cantidadActual: 4,  ultimoCosto: 350  }
    ],
    movimientos: [
      { fechaMovimiento: new Date().toISOString(), tipoMovimiento: 'E', tipoMovimientoDescripcion: 'Entrada', productoNombre: 'Laptop Pro 14"', productoCodigo: 'NT-001', bodegaNombre: 'Central', cantidad: 10, cantidadAnterior: 0, cantidadNueva: 10, empleadoNombre: 'Admin', motivo: 'Compra' },
      { fechaMovimiento: new Date().toISOString(), tipoMovimiento: 'S', tipoMovimientoDescripcion: 'Salida',  productoNombre: 'Teclado Mecánico',  productoCodigo: 'NT-003', bodegaNombre: 'Zona 19', cantidad: -1, cantidadAnterior: 5, cantidadNueva: 4, empleadoNombre: 'Admin', motivo: 'Venta' }
    ],
    alertas: [
      { fechaAlerta: new Date().toISOString(), tipoAlerta: 'S', tipoAlertaDescripcion: 'Sin Stock', productoNombre: 'Mouse Inalámbrico', productoCodigo: 'NT-002', bodegaNombre: 'Central', cantidadActual: 0, stockMinimo: 3, mensaje: 'Reponer stock' },
      { fechaAlerta: new Date().toISOString(), tipoAlerta: 'M', tipoAlertaDescripcion: 'Mínimo',    productoNombre: 'Teclado Mecánico',  productoCodigo: 'NT-003', bodegaNombre: 'Zona 19', cantidadActual: 4, stockMinimo: 5, mensaje: 'Bajo nivel' }
    ]
  };

  function mockEnabled() {
    return localStorage.getItem('mock_inventario') === '1';
  }

  // ------------------------
  // Builder de URLs
  // ------------------------
  function buildCandidates(path) {
    const list = [];
    const uniq = new Set();
    const push = (u) => { if (u && !uniq.has(u)) { uniq.add(u); list.push(u); } };

    const abs    = (p) => (API_BASE ? (API_BASE + p) : p);
    const withCx = (p) => (CTX ? (API_BASE + CTX + p) : null);

    push(abs(path));
    push(withCx(path));

    // también probar sin /api (o con /api)
    if (/^\/api(\/|$)/i.test(path)) {
      const sinApi = path.replace(/^\/api/, '');
      push(abs(sinApi));
      push(withCx(sinApi));
    } else {
      const conApi = '/api' + (path.startsWith('/') ? path : ('/' + path));
      push(abs(conApi));
      push(withCx(conApi));
    }

    return list.filter(Boolean);
  }

  // ------------------------
  // Fetch con fallback + caché
  // ------------------------
  async function fetchResolve(key, query = null, init = {}) {
    const cacheKey = `inv.endpoint.${key}`;
    const cached = localStorage.getItem(cacheKey);
    if (cached) {
      const url = withQuery(cached, query);
      const res = await fetch(url, ensureHeaders(init));
      const ok = await isOk(res);
      if (ok.ok) return ok.payload;
      localStorage.removeItem(cacheKey);
    }

    const candidates = [];
    (ENDPOINTS[key] || []).forEach(p => candidates.push(...buildCandidates(p)));

    let last500 = null;
    for (const abs of candidates) {
      try {
        const url = withQuery(abs, query);
        const res = await fetch(url, ensureHeaders(init));
        const ok = await isOk(res);
        if (ok.ok) {
          localStorage.setItem(cacheKey, abs);
          return ok.payload;
        }
        // si fue 500, guardamos para informar pero seguimos probando
        if ((res.status >= 500 && res.status <= 599) || /HTTP 500|Estado HTTP 500/i.test(ok.errMsg || '')) {
          last500 = { url: abs, msg: ok.errMsg };
          continue;
        }
        // 404 y similares: probar siguiente
        continue;
      } catch (e) {
        last500 = last500 || { url: abs, msg: String(e) };
        continue;
      }
    }

    // Si todo falló, modo mock (si está habilitado)
    if (mockEnabled()) {
      return JSON.parse(JSON.stringify(MOCK[key] || []));
    }

    // Como ayuda, si hay un 500 registrado, mostramos ese detalle
    if (last500) {
      throw new Error(`HTTP 500 en ${last500.url}`);
    }
    throw new Error(`No se encontró endpoint válido para ${key}`);
  }

  function ensureHeaders(init) {
    init = init || {};
    const headers = init.headers instanceof Headers ? init.headers : new Headers(init.headers || {});
    if (!headers.has('Accept')) headers.set('Accept', 'application/json');
    // Sugerido para algunos backends (no interfiere con tu common.js)
    if (!headers.has('X-Requested-With')) headers.set('X-Requested-With', 'XMLHttpRequest');
    return { ...init, headers };
  }

  async function isOk(res) {
    const text = await res.text();
    const tryJson = () => { try { return text ? JSON.parse(text) : null; } catch { return null; } };
    const isHtml404 = /No encontrado|No static resource|HTTP 404|Estado HTTP 404/i.test(text);

    if (res.ok) return { ok: true, payload: tryJson() ?? text ?? null };

    if (res.status === 404 || isHtml404) return { ok: false, errMsg: text };
    if (res.status >= 500 && res.status <= 599) return { ok: false, errMsg: text || `HTTP ${res.status}` };

    return { ok: false, errMsg: text || `HTTP ${res.status}` };
  }

  function withQuery(url, params) {
    if (!params || typeof params !== 'object') return url;
    const u = new URL(url, window.location.origin);
    Object.entries(params).forEach(([k, v]) => {
      if (v !== undefined && v !== null && v !== '') u.searchParams.set(k, v);
    });
    return u.toString();
  }

  // ------------------------
  // DOM / Estado UI
  // ------------------------
  let toastStack;
  let bodegas = [];

  document.addEventListener('DOMContentLoaded', init);

  function init() {
    toastStack = document.getElementById('toastStack');

    // Limpia endpoints cacheados para forzar re-descubrimiento de rutas válidas
    try {
      ['stock','movimientos','alertas','bodegas'].forEach(k => {
        localStorage.removeItem(`inv.endpoint.${k}`);
      });
    } catch {}

    document.getElementById('btnBuscarStock')?.addEventListener('click', cargarStock);
    document.getElementById('btnBuscarMov')?.addEventListener('click', cargarMovimientos);
    document.getElementById('btnBuscarAlert')?.addEventListener('click', cargarAlertas);

    document.getElementById('txtSearchStock')?.addEventListener('keyup', (e) => {
      if (e.key === 'Enter') cargarStock();
    });

    document.querySelectorAll('#inventarioTabs button[data-bs-toggle="tab"]').forEach(tab => {
      tab.addEventListener('shown.bs.tab', (e) => {
        const target = e.target.getAttribute('data-bs-target');
        if (target === '#stock')       cargarStock();
        if (target === '#movimientos') cargarMovimientos();
        if (target === '#alertas')     cargarAlertas();
      });
    });

    cargarBodegas().finally(cargarStock);
  }

  // ==========================
  // Bodegas
  // ==========================
  async function cargarBodegas() {
    try {
      const data = await fetchResolve('bodegas');
      bodegas = Array.isArray(data) ? data : (data?.items || data?.data || data?.content || []);
      const selects = [
        document.getElementById('filtroBodegaStock'),
        document.getElementById('filtroBodegaMov'),
        document.getElementById('filtroBodegaAlert')
      ];
      selects.forEach(sel => {
        if (!sel) return;
        const first = sel.querySelector('option');
        sel.innerHTML = first ? first.outerHTML : '<option value="">Todas</option>';
        bodegas.forEach(b => {
          const opt = document.createElement('option');
          opt.value = b.id;
          opt.textContent = b.nombre;
          sel.appendChild(opt);
        });
      });
    } catch (e) {
      console.error('Bodegas:', e);
      // Fallback mock puntual si falla y no está activado global
      if (!mockEnabled()) {
        showToast('Backend devolvió 500 al cargar bodegas. Activa mock con localStorage.setItem("mock_inventario","1") para probar UI.', 'warning');
      }
      bodegas = MOCK.bodegas;
    }
  }

  // ==========================
  // STOCK
  // ==========================
  async function cargarStock() {
    const bodegaId   = document.getElementById('filtroBodegaStock')?.value || '';
    const searchTerm = document.getElementById('txtSearchStock')?.value || '';

    try {
      showLoading('tblStock', 9);
      const params = {};
      if (bodegaId) params.bodegaId = bodegaId;

      let inventarios = await fetchResolve('stock', params);
      if (!Array.isArray(inventarios)) {
        inventarios = inventarios?.content || inventarios?.items || inventarios?.data || [];
      }

      if (searchTerm) {
        const term = searchTerm.toLowerCase();
        inventarios = inventarios.filter(i =>
          (i.productoNombre || '').toLowerCase().includes(term) ||
          (i.productoCodigo || '').toLowerCase().includes(term)
        );
      }

      renderizarStock(inventarios);
      setResumen('lblResumenStock', `Mostrando ${inventarios.length} producto(s) en inventario`);
    } catch (error) {
      console.error('Stock:', error);
      const useMock = mockEnabled();
      if (useMock) {
        renderizarStock(MOCK.stock);
        setResumen('lblResumenStock', `Mostrando ${MOCK.stock.length} producto(s) [mock]`);
        showToast('Backend respondió 500 en /inventario. Mostrando datos de ejemplo (mock).', 'warning');
        return;
      }
      setTableError('tblStock', 9, error);
      setResumen('lblResumenStock', 'No se pudo cargar el inventario');
      showToast('Error al cargar el inventario', 'danger');
    }
  }

  function renderizarStock(data) {
    const tbody = document.getElementById('tblStock');
    if (!Array.isArray(data) || data.length === 0) {
      tbody.innerHTML = '<tr><td colspan="9" class="text-center nt-empty py-4">No hay datos de inventario</td></tr>';
      return;
    }
    tbody.innerHTML = data.map(i => `
      <tr>
        <td><code>${i.productoCodigo || 'N/A'}</code></td>
        <td><strong>${i.productoNombre || 'N/A'}</strong></td>
        <td>${i.bodegaNombre || 'N/A'}</td>
        <td><strong class="text-success">${coalesce(i.cantidadDisponible, i.disponible, 0)}</strong></td>
        <td>${coalesce(i.cantidadReservada, i.reservada, 0)}</td>
        <td>${coalesce(i.cantidadEnTransito, i.enTransito, 0)}</td>
        <td><strong>${coalesce(i.cantidadActual, i.total, 0)}</strong></td>
        <td>${formatMoney(coalesce(i.ultimoCosto, i.costoUltimo, null))}</td>
        <td>${getBadgeStock(coalesce(i.cantidadDisponible, i.disponible, 0))}</td>
      </tr>
    `).join('');
  }

  function getBadgeStock(disp) {
    const d = Number(disp) || 0;
    if (d === 0) return '<span class="badge bg-danger">Sin Stock</span>';
    if (d <= 5)  return '<span class="badge bg-warning">Bajo</span>';
    return '<span class="badge bg-success">OK</span>';
  }

  // ==========================
  // MOVIMIENTOS (KARDEX)
  // ==========================
  async function cargarMovimientos() {
    const bodegaId   = document.getElementById('filtroBodegaMov')?.value || '';
    const fechaDesde = document.getElementById('filtroFechaDesde')?.value || '';
    const fechaHasta = document.getElementById('filtroFechaHasta')?.value || '';

    try {
      showLoading('tblMovimientos', 9);
      const params = {};
      if (bodegaId)   params.bodegaId   = bodegaId;
      if (fechaDesde) params.fechaDesde = fechaDesde;
      if (fechaHasta) params.fechaHasta = fechaHasta;

      let movs = await fetchResolve('movimientos', params);
      if (!Array.isArray(movs)) movs = movs?.content || movs?.items || movs?.data || [];

      renderizarMovimientos(movs);
      setResumen('lblResumenMov', `Mostrando ${movs.length} movimiento(s)`);
    } catch (error) {
      console.error('Movimientos:', error);
      renderizarMovimientos(MOCK.movimientos);
      setResumen('lblResumenMov', `Mostrando ${MOCK.movimientos.length} movimiento(s) [mock]`);
      showToast('Backend 500 en movimientos. Mostrando datos mock.', 'warning');
    }
  }

  function renderizarMovimientos(data) {
    const tbody = document.getElementById('tblMovimientos');
    if (!Array.isArray(data) || data.length === 0) {
      tbody.innerHTML = '<tr><td colspan="9" class="text-center nt-empty py-4">No hay movimientos registrados</td></tr>';
      return;
    }

    const labelTipo = (t) => ({ 'E':'Entrada', 'S':'Salida', 'T':'Traslado', 'A':'Ajuste' }[t] || t || '-');

    tbody.innerHTML = data.map(m => {
      const fecha  = coalesce(m.fechaMovimiento, m.fecha, m.fecha_movimiento, null);
      const tipo   = coalesce(m.tipoMovimiento, m.tipo, m.tipo_movimiento, null);

      // Producto
      const prodNom = coalesce(m.productoNombre, m.producto, m.producto_nombre, '');
      const prodCod = coalesce(m.productoCodigo, m.producto_codigo, '');
      const prodLbl = prodNom || (prodCod ? `(${prodCod})` : (m.producto_id ? `ID ${m.producto_id}` : ''));

      // Bodega
      const bodNom = coalesce(m.bodegaNombre, m.bodega, m.bodega_nombre, '');
      const bodLbl = bodNom || (m.bodega_id ? `#${m.bodega_id}` : '');

      // Cantidades
      const cant  = coalesce(m.cantidad, 0);
      const prev  = coalesce(m.cantidadAnterior, m.saldoAnterior, m.cantidad_anterior, '-');
      const nuevo = coalesce(m.cantidadNueva, m.saldoNuevo, m.cantidad_nueva, '-');

      // Responsable
      const resp   = coalesce(m.empleadoNombre, m.responsable, m.empleado_responsable, null);
      const respLbl= resp || (m.empleado_responsable_id ? `#${m.empleado_responsable_id}` : 'N/A');

      return `
        <tr>
          <td>${formatDateTime(fecha)}</td>
          <td>${getBadgeTipoMovimiento((tipo || '').toString().toUpperCase(), labelTipo((tipo || '').toString().toUpperCase()))}</td>
          <td><strong>${prodLbl || '-'}</strong><br><small class="text-muted">${prodCod || ''}</small></td>
          <td>${bodLbl || '-'}</td>
          <td><strong class="${(cant ?? 0) > 0 ? 'text-success' : 'text-danger'}">${(cant ?? 0) > 0 ? '+' : ''}${cant ?? 0}</strong></td>
          <td>${prev}</td>
          <td><strong>${nuevo}</strong></td>
          <td><small>${respLbl}</small></td>
          <td><small>${m.motivo || '-'}</small></td>
        </tr>
      `;
    }).join('');
  }

  function getBadgeTipoMovimiento(tipo, descripcion) {
    const t = (tipo || '').toString().toUpperCase();
    const cls = { 'E': 'bg-success', 'S': 'bg-danger', 'T': 'bg-info', 'A': 'bg-warning' }[t] || 'bg-secondary';
    return `<span class="badge ${cls}">${descripcion || t || '-'}</span>`;
  }

  // ==========================
  // ALERTAS
  // ==========================
  async function cargarAlertas() {
    const bodegaId  = document.getElementById('filtroBodegaAlert')?.value || '';
    const tipoAlerta = document.getElementById('filtroTipoAlert')?.value || '';

    try {
      showLoading('tblAlertas', 7);
      const params = { activa: 'true' };
      if (bodegaId)   params.bodegaId   = bodegaId;
      if (tipoAlerta) params.tipoAlerta = tipoAlerta;

      let alertas = await fetchResolve('alertas', params);
      if (!Array.isArray(alertas)) alertas = alertas?.content || alertas?.items || alertas?.data || [];

      renderizarAlertas(alertas);
      setResumen('lblResumenAlert', `${alertas.length} alerta(s) activa(s)`);
    } catch (error) {
      console.error('Alertas:', error);
      renderizarAlertas(MOCK.alertas);
      setResumen('lblResumenAlert', `${MOCK.alertas.length} alerta(s) [mock]`);
      showToast('Backend 500 en alertas. Mostrando datos mock.', 'warning');
    }
  }

  function renderizarAlertas(data) {
    const tbody = document.getElementById('tblAlertas');
    if (!Array.isArray(data) || data.length === 0) {
      tbody.innerHTML = '<tr><td colspan="7" class="text-center text-success py-4"><i class="bi bi-check-circle"></i> No hay alertas activas</td></tr>';
      return;
    }
    tbody.innerHTML = data.map(a => {
      const fecha   = coalesce(a.fechaAlerta, a.fecha, a.fecha_alerta, null);
      const tipo    = coalesce(a.tipoAlerta, a.tipo, a.tipo_alerta, null);
      const tipoDes = coalesce(a.tipoAlertaDescripcion, a.tipoDescripcion, a.tipo_alerta_descripcion, null);

      const prodNom = coalesce(a.productoNombre, a.producto, a.producto_nombre, '');
      const prodCod = coalesce(a.productoCodigo, a.producto_codigo, '');
      const bodNom  = coalesce(a.bodegaNombre, a.bodega, a.bodega_nombre, '');
      const bodLbl  = bodNom || (a.bodega_id ? `#${a.bodega_id}` : '');

      const cant    = coalesce(a.cantidadActual, a.stockActual, a.stock_actual, 0);
      const minimo  = coalesce(a.stockMinimo, a.minimo, a.stock_minimo, '-');

      return `
        <tr>
          <td>${formatDateTime(fecha)}</td>
          <td>${getBadgeTipoAlerta((tipo || '').toString().toUpperCase(), tipoDes)}</td>
          <td><strong>${prodNom || (prodCod ? `(${prodCod})` : (a.producto_id ? `ID ${a.producto_id}` : '-'))}</strong><br><small class="text-muted">${prodCod || ''}</small></td>
          <td>${bodLbl || '-'}</td>
          <td><strong class="${cant === 0 ? 'text-danger' : 'text-warning'}">${cant}</strong></td>
          <td>${minimo}</td>
          <td><small>${a.mensaje || '-'}</small></td>
        </tr>
      `;
    }).join('');
  }

  function getBadgeTipoAlerta(tipo, descripcion) {
    const t = (tipo || '').toString().toUpperCase();
    const cls = { 'M': 'bg-warning', 'S': 'bg-danger', 'A': 'bg-info' }[t] || 'bg-secondary';
    return `<span class="badge ${cls}">${descripcion || t || '-'}</span>`;
  }

  // ------------------------
  // Utilidades UI/formatos
  // ------------------------
  function showLoading(tbodyId, colSpan) {
    const tb = document.getElementById(tbodyId);
    if (tb) tb.innerHTML = `<tr><td colspan="${colSpan}" class="text-center py-4"><div class="spinner-border" role="status"></div></td></tr>`;
  }
  function setTableError(tbodyId, colSpan, err) {
    const tb = document.getElementById(tbodyId); if (!tb) return;
    const msg = extractMsg(err);
    tb.innerHTML = `<tr><td colspan="${colSpan}" class="text-center nt-error py-4">${escapeHtml(msg)}</td></tr>`;
  }
  function setResumen(id, text) {
    const el = document.getElementById(id);
    if (el) el.textContent = text || '';
  }
  function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `toast align-items-center text-white bg-${type} border-0`;
    toast.setAttribute('role', 'alert');
    toast.innerHTML = `
      <div class="d-flex">
        <div class="toast-body">${escapeHtml(message || '')}</div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
      </div>`;
    (toastStack || document.body).appendChild(toast);
    const bsToast = new bootstrap.Toast(toast);
    bsToast.show();
    toast.addEventListener('hidden.bs.toast', () => toast.remove());
  }

  function coalesce(...vals) { for (const v of vals) if (v !== undefined && v !== null) return v; return null; }
  function formatMoney(v) { if (v == null) return '-'; try { return new Intl.NumberFormat('es-GT', { style: 'currency', currency: 'GTQ' }).format(Number(v)); } catch { return 'Q ' + Number(v).toFixed(2); } }
  function formatDateTime(f) { if (!f) return '-'; const d = new Date(f); return d.toLocaleDateString('es-GT', { year:'numeric', month:'2-digit', day:'2-digit', hour:'2-digit', minute:'2-digit' }); }
  function escapeHtml(s) { return String(s || '').replace(/[&<>"']/g, m => ({ '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;' }[m])); }
  function extractMsg(e) {
    const raw = (e && (e.message || e)) ? String(e.message || e) : 'Error';
    if (/<html[^>]*>/i.test(raw)) {
      try {
        const tmp = document.implementation.createHTMLDocument('');
        tmp.documentElement.innerHTML = raw;
        const t = tmp.querySelector('title')?.textContent?.trim();
        const h1 = tmp.querySelector('h1')?.textContent?.trim();
        return [t, h1].filter(Boolean).join(' – ') || 'Error';
      } catch { return 'Error'; }
    }
    return raw;
  }
})();

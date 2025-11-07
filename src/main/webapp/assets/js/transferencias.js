// ============================================
// TRANSFERENCIAS.JS - Gestión de Transferencias
// (acoplado al TransferenciaController actual)  v18
// ============================================

(function () {
  'use strict';

  // =========================
  // CONFIGURACIÓN DE ENDPOINTS
  // =========================
  const API_BASE = (function(){
    const fromMeta = document.querySelector('meta[name="api-base"]')?.content || '';
    const fromCommon = (typeof window.getApiBase === 'function') ? window.getApiBase() : '';
    return (fromCommon || fromMeta || 'http://localhost:8080').replace(/\/+$/,'');
  })();
  const API_URL = `${API_BASE}/api/transferencias`;
  const API_BODEGAS = `${API_BASE}/api/bodegas`;

  // =========================
  // ESTADO / REFERENCIAS
  // =========================
  let toastStack, mdlDetalle, mdlCrear, frmCrear;

  // =========================
  // INICIALIZACIÓN
  // =========================
  document.addEventListener('DOMContentLoaded', init);

  function init() {
    // Usa el contenedor de toasts clásico (#toastStack) o el toast unificado del JSP (#appToast)
    toastStack = document.getElementById('toastStack') || document.getElementById('appToast');

    mdlDetalle = new bootstrap.Modal(document.getElementById('mdlDetalle'));
    mdlCrear   = new bootstrap.Modal(document.getElementById('mdlCrear'));
    frmCrear   = document.getElementById('frmCrear');

    // Listeners
    document.getElementById('btnBuscar')?.addEventListener('click', cargarTransferencias);
    document.getElementById('btnNuevaTransferencia')?.addEventListener('click', abrirModalCrear);
    document.getElementById('btnAgregarProducto')?.addEventListener('click', agregarProducto);
    frmCrear?.addEventListener('submit', crearTransferencia);

    // Fecha hoy
    const hoy = new Date().toISOString().split('T')[0];
    const inputFecha = document.getElementById('crear_fecha');
    if (inputFecha) inputFecha.value = hoy;

    // Carga inicial
    cargarBodegas().finally(cargarTransferencias);
  }

  // =========================
  // HELPERS HTTP (no eliminan tus fetch; solo agregan alternativas seguras)
  // =========================
  async function httpGet(url, params) {
    // Construcción de URL + query
    const u = new URL(url);
    if (params && typeof params === 'object') {
      Object.entries(params).forEach(([k,v])=>{
        if (v !== undefined && v !== null && v !== '') u.searchParams.append(k, v);
      });
    }
    // Headers (si existe buildHeaders en common.js lo usamos)
    const headers = (typeof window.buildHeaders === 'function')
      ? window.buildHeaders()
      : { 'Accept': 'application/json' };

    const res = await fetch(u.toString(), { headers });
    const txt = await res.text();
    let data = null; try { data = txt ? JSON.parse(txt) : null; } catch {}
    if (!res.ok) {
      const msg = (data && (data.message || data.error || data.detail)) || `HTTP ${res.status}`;
      throw new Error(msg);
    }
    return data ?? [];
  }

  async function httpSend(method, url, body) {
    const headers = (typeof window.buildHeaders === 'function')
      ? window.buildHeaders({'Content-Type':'application/json'})
      : { 'Accept': 'application/json', 'Content-Type': 'application/json' };

    const res = await fetch(url, {
      method,
      headers,
      body: body === undefined ? null : JSON.stringify(body)
    });
    const txt = await res.text();
    let data = null; try { data = txt ? JSON.parse(txt) : null; } catch {}
    if (!res.ok) {
      const msg = (data && (data.message || data.error || data.detail)) || `HTTP ${res.status}`;
      throw new Error(msg);
    }
    return data;
  }

  // =========================
  // BANNER/FALLBACK
  // =========================
  function setFallbackBanner(show, detalle){
    const exist = document.getElementById('nt-fallback-banner');
    if (!show) { if (exist) exist.remove(); return; }
    if (exist) { exist.querySelector('.msg').textContent = detalle || ''; return; }
    const cont = document.querySelector('.container') || document.body;
    const banner = document.createElement('div');
    banner.id = 'nt-fallback-banner';
    banner.className = 'alert alert-warning d-flex align-items-center gap-2';
    banner.innerHTML = `
      <i class="bi bi-exclamation-triangle"></i>
      <div>
        Modo de contingencia activo: el backend respondió <code>HTTP 500</code> sin filtros.
        Mostrando resultados con filtro alternativo. <span class="msg">${detalle || ''}</span>
      </div>`;
    cont.insertBefore(banner, cont.firstChild);
  }

  async function sondearPorEstado() {
    const orden = ['P', 'E', 'R', 'C'];
    for (const estado of orden) {
      try {
        const rows = await httpGet(API_URL, { estado });
        if (Array.isArray(rows)) return { usado: estado, rows };
      } catch { /* seguir intentando */ }
    }
    throw new Error('Ningún estado respondió OK durante el sondeo.');
  }

  // =========================
  // CARGAR BODEGAS
  // =========================
  async function cargarBodegas() {
    try {
      const lista = await httpGet(API_BODEGAS);

      // Llenar selects
      const selectOrigen       = document.getElementById('filtroBodegaOrigen');
      const selectDestino      = document.getElementById('filtroBodegaDestino');
      const selectCrearOrigen  = document.getElementById('crear_bodega_origen');
      const selectCrearDestino = document.getElementById('crear_bodega_destino');

      [selectOrigen, selectDestino].forEach(select => {
        if (select) {
          select.innerHTML = '<option value="">Todas</option>';
          (Array.isArray(lista)? lista: []).forEach(b => {
            const opt = document.createElement('option');
            opt.value = b.id;
            opt.textContent = b.nombre;
            select.appendChild(opt);
          });
        }
      });

      [selectCrearOrigen, selectCrearDestino].forEach(select => {
        if (select) {
          select.innerHTML = '<option value="">Seleccione...</option>';
          (Array.isArray(lista)? lista: []).forEach(b => {
            const opt = document.createElement('option');
            opt.value = b.id;
            opt.textContent = b.nombre;
            select.appendChild(opt);
          });
        }
      });
    } catch (error) {
      console.error('Error cargando bodegas:', error);
      showToast('Error al cargar bodegas', 'danger');
    }
  }

  // =========================
  // CARGAR TRANSFERENCIAS (con fallback si 500 sin filtros)
  // =========================
  async function cargarTransferencias() {
    const bodegaOrigenId  = document.getElementById('filtroBodegaOrigen')?.value || '';
    const bodegaDestinoId = document.getElementById('filtroBodegaDestino')?.value || '';
    const estado          = document.getElementById('filtroEstado')?.value || '';

    try {
      showLoading();

      // Construir params y pedir
      const params = {};
      if (bodegaOrigenId)  params.bodegaOrigenId  = bodegaOrigenId;
      if (bodegaDestinoId) params.bodegaDestinoId = bodegaDestinoId;
      if (estado)          params.estado          = estado;

      const data = await httpGet(API_URL, params);
      renderizarTabla(Array.isArray(data) ? data : []);
      const lbl = document.getElementById('lblResumen');
      if (lbl) lbl.textContent = `Mostrando ${Array.isArray(data)?data.length:0} transferencia(s)`;
      setFallbackBanner(false);
    } catch (error) {
      console.error('Transferencias ERROR: ', error);

      // Solo aplica fallback si NO hay filtros elegidos
      if (!bodegaOrigenId && !bodegaDestinoId && !estado && /HTTP 500/.test(String(error.message))) {
        try {
          const probe = await sondearPorEstado();
          renderizarTabla(probe.rows);
          const lbl = document.getElementById('lblResumen');
          if (lbl) lbl.textContent = `Mostrando ${probe.rows.length} transferencia(s) [filtro automático: estado=${probe.usado}]`;
          setFallbackBanner(true, `(estado=${probe.usado})`);
          showToast('El backend falló sin filtros. Se aplicó contingencia por estado.', 'warning');
          return;
        } catch (e2) {
          console.error('Fallback/sondeo ERROR:', e2);
        }
      }

      document.getElementById('tblTransferencias').innerHTML =
        `<tr><td colspan="9" class="text-center text-danger py-4">
          Error al cargar datos${error?.message ? `: ${error.message}` : ''}</td></tr>`;
      showToast('Error al cargar transferencias', 'danger');
      setFallbackBanner(false);
    }
  }

  function renderizarTabla(data) {
    const tbody = document.getElementById('tblTransferencias');

    if (!Array.isArray(data) || data.length === 0) {
      tbody.innerHTML = '<tr><td colspan="9" class="text-center text-muted py-4">No hay transferencias registradas</td></tr>';
      return;
    }

    tbody.innerHTML = data.map(t => `
      <tr>
        <td><strong>${t.numeroTransferencia}</strong></td>
        <td>${formatearFecha(t.fechaTransferencia)}</td>
        <td><small>${t.bodegaOrigenNombre}</small></td>
        <td><small>${t.bodegaDestinoNombre}</small></td>
        <td>${getBadgeEstado(t.estado, t.estadoDescripcion)}</td>
        <td>${t.fechaEnvio ? formatearFecha(t.fechaEnvio) : '-'}</td>
        <td>${t.fechaRecepcion ? formatearFecha(t.fechaRecepcion) : '-'}</td>
        <td><small>${t.observaciones || '-'}</small></td>
        <td class="text-end">
          <div class="btn-group btn-group-sm">
            <button class="btn btn-outline-primary" onclick="window.transferenciaApp.verDetalle(${t.id})" title="Ver">
              <i class="bi bi-eye"></i>
            </button>
            ${t.estado === 'P' ? `
            <button class="btn btn-outline-success" onclick="window.transferenciaApp.enviar(${t.id})" title="Enviar/Aprobar">
              <i class="bi bi-send"></i>
            </button>
            <button class="btn btn-outline-danger" onclick="window.transferenciaApp.cancelar(${t.id})" title="Cancelar">
              <i class="bi bi-x-circle"></i>
            </button>
            ` : ''}
            ${t.estado === 'E' ? `
            <button class="btn btn-outline-info" onclick="window.transferenciaApp.recibir(${t.id})" title="Recibir">
              <i class="bi bi-box-arrow-in-down"></i>
            </button>
            ` : ''}
          </div>
        </td>
      </tr>
    `).join('');
  }

  function getBadgeEstado(estado, descripcion) {
    const badges = { 'P': 'bg-warning', 'E': 'bg-info', 'R': 'bg-success', 'C': 'bg-danger' };
    return `<span class="badge ${badges[estado] || 'bg-secondary'}">${descripcion || estado || '-'}</span>`;
  }

  // =========================
  // VER DETALLE
  // =========================
  async function verDetalle(id) {
    try {
      const transferencia = await httpGet(`${API_URL}/${id}`);

      document.getElementById('detNumero').textContent = transferencia.numeroTransferencia || ('ID ' + (transferencia.id ?? id));
      document.getElementById('detFecha').textContent  = formatearFecha(transferencia.fechaTransferencia);
      document.getElementById('detEstado').innerHTML   = getBadgeEstado(transferencia.estado, transferencia.estadoDescripcion);
      document.getElementById('detOrigen').textContent = transferencia.bodegaOrigenNombre;
      document.getElementById('detDestino').textContent= transferencia.bodegaDestinoNombre;
      document.getElementById('detObservaciones').textContent = transferencia.observaciones || '-';

      const tbody = document.getElementById('tblDetalleProductos');
      if (transferencia.detalles && transferencia.detalles.length > 0) {
        tbody.innerHTML = transferencia.detalles.map(d => `
          <tr>
            <td><code>${d.productoCodigo}</code></td>
            <td><strong>${d.productoNombre}</strong></td>
            <td class="text-center">${d.cantidadSolicitada}</td>
            <td class="text-center">${d.cantidadEnviada || 0}</td>
            <td class="text-center">${d.cantidadRecibida || 0}</td>
          </tr>
        `).join('');
      } else {
        tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted">Sin productos</td></tr>';
      }

      mdlDetalle.show();
    } catch (error) {
      console.error('Error:', error);
      showToast('Error al cargar el detalle', 'danger');
    }
  }

  // =========================
  // CREAR TRANSFERENCIA
  // =========================
  function abrirModalCrear() {
    frmCrear.reset();
    frmCrear.classList.remove('was-validated');

    const hoy = new Date().toISOString().split('T')[0];
    document.getElementById('crear_fecha').value = hoy;

    const container = document.getElementById('productosContainer');
    container.innerHTML = `
      <div class="producto-item row g-2 mb-2">
        <div class="col-md-2">
          <input type="number" class="form-control producto-id" placeholder="Producto ID" required>
          <div class="invalid-feedback">Requerido</div>
        </div>
        <div class="col-md-8">
          <input type="text" class="form-control" placeholder="Nombre del producto" disabled>
        </div>
        <div class="col-md-2">
          <input type="number" class="form-control producto-cantidad" placeholder="Cantidad" min="1" required>
          <div class="invalid-feedback">Mínimo 1</div>
        </div>
      </div>
    `;

    mdlCrear.show();
  }

  function agregarProducto() {
    const container = document.getElementById('productosContainer');
    const newItem = document.createElement('div');
    newItem.className = 'producto-item row g-2 mb-2';
    newItem.innerHTML = `
      <div class="col-md-2">
        <input type="number" class="form-control producto-id" placeholder="Producto ID" required>
        <div class="invalid-feedback">Requerido</div>
      </div>
      <div class="col-md-8">
        <input type="text" class="form-control" placeholder="Nombre del producto" disabled>
      </div>
      <div class="col-md-2">
        <input type="number" class="form-control producto-cantidad" placeholder="Cantidad" min="1" required>
        <div class="invalid-feedback">Mínimo 1</div>
      </div>
    `;
    container.appendChild(newItem);
  }

  async function crearTransferencia(e) {
    e.preventDefault();

    if (!frmCrear.checkValidity()) {
      frmCrear.classList.add('was-validated');
      return;
    }

    // Leer valores
const solicitadoInput = document.getElementById('crear_solicitado');
const solicitadoValue = solicitadoInput ? solicitadoInput.value : null;
const solicitadoInt = parseInt(solicitadoValue);

console.log('🔍 DEBUG solicitanteId:');
console.log('   Input element:', solicitadoInput);
console.log('   Value from input:', solicitadoValue);
console.log('   ParseInt result:', solicitadoInt);
console.log('   IsNaN:', isNaN(solicitadoInt));

const data = {
  numeroTransferencia: document.getElementById('crear_numero').value.trim(),
  fechaTransferencia:  document.getElementById('crear_fecha').value,
  bodegaOrigenId:      parseInt(document.getElementById('crear_bodega_origen').value),
  bodegaDestinoId:     parseInt(document.getElementById('crear_bodega_destino').value),
  solicitanteId:       isNaN(solicitadoInt) ? 1 : solicitadoInt,  // ← FIX: Si es NaN, usa 1
  observaciones:       document.getElementById('crear_observaciones').value.trim() || null,
  detalles: []
};

    if (data.bodegaOrigenId === data.bodegaDestinoId) {
      showToast('La bodega origen y destino deben ser diferentes', 'warning');
      return;
    }

    const productosItems = document.querySelectorAll('.producto-item');
    productosItems.forEach(item => {
      const productoId = item.querySelector('.producto-id').value;
      const cantidad   = item.querySelector('.producto-cantidad').value;
      if (productoId && cantidad) {
        data.detalles.push({
          productoId: parseInt(productoId),
          cantidadSolicitada: parseInt(cantidad)
        });
      }
    });

    if (data.detalles.length === 0) {
      showToast('Debe agregar al menos un producto', 'warning');
      return;
    }
        try {
      console.log('📤 Enviando al backend:', JSON.stringify(data, null, 2));
      const result = await httpSend('POST', API_URL, data);
      if (result && result.success === false) {
  throw new Error(result.message || 'Error al crear la transferencia');
}
      showToast(result?.message || 'Transferencia creada exitosamente', 'success');
      mdlCrear.hide();
      cargarTransferencias();
    } catch (error) {
      console.error('Error:', error);
      showToast(error.message || 'Error al crear la transferencia', 'danger');
    }
  }

  // =========================
  // CAMBIAR ESTADO (mapeado a tu Controller)
  // =========================
  async function enviar(id) {
    if (!confirm('¿Desea marcar esta transferencia como ENVIADA/APROBADA?')) return;
    await cambiarEstado(`${API_URL}/${id}/aprobar?aprobadorId=1`, 'Transferencia aprobada');
  }

  async function recibir(id) {
    if (!confirm('¿Desea marcar esta transferencia como RECIBIDA?')) return;
    await cambiarEstado(`${API_URL}/${id}/recibir?receptorId=1`, 'Transferencia recibida');
  }

  async function cancelar(id) {
    if (!confirm('¿Desea CANCELAR esta transferencia?')) return;
    await cambiarEstado(`${API_URL}/${id}/cancelar`, 'Transferencia cancelada');
  }

  async function cambiarEstado(url, okMsg) {
    try {
      const json = await httpSend('PUT', url, undefined);
      if (json && json.success === false) throw new Error(json.message || 'No se pudo actualizar');
      showToast(json?.message || okMsg || 'Estado actualizado', 'success');
      cargarTransferencias();
    } catch (error) {
      console.error('Error:', error);
      showToast('Error al cambiar el estado: ' + error.message, 'danger');
    }
  }

  // =========================
  // UTILIDADES
  // =========================
  function showLoading() {
    document.getElementById('tblTransferencias').innerHTML =
      '<tr><td colspan="9" class="text-center py-4"><div class="spinner-border text-primary"></div></td></tr>';
    const lbl = document.getElementById('lblResumen');
    if (lbl) lbl.textContent = 'Cargando…';
  }

  // Toast seguro: usa #appToast/#toastMsg si existen (JSP actual) o el contenedor clásico; si no, alerta/console
  function showToast(message, type = 'info') {
    const appToast = document.getElementById('appToast');
    const toastMsg = document.getElementById('toastMsg');
    if (appToast && toastMsg && window.bootstrap) {
      // Limpia cualquier text-bg-* previo
      appToast.className = appToast.className.replace(/\btext-bg-\w+\b/g, '').trim();
      const map = { success: 'success', danger: 'danger', warning: 'warning', info: 'primary' };
      appToast.classList.add(`text-bg-${map[type] || 'primary'}`);
      toastMsg.textContent = message;
      bootstrap.Toast.getOrCreateInstance(appToast, { delay: 3000 }).show();
      return;
    }

    const stack = document.getElementById('toastStack');
    if (stack && window.bootstrap) {
      const t = document.createElement('div');
      t.className = `toast align-items-center text-white bg-${type} border-0`;
      t.setAttribute('role', 'alert');
      t.innerHTML = `
        <div class="d-flex">
          <div class="toast-body">${message}</div>
          <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
        </div>`;
      stack.appendChild(t);
      const bsToast = new bootstrap.Toast(t, { delay: 3000 });
      bsToast.show();
      t.addEventListener('hidden.bs.toast', () => t.remove());
      return;
    }

    console[(type === 'danger' ? 'error' : 'log')](message);
    if (typeof alert === 'function') alert(message);
  }

  function formatearFecha(fecha) {
    if (!fecha) return '-';
    const d = new Date(fecha);
    return isNaN(+d) ? (fecha + '') : d.toLocaleDateString('es-GT');
  }

  // =========================
  // API PÚBLICA
  // =========================
  window.transferenciaApp = {
    verDetalle,
    enviar,
    recibir,
    cancelar
  };

})();

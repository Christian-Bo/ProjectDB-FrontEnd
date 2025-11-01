/* 
 * compras_pagos.js — Pagos de Compras (ARREGLADO)
 * - Usa URL ABSOLUTA basada en <meta name="api-base"> o window.API_BASE
 * - No depende de rutas relativas (evita 404 en :8082)
 * - Mantiene snake_case en payload para compatibilidad con tu backend actual
 */

(function () {
  // ===== Helpers =====
  const q  = (s, r=document) => r.querySelector(s);
  const qa = (s, r=document) => Array.from(r.querySelectorAll(s));
  const fmtMonto = (v) => Number(v ?? 0).toLocaleString('es-GT',{minimumFractionDigits:2,maximumFractionDigits:2});

  function getApiBase(){
    try{
      if (window.API?.baseUrl) return String(window.API.baseUrl).trim();
      if (window.API_BASE)      return String(window.API_BASE).trim();
      const meta = document.querySelector('meta[name="api-base"]');
      return meta?.getAttribute('content')?.trim() || '';
    }catch(_){ return ''; }
  }
  // ✅ Endpoint ABSOLUTO al backend
  const API_PAGOS = (getApiBase().replace(/\/+$/,'') || '').concat('/api/compras/pagos');

  // ===== Estado de filtros (soporta ?compraId= en URL) =====
  let COMPRA_ID = null;
  const params = new URLSearchParams(location.search);
  if (params.get('compraId')) COMPRA_ID = Number(params.get('compraId'));

  // ===== Referencias =====
  let $tblBody, $filtroTexto, $filtroCompraId, $btnBuscar, $btnNuevo;
  let modalEl, bsModal, $form, $id, $compraId, $formaPago, $monto, $referencia, $btnGuardar;

  // ===== Render de tabla =====
  function renderTabla(rows) {
    $tblBody.innerHTML = '';
    if (!rows.length) {
      $tblBody.innerHTML = `<tr><td colspan="6" class="text-center text-muted py-3">Sin registros</td></tr>`;
      return;
    }
    for (const r of rows) {
      // Soporte a camelCase/snake_case del back
      const id         = r.id;
      const compraId   = r.compra_id ?? r.compraId ?? '-';
      const formaPago  = (r.forma_pago ?? r.formaPago ?? '').toString().toUpperCase();
      const monto      = r.monto ?? r.monto_total ?? 0;
      const referencia = r.referencia ?? '';

      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td class="text-muted">#${id}</td>
        <td>${compraId}</td>
        <td><span class="badge bg-primary-subtle text-primary badge-forma">${formaPago}</span></td>
        <td class="text-end">Q ${fmtMonto(monto)}</td>
        <td>${referencia}</td>
        <td class="text-end">
          <button class="btn btn-sm btn-outline-secondary me-2 btn-edit" data-id="${id}">
            <i class="bi bi-pencil"></i> Editar
          </button>
          <button class="btn btn-sm btn-outline-danger btn-del" data-id="${id}">
            <i class="bi bi-trash"></i> Eliminar
          </button>
        </td>`;
      $tblBody.appendChild(tr);
    }
    // Bind acciones
    qa('.btn-edit').forEach(b => b.addEventListener('click', onEditarClick));
    qa('.btn-del').forEach(b => b.addEventListener('click', onEliminarClick));
  }

  // ===== HTTP helpers (usan buildHeaders/handleResponse de common.js si existen) =====
  async function httpGet(urlObj){
    const res = await fetch(urlObj.toString(), { headers: (typeof buildHeaders==='function' ? buildHeaders() : {'Accept':'application/json'}) });
    return (typeof handleResponse==='function') ? handleResponse(res) : res.json();
  }
  async function httpSend(method, url, json){
    const headers = (typeof buildHeaders==='function' ? buildHeaders({'Content-Type':'application/json'}) : {'Accept':'application/json','Content-Type':'application/json'});
    const res = await fetch(url, { method, headers, body: json ? JSON.stringify(json) : null });
    return (typeof handleResponse==='function') ? handleResponse(res) : res.json();
  }

  // ===== Lógica de datos =====
  async function cargar() {
    const texto = $filtroTexto.value.trim() || null;
    const compraId = ($filtroCompraId.value || COMPRA_ID || '').toString().trim() || null;

    const url = new URL(API_PAGOS);
    if (compraId) url.searchParams.set('compraId', compraId);
    if (texto)    url.searchParams.set('texto', texto);

    try {
      const data = await httpGet(url);
      renderTabla(Array.isArray(data) ? data : []);
    } catch (e) {
      (window.API?.toast || window.ntToast || console.error)(`Error al listar pagos: ${e.message}`, 'danger');
      renderTabla([]);
    }
  }

  function abrirCrear() {
    $form.reset();
    $id.value = '';
    $compraId.value = COMPRA_ID || $filtroCompraId.value || '';
    $btnGuardar.dataset.mode = 'create';
    q('#modalPagoLabel').textContent = 'Nuevo pago de compra';
    bsModal.show();
  }

  function abrirEditar(row) {
    $form.reset();
    $id.value         = row.id;
    $compraId.value   = row.compra_id ?? row.compraId ?? '';
    $formaPago.value  = (row.forma_pago ?? row.formaPago ?? '').toString().toLowerCase();
    $monto.value      = row.monto ?? row.monto_total ?? 0;
    $referencia.value = row.referencia || '';
    $btnGuardar.dataset.mode = 'edit';
    q('#modalPagoLabel').textContent = `Editar pago #${row.id}`;
    bsModal.show();
  }

  function rowDesdeTr(tr, id) {
    return {
      id,
      compra_id: Number(tr.children[1].textContent.trim()) || null,
      forma_pago: tr.querySelector('.badge-forma').textContent.trim().toLowerCase(),
      monto: Number((tr.children[3].textContent || '').replace(/[^\d.]/g,'')),
      referencia: tr.children[4].textContent.trim() || null
    };
  }

  async function onEditarClick(ev) {
    const id = Number(ev.currentTarget.dataset.id);
    const tr = ev.currentTarget.closest('tr');
    abrirEditar(rowDesdeTr(tr, id));
  }

  async function onEliminarClick(ev) {
    const id = Number(ev.currentTarget.dataset.id);
    if (!confirm(`¿Eliminar el pago #${id}?`)) return;
    try {
      await httpSend('DELETE', `${API_PAGOS}/${id}`);
      (window.API?.toast || window.ntToast || console.log)('Pago eliminado.', 'success');
      cargar();
    } catch (e) {
      (window.API?.toast || window.ntToast || console.error)(`Error eliminando: ${e.message}`, 'danger');
    }
  }

  async function onSubmit(ev) {
    ev.preventDefault();
    const mode = $btnGuardar.dataset.mode;

    // 🚩 Payload en snake_case (coincide con tu JS/JSP actual)
    const payloadCreate = {
      compra_id:  Number($compraId.value),
      forma_pago: $formaPago.value.trim(),
      monto:      Number($monto.value),
      referencia: $referencia.value.trim() || null
    };
    const payloadEdit = {
      forma_pago: $formaPago.value.trim(),
      monto:      Number($monto.value),
      referencia: $referencia.value.trim() || null
    };

    try {
      if (mode === 'create') {
        await httpSend('POST', API_PAGOS, payloadCreate);
        (window.API?.toast || window.ntToast || console.log)('Pago creado.', 'success');
      } else {
        const id = Number($id.value);
        await httpSend('PUT', `${API_PAGOS}/${id}`, payloadEdit);
        (window.API?.toast || window.ntToast || console.log)('Pago actualizado.', 'success');
      }
      bsModal.hide();
      cargar();
    } catch (e) {
      (window.API?.toast || window.ntToast || console.error)(`Error guardando: ${e.message}`, 'danger');
    }
  }

  // ===== Init =====
  window.addEventListener('DOMContentLoaded', () => {
    console.log('[compras_pagos] API_PAGOS =', API_PAGOS);

    // Refs
    $tblBody       = q('#pagos-tbody');
    $filtroTexto   = q('#filtro-texto');
    $filtroCompraId= q('#filtro-compra-id');
    $btnBuscar     = q('#btn-buscar');
    $btnNuevo      = q('#btn-nuevo');

    modalEl    = q('#modalPago');
    bsModal    = new bootstrap.Modal(modalEl);
    $form      = q('#form-pago');
    $id        = q('#pago-id');
    $compraId  = q('#compra_id');
    $formaPago = q('#forma_pago');
    $monto     = q('#monto');
    $referencia= q('#referencia');
    $btnGuardar= q('#btn-guardar');

    // Eventos
    $btnBuscar.addEventListener('click', cargar);
    $btnNuevo.addEventListener('click', abrirCrear);
    $form.addEventListener('submit', onSubmit);

    if (COMPRA_ID) $filtroCompraId.value = String(COMPRA_ID);

    // Carga inicial
    cargar();
  });
})();
